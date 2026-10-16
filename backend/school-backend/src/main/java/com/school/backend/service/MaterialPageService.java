package com.school.backend.service;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import lombok.extern.slf4j.Slf4j;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.ImageType;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;

@Slf4j
@Service
public class MaterialPageService {

    private static final int MAX_DPI = 150;
    private static final int DEFAULT_DPI = 110;

    /**
     * Caffeine In-Memory Cache:
     * - Lưu tối đa 300 trang ảnh gần nhất (~30MB RAM)
     * - Tự động dọn dẹp sau 2 giờ không có lượt đọc
     * - Tránh việc render lại PDF gây nghẽn CPU máy chủ khi học sinh lật trang liên tục
     */
    private final Cache<String, byte[]> pageCache = Caffeine.newBuilder()
            .maximumSize(300)
            .expireAfterAccess(Duration.ofHours(2))
            .build();

    /**
     * Đếm tổng số trang của tệp PDF
     */
    public int pageCount(Path pdf) throws IOException {
        if (!Files.exists(pdf)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Tệp PDF không tồn tại trên hệ thống");
        }
        try (PDDocument doc = Loader.loadPDF(pdf.toFile())) {
            return doc.getNumberOfPages();
        }
    }

    /**
     * Render trang PDF sang ảnh JPEG
     *
     * @param pdf         Đường dẫn tệp PDF vật lý an toàn
     * @param pageNumber  Số trang (bắt đầu từ 1)
     * @param dpi         Độ phân giải mong muốn (khống chế 72 - 150)
     * @param fileId      ID của MaterialFile phục vụ tạo cache key
     * @param version     Phiên bản của MaterialFile
     * @return Mảng byte chứa ảnh JPEG
     */
    public byte[] renderPage(Path pdf, int pageNumber, int dpi, Long fileId, int version) throws IOException {
        if (!Files.exists(pdf)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Tệp PDF không tồn tại trên hệ thống");
        }

        int clampedDpi = Math.min(Math.max(dpi, 72), MAX_DPI);
        String cacheKey = (fileId != null ? fileId : "temp") + "_v" + version + "_p" + pageNumber + "_dpi" + clampedDpi;

        byte[] cached = pageCache.getIfPresent(cacheKey);
        if (cached != null) {
            log.debug("Cache hit for page key: {}", cacheKey);
            return cached;
        }

        try (PDDocument doc = Loader.loadPDF(pdf.toFile())) {
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
            log.debug("Rendered and cached page key: {} ({} bytes)", cacheKey, bytes.length);
            return bytes;
        }
    }
}
