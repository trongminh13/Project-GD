package com.school.backend.service;

import com.school.backend.entity.MaterialFile;
import com.school.backend.repository.MaterialFileRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.io.RandomAccessReadBufferedFile;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.ImageType;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Semaphore;

@Slf4j
@Service
@RequiredArgsConstructor
public class PdfPreRenderJob {

    private static final int RENDER_DPI   = 120; // Độ phân giải tối ưu cho màn hình di động
    private static final int MAX_FILE_MB  = 200; // Giới hạn kích thước file an toàn
    private static final int MAX_PAGES    = 400; // Giới hạn số trang xử lý
    private static final int JPEG_QUALITY = 80;  // 80% chất lượng cân bằng dung lượng và độ sắc nét

    private final MaterialFileRepository materialFileRepository;

    @Qualifier("pdfRenderSemaphore")
    private final Semaphore pdfRenderSemaphore;

    /**
     * Tự động quét và kích hoạt render cho các tài liệu chưa được render khi hệ thống khởi động.
     */
    @EventListener(ApplicationReadyEvent.class)
    public void backfillUnrenderedMaterials() {
        log.info("[PreRender] Bắt đầu quét backfill tài liệu chưa hoàn thành pre-render...");
        List<MaterialFile> unrendered = materialFileRepository.findByRenderedAtIsNull();
        for (MaterialFile mf : unrendered) {
            if (mf.getMaterial() != null && "PUBLISHED".equals(mf.getMaterial().getStatus())) {
                log.info("[PreRender-Backfill] Kích hoạt render nền cho fileId={}", mf.getId());
                preRenderAllPages(mf.getId());
            }
        }
    }

    /**
     * Render toàn bộ các trang của tài liệu bất đồng bộ.
     */
    @Async("pdfRenderExecutor")
    public CompletableFuture<Void> preRenderAllPages(Long materialFileId) {
        MaterialFile mf = materialFileRepository.findById(materialFileId).orElse(null);
        if (mf == null || mf.getRenderedAt() != null) {
            return CompletableFuture.completedFuture(null);
        }

        Path baseDir   = Paths.get("uploads/materials").toAbsolutePath().normalize();
        Path pdfPath   = baseDir.resolve(mf.getFileName()).normalize();
        Path outputDir = baseDir.resolve("pages/" + materialFileId);

        if (!Files.exists(pdfPath)) {
            log.warn("[PreRender] Tệp PDF không tồn tại trên đĩa: {}", pdfPath);
            return CompletableFuture.completedFuture(null);
        }

        try {
            long fileMb = Files.size(pdfPath) / (1024 * 1024);
            if (fileMb > MAX_FILE_MB) {
                log.warn("[PreRender] File {} dung lượng {}MB vượt ngưỡng cho phép {}MB", materialFileId, fileMb, MAX_FILE_MB);
                return CompletableFuture.completedFuture(null);
            }
            Files.createDirectories(outputDir);

            // PDFBox 3.x: Sử dụng RandomAccessReadBufferedFile nạp buffer từ đĩa
            try (RandomAccessReadBufferedFile source = new RandomAccessReadBufferedFile(pdfPath.toFile());
                 PDDocument doc = Loader.loadPDF(source)) {

                int totalPages = doc.getNumberOfPages();
                if (totalPages > MAX_PAGES) {
                    log.warn("[PreRender] File {} có {} trang vượt giới hạn {} trang", materialFileId, totalPages, MAX_PAGES);
                    return CompletableFuture.completedFuture(null);
                }

                PDFRenderer renderer = new PDFRenderer(doc);
                int renderedSuccessCount = 0;
                for (int i = 0; i < totalPages; i++) {
                    Path imgPath = outputDir.resolve("p" + (i + 1) + ".jpg");
                    if (Files.exists(imgPath)) {
                        renderedSuccessCount++;
                        continue; // Bỏ qua nếu đã render từ trước
                    }

                    try {
                        pdfRenderSemaphore.acquire();
                        try {
                            BufferedImage img = renderer.renderImageWithDPI(i, RENDER_DPI, ImageType.RGB);
                            saveJpeg(img, imgPath.toFile(), JPEG_QUALITY);
                            renderedSuccessCount++;
                        } finally {
                            pdfRenderSemaphore.release();
                        }
                    } catch (Exception pageEx) {
                        log.warn("[PreRender] Bỏ qua trang {} của fileId={} do lỗi render: {}", (i + 1), materialFileId, pageEx.getMessage());
                    }
                }

                if (renderedSuccessCount > 0) {
                    mf.setRenderedAt(LocalDateTime.now());
                    materialFileRepository.save(mf);
                    log.info("[PreRender] Hoàn thành pre-render {}/{} trang cho fileId={}", renderedSuccessCount, totalPages, materialFileId);
                }
            }

        } catch (Exception e) {
            log.error("[PreRender] Lỗi trong quá trình pre-render fileId={}: {}", materialFileId, e.getMessage(), e);
        }

        return CompletableFuture.completedFuture(null);
    }

    private void saveJpeg(BufferedImage img, File dest, int quality) throws IOException {
        Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName("jpeg");
        if (!writers.hasNext()) {
            throw new IllegalStateException("Không tìm thấy JPEG ImageWriter trong JVM");
        }
        ImageWriter writer = writers.next();
        ImageWriteParam param = writer.getDefaultWriteParam();
        param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
        param.setCompressionQuality(quality / 100f);

        try (ImageOutputStream ios = ImageIO.createImageOutputStream(dest)) {
            writer.setOutput(ios);
            writer.write(null, new IIOImage(img, null, null), param);
        } finally {
            writer.dispose();
        }
    }
}
