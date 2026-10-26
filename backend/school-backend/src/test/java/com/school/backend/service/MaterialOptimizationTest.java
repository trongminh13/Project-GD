package com.school.backend.service;

import com.school.backend.entity.MaterialFile;
import com.school.backend.repository.MaterialFileRepository;
import com.school.backend.repository.MaterialRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class MaterialOptimizationTest {

    @Autowired
    private MaterialService materialService;

    @Autowired
    private MaterialPageService materialPageService;

    @Autowired
    private MaterialRepository materialRepository;

    @Autowired
    private MaterialFileRepository materialFileRepository;

    @Test
    @DisplayName("TC-OPT-01: ReBAC phân quyền sách chính xác cho từng khối lớp")
    public void testReBACIsolationByClass() {
        // student01 -> Lớp 1A (Tiểu học)
        List<Map<String, Object>> books1 = materialService.getMaterialsForStudent("student01");
        assertFalse(books1.isEmpty(), "student01 phải có sách");
        for (Map<String, Object> b : books1) {
            String title = (String) b.get("title");
            assertTrue(title.contains("1") && !title.contains("10"),
                    "student01 chỉ được thấy sách lớp 1, phát hiện: " + title);
        }

        // student02 -> Lớp 6A (THCS)
        List<Map<String, Object>> books6 = materialService.getMaterialsForStudent("student02");
        assertFalse(books6.isEmpty(), "student02 phải có sách");
        for (Map<String, Object> b : books6) {
            String title = (String) b.get("title");
            assertTrue(title.contains("6"),
                    "student02 chỉ được thấy sách lớp 6, phát hiện: " + title);
        }

        // student03 -> Lớp 10A (THPT)
        List<Map<String, Object>> books10 = materialService.getMaterialsForStudent("student03");
        assertFalse(books10.isEmpty(), "student03 phải có sách");
        for (Map<String, Object> b : books10) {
            String title = (String) b.get("title");
            assertTrue(title.contains("10"),
                    "student03 chỉ được thấy sách lớp 10, phát hiện: " + title);
        }
    }

    @Test
    @DisplayName("TC-OPT-02: Kiểm tra tối ưu truy vấn existsByTitle trong MaterialRepository")
    public void testExistsByTitle() {
        assertTrue(materialRepository.existsByTitle("Sách giáo khoa Toán 1 - Tập 1"));
        assertTrue(materialRepository.existsByTitle("Sách giáo khoa Tiếng Việt 1 - Tập 1"));
        assertTrue(materialRepository.existsByTitle("Sách giáo khoa Ngữ văn 6 - Tập 1"));
        assertTrue(materialRepository.existsByTitle("Sách giáo khoa Toán 6 - Tập 1"));
        assertTrue(materialRepository.existsByTitle("Sách giáo khoa Ngữ văn 10 - Tập 2"));
        assertTrue(materialRepository.existsByTitle("Sách giáo khoa Toán 10 - Tập 2"));
        assertFalse(materialRepository.existsByTitle("Sách Không Tồn Tại 999"));
    }

    @Test
    @DisplayName("TC-OPT-03: Lớp 2 Disk Cache - Ảnh JPEG được phân phối trực tiếp từ đĩa với tốc độ cao")
    public void testDiskCacheSpeed() throws IOException {
        List<MaterialFile> files = materialFileRepository.findAll();
        assertFalse(files.isEmpty(), "Phải có MaterialFile trong hệ thống");

        MaterialFile sample = files.get(0);
        Path pdfPath = Paths.get("uploads/materials").resolve(sample.getFileName()).toAbsolutePath().normalize();

        // Kiểm tra ảnh trên đĩa có tồn tại
        Path diskImg = Paths.get("uploads/materials/pages").resolve(sample.getId() + "/p1.jpg").toAbsolutePath().normalize();
        if (Files.exists(diskImg)) {
            long start = System.currentTimeMillis();
            byte[] pageBytes = materialPageService.renderPage(pdfPath, 1, 120, sample.getId(), sample.getVersion());
            long duration = System.currentTimeMillis() - start;

            assertNotNull(pageBytes);
            assertTrue(pageBytes.length > 0);
            assertTrue(duration < 50, "Thời gian đọc từ Disk Cache L2 phải dưới 50ms, thực tế: " + duration + "ms");
        }
    }
}
