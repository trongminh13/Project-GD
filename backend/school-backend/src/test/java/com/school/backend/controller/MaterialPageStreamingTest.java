package com.school.backend.controller;

import com.school.backend.entity.*;
import com.school.backend.enums.Role;
import com.school.backend.repository.*;
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

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;

import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
public class MaterialPageStreamingTest {

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
    private TeacherRepository teacherRepository;

    @Autowired
    private SchoolClassRepository classRepository;

    @Autowired
    private AcademicYearRepository academicYearRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @Autowired
    private MaterialRepository materialRepository;

    @Autowired
    private MaterialFileRepository materialFileRepository;

    @Autowired
    private MaterialClassRepository materialClassRepository;

    private User userStudentA;
    private User userStudentB;
    private Student studentA;
    private Student studentB;
    private Teacher teacher;
    private SchoolClass classA;
    private SchoolClass classB;
    private AcademicYear academicYear;
    private Subject mathSubject;
    private Material material;
    private MaterialFile materialFile;
    private MaterialClass materialClass;

    private final String TEST_PREFIX = "test_stream_";

    @BeforeEach
    void setUp() throws Exception {
        cleanUp();

        // Đảm bảo thư mục lưu trữ có file PDF mẫu
        Path baseDir = Paths.get("uploads/materials").toAbsolutePath().normalize();
        Files.createDirectories(baseDir);
        Path targetPdf = baseDir.resolve("SGK_Toan_1_Tap_1.pdf");
        if (!Files.exists(targetPdf)) {
            Path rootPdf = Paths.get("../../SGK Toán 1, tập một-mau.pdf").toAbsolutePath().normalize();
            if (Files.exists(rootPdf)) {
                Files.copy(rootPdf, targetPdf);
            }
        }

        // Tạo niên khóa
        academicYear = academicYearRepository.findByIsCurrentTrue().orElseGet(() -> {
            AcademicYear ay = new AcademicYear();
            ay.setName(TEST_PREFIX + "AY");
            ay.setStartDate(LocalDate.of(2026, 9, 1));
            ay.setEndDate(LocalDate.of(2027, 6, 30));
            ay.setIsCurrent(true);
            ay.setStatus("ACTIVE");
            return academicYearRepository.save(ay);
        });

        // Tạo môn học
        mathSubject = subjectRepository.findByName("Toán").orElseGet(() -> {
            Subject s = new Subject();
            s.setName("Toán");
            return subjectRepository.save(s);
        });

        // Tạo giáo viên
        User uTeacher = new User();
        uTeacher.setUsername(TEST_PREFIX + "teacher");
        uTeacher.setPassword(passwordEncoder.encode("secret"));
        uTeacher.setRole(Role.TEACHER);
        uTeacher = userRepository.save(uTeacher);

        teacher = new Teacher();
        teacher.setUser(uTeacher);
        teacher.setName("Cô Thu Hà Test");
        teacher.setEmail(TEST_PREFIX + "teacher@school.edu");
        teacher.setPhone("0988776655");
        teacher = teacherRepository.save(teacher);

        // Tạo 2 lớp học: Lớp A và Lớp B
        classA = new SchoolClass();
        classA.setGrade("1");
        classA.setSection(TEST_PREFIX + "A");
        classA.setHomeroomTeacher(teacher);
        classA = classRepository.save(classA);

        classB = new SchoolClass();
        classB.setGrade("1");
        classB.setSection(TEST_PREFIX + "B");
        classB = classRepository.save(classB);

        // Học sinh A thuộc Lớp A
        userStudentA = new User();
        userStudentA.setUsername(TEST_PREFIX + "studentA");
        userStudentA.setPassword(passwordEncoder.encode("secret"));
        userStudentA.setRole(Role.STUDENT);
        userStudentA = userRepository.save(userStudentA);

        studentA = new Student();
        studentA.setUser(userStudentA);
        studentA.setName("Học sinh A");
        studentA.setAdmissionNumber(TEST_PREFIX + "ADM_A");
        studentA.setRollNo("01");
        studentA.setSchoolClass(classA);
        studentA = studentRepository.save(studentA);

        Enrollment enA = new Enrollment();
        enA.setStudent(studentA);
        enA.setSchoolClass(classA);
        enA.setAcademicYear(academicYear);
        enrollmentRepository.save(enA);

        // Học sinh B thuộc Lớp B
        userStudentB = new User();
        userStudentB.setUsername(TEST_PREFIX + "studentB");
        userStudentB.setPassword(passwordEncoder.encode("secret"));
        userStudentB.setRole(Role.STUDENT);
        userStudentB = userRepository.save(userStudentB);

        studentB = new Student();
        studentB.setUser(userStudentB);
        studentB.setName("Học sinh B");
        studentB.setAdmissionNumber(TEST_PREFIX + "ADM_B");
        studentB.setRollNo("02");
        studentB.setSchoolClass(classB);
        studentB = studentRepository.save(studentB);

        Enrollment enB = new Enrollment();
        enB.setStudent(studentB);
        enB.setSchoolClass(classB);
        enB.setAcademicYear(academicYear);
        enrollmentRepository.save(enB);

        // Tạo học liệu chỉ phân phối cho Lớp A
        material = new Material();
        material.setTitle("SGK Toán 1 Test Stream");
        material.setStatus("PUBLISHED");
        material.setSubject(mathSubject);
        material.setCreatedByTeacher(teacher);
        material = materialRepository.save(material);

        materialFile = new MaterialFile();
        materialFile.setMaterial(material);
        materialFile.setFileName("SGK_Toan_1_Tap_1.pdf");
        materialFile.setFileUrl("uploads/materials/SGK_Toan_1_Tap_1.pdf");
        materialFile.setPageCount(118);
        materialFile.setVersion(1);
        materialFile = materialFileRepository.save(materialFile);

        materialClass = new MaterialClass();
        materialClass.setMaterial(material);
        materialClass.setSchoolClass(classA);
        materialClass = materialClassRepository.save(materialClass);
    }

