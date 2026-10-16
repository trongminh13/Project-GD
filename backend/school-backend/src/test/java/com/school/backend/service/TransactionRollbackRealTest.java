package com.school.backend.service;

import com.school.backend.entity.*;
import com.school.backend.enums.Role;
import com.school.backend.payload.RazorpayVerifyRequest;
import com.school.backend.payload.request.BulkAttendanceRequest;
import com.school.backend.repository.*;
import com.school.backend.security.jwt.JwtUtils;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Non-Transactional Integration Test:
 * Tuyệt đối KHÔNG gắn @Transactional trên test class hoặc test methods
 * để tránh bẫy tự rollback của Spring Test Context, chứng thực dữ liệu thực sự
 * được commit khi hợp lệ và được hoàn tác sạch sẽ khi vi phạm ràng buộc.
 */
@SpringBootTest
@AutoConfigureMockMvc
public class TransactionRollbackRealTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private ParentRepository parentRepository;

    @Autowired
    private SchoolClassRepository schoolClassRepository;

    @Autowired
    private FeePaymentRepository feePaymentRepository;

    @Autowired
    private FeeService feeService;

    @Autowired
    private AttendanceService attendanceService;

    private String adminToken;

    @BeforeEach
    public void setup() {
        cleanTestData();

        // Tạo tài khoản Admin cho test nếu chưa có
        User adminUser = userRepository.findByUsername("TEST_RB_ADMIN").orElseGet(() -> {
            User u = new User();
            u.setUsername("TEST_RB_ADMIN");
            u.setPassword(passwordEncoder.encode("admin123"));
            u.setRole(Role.ADMIN);
            return userRepository.save(u);
        });

        adminToken = jwtUtils.generateTokenFromUsername("TEST_RB_ADMIN");
    }

    @AfterEach
    public void tearDown() {
        cleanTestData();
    }

    private void cleanTestData() {
        // Dọn dẹp bản ghi kiểm thử theo tiền tố TEST_RB_
        List<FeePayment> testPayments = feePaymentRepository.findAll().stream()
                .filter(p -> p.getTransactionId() != null && p.getTransactionId().startsWith("TEST_RB_"))
                .toList();
        feePaymentRepository.deleteAll(testPayments);
        feePaymentRepository.flush();

        List<Student> testStudents = studentRepository.findAll().stream()
                .filter(s -> s.getAdmissionNumber() != null && s.getAdmissionNumber().startsWith("TEST_RB_"))
                .toList();
        studentRepository.deleteAll(testStudents);

        List<Parent> testParents = parentRepository.findAll().stream()
                .filter(p -> p.getPhone() != null && p.getPhone().startsWith("999999"))
                .toList();
        parentRepository.deleteAll(testParents);

        List<User> testUsers = userRepository.findAll().stream()
                .filter(u -> u.getUsername().startsWith("TEST_RB_") || u.getUsername().startsWith("999999"))
                .toList();
        userRepository.deleteAll(testUsers);
    }

    @Test
    @DisplayName("TC-RB-01: Pre-validation phát hiện toàn bộ lỗi trong file Excel và hoàn tác 100% CSDL")
    public void testBulkImport_PreValidation_ReportsAllErrors_AndRollsBack() throws Exception {
        // 1. Tạo file Excel giả lập có 2 dòng lỗi:
        // Dòng 1: Tên học sinh rỗng
        // Dòng 2: Hợp lệ
        // Dòng 3: Trùng lặp admissionNumber với dòng 2 trong nội bộ file
        byte[] excelBytes;
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("Class 10A");
            Row header = sheet.createRow(0);
            header.createCell(0).setCellValue("Name");
            header.createCell(1).setCellValue("Adm No");
            header.createCell(2).setCellValue("Roll No");
            header.createCell(3).setCellValue("Phone");

            // Row 1 (Index 1): Missing Name
            Row r1 = sheet.createRow(1);
            r1.createCell(0).setCellValue("");
            r1.createCell(1).setCellValue("TEST_RB_ADM_001");
            r1.createCell(2).setCellValue("1");
            r1.createCell(3).setCellValue("9999990001");

            // Row 2 (Index 2): Valid
            Row r2 = sheet.createRow(2);
            r2.createCell(0).setCellValue("Student Two");
            r2.createCell(1).setCellValue("TEST_RB_ADM_002");
            r2.createCell(2).setCellValue("2");
            r2.createCell(3).setCellValue("9999990002");

            // Row 3 (Index 3): Duplicate Adm No with Row 2
            Row r3 = sheet.createRow(3);
            r3.createCell(0).setCellValue("Student Three");
            r3.createCell(1).setCellValue("TEST_RB_ADM_002");
            r3.createCell(2).setCellValue("3");
            r3.createCell(3).setCellValue("9999990003");

            workbook.write(out);
            excelBytes = out.toByteArray();
        }

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "invalid_students.xlsx",
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                excelBytes
        );

        // 2. Gọi API upload
        mockMvc.perform(multipart("/api/upload/students")
                        .file(file)
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success", is(false)))
                .andExpect(jsonPath("$.errors", hasSize(2)))
                .andExpect(jsonPath("$.errors[0].row", is(2))) // Row 2 in Excel (index 1)
                .andExpect(jsonPath("$.errors[0].field", is("name")))
                .andExpect(jsonPath("$.errors[1].row", is(4))) // Row 4 in Excel (index 3)
                .andExpect(jsonPath("$.errors[1].field", is("admissionNumber")))
                .andExpect(jsonPath("$.errors[1].message", containsString("trùng lặp")));

        // 3. Khẳng định CSDL thật hoàn toàn KHÔNG có bất kỳ học sinh nào được ghi nhận
        assertTrue(studentRepository.findByAdmissionNumber("TEST_RB_ADM_001").isEmpty(),
                "Học sinh dòng 1 không được phép xuất hiện trong DB");
        assertTrue(studentRepository.findByAdmissionNumber("TEST_RB_ADM_002").isEmpty(),
                "Học sinh dòng 2 không được phép xuất hiện trong DB khi batch bị hủy");
    }

    @Test
    @DisplayName("TC-RB-02: Happy Path - File Excel hợp lệ được lưu thành công vào CSDL thực")
    public void testBulkImport_HappyPath_DataCommitted() throws Exception {
        byte[] excelBytes;
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("Class 10B");
            Row header = sheet.createRow(0);
            header.createCell(0).setCellValue("Name");
            header.createCell(1).setCellValue("Adm No");
            header.createCell(2).setCellValue("Roll No");
            header.createCell(3).setCellValue("Phone");

            Row r1 = sheet.createRow(1);
            r1.createCell(0).setCellValue("Valid Student A");
            r1.createCell(1).setCellValue("TEST_RB_ADM_101");
            r1.createCell(2).setCellValue("101");
            r1.createCell(3).setCellValue("9999990101");

            Row r2 = sheet.createRow(2);
            r2.createCell(0).setCellValue("Valid Student B");
            r2.createCell(1).setCellValue("TEST_RB_ADM_102");
            r2.createCell(2).setCellValue("102");
            r2.createCell(3).setCellValue("9999990102");

            workbook.write(out);
            excelBytes = out.toByteArray();
        }

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "valid_students.xlsx",
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                excelBytes
        );

        mockMvc.perform(multipart("/api/upload/students")
                        .file(file)
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message", containsString("Imported 2 students")));

        // Khẳng định dữ liệu đã thực sự được commit vào PostgreSQL thật
        assertTrue(studentRepository.findByAdmissionNumber("TEST_RB_ADM_101").isPresent(),
                "Học sinh 101 phải tồn tại trong CSDL thực");
        assertTrue(studentRepository.findByAdmissionNumber("TEST_RB_ADM_102").isPresent(),
                "Học sinh 102 phải tồn tại trong CSDL thực");
    }

    @Test
    @DisplayName("TC-RB-03: Điểm danh với định dạng ngày sai văng ngoại lệ rõ ràng, không nuốt lỗi")
    public void testAttendance_InvalidDateFormat_ThrowsException() {
        BulkAttendanceRequest req = new BulkAttendanceRequest();
        req.setClassName("Class 10A");
        req.setDate("2026-99-99"); // Ngày không hợp lệ
        BulkAttendanceRequest.Record rec = new BulkAttendanceRequest.Record();
        rec.setStudentId(99999L);
        rec.setStatus("PRESENT");
        req.setRecords(List.of(rec));

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () ->
                attendanceService.saveBulkAttendance(req, "TEST_RB_ADMIN", false));

        assertTrue(ex.getMessage().contains("Định dạng ngày điểm danh không hợp lệ"),
                "Ngoại lệ phải thông báo rõ định dạng ngày sai thay vì nuốt lỗi");
    }

    @Test
    @DisplayName("TC-RB-04: FeeService Idempotency - Không cập nhật lại khi mã thanh toán đã được xử lý PAID")
    public void testFeeService_Idempotency_AlreadyPaid() throws Exception {
        String paymentId = "TEST_RB_PAY_ID_" + System.currentTimeMillis();
        // Tạo trước một bản ghi FeePayment với trạng thái PAID
        FeePayment existing = new FeePayment();
        existing.setAmountPaid(BigDecimal.valueOf(500.00));
        existing.setStatus("PAID");
        existing.setTransactionId(paymentId);
        Student student = studentRepository.findAll().stream().findFirst().orElseGet(() -> {
            Student s = new Student();
            s.setName("Test Student");
            s.setAdmissionNumber("TEST_RB_STU_888");
            return studentRepository.save(s);
        });
        existing.setStudent(student);
        existing = feePaymentRepository.saveAndFlush(existing);

        RazorpayVerifyRequest req = new RazorpayVerifyRequest();
        req.setRazorpayOrderId("TEST_RB_ORDER_888");
        req.setRazorpayPaymentId(paymentId);
        req.setRazorpaySignature("any_signature");

        FeePayment result = feeService.verifyRazorpayPayment(req);

        assertNotNull(result);
        assertEquals("PAID", result.getStatus());
        assertEquals(paymentId, result.getTransactionId());
        assertEquals(existing.getId(), result.getId(), "Phải trả về đúng bản ghi đã tồn tại");
        assertEquals(existing.getPaymentDate(), result.getPaymentDate(),
                "Ngày thanh toán gốc phải được giữ nguyên, không bị ghi đè");
    }
}
