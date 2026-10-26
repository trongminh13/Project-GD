package com.school.backend.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.school.backend.entity.SchoolClass;
import com.school.backend.entity.Student;
import com.school.backend.entity.User;
import com.school.backend.enums.Role;
import com.school.backend.payload.request.ChangePasswordRequest;
import com.school.backend.payload.request.LoginRequest;
import com.school.backend.repository.SchoolClassRepository;
import com.school.backend.repository.StudentRepository;
import com.school.backend.repository.UserRepository;
import com.school.backend.security.jwt.JwtUtils;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class StudentSecurityMatrixTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private SchoolClassRepository classRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private ObjectMapper objectMapper;

    private User studentUser;
    private Student studentProfile;
    private SchoolClass schoolClass;

    @BeforeEach
    void setUp() {
        cleanUp();

        // Tạo hoặc lấy lớp học mẫu độc lập cho test
        schoolClass = classRepository.findByGradeAndSection("99", "SEC").orElseGet(() -> {
            SchoolClass sc = new SchoolClass();
            sc.setGrade("99");
            sc.setSection("SEC");
            return classRepository.save(sc);
        });

        // Tạo tài khoản User role STUDENT
        studentUser = new User();
        studentUser.setUsername("STU_TEST_001");
        studentUser.setPassword(passwordEncoder.encode("initial123"));
        studentUser.setRole(Role.STUDENT);
        studentUser.setMustChangePassword(true);
        studentUser = userRepository.save(studentUser);

        // Tạo hồ sơ Student gắn với studentUser
        studentProfile = new Student();
        studentProfile.setAdmissionNumber("STU_TEST_001");
        studentProfile.setName("Nguyen Van Test");
        studentProfile.setRollNo("01");
        studentProfile.setSchoolClass(schoolClass);
        studentProfile.setUser(studentUser);
        studentProfile = studentRepository.save(studentProfile);
    }

    @AfterEach
    void tearDown() {
        cleanUp();
    }

    private void cleanUp() {
        studentRepository.findByAdmissionNumber("STU_TEST_001").ifPresent(s -> studentRepository.delete(s));
        userRepository.findByUsername("STU_TEST_001").ifPresent(u -> userRepository.delete(u));
        userRepository.findByUsername("TEACHER_TEST_001").ifPresent(u -> userRepository.delete(u));
        userRepository.findByUsername("PARENT_TEST_001").ifPresent(u -> userRepository.delete(u));
        classRepository.findByGradeAndSection("99", "SEC").ifPresent(classRepository::delete);
        schoolClass = null;
    }

    @Test
    @DisplayName("1. Server Enforcement: Phải đổi mật khẩu nếu must_change_password=true, chặn các API khác")
    void testMustChangePasswordEnforcement() throws Exception {
        String token = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        // 1.1 Gọi /api/student-portal/profile -> Bắt buộc nhận 403 Forbidden kèm mã PASSWORD_CHANGE_REQUIRED
        mockMvc.perform(get("/api/student-portal/profile")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.error").value("PASSWORD_CHANGE_REQUIRED"));

        // 1.2 Gọi /api/auth/change-password -> Được phép truy cập để đổi mật khẩu
        ChangePasswordRequest changeReq = new ChangePasswordRequest();
        changeReq.setOldPassword("initial123");
        changeReq.setNewPassword("NewPassword@2026");

        mockMvc.perform(post("/api/auth/change-password")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(changeReq)))
                .andExpect(status().isOk());

        // 1.3 Gọi lại /api/student-portal/profile -> Giờ đã thành công 200 OK
        mockMvc.perform(get("/api/student-portal/profile")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Nguyen Van Test"))
                .andExpect(jsonPath("$.admissionNumber").value("STU_TEST_001"));
    }

    @Test
    @DisplayName("2. Cross-Role Matrix: STUDENT bị chặn 403 ở 100% các endpoint quản lý")
    void testStudentCannotAccessManagementApis() throws Exception {
        // Cho student đổi mật khẩu để vượt qua MustChangePasswordFilter
        studentUser.setMustChangePassword(false);
        userRepository.save(studentUser);
        String token = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        // Chặn /api/students
        mockMvc.perform(get("/api/students").header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());

        // Chặn /api/students/{id}
        mockMvc.perform(get("/api/students/" + studentProfile.getId()).header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());

        // Chặn /api/teachers
        mockMvc.perform(get("/api/teachers").header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());

        // Chặn /api/fees
        mockMvc.perform(get("/api/fees/statement/1").header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());

        // Chặn /api/profile (Đã được vá trong ProfileController)
        mockMvc.perform(get("/api/profile").header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());

        // Chặn /api/attendance/mark
        mockMvc.perform(post("/api/attendance/mark").header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("3. Chặn Role khác (PARENT, TEACHER) truy cập vào /api/student-portal/**")
    void testOtherRolesCannotAccessStudentPortal() throws Exception {
        // Tạo Teacher
        User teacher = new User();
        teacher.setUsername("TEACHER_TEST_001");
        teacher.setPassword(passwordEncoder.encode("123456"));
        teacher.setRole(Role.TEACHER);
        userRepository.save(teacher);
        String teacherToken = jwtUtils.generateTokenFromUsername(teacher.getUsername());

        mockMvc.perform(get("/api/student-portal/profile").header("Authorization", "Bearer " + teacherToken))
                .andExpect(status().isForbidden());

        // Tạo Parent
        User parent = new User();
        parent.setUsername("PARENT_TEST_001");
        parent.setPassword(passwordEncoder.encode("123456"));
        parent.setRole(Role.PARENT);
        userRepository.save(parent);
        String parentToken = jwtUtils.generateTokenFromUsername(parent.getUsername());

        mockMvc.perform(get("/api/student-portal/profile").header("Authorization", "Bearer " + parentToken))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("4. Phòng thủ Lockout: Khóa sau 5 lần đăng nhập sai, reset khi đúng")
    void testAccountLockoutFlow() throws Exception {
        LoginRequest badLogin = new LoginRequest();
        badLogin.setUsername(studentUser.getUsername());
        badLogin.setPassword("wrongpassword");

        // Nhập sai 4 lần -> 401 Unauthorized
        for (int i = 0; i < 4; i++) {
            mockMvc.perform(post("/api/auth/signin")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(badLogin)))
                    .andExpect(status().isUnauthorized());
        }

        // Lần thứ 5 sai -> 423 Locked
        mockMvc.perform(post("/api/auth/signin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(badLogin)))
                .andExpect(status().isLocked());

        // Lần thứ 6 dù gõ đúng vẫn nhận 423 vì đang trong 15 phút khóa
        LoginRequest correctLogin = new LoginRequest();
        correctLogin.setUsername(studentUser.getUsername());
        correctLogin.setPassword("initial123");

        mockMvc.perform(post("/api/auth/signin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(correctLogin)))
                .andExpect(status().isLocked());
    }

    @Test
    @DisplayName("5. Hết hạn khóa 15 phút: Tự động mở khóa khi đăng nhập đúng mật khẩu")
    void testLockoutExpirationAndAutoUnlock() throws Exception {
        // Giả lập tài khoản đã bị khóa 16 phút trước
        studentUser.setFailedAttempts(5);
        studentUser.setLockTime(java.time.LocalDateTime.now().minusMinutes(16));
        userRepository.save(studentUser);

        LoginRequest correctLogin = new LoginRequest();
        correctLogin.setUsername(studentUser.getUsername());
        correctLogin.setPassword("initial123");

        mockMvc.perform(post("/api/auth/signin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(correctLogin)))
                .andExpect(status().isOk());

        // Kiểm tra trong DB: failed_attempts và lock_time đã được reset
        User refreshed = userRepository.findByUsername(studentUser.getUsername()).orElseThrow();
        org.junit.jupiter.api.Assertions.assertEquals(0, refreshed.getFailedAttempts());
        org.junit.jupiter.api.Assertions.assertNull(refreshed.getLockTime());
    }

    @Test
    @DisplayName("6. Chặn brute-force qua change-password: Đoán sai 5 lần mật khẩu cũ sẽ bị khóa 423")
    void testChangePasswordLockoutProtection() throws Exception {
        String token = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        ChangePasswordRequest badReq = new ChangePasswordRequest();
        badReq.setOldPassword("wrong_old_pwd");
        badReq.setNewPassword("ValidPass@2026");

        // Đoán sai 4 lần -> 400 Bad Request
        for (int i = 0; i < 4; i++) {
            mockMvc.perform(post("/api/auth/change-password")
                            .header("Authorization", "Bearer " + token)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(badReq)))
                    .andExpect(status().isBadRequest());
        }

        // Lần thứ 5 sai -> 423 Locked
        mockMvc.perform(post("/api/auth/change-password")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(badReq)))
                .andExpect(status().isLocked());
    }

    @Test
    @DisplayName("7. STUDENT bị chặn 403 khi gọi /api/test/sms")
    void testStudentCannotAccessDebugSms() throws Exception {
        String token = jwtUtils.generateTokenFromUsername(studentUser.getUsername());

        mockMvc.perform(get("/api/test/sms?phone=0912345678&otp=1234")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
    }
}
