package com.school.backend.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.school.backend.entity.*;
import com.school.backend.enums.Role;
import com.school.backend.payload.request.AnswerSubmitRequest;
import com.school.backend.payload.request.LeaveRequestReviewRequest;
import com.school.backend.payload.request.SubmissionSubmitRequest;
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

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class SecurityReBACTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

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
    private TeacherRepository teacherRepository;

    @Autowired
    private SchoolClassRepository classRepository;

    @Autowired
    private AcademicYearRepository academicYearRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private GuardianStudentRepository guardianStudentRepository;

    @Autowired
    private TeachingAssignmentRepository teachingAssignmentRepository;

    @Autowired
    private LeaveRequestRepository leaveRequestRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @Autowired
    private HomeworkRepository homeworkRepository;

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private HomeworkAssignmentRepository homeworkAssignmentRepository;

    @Autowired
    private SubmissionRepository submissionRepository;

    @Autowired
    private AnswerRepository answerRepository;

    @Autowired
    private MaterialRepository materialRepository;

    @Autowired
    private MaterialFileRepository materialFileRepository;

    @Autowired
    private MaterialClassRepository materialClassRepository;

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private AttendanceRecordRepository attendanceRecordRepository;

    @Autowired
    private AttendanceSessionRepository attendanceSessionRepository;

    // Test entities
    private AcademicYear academicYear;
    private SchoolClass classA;
    private SchoolClass classB;

    private User userStudentA;
    private Student studentA;

    private User userStudentB;
    private Student studentB;

    private User userParentA;
    private Parent parentA;

    private User userParentB;
    private Parent parentB;

    private User userHomeroomTeacher;
    private Teacher homeroomTeacher;

    private User userSubjectTeacher;
    private Teacher subjectTeacher;

    private User userOtherTeacher;
    private Teacher otherTeacher;

    private Subject mathSubject;

    @BeforeEach
    void setUp() {
        cleanUp();

        // 1. Năm học
        academicYear = academicYearRepository.findByIsCurrentTrue().orElseGet(() -> {
            AcademicYear ay = new AcademicYear();
            ay.setName("2026-2027-TEST");
            ay.setStartDate(LocalDate.of(2026, 9, 1));
            ay.setEndDate(LocalDate.of(2027, 6, 30));
            ay.setIsCurrent(true);
            return academicYearRepository.save(ay);
        });

        // 2. Giáo viên chủ nhiệm & Bộ môn
        userHomeroomTeacher = createUser("TEACHER_HR_TEST", Role.TEACHER);
        homeroomTeacher = new Teacher();
        homeroomTeacher.setUser(userHomeroomTeacher);
        homeroomTeacher.setName("Co Giao Chu Nhiem");
        homeroomTeacher.setEmail("hr_teacher@test.edu");
        homeroomTeacher.setPhone("0901000001");
        homeroomTeacher = teacherRepository.save(homeroomTeacher);

        userSubjectTeacher = createUser("TEACHER_SUBJ_TEST", Role.TEACHER);
        subjectTeacher = new Teacher();
        subjectTeacher.setUser(userSubjectTeacher);
        subjectTeacher.setName("Thay Giao Bo Mon");
        subjectTeacher.setEmail("subj_teacher@test.edu");
        subjectTeacher.setPhone("0901000002");
        subjectTeacher = teacherRepository.save(subjectTeacher);

        userOtherTeacher = createUser("TEACHER_OTHER_TEST", Role.TEACHER);
        otherTeacher = new Teacher();
        otherTeacher.setUser(userOtherTeacher);
        otherTeacher.setName("Giao Vien Lop Khac");
        otherTeacher.setEmail("other_teacher@test.edu");
        otherTeacher.setPhone("0901000003");
        otherTeacher = teacherRepository.save(otherTeacher);

        // 3. Lớp học A và Lớp B
        classA = new SchoolClass();
        classA.setGrade("3");
        classA.setSection("A_TEST");
        classA.setClassTeacher(homeroomTeacher);
        classA.setHomeroomTeacher(homeroomTeacher);
        classA = classRepository.save(classA);

        classB = new SchoolClass();
        classB.setGrade("3");
        classB.setSection("B_TEST");
        classB = classRepository.save(classB);

        // 4. Môn học & Phân công giảng dạy
        mathSubject = subjectRepository.findByName("Toan Hoc Test").orElseGet(() -> {
            Subject s = new Subject();
            s.setName("Toan Hoc Test");
            s.setCode("MATH_TEST_99");
            return subjectRepository.save(s);
        });

        TeachingAssignment ta = new TeachingAssignment();
        ta.setTeacher(subjectTeacher);
        ta.setSchoolClass(classA);
        ta.setSubject(mathSubject);
        ta.setAcademicYear(academicYear);
        ta.setAssignmentType("SUBJECT_TEACHER");
        teachingAssignmentRepository.save(ta);

        // 5. Học sinh A (Lớp A) và Phụ huynh A
        userParentA = createUser("PARENT_A_TEST", Role.PARENT);
        parentA = new Parent();
        parentA.setUser(userParentA);
        parentA.setName("Phu Huynh A");
        parentA.setPhone("0911000001");
        parentA = parentRepository.save(parentA);

        userStudentA = createUser("STU_A_TEST", Role.STUDENT);
        studentA = new Student();
        studentA.setUser(userStudentA);
        studentA.setAdmissionNumber("ADM_A_TEST");
        studentA.setRollNo("01");
        studentA.setName("Em Hoc Sinh A");
        studentA.setSchoolClass(classA);
        studentA = studentRepository.save(studentA);

        Enrollment enrA = new Enrollment();
        enrA.setStudent(studentA);
        enrA.setSchoolClass(classA);
        enrA.setAcademicYear(academicYear);
        enrollmentRepository.save(enrA);

        GuardianStudent gsA = new GuardianStudent();
        gsA.setGuardian(parentA);
        gsA.setStudent(studentA);
        gsA.setIsPrimary(true);
        guardianStudentRepository.save(gsA);

        // 6. Học sinh B (Lớp B) và Phụ huynh B
        userParentB = createUser("PARENT_B_TEST", Role.PARENT);
        parentB = new Parent();
        parentB.setUser(userParentB);
        parentB.setName("Phu Huynh B");
        parentB.setPhone("0911000002");
        parentB = parentRepository.save(parentB);

        userStudentB = createUser("STU_B_TEST", Role.STUDENT);
        studentB = new Student();
        studentB.setUser(userStudentB);
        studentB.setAdmissionNumber("ADM_B_TEST");
        studentB.setRollNo("02");
        studentB.setName("Em Hoc Sinh B");
        studentB.setSchoolClass(classB);
        studentB = studentRepository.save(studentB);

        Enrollment enrB = new Enrollment();
        enrB.setStudent(studentB);
        enrB.setSchoolClass(classB);
        enrB.setAcademicYear(academicYear);
        enrollmentRepository.save(enrB);

        GuardianStudent gsB = new GuardianStudent();
        gsB.setGuardian(parentB);
        gsB.setStudent(studentB);
        gsB.setIsPrimary(true);
        guardianStudentRepository.save(gsB);
    }

    private User createUser(String username, Role role) {
        User u = new User();
        u.setUsername(username);
        u.setPassword(passwordEncoder.encode("password123"));
        u.setRole(role);
        u.setMustChangePassword(false);
        return userRepository.save(u);
    }

    @AfterEach
    void tearDown() {
        cleanUp();
    }

    private void cleanUp() {
        try {
            java.nio.file.Path testFilePath = java.nio.file.Paths.get("uploads/materials/toan_lop_3a.pdf").toAbsolutePath().normalize();
            java.nio.file.Files.deleteIfExists(testFilePath);
        } catch (Exception ignored) {}

        // 1. Dọn dẹp câu trả lời & bài làm kiểm thử
        homeworkRepository.findAll().stream()
                .filter(h -> "Kiểm tra 15 phút Toán Lớp 3A".equals(h.getTitle()))
                .forEach(h -> {
                    homeworkAssignmentRepository.findAll().stream()
                            .filter(ha -> ha.getHomework() != null && ha.getHomework().getId().equals(h.getId()))
                            .forEach(ha -> {
                                submissionRepository.findByAssignmentIdOrderByStartedAtAsc(ha.getId()).forEach(sub -> {
                                    answerRepository.deleteAll(answerRepository.findBySubmissionId(sub.getId()));
                                    submissionRepository.delete(sub);
                                });
                                homeworkAssignmentRepository.delete(ha);
                            });
                    questionRepository.deleteAll(questionRepository.findByHomeworkIdOrderByQuestionOrderAsc(h.getId()));
                    homeworkRepository.delete(h);
                    homeworkRepository.flush();
                });

        // 2. Dọn dẹp học liệu kiểm thử
        materialRepository.findAll().stream()
                .filter(m -> "Tài liệu Toán Lớp 3A".equals(m.getTitle()))
                .forEach(m -> {
                    materialClassRepository.deleteAll(materialClassRepository.findByMaterialId(m.getId()));
                    materialFileRepository.deleteAll(materialFileRepository.findByMaterialId(m.getId()));
                    materialRepository.delete(m);
                    materialRepository.flush();
                });

        // 3. Dọn dẹp học sinh A, B
        studentRepository.findByAdmissionNumber("ADM_A_TEST").ifPresent(s -> {
            submissionRepository.findByStudentIdOrderByStartedAtDesc(s.getId()).forEach(sub -> {
                answerRepository.deleteAll(answerRepository.findBySubmissionId(sub.getId()));
                submissionRepository.delete(sub);
            });
            attendanceRecordRepository.deleteAll(attendanceRecordRepository.findByStudentId(s.getId()));
            attendanceRepository.deleteAll(attendanceRepository.findByStudentId(s.getId()));
            leaveRequestRepository.deleteAll(leaveRequestRepository.findByStudentIdOrderByCreatedAtDesc(s.getId()));
            enrollmentRepository.deleteAll(enrollmentRepository.findByStudentId(s.getId()));
            guardianStudentRepository.deleteAll(guardianStudentRepository.findByStudentId(s.getId()));
            studentRepository.delete(s);
            studentRepository.flush();
        });

        studentRepository.findByAdmissionNumber("ADM_B_TEST").ifPresent(s -> {
            submissionRepository.findByStudentIdOrderByStartedAtDesc(s.getId()).forEach(sub -> {
                answerRepository.deleteAll(answerRepository.findBySubmissionId(sub.getId()));
                submissionRepository.delete(sub);
            });
            attendanceRecordRepository.deleteAll(attendanceRecordRepository.findByStudentId(s.getId()));
            attendanceRepository.deleteAll(attendanceRepository.findByStudentId(s.getId()));
            leaveRequestRepository.deleteAll(leaveRequestRepository.findByStudentIdOrderByCreatedAtDesc(s.getId()));
            enrollmentRepository.deleteAll(enrollmentRepository.findByStudentId(s.getId()));
            guardianStudentRepository.deleteAll(guardianStudentRepository.findByStudentId(s.getId()));
            studentRepository.delete(s);
            studentRepository.flush();
        });

        // 4. Dọn dẹp phụ huynh A, B
        userRepository.findByUsername("PARENT_A_TEST").ifPresent(u -> {
            parentRepository.findByUserId(u.getId()).ifPresent(p -> {
                guardianStudentRepository.deleteAll(guardianStudentRepository.findByGuardianId(p.getId()));
                parentRepository.delete(p);
                parentRepository.flush();
            });
            userRepository.delete(u);
            userRepository.flush();
        });

        userRepository.findByUsername("PARENT_B_TEST").ifPresent(u -> {
            parentRepository.findByUserId(u.getId()).ifPresent(p -> {
                guardianStudentRepository.deleteAll(guardianStudentRepository.findByGuardianId(p.getId()));
                parentRepository.delete(p);
                parentRepository.flush();
            });
            userRepository.delete(u);
            userRepository.flush();
        });

        // 5. Dọn dẹp lớp học test trước để gỡ foreign key (class_teacher_id, homeroom_teacher_id)
        classRepository.findByGradeAndSection("3", "A_TEST").ifPresent(sc -> {
            teachingAssignmentRepository.deleteAll(teachingAssignmentRepository.findBySchoolClassIdAndAcademicYearIsCurrentTrue(sc.getId()));
            sc.setClassTeacher(null);
            sc.setHomeroomTeacher(null);
            classRepository.saveAndFlush(sc);
            classRepository.delete(sc);
            classRepository.flush();
        });

        classRepository.findByGradeAndSection("3", "B_TEST").ifPresent(sc -> {
            teachingAssignmentRepository.deleteAll(teachingAssignmentRepository.findBySchoolClassIdAndAcademicYearIsCurrentTrue(sc.getId()));
            sc.setClassTeacher(null);
            sc.setHomeroomTeacher(null);
            classRepository.saveAndFlush(sc);
            classRepository.delete(sc);
            classRepository.flush();
        });

        // 6. Dọn dẹp giáo viên test & giải phóng mọi foreign key liên quan
        userRepository.findByUsername("TEACHER_HR_TEST").ifPresent(u -> {
            teacherRepository.findByUserId(u.getId()).ifPresent(t -> {
                homeworkRepository.findAll().stream()
                        .filter(h -> h.getCreatedByTeacher() != null && h.getCreatedByTeacher().getId().equals(t.getId()))
                        .forEach(h -> {
                            homeworkAssignmentRepository.findAll().stream()
                                    .filter(ha -> ha.getHomework() != null && ha.getHomework().getId().equals(h.getId()))
                                    .forEach(ha -> {
                                        submissionRepository.findByAssignmentIdOrderByStartedAtAsc(ha.getId()).forEach(sub -> {
                                            answerRepository.deleteAll(answerRepository.findBySubmissionId(sub.getId()));
                                            submissionRepository.delete(sub);
                                        });
                                        homeworkAssignmentRepository.delete(ha);
                                    });
                            questionRepository.deleteAll(questionRepository.findByHomeworkIdOrderByQuestionOrderAsc(h.getId()));
                            homeworkRepository.delete(h);
                            homeworkRepository.flush();
                        });

                classRepository.findByClassTeacherId(t.getId()).forEach(sc -> {
                    sc.setClassTeacher(null);
                    classRepository.saveAndFlush(sc);
                });
                classRepository.findByHomeroomTeacherId(t.getId()).forEach(sc -> {
                    sc.setHomeroomTeacher(null);
                    classRepository.saveAndFlush(sc);
                });
                teachingAssignmentRepository.deleteAll(teachingAssignmentRepository.findByTeacherId(t.getId()));
                teacherRepository.delete(t);
                teacherRepository.flush();
            });
            userRepository.delete(u);
            userRepository.flush();
        });

        userRepository.findByUsername("TEACHER_SUBJ_TEST").ifPresent(u -> {
            teacherRepository.findByUserId(u.getId()).ifPresent(t -> {
                homeworkRepository.findAll().stream()
                        .filter(h -> h.getCreatedByTeacher() != null && h.getCreatedByTeacher().getId().equals(t.getId()))
                        .forEach(h -> {
                            homeworkAssignmentRepository.findAll().stream()
                                    .filter(ha -> ha.getHomework() != null && ha.getHomework().getId().equals(h.getId()))
                                    .forEach(ha -> {
                                        submissionRepository.findByAssignmentIdOrderByStartedAtAsc(ha.getId()).forEach(sub -> {
                                            answerRepository.deleteAll(answerRepository.findBySubmissionId(sub.getId()));
                                            submissionRepository.delete(sub);
                                        });
                                        homeworkAssignmentRepository.delete(ha);
                                    });
                            questionRepository.deleteAll(questionRepository.findByHomeworkIdOrderByQuestionOrderAsc(h.getId()));
                            homeworkRepository.delete(h);
                            homeworkRepository.flush();
                        });

                classRepository.findByClassTeacherId(t.getId()).forEach(sc -> {
                    sc.setClassTeacher(null);
                    classRepository.saveAndFlush(sc);
                });
                classRepository.findByHomeroomTeacherId(t.getId()).forEach(sc -> {
                    sc.setHomeroomTeacher(null);
                    classRepository.saveAndFlush(sc);
                });
                teachingAssignmentRepository.deleteAll(teachingAssignmentRepository.findByTeacherId(t.getId()));
                teacherRepository.delete(t);
                teacherRepository.flush();
            });
            userRepository.delete(u);
            userRepository.flush();
        });

        userRepository.findByUsername("TEACHER_OTHER_TEST").ifPresent(u -> {
            teacherRepository.findByUserId(u.getId()).ifPresent(t -> {
                classRepository.findByClassTeacherId(t.getId()).forEach(sc -> {
                    sc.setClassTeacher(null);
                    classRepository.saveAndFlush(sc);
                });
                classRepository.findByHomeroomTeacherId(t.getId()).forEach(sc -> {
                    sc.setHomeroomTeacher(null);
                    classRepository.saveAndFlush(sc);
                });
                teachingAssignmentRepository.deleteAll(teachingAssignmentRepository.findByTeacherId(t.getId()));
                teacherRepository.delete(t);
                teacherRepository.flush();
            });
            userRepository.delete(u);
            userRepository.flush();
        });

        // 7. Dọn dẹp tài khoản người dùng test
        userRepository.findByUsername("STU_A_TEST").ifPresent(u -> { userRepository.delete(u); userRepository.flush(); });
        userRepository.findByUsername("STU_B_TEST").ifPresent(u -> { userRepository.delete(u); userRepository.flush(); });
        userRepository.findByUsername("PARENT_A_TEST").ifPresent(u -> { userRepository.delete(u); userRepository.flush(); });
        userRepository.findByUsername("PARENT_B_TEST").ifPresent(u -> { userRepository.delete(u); userRepository.flush(); });
        userRepository.findByUsername("TEACHER_HR_TEST").ifPresent(u -> { userRepository.delete(u); userRepository.flush(); });
        userRepository.findByUsername("TEACHER_SUBJ_TEST").ifPresent(u -> { userRepository.delete(u); userRepository.flush(); });
        userRepository.findByUsername("TEACHER_OTHER_TEST").ifPresent(u -> { userRepository.delete(u); userRepository.flush(); });
    }

    @Test
    @DisplayName("ISSUE-02 ReBAC: Phụ huynh chỉ xem được Enrollment con mình; xem con người khác phải nhận 403 Forbidden")
    void testEnrollment_ParentReBAC() throws Exception {
        String tokenParentA = jwtUtils.generateTokenFromUsername(userParentA.getUsername());

        // Phụ huynh A xem con mình (Student A) -> 200 OK
        mockMvc.perform(get("/api/enrollments/student/" + studentA.getId())
                        .header("Authorization", "Bearer " + tokenParentA))
                .andExpect(status().isOk());

        // Phụ huynh A cố tình xem con người khác (Student B) -> 403 Forbidden
        mockMvc.perform(get("/api/enrollments/student/" + studentB.getId())
                        .header("Authorization", "Bearer " + tokenParentA))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("ISSUE-02 ReBAC: Học sinh chỉ xem được Enrollment của chính mình; xem bạn học phải nhận 403 Forbidden")
    void testEnrollment_StudentReBAC() throws Exception {
        String tokenStudentA = jwtUtils.generateTokenFromUsername(userStudentA.getUsername());

        // Học sinh A xem chính mình -> 200 OK
        mockMvc.perform(get("/api/enrollments/student/" + studentA.getId())
                        .header("Authorization", "Bearer " + tokenStudentA))
                .andExpect(status().isOk());

        // Học sinh A xem học sinh B -> 403 Forbidden
        mockMvc.perform(get("/api/enrollments/student/" + studentB.getId())
                        .header("Authorization", "Bearer " + tokenStudentA))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("ISSUE-01 ReBAC: Chỉ Giáo viên Chủ nhiệm mới được duyệt đơn nghỉ phép; Giáo viên bộ môn nhận 403 Forbidden")
    void testLeaveRequest_ReviewPermissions() throws Exception {
        // Tạo đơn nghỉ phép cho Học sinh A do Phụ huynh A gửi
        LeaveRequest lr = new LeaveRequest();
        lr.setStudent(studentA);
        lr.setSubmittedByGuardian(parentA);
        lr.setStartDate(LocalDate.now().plusDays(1));
        lr.setEndDate(LocalDate.now().plusDays(2));
        lr.setReason("Em bị sốt");
        lr.setStatus("PENDING");
        lr = leaveRequestRepository.save(lr);

        String tokenSubjTeacher = jwtUtils.generateTokenFromUsername(userSubjectTeacher.getUsername());
        String tokenHrTeacher = jwtUtils.generateTokenFromUsername(userHomeroomTeacher.getUsername());

        LeaveRequestReviewRequest req = new LeaveRequestReviewRequest();
        req.setDecision("APPROVED");
        req.setTeacherNote("Đồng ý cho nghỉ");

        // Giáo viên bộ môn cố tình duyệt đơn -> 403 Forbidden
        mockMvc.perform(put("/api/leave-requests/" + lr.getId() + "/review")
                        .header("Authorization", "Bearer " + tokenSubjTeacher)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isForbidden());

        // Giáo viên chủ nhiệm duyệt đơn -> 200 OK
        mockMvc.perform(put("/api/leave-requests/" + lr.getId() + "/review")
                        .header("Authorization", "Bearer " + tokenHrTeacher)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("APPROVED")));
    }

    @Test
    @DisplayName("LMS Auto-Grading: Câu hỏi Điền ngắn (SHORT_ANSWER) chuẩn hóa Unicode NFC và so khớp đáp án |")
    void testShortAnswer_AutoGrading_NFC() throws Exception {
        // 1. Tạo bài tập có câu hỏi SHORT_ANSWER
        Homework hw = new Homework();
        hw.setSubject(mathSubject);
        hw.setCreatedByTeacher(homeroomTeacher);
        hw.setTitle("Bài tập Thủ đô");
        hw.setTotalPoints(10.0);
        hw = homeworkRepository.save(hw);

        Question q = new Question();
        q.setHomework(hw);
        q.setQuestionOrder(1);
        q.setQuestionType("SHORT_ANSWER");
        q.setContent("Thủ đô của Việt Nam là gì?");
        q.setPoints(10.0);
        q.setCorrectAnswerText("Hà Nội|Ha Noi");
        q = questionRepository.save(q);
        hw.getQuestions().add(q);

        // 2. Giao bài tập cho Lớp A
        HomeworkAssignment ha = new HomeworkAssignment();
        ha.setHomework(hw);
        ha.setSchoolClass(classA);
        ha.setAssignedByTeacher(homeroomTeacher);
        ha.setDueDate(LocalDateTime.now().plusDays(5));
        ha.setAllowLateSubmission(true);
        ha = homeworkAssignmentRepository.save(ha);

        // 3. Học sinh A mở làm bài tập
        String tokenStudentA = jwtUtils.generateTokenFromUsername(userStudentA.getUsername());
        Submission sub = new Submission();
        sub.setAssignment(ha);
        sub.setStudent(studentA);
        sub.setAttemptNumber(1);
        sub.setStatus("IN_PROGRESS");
        sub = submissionRepository.save(sub);

        // 4. Học sinh nộp bài với câu trả lời chuẩn Unicode NFC có khoảng trắng thừa
        SubmissionSubmitRequest submitReq = new SubmissionSubmitRequest();
        AnswerSubmitRequest ansReq = new AnswerSubmitRequest();
        ansReq.setQuestionId(q.getId());
        ansReq.setAnswerText("   hà nội   "); // Unicode có dấu, chữ thường, cách lề
        submitReq.setAnswers(List.of(ansReq));

        mockMvc.perform(post("/api/student-portal/homework/submissions/" + sub.getId() + "/submit")
                        .header("Authorization", "Bearer " + tokenStudentA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(submitReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status", is("GRADED")))
                .andExpect(jsonPath("$.autoScore", is(10.0)))
                .andExpect(jsonPath("$.finalScore", is(10.0)))
                .andExpect(jsonPath("$.isLate", is(false)));
    }

    @Test
    @DisplayName("Materials ReBAC: Học sinh đúng lớp tải tài liệu -> 200 OK; học sinh khác lớp -> 403 Forbidden")
    void testMaterialDownload_StudentAccessControl() throws Exception {
        // Tạo file vật lý thực tế trên ổ đĩa
        java.nio.file.Path baseDir = java.nio.file.Paths.get("uploads/materials").toAbsolutePath().normalize();
        java.nio.file.Files.createDirectories(baseDir);
        java.nio.file.Path testFilePath = baseDir.resolve("toan_lop_3a.pdf");
        java.nio.file.Files.writeString(testFilePath, "Nội dung học liệu mẫu cho Lớp 3A");

        // Tạo học liệu phân phối cho Lớp A
        Material m = new Material();
        m.setSubject(mathSubject);
        m.setCreatedByTeacher(homeroomTeacher);
        m.setTitle("Tài liệu Toán Lớp 3A");
        m.setStatus("PUBLISHED");
        m = materialRepository.save(m);

        MaterialClass mc = new MaterialClass();
        mc.setMaterial(m);
        mc.setSchoolClass(classA);
        materialClassRepository.save(mc);

        MaterialFile mf = new MaterialFile();
        mf.setMaterial(m);
        mf.setFileName("toan_lop_3a.pdf");
        mf.setFileUrl("uploads/materials/toan_lop_3a.pdf");
        mf = materialFileRepository.save(mf);

        String tokenStudentA = jwtUtils.generateTokenFromUsername(userStudentA.getUsername());
        String tokenStudentB = jwtUtils.generateTokenFromUsername(userStudentB.getUsername());

        // Học sinh A (thuộc Lớp A) tải tài liệu -> 200 OK
        mockMvc.perform(get("/api/materials/files/" + mf.getId() + "/download")
                        .header("Authorization", "Bearer " + tokenStudentA))
                .andExpect(status().isOk());

        // Học sinh B (thuộc Lớp B) cố tình tải tài liệu của Lớp A -> 403 Forbidden
        mockMvc.perform(get("/api/materials/files/" + mf.getId() + "/download")
                        .header("Authorization", "Bearer " + tokenStudentB))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Materials ReBAC: Phụ huynh có con học lớp nhận học liệu -> 200 OK; phụ huynh lớp khác -> 403 Forbidden")
    void testMaterialDownload_ParentReBAC() throws Exception {
        // Tạo file vật lý thực tế trên ổ đĩa
        java.nio.file.Path baseDir = java.nio.file.Paths.get("uploads/materials").toAbsolutePath().normalize();
        java.nio.file.Files.createDirectories(baseDir);
        java.nio.file.Path testFilePath = baseDir.resolve("toan_lop_3a.pdf");
        java.nio.file.Files.writeString(testFilePath, "Nội dung học liệu mẫu cho Lớp 3A");

        Material m = new Material();
        m.setSubject(mathSubject);
        m.setCreatedByTeacher(homeroomTeacher);
        m.setTitle("Tài liệu Toán Lớp 3A");
        m.setStatus("PUBLISHED");
        m = materialRepository.save(m);

        MaterialClass mc = new MaterialClass();
        mc.setMaterial(m);
        mc.setSchoolClass(classA);
        materialClassRepository.save(mc);

        MaterialFile mf = new MaterialFile();
        mf.setMaterial(m);
        mf.setFileName("toan_lop_3a.pdf");
        mf.setFileUrl("uploads/materials/toan_lop_3a.pdf");
        mf = materialFileRepository.save(mf);

        String tokenParentA = jwtUtils.generateTokenFromUsername(userParentA.getUsername());
        String tokenParentB = jwtUtils.generateTokenFromUsername(userParentB.getUsername());

        // Phụ huynh A (có con Student A học Lớp 3A) -> 200 OK
        mockMvc.perform(get("/api/materials/files/" + mf.getId() + "/download")
                        .header("Authorization", "Bearer " + tokenParentA))
                .andExpect(status().isOk());

        // Phụ huynh B (con Student B học Lớp 3B) tải học liệu Lớp 3A -> 403 Forbidden
        mockMvc.perform(get("/api/materials/files/" + mf.getId() + "/download")
                        .header("Authorization", "Bearer " + tokenParentB))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Materials ReBAC: Giáo viên chủ nhiệm & Giáo viên bộ môn lớp nhận -> 200 OK; Giáo viên lớp khác -> 403 Forbidden")
    void testMaterialDownload_TeacherReBAC() throws Exception {
        // Tạo file vật lý thực tế trên ổ đĩa
        java.nio.file.Path baseDir = java.nio.file.Paths.get("uploads/materials").toAbsolutePath().normalize();
        java.nio.file.Files.createDirectories(baseDir);
        java.nio.file.Path testFilePath = baseDir.resolve("toan_lop_3a.pdf");
        java.nio.file.Files.writeString(testFilePath, "Nội dung học liệu mẫu cho Lớp 3A");

        Material m = new Material();
        m.setSubject(mathSubject);
        m.setCreatedByTeacher(homeroomTeacher);
        m.setTitle("Tài liệu Toán Lớp 3A");
        m.setStatus("PUBLISHED");
        m = materialRepository.save(m);

        MaterialClass mc = new MaterialClass();
        mc.setMaterial(m);
        mc.setSchoolClass(classA);
        materialClassRepository.save(mc);

        MaterialFile mf = new MaterialFile();
        mf.setMaterial(m);
        mf.setFileName("toan_lop_3a.pdf");
        mf.setFileUrl("uploads/materials/toan_lop_3a.pdf");
        mf = materialFileRepository.save(mf);

        String tokenHomeroomTeacher = jwtUtils.generateTokenFromUsername(userHomeroomTeacher.getUsername());
        String tokenSubjectTeacher = jwtUtils.generateTokenFromUsername(userSubjectTeacher.getUsername());
        String tokenOtherTeacher = jwtUtils.generateTokenFromUsername(userOtherTeacher.getUsername());

        // GVCN Lớp 3A -> 200 OK
        mockMvc.perform(get("/api/materials/files/" + mf.getId() + "/download")
                        .header("Authorization", "Bearer " + tokenHomeroomTeacher))
                .andExpect(status().isOk());

        // GV bộ môn giảng dạy Lớp 3A -> 200 OK
        mockMvc.perform(get("/api/materials/files/" + mf.getId() + "/download")
                        .header("Authorization", "Bearer " + tokenSubjectTeacher))
                .andExpect(status().isOk());

        // GV lớp khác không liên quan -> 403 Forbidden
        mockMvc.perform(get("/api/materials/files/" + mf.getId() + "/download")
                        .header("Authorization", "Bearer " + tokenOtherTeacher))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Materials File Storage: Khi file vật lý không tồn tại trên đĩa cứng -> Phải trả về 404 Not Found (không sinh file giả)")
    void testMaterialDownload_PhysicalFileNotFound() throws Exception {
        // Đảm bảo file vật lý KHÔNG tồn tại
        java.nio.file.Path testFilePath = java.nio.file.Paths.get("uploads/materials/toan_lop_3a.pdf").toAbsolutePath().normalize();
        java.nio.file.Files.deleteIfExists(testFilePath);

        Material m = new Material();
        m.setSubject(mathSubject);
        m.setCreatedByTeacher(homeroomTeacher);
        m.setTitle("Tài liệu Toán Lớp 3A");
        m.setStatus("PUBLISHED");
        m = materialRepository.save(m);

        MaterialClass mc = new MaterialClass();
        mc.setMaterial(m);
        mc.setSchoolClass(classA);
        materialClassRepository.save(mc);

        MaterialFile mf = new MaterialFile();
        mf.setMaterial(m);
        mf.setFileName("toan_lop_3a.pdf");
        mf.setFileUrl("uploads/materials/toan_lop_3a.pdf");
        mf = materialFileRepository.save(mf);

        String tokenStudentA = jwtUtils.generateTokenFromUsername(userStudentA.getUsername());

        // Học sinh A có quyền nhưng file vật lý không tồn tại trên disk -> 404 Not Found
        mockMvc.perform(get("/api/materials/files/" + mf.getId() + "/download")
                        .header("Authorization", "Bearer " + tokenStudentA))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("P0 Hardening: Đăng ký công khai không được phép chọn vai trò ADMIN -> Phải trả về 400 Bad Request")
    void testSignup_CannotRegisterAsAdmin() throws Exception {
        String payload = """
                {
                    "username": "hacker_admin_test",
                    "email": "hacker@test.com",
                    "password": "Password123@",
                    "role": ["ADMIN"]
                }
                """;

        mockMvc.perform(post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(payload))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", org.hamcrest.Matchers.containsString("Lỗi bảo mật")));
    }

    @Test
    @DisplayName("P0 Hardening: Chuỗi JSON của User và Student tuyệt đối không bao giờ chứa password hash")
    void testUserSerialization_PasswordNeverExposed() throws Exception {
        String userJson = objectMapper.writeValueAsString(userStudentA);
        org.junit.jupiter.api.Assertions.assertFalse(userJson.contains("\"password\""),
                "User JSON serialization must NOT contain password field!");

        String studentJson = objectMapper.writeValueAsString(studentA);
        org.junit.jupiter.api.Assertions.assertFalse(studentJson.contains("\"password\""),
                "Student JSON serialization must NOT contain password field!");
    }

    @Test
    @DisplayName("P0 Hardening: Phụ huynh B cố tình xem sao kê học phí của con Phụ huynh A (IDOR) -> Phải nhận 403 Forbidden")
    void testFeeStatement_ParentReBAC_IDOR() throws Exception {
        String tokenParentA = jwtUtils.generateTokenFromUsername(userParentA.getUsername());
        String tokenParentB = jwtUtils.generateTokenFromUsername(userParentB.getUsername());

        // Phụ huynh A xem con mình -> 200 OK
        mockMvc.perform(get("/api/fees/statement/" + studentA.getId())
                        .header("Authorization", "Bearer " + tokenParentA))
                .andExpect(status().isOk());

        // Phụ huynh B xem con người khác -> 403 Forbidden
        mockMvc.perform(get("/api/fees/statement/" + studentA.getId())
                        .header("Authorization", "Bearer " + tokenParentB))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("BUG-002: Giáo viên không phụ trách lớp gửi điểm danh hàng loạt -> 403 Forbidden")
    void testAttendanceBulk_OtherTeacherBlocked() throws Exception {
        String tokenOtherTeacher = jwtUtils.generateTokenFromUsername(userOtherTeacher.getUsername());

        String payload = """
                {
                    "classId": %d,
                    "date": "2026-10-15",
                    "records": [
                        {"studentId": %d, "status": "PRESENT"}
                    ]
                }
                """.formatted(classA.getId(), studentA.getId());

        mockMvc.perform(post("/api/attendance/bulk")
                        .header("Authorization", "Bearer " + tokenOtherTeacher)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(payload))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("BUG-003: Giáo viên xem lịch phân công giảng dạy của giáo viên khác -> 403 Forbidden")
    void testTeachingAssignment_OtherTeacherBlocked() throws Exception {
        String tokenOtherTeacher = jwtUtils.generateTokenFromUsername(userOtherTeacher.getUsername());

        // otherTeacher cố tình xem phân công của homeroomTeacher
        mockMvc.perform(get("/api/teaching-assignments/teacher/" + homeroomTeacher.getId())
                        .header("Authorization", "Bearer " + tokenOtherTeacher))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("BUG-004 Verification: Học sinh gọi GET /api/student-portal/profile -> 200 OK với thông tin profile học sinh")
    void testStudent_CanAccessProfile() throws Exception {
        String tokenStudentA = jwtUtils.generateTokenFromUsername(userStudentA.getUsername());

        mockMvc.perform(get("/api/student-portal/profile")
                        .header("Authorization", "Bearer " + tokenStudentA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name", is(studentA.getName())));
    }

    @Test
    @DisplayName("SEC-MARK-01: Học sinh xem học bạ của chính mình -> 200 OK; xem học bạ của bạn khác (BOLA/IDOR) -> 403 Forbidden")
    void testStudent_CannotAccessOtherStudentMarkbook_BOLA() throws Exception {
        String tokenStudentA = jwtUtils.generateTokenFromUsername(userStudentA.getUsername());

        // 1. Học sinh A xem học bạ của chính mình -> 200 OK
        mockMvc.perform(get("/api/marks/student/" + studentA.getId() + "/markbook")
                        .header("Authorization", "Bearer " + tokenStudentA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.studentId", is(studentA.getId().intValue())));

        // 2. Học sinh A cố tình xem học bạ của học sinh B -> 403 Forbidden (chặn BOLA/IDOR)
        mockMvc.perform(get("/api/marks/student/" + studentB.getId() + "/markbook")
                        .header("Authorization", "Bearer " + tokenStudentA))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("SEC-MARK-02: Giáo viên không có phân công giảng dạy môn học cho lớp -> 403 Forbidden khi nhập điểm")
    void testTeacher_CannotInputMarksForUnassignedSubject() throws Exception {
        String tokenOtherTeacher = jwtUtils.generateTokenFromUsername(userOtherTeacher.getUsername());

        // otherTeacher không dạy lớp A, gửi payload nhập điểm môn Toán cho studentA
        String payload = """
                {
                    "subject": "Toán",
                    "records": [
                        {"studentId": %d, "marksObtained": 8.5}
                    ]
                }
                """.formatted(studentA.getId());

        mockMvc.perform(post("/api/marks/bulk")
                        .header("Authorization", "Bearer " + tokenOtherTeacher)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(payload))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("SEC-MARK-03: Giáo viên chủ nhiệm nhưng không dạy môn Toán -> 403 Forbidden khi cố tình sửa điểm môn Toán")
    void testHomeroomTeacher_CannotGradeSubjectWithoutAssignment() throws Exception {
        String tokenHomeroom = jwtUtils.generateTokenFromUsername(userHomeroomTeacher.getUsername());

        // homeroomTeacher là GVCN lớp A nhưng không có TeachingAssignment môn mathSubject
        String payload = """
                {
                    "subjectId": %d,
                    "records": [
                        {"studentId": %d, "marksObtained": 9.0}
                    ]
                }
                """.formatted(mathSubject.getId(), studentA.getId());

        mockMvc.perform(post("/api/marks/bulk")
                        .header("Authorization", "Bearer " + tokenHomeroom)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(payload))
                .andExpect(status().isForbidden());
    }
}
