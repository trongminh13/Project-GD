package com.school.backend.service;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.io.RandomAccessReadBufferedFile;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.ImageType;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Duration;
import java.util.concurrent.Semaphore;

@Slf4j
@Service
@RequiredArgsConstructor
public class MaterialPageService {

    private static final int MAX_DPI = 150;
    private static final int DEFAULT_DPI = 110;
    private static final Path PAGES_BASE = Paths.get("uploads/materials/pages").toAbsolutePath().normalize();

    @Qualifier("pdfRenderSemaphore")
    private final Semaphore pdfRenderSemaphore;

    /**
     * Caffeine In-Memory Cache (L1 Cache):
     * - Lưu tối đa 300 trang ảnh gần nhất (~30MB RAM)
     * - Tự động dọn dẹp sau 2 giờ không có lượt đọc
     * - Giúp truy xuất tức thì (<1ms) các trang đang được đọc nhiều
     */
    private final Cache<String, byte[]> pageCache = Caffeine.newBuilder()
            .maximumSize(300)
            .expireAfterAccess(Duration.ofHours(2))
            .build();

    /**
     * Đếm tổng số trang của tệp PDF (dùng buffer đọc từ đĩa, tránh OOM)
     */
    public int pageCount(Path pdf) throws IOException {
        if (!Files.exists(pdf)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Tệp PDF không tồn tại trên hệ thống");
        }
        try (RandomAccessReadBufferedFile source = new RandomAccessReadBufferedFile(pdf.toFile());
             PDDocument doc = Loader.loadPDF(source)) {
            return doc.getNumberOfPages();
        }
    }

    /**
     * Phân phối trang PDF sang ảnh JPEG với kiến trúc 3 lớp Cache:
     * - Lớp 1: Caffeine RAM Cache (siêu tốc)
     * - Lớp 2: Disk Image Cache (đọc ảnh pre-rendered sẵn từ đĩa)
     * - Lớp 3: Fallback On-the-fly Render có bảo vệ bởi Semaphore toàn cục
     *
     * @param pdf         Đường dẫn tệp PDF vật lý an toàn
     * @param pageNumber  Số trang (bắt đầu từ 1)
     * @param dpi         Độ phân giải mong muốn (khống chế 72 - 150)
     * @param fileId      ID của MaterialFile phục vụ tạo cache key và tìm ảnh đĩa
     * @param version     Phiên bản của MaterialFile
     * @return Mảng byte chứa ảnh JPEG
     */
    public byte[] renderPage(Path pdf, int pageNumber, int dpi, Long fileId, int version) throws IOException {
        if (!Files.exists(pdf)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Tệp PDF không tồn tại trên hệ thống");
        }

        int clampedDpi = Math.min(Math.max(dpi, 72), MAX_DPI);
        String cacheKey = (fileId != null ? fileId : "temp") + "_v" + version + "_p" + pageNumber + "_dpi" + clampedDpi;

        // [Lớp 1] Caffeine RAM cache
        byte[] cached = pageCache.getIfPresent(cacheKey);
        if (cached != null) {
            log.debug("[Cache L1 Hit] key: {}", cacheKey);
            return cached;
        }

        // [Lớp 2] Disk cache (ảnh pre-rendered)
        if (fileId != null) {
            Path diskImg = PAGES_BASE.resolve(fileId + "/p" + pageNumber + ".jpg");
            if (Files.exists(diskImg)) {
                byte[] bytes = Files.readAllBytes(diskImg);
                pageCache.put(cacheKey, bytes); // Warm-up RAM L1
                log.debug("[Cache L2 Disk Hit] key: {}", cacheKey);
                return bytes;
            }
        }

        // [Lớp 3] On-the-fly fallback render (bảo vệ bởi Semaphore chung)
        try {
            pdfRenderSemaphore.acquire();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Hệ thống đang bận render, vui lòng thử lại.");
        }

        try (RandomAccessReadBufferedFile source = new RandomAccessReadBufferedFile(pdf.toFile());
             PDDocument doc = Loader.loadPDF(source)) {

            int index = pageNumber - 1;
            if (index < 0 || index >= doc.getNumberOfPages()) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Trang không tồn tại: " + pageNumber);
            }

            BufferedImage img = new PDFRenderer(doc)
                    .renderImageWithDPI(index, clampedDpi, ImageType.RGB);

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            ImageIO.write(img, "jpg", out);
            byte[] bytes = out.toByteArray();

            pageCache.put(cacheKey, bytes);
            log.debug("[Cache L3 Rendered Fallback] key: {} ({} bytes)", cacheKey, bytes.length);
            return bytes;
        } finally {
            pdfRenderSemaphore.release();
        }
    }
}
