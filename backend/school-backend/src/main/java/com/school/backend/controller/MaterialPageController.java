package com.school.backend.controller;

import com.school.backend.entity.MaterialFile;
import com.school.backend.security.SchoolAccessPolicy;
import com.school.backend.service.MaterialPageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Duration;

@Slf4j
@RestController
@RequestMapping("/api/materials/files/{fileId}")
@RequiredArgsConstructor
public class MaterialPageController {

    private final SchoolAccessPolicy accessPolicy;
    private final MaterialPageService pageService;

    /**
     * Xác thực an toàn thư mục lưu trữ và chống tấn công Path Traversal:
     * - Tên tệp được lấy 100% từ CSDL (MaterialFile.fileName), tuyệt đối không nhận từ tham số client.
     * - Chuẩn hóa và kiểm tra tiền tố thư mục gốc uploads/materials.
     */
    private Path resolveSafePhysicalPath(MaterialFile mf) {
        Path baseDir = Paths.get("uploads/materials").toAbsolutePath().normalize();
        Path resolvedPath = baseDir.resolve(mf.getFileName()).normalize();

        if (!resolvedPath.startsWith(baseDir)) {
            log.error("Cảnh báo bảo mật: Phát hiện Path Traversal cố gắng truy cập: {}", resolvedPath);
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Phát hiện hành vi Path Traversal bất hợp pháp.");
        }

        if (!Files.exists(resolvedPath) || !Files.isReadable(resolvedPath)) {
            log.warn("Tệp sách không tồn tại trên đĩa: {}", resolvedPath);
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy tệp sách PDF trên máy chủ.");
        }

        return resolvedPath;
    }

    /**
     * Lấy thông tin tổng số trang của cuốn sách
     */
    @GetMapping("/pages")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('STUDENT') or hasAuthority('PARENT')")
    public PageInfo getPageInfo(@PathVariable Long fileId, Authentication auth) throws IOException {
        MaterialFile mf = accessPolicy.verifyCanDownloadMaterialFile(auth, fileId);
        Path pdfPath = resolveSafePhysicalPath(mf);
        int total = pageService.pageCount(pdfPath);
        return new PageInfo(total);
    }

    /**
     * Render và truyền tải ảnh của một trang cụ thể (JPEG Streaming)
     *
     * @param fileId ID của MaterialFile
     * @param page   Số trang cần xem (1-indexed)
     * @param dpi    Chỉ số DPI mong muốn (mặc định 110, tối đa 150)
     */
    @GetMapping("/pages/{page}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('STUDENT') or hasAuthority('PARENT')")
    public ResponseEntity<byte[]> getPage(
            @PathVariable Long fileId,
            @PathVariable int page,
            @RequestParam(defaultValue = "110") int dpi,
            Authentication auth) throws IOException {

        MaterialFile mf = accessPolicy.verifyCanDownloadMaterialFile(auth, fileId);
        Path pdfPath = resolveSafePhysicalPath(mf);
        byte[] jpg = pageService.renderPage(pdfPath, page, dpi, mf.getId(), mf.getVersion());

        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_JPEG)
                .cacheControl(CacheControl.maxAge(Duration.ofMinutes(15)).cachePrivate())
                .header("X-Content-Type-Options", "nosniff")
                .eTag("\"" + mf.getId() + "-" + mf.getVersion() + "-" + page + "-" + dpi + "\"")
                .body(jpg);
    }

    public record PageInfo(int totalPages) {}
}