    @AfterEach
    void tearDown() {
        cleanUp();
    }

    private void cleanUp() {
        materialRepository.findAll().stream()
                .filter(m -> "SGK Toán 1 Test Stream".equals(m.getTitle()))
                .forEach(m -> {
                    materialClassRepository.deleteAll(materialClassRepository.findByMaterialId(m.getId()));
                    materialFileRepository.deleteAll(materialFileRepository.findByMaterialId(m.getId()));
                    materialRepository.delete(m);
                    materialRepository.flush();
                });

        studentRepository.findByAdmissionNumber(TEST_PREFIX + "ADM_A").ifPresent(s -> {
            enrollmentRepository.deleteAll(enrollmentRepository.findByStudentId(s.getId()));
            studentRepository.delete(s);
            studentRepository.flush();
        });

        studentRepository.findByAdmissionNumber(TEST_PREFIX + "ADM_B").ifPresent(s -> {
            enrollmentRepository.deleteAll(enrollmentRepository.findByStudentId(s.getId()));
            studentRepository.delete(s);
            studentRepository.flush();
        });

        classRepository.findAll().stream()
                .filter(c -> (TEST_PREFIX + "A").equals(c.getSection()) || (TEST_PREFIX + "B").equals(c.getSection()))
                .forEach(c -> classRepository.delete(c));

        teacherRepository.findByUserUsername(TEST_PREFIX + "teacher").ifPresent(t -> {
            teacherRepository.delete(t);
            teacherRepository.flush();
        });

        userRepository.findByUsername(TEST_PREFIX + "studentA").ifPresent(u -> userRepository.delete(u));
        userRepository.findByUsername(TEST_PREFIX + "studentB").ifPresent(u -> userRepository.delete(u));
        userRepository.findByUsername(TEST_PREFIX + "teacher").ifPresent(u -> userRepository.delete(u));
    }

    @Test
    @DisplayName("PDF Page Info: Học sinh đúng lớp lấy tổng số trang -> 200 OK & totalPages = 118")
    void testGetPageInfo_StudentBelongingToClass() throws Exception {
        String token = jwtUtils.generateTokenFromUsername(userStudentA.getUsername());

        mockMvc.perform(get("/api/materials/files/" + materialFile.getId() + "/pages")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalPages", is(118)));
    }

    @Test
    @DisplayName("PDF Render Page: Học sinh đúng lớp xem trang 1 -> 200 OK & Content-Type image/jpeg")
    void testGetPage_StudentBelongingToClass() throws Exception {
        String token = jwtUtils.generateTokenFromUsername(userStudentA.getUsername());

        mockMvc.perform(get("/api/materials/files/" + materialFile.getId() + "/pages/1")
                        .param("dpi", "110")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.IMAGE_JPEG))
                .andExpect(header().exists("ETag"))
                .andExpect(header().string("X-Content-Type-Options", "nosniff"));
    }

    @Test
    @DisplayName("PDF Render Page: Yêu cầu số trang vượt quá giới hạn -> 404 Not Found")
    void testGetPage_PageOutOfRange_Returns404() throws Exception {
        String token = jwtUtils.generateTokenFromUsername(userStudentA.getUsername());

        mockMvc.perform(get("/api/materials/files/" + materialFile.getId() + "/pages/999")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("PDF ReBAC: Học sinh lớp khác cố tình xem trang sách -> 403 Forbidden")
    void testGetPage_StudentOtherClass_Returns403() throws Exception {
        String token = jwtUtils.generateTokenFromUsername(userStudentB.getUsername());

        mockMvc.perform(get("/api/materials/files/" + materialFile.getId() + "/pages/1")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
    }
}
