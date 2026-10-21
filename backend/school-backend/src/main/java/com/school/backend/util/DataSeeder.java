package com.school.backend.util;

import com.school.backend.entity.Parent;
import com.school.backend.entity.Teacher;
import com.school.backend.entity.SchoolClass;
import com.school.backend.entity.Student;
import com.school.backend.entity.Enrollment;
import com.school.backend.entity.GuardianStudent;
import com.school.backend.entity.Marks;
import com.school.backend.enums.ExamType;
import com.school.backend.repository.TeacherRepository;
import com.school.backend.repository.SchoolClassRepository;
import com.school.backend.repository.EnrollmentRepository;
import com.school.backend.repository.GuardianStudentRepository;
import com.school.backend.repository.MarksRepository;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import com.school.backend.entity.User;
import com.school.backend.enums.Role;
import com.school.backend.repository.ParentRepository;
import com.school.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataSeeder implements CommandLineRunner {

    @Autowired
    UserRepository userRepository;

    @Autowired
    ParentRepository parentRepository;

    @Autowired
    PasswordEncoder passwordEncoder;

    @Autowired
    com.school.backend.service.DataMigrationService dataMigrationService;

    @Autowired
    com.school.backend.repository.StudentRepository studentRepository;

    @Autowired
    TeacherRepository teacherRepository;

    @Autowired
    SchoolClassRepository schoolClassRepository;

    @Autowired
    com.school.backend.repository.AcademicYearRepository academicYearRepository;

    @Autowired
    com.school.backend.repository.SubjectRepository subjectRepository;

    @Autowired
    com.school.backend.repository.TeachingAssignmentRepository teachingAssignmentRepository;

    @Autowired
    com.school.backend.repository.MaterialRepository materialRepository;

    @Autowired
    com.school.backend.repository.MaterialFileRepository materialFileRepository;

    @Autowired
    com.school.backend.repository.MaterialClassRepository materialClassRepository;

    @Autowired
    com.school.backend.repository.HomeworkRepository homeworkRepository;

    @Autowired
    com.school.backend.repository.HomeworkAssignmentRepository homeworkAssignmentRepository;

    @Autowired
    com.school.backend.repository.QuestionRepository questionRepository;

    @Autowired
    com.school.backend.repository.QuestionOptionRepository questionOptionRepository;

    @Autowired
    com.school.backend.repository.NotificationRepository notificationRepository;

    @Autowired
    GuardianStudentRepository guardianStudentRepository;

    @Autowired
    EnrollmentRepository enrollmentRepository;

    @Autowired
    MarksRepository marksRepository;

    @Override
    public void run(String... args) throws Exception {
        // Excel import on startup is disabled. Use the Admin Dashboard > Bulk Import feature instead.
        if (studentRepository.count() == 0) {
            System.out.println("No students found. Please use the Admin Dashboard > Bulk Import to load student data.");
        } else {
            System.out.println(
                    "Students already exist in database (" + studentRepository.count() + "). Skipping import.");
        }
        // Create Admin user only if not already existing (preserve existing credentials)
        userRepository.findByUsername("admin").ifPresentOrElse(
                existingAdmin -> System.out.println("Admin user already exists. Skipping password reset to preserve credentials."),
                () -> {
                    User admin = new User();
                    admin.setUsername("admin");
                    admin.setPassword(passwordEncoder.encode("admin123"));
                    admin.setRole(Role.ADMIN);
                    userRepository.save(admin);
                    System.out.println("Initial admin user created: admin / admin123");
                }
        );

        // Seed AcademicYear
        com.school.backend.entity.AcademicYear currentYear = academicYearRepository.findByIsCurrentTrue().orElseGet(() -> {
            com.school.backend.entity.AcademicYear ay = new com.school.backend.entity.AcademicYear();
            ay.setName("2026-2027");
            ay.setStartDate(java.time.LocalDate.of(2026, 9, 1));
            ay.setEndDate(java.time.LocalDate.of(2027, 6, 30));
            ay.setIsCurrent(true);
            ay.setStatus("ACTIVE");
            return academicYearRepository.save(ay);
        });

        // Seed Subjects
        com.school.backend.entity.Subject math = subjectRepository.findByName("Mathematics").orElseGet(() -> {
            com.school.backend.entity.Subject s = new com.school.backend.entity.Subject();
            s.setName("Mathematics");
            s.setCode("MATH101");
            return subjectRepository.save(s);
        });

        com.school.backend.entity.Subject english = subjectRepository.findByName("English").orElseGet(() -> {
            com.school.backend.entity.Subject s = new com.school.backend.entity.Subject();
            s.setName("English");
            s.setCode("ENG101");
            return subjectRepository.save(s);
        });

        subjectRepository.findByName("Science").orElseGet(() -> {
            com.school.backend.entity.Subject s = new com.school.backend.entity.Subject();
            s.setName("Science");
            s.setCode("SCI101");
            return subjectRepository.save(s);
        });

        List<SchoolClass> classes = schoolClassRepository.findAll();

        // 1. Teacher T001: Homeroom & Math Teacher of Class 1
        User teacherUser1 = userRepository.findByUsername("T001").orElseGet(() -> {
            User teacher = new User();
            teacher.setUsername("T001");
            teacher.setPassword(passwordEncoder.encode("teacher123"));
            teacher.setRole(Role.TEACHER);
            return userRepository.save(teacher);
        });

        Teacher devTeacher = teacherRepository.findByUserId(teacherUser1.getId()).orElseGet(() -> {
            Teacher t = new Teacher();
            t.setUser(teacherUser1);
            t.setName("Rajesh Sharma");
            t.setEmail("teacher@ashadeep.edu");
            t.setPhone("9876543210");
            t.setQualification("M.Sc Mathematics, B.Ed");
            t.setSubjectSpecialization("Mathematics");
            return teacherRepository.save(t);
        });

        if (!classes.isEmpty()) {
            SchoolClass sc = classes.get(0);
            if (sc.getClassTeacher() == null) {
                sc.setClassTeacher(devTeacher);
            }
            if (sc.getHomeroomTeacher() == null) {
                sc.setHomeroomTeacher(devTeacher);
            }
            schoolClassRepository.save(sc);

            if (teachingAssignmentRepository.findByTeacherIdAndSchoolClassIdAndAcademicYearIsCurrentTrue(devTeacher.getId(), sc.getId()).isEmpty()) {
                com.school.backend.entity.TeachingAssignment ta = new com.school.backend.entity.TeachingAssignment();
                ta.setTeacher(devTeacher);
                ta.setSchoolClass(sc);
                ta.setSubject(math);
                ta.setAcademicYear(currentYear);
                ta.setAssignmentType("HOMEROOM_AND_SUBJECT");
                teachingAssignmentRepository.save(ta);
            }
        }
        System.out.println("Teacher profile T001 created & linked as Homeroom Teacher");

        // 2. Teacher T002: English Subject Teacher of Class 1 (NOT Homeroom)
        User teacherUser2 = userRepository.findByUsername("T002").orElseGet(() -> {
            User teacher = new User();
            teacher.setUsername("T002");
            teacher.setPassword(passwordEncoder.encode("teacher123"));
            teacher.setRole(Role.TEACHER);
            return userRepository.save(teacher);
        });

        Teacher teacher2 = teacherRepository.findByUserId(teacherUser2.getId()).orElseGet(() -> {
            Teacher t = new Teacher();
            t.setUser(teacherUser2);
            t.setName("Priya Singh");
            t.setEmail("priya@ashadeep.edu");
            t.setPhone("9876543211");
            t.setQualification("M.A English, B.Ed");
            t.setSubjectSpecialization("English");
            return teacherRepository.save(t);
        });

        if (!classes.isEmpty()) {
            SchoolClass sc = classes.get(0);
            if (teachingAssignmentRepository.findByTeacherIdAndSchoolClassIdAndAcademicYearIsCurrentTrue(teacher2.getId(), sc.getId()).isEmpty()) {
                com.school.backend.entity.TeachingAssignment ta = new com.school.backend.entity.TeachingAssignment();
                ta.setTeacher(teacher2);
                ta.setSchoolClass(sc);
                ta.setSubject(english);
                ta.setAcademicYear(currentYear);
                ta.setAssignmentType("SUBJECT_TEACHER");
                teachingAssignmentRepository.save(ta);
            }
        }
        System.out.println("Teacher profile T002 created & linked as Subject Teacher");

        // 3. Teacher T003: Stranger Teacher (No assignment to Class 1)
        User teacherUser3 = userRepository.findByUsername("T003").orElseGet(() -> {
            User teacher = new User();
            teacher.setUsername("T003");
            teacher.setPassword(passwordEncoder.encode("teacher123"));
            teacher.setRole(Role.TEACHER);
            return userRepository.save(teacher);
        });

        teacherRepository.findByUserId(teacherUser3.getId()).orElseGet(() -> {
            Teacher t = new Teacher();
            t.setUser(teacherUser3);
            t.setName("Amit Patel");
            t.setEmail("amit@ashadeep.edu");
            t.setPhone("9876543212");
            t.setQualification("M.Sc Physics, B.Ed");
            t.setSubjectSpecialization("Science");
            return teacherRepository.save(t);
        });
        System.out.println("Teacher profile T003 created as unassigned teacher");

        // Demo parent creation removed - use Excel import or admin dashboard to add parents

        // Always ensure developer's test number is available for parent login testing
        String developerPhone = "9910157611";
        if (parentRepository.findByPhone(developerPhone).isEmpty()) {
            User devParentUser = new User();
            devParentUser.setUsername(developerPhone);
            devParentUser.setPassword(passwordEncoder.encode("123456"));
            devParentUser.setRole(Role.PARENT);
            devParentUser = userRepository.save(devParentUser);

            Parent devParent = new Parent();
            devParent.setUser(devParentUser);
            devParent.setName("Developer (Test)");
            devParent.setPhone(developerPhone);
            devParent.setEmail("developer@ashadeep.edu");
            devParent.setAddress("Developer Testing Account");
            parentRepository.save(devParent);
            System.out.println("Developer test parent created: Phone " + developerPhone);
        } else {
            System.out.println("Developer test parent already exists: Phone " + developerPhone);
        }

        Parent devParent = parentRepository.findByPhone(developerPhone).orElse(null);

        // Seed 3 lớp học chuẩn cho 3 cấp học nếu chưa có
        SchoolClass class1A = schoolClassRepository.findByGradeAndSection("1", "A").orElseGet(() -> {
            SchoolClass sc = new SchoolClass();
            sc.setGrade("1");
            sc.setSection("A");
            sc.setHomeroomTeacher(devTeacher);
            sc.setClassTeacher(devTeacher);
            return schoolClassRepository.save(sc);
        });

        SchoolClass class6A = schoolClassRepository.findByGradeAndSection("6", "A").orElseGet(() -> {
            SchoolClass sc = new SchoolClass();
            sc.setGrade("6");
            sc.setSection("A");
            sc.setHomeroomTeacher(teacher2);
            sc.setClassTeacher(teacher2);
            return schoolClassRepository.save(sc);
        });

        SchoolClass class10A = schoolClassRepository.findByGradeAndSection("10", "A").orElseGet(() -> {
            SchoolClass sc = new SchoolClass();
            sc.setGrade("10");
            sc.setSection("A");
            sc.setHomeroomTeacher(devTeacher);
            sc.setClassTeacher(devTeacher);
            return schoolClassRepository.save(sc);
        });

        // 1. Học sinh Cấp 1 (Tiểu học - Lớp 1A)
        User studentUser1 = userRepository.findByUsername("student01").orElseGet(() -> {
            User u = new User();
            u.setUsername("student01");
            u.setPassword(passwordEncoder.encode("student123"));
            u.setRole(Role.STUDENT);
            u.setMustChangePassword(false);
            return userRepository.save(u);
        });
        Student student1 = studentRepository.findByAdmissionNumber("STU001")
                .or(() -> studentRepository.findByUserId(studentUser1.getId()))
                .orElseGet(() -> {
                    Student s = new Student();
                    s.setUser(studentUser1);
                    s.setAdmissionNumber("STU001");
                    s.setName("Nguyễn Minh Anh");
                    s.setRollNo("01");
                    s.setGender("Female");
                    s.setDob(LocalDate.of(2019, 5, 12));
                    s.setSchoolClass(class1A);
                    s.setParent(devParent);
                    return studentRepository.save(s);
                });
        student1.setUser(studentUser1);
        student1.setSchoolClass(class1A);
        student1.setParent(devParent);
        studentRepository.save(student1);
        syncStudentRelations(student1, class1A, currentYear, devParent);

        // 2. Học sinh Cấp 2 (THCS - Lớp 6A)
        User studentUser2 = userRepository.findByUsername("student02").orElseGet(() -> {
            User u = new User();
            u.setUsername("student02");
            u.setPassword(passwordEncoder.encode("student123"));
            u.setRole(Role.STUDENT);
            u.setMustChangePassword(false);
            return userRepository.save(u);
        });
        Student student2 = studentRepository.findByAdmissionNumber("STU002")
                .or(() -> studentRepository.findByUserId(studentUser2.getId()))
                .orElseGet(() -> {
                    Student s = new Student();
                    s.setUser(studentUser2);
                    s.setAdmissionNumber("STU002");
                    s.setName("Trần Bảo Nam");
                    s.setRollNo("02");
                    s.setGender("Male");
                    s.setDob(LocalDate.of(2014, 8, 20));
                    s.setSchoolClass(class6A);
                    s.setParent(devParent);
                    return studentRepository.save(s);
                });
        student2.setUser(studentUser2);
        student2.setSchoolClass(class6A);
        student2.setParent(devParent);
        studentRepository.save(student2);
        syncStudentRelations(student2, class6A, currentYear, devParent);

        // 3. Học sinh Cấp 3 (THPT - Lớp 10A)
        User studentUser3 = userRepository.findByUsername("student03").orElseGet(() -> {
            User u = new User();
            u.setUsername("student03");
            u.setPassword(passwordEncoder.encode("student123"));
            u.setRole(Role.STUDENT);
            u.setMustChangePassword(false);
            return userRepository.save(u);
        });
        Student student3 = studentRepository.findByAdmissionNumber("STU003")
                .or(() -> studentRepository.findByUserId(studentUser3.getId()))
                .orElseGet(() -> {
                    Student s = new Student();
                    s.setUser(studentUser3);
                    s.setAdmissionNumber("STU003");
                    s.setName("Lê Hoàng Long");
                    s.setRollNo("03");
                    s.setGender("Male");
                    s.setDob(LocalDate.of(2010, 10, 15));
                    s.setSchoolClass(class10A);
                    s.setParent(devParent);
                    return studentRepository.save(s);
                });
        student3.setUser(studentUser3);
        student3.setSchoolClass(class10A);
        student3.setParent(devParent);
        studentRepository.save(student3);
        syncStudentRelations(student3, class10A, currentYear, devParent);

        System.out.println("Seeded standard students for all 3 levels: student01 (1A), student02 (6A), student03 (10A)");

        // Seed sample marks cho student02 (THCS) và student03 (THPT)
        seedSubjectMarks(student2, math, currentYear, 1, new double[]{8.5, 9.0}, 8.0, 8.5);
        seedSubjectMarks(student2, english, currentYear, 1, new double[]{8.0, 8.5}, 8.5, 9.0);
        seedSubjectMarks(student3, math, currentYear, 1, new double[]{9.0, 9.5}, 9.0, 9.5);
        seedSubjectMarks(student3, english, currentYear, 1, new double[]{8.5, 9.0}, 8.5, 9.0);


        // 4. Seed textbook SGK Toán 1 - Tập 1 (118 pages) if not already exists
        if (materialRepository.findAll().stream().noneMatch(m -> "Sách giáo khoa Toán 1 - Tập 1".equals(m.getTitle()))) {
            com.school.backend.entity.Subject mathSubject = subjectRepository.findByName("Toán").orElseGet(() -> {
                com.school.backend.entity.Subject s = new com.school.backend.entity.Subject();
                s.setName("Toán");
                return subjectRepository.save(s);
            });

            Teacher author = teacherRepository.findAll().stream().findFirst().orElse(null);

            if (author != null) {
                com.school.backend.entity.Material book = new com.school.backend.entity.Material();
                book.setTitle("Sách giáo khoa Toán 1 - Tập 1");
                book.setDescription("Sách giáo khoa Toán 1 Bộ Kết nối tri thức với cuộc sống. Bản số hóa tương tác có lật trang trực tiếp.");
                book.setSubject(mathSubject);
                book.setCreatedByTeacher(author);
                book.setStatus("PUBLISHED");
                book = materialRepository.save(book);

                com.school.backend.entity.MaterialFile mf = new com.school.backend.entity.MaterialFile();
                mf.setMaterial(book);
                mf.setFileName("SGK_Toan_1_Tap_1.pdf");
                mf.setFileUrl("uploads/materials/SGK_Toan_1_Tap_1.pdf");
                mf.setPageCount(118);
                mf.setVersion(1);
                materialFileRepository.save(mf);

                for (SchoolClass sc : schoolClassRepository.findAll()) {
                    com.school.backend.entity.MaterialClass mc = new com.school.backend.entity.MaterialClass();
                    mc.setMaterial(book);
                    mc.setSchoolClass(sc);
                    materialClassRepository.save(mc);
                }
                System.out.println("Seeded textbook: Sách giáo khoa Toán 1 - Tập 1 (118 pages)");
            }
        }

        // 9. Seed Bài tập tự động (Homework & HomeworkAssignment) phục vụ tính năng nộp bài
        if (homeworkRepository.count() == 0) {
            Teacher teacher = teacherRepository.findAll().stream().findFirst().orElse(null);
            com.school.backend.entity.Subject hwSubject = subjectRepository.findByName("Toán").orElse(null);

            if (teacher != null && hwSubject != null) {
                com.school.backend.entity.Homework hw = new com.school.backend.entity.Homework();
                hw.setTitle("Bài tập tuần 5 - Phép nhân");
                hw.setDescription("Bài tập trắc nghiệm và tự luận ôn tập bảng nhân trong phạm vi 100.");
                hw.setSubject(hwSubject);
                hw.setCreatedByTeacher(teacher);
                hw.setTotalPoints(10.0);
                hw = homeworkRepository.save(hw);

                // Câu 1: SINGLE_CHOICE (2.5 điểm)
                com.school.backend.entity.Question q1 = new com.school.backend.entity.Question();
                q1.setHomework(hw);
                q1.setQuestionOrder(1);
                q1.setQuestionType("SINGLE_CHOICE");
                q1.setContent("Kết quả của phép tính 7 x 8 là bao nhiêu?");
                q1.setPoints(2.5);
                q1 = questionRepository.save(q1);

                com.school.backend.entity.QuestionOption opt1 = new com.school.backend.entity.QuestionOption();
                opt1.setQuestion(q1);
                opt1.setOptionOrder(1);
                opt1.setContent("54");
                opt1.setIsCorrect(false);
                questionOptionRepository.save(opt1);

                com.school.backend.entity.QuestionOption opt2 = new com.school.backend.entity.QuestionOption();
                opt2.setQuestion(q1);
                opt2.setOptionOrder(2);
                opt2.setContent("56");
                opt2.setIsCorrect(true);
                questionOptionRepository.save(opt2);

                com.school.backend.entity.QuestionOption opt3 = new com.school.backend.entity.QuestionOption();
                opt3.setQuestion(q1);
                opt3.setOptionOrder(3);
                opt3.setContent("64");
                opt3.setIsCorrect(false);
                questionOptionRepository.save(opt3);

                com.school.backend.entity.QuestionOption opt4 = new com.school.backend.entity.QuestionOption();
                opt4.setQuestion(q1);
                opt4.setOptionOrder(4);
                opt4.setContent("48");
                opt4.setIsCorrect(false);
                questionOptionRepository.save(opt4);

                // Câu 2: MULTIPLE_CHOICE (2.5 điểm)
                com.school.backend.entity.Question q2 = new com.school.backend.entity.Question();
                q2.setHomework(hw);
                q2.setQuestionOrder(2);
                q2.setQuestionType("MULTIPLE_CHOICE");
                q2.setContent("Chọn các phép tính có kết quả bằng 36:");
                q2.setPoints(2.5);
                q2 = questionRepository.save(q2);

                com.school.backend.entity.QuestionOption opt2_1 = new com.school.backend.entity.QuestionOption();
                opt2_1.setQuestion(q2);
                opt2_1.setOptionOrder(1);
                opt2_1.setContent("6 x 6");
                opt2_1.setIsCorrect(true);
                questionOptionRepository.save(opt2_1);

                com.school.backend.entity.QuestionOption opt2_2 = new com.school.backend.entity.QuestionOption();
                opt2_2.setQuestion(q2);
                opt2_2.setOptionOrder(2);
                opt2_2.setContent("4 x 9");
                opt2_2.setIsCorrect(true);
                questionOptionRepository.save(opt2_2);

                com.school.backend.entity.QuestionOption opt2_3 = new com.school.backend.entity.QuestionOption();
                opt2_3.setQuestion(q2);
                opt2_3.setOptionOrder(3);
                opt2_3.setContent("5 x 7");
                opt2_3.setIsCorrect(false);
                questionOptionRepository.save(opt2_3);

                // Câu 3: TRUE_FALSE (2.0 điểm)
                com.school.backend.entity.Question q3 = new com.school.backend.entity.Question();
                q3.setHomework(hw);
                q3.setQuestionOrder(3);
                q3.setQuestionType("TRUE_FALSE");
                q3.setContent("Phép tính 9 x 0 có kết quả bằng 9 đúng hay sai?");
                q3.setPoints(2.0);
                q3 = questionRepository.save(q3);

                com.school.backend.entity.QuestionOption opt3_1 = new com.school.backend.entity.QuestionOption();
                opt3_1.setQuestion(q3);
                opt3_1.setOptionOrder(1);
                opt3_1.setContent("Đúng");
                opt3_1.setIsCorrect(false);
                questionOptionRepository.save(opt3_1);

                com.school.backend.entity.QuestionOption opt3_2 = new com.school.backend.entity.QuestionOption();
                opt3_2.setQuestion(q3);
                opt3_2.setOptionOrder(2);
                opt3_2.setContent("Sai");
                opt3_2.setIsCorrect(true);
                questionOptionRepository.save(opt3_2);

                // Câu 4: ESSAY (3.0 điểm)
                com.school.backend.entity.Question q4 = new com.school.backend.entity.Question();
                q4.setHomework(hw);
                q4.setQuestionOrder(4);
                q4.setQuestionType("ESSAY");
                q4.setContent("Một cửa hàng có 5 bao gạo, mỗi bao cân nặng 12kg. Hỏi cửa hàng có tất cả bao nhiêu ki-lô-gam gạo? Hãy trình bày lời giải của em.");
                q4.setPoints(3.0);
                questionRepository.save(q4);

                // Giao bài tập cho tất cả các lớp học
                for (SchoolClass sc : schoolClassRepository.findAll()) {
                    com.school.backend.entity.HomeworkAssignment ha = new com.school.backend.entity.HomeworkAssignment();
                    ha.setHomework(hw);
                    ha.setSchoolClass(sc);
                    ha.setAssignedByTeacher(teacher);
                    ha.setDueDate(java.time.LocalDateTime.now().plusDays(7));
                    ha.setAllowLateSubmission(true);
                    homeworkAssignmentRepository.save(ha);
                }
                System.out.println("Seeded homework: Bài tập tuần 5 - Phép nhân");
            }
        }

        // Seed Notifications mẫu nếu chưa có
        if (notificationRepository.count() == 0) {
            com.school.backend.entity.User adminUser = userRepository.findByUsername("admin").orElse(null);

            com.school.backend.entity.Notification n1 = com.school.backend.entity.Notification.builder()
                    .title("Họp phụ huynh đầu năm học 2026-2027")
                    .body("Kính mời quý phụ huynh học sinh tham dự buổi họp phụ huynh đầu năm tại phòng học lớp 3A vào lúc 08:00 sáng Chủ nhật ngày 25/10/2026.")
                    .audienceType(com.school.backend.enums.AudienceType.ALL)
                    .notificationType(com.school.backend.enums.NotificationType.ANNOUNCEMENT)
                    .sender(adminUser)
                    .senderName("Ban Giám Hiệu")
                    .build();
            notificationRepository.save(n1);

            com.school.backend.entity.Notification n2 = com.school.backend.entity.Notification.builder()
                    .title("Đổi giờ ra về chiều nay do ngoại khóa")
                    .body("Chiều nay khối 3 tham gia hoạt động kỹ năng sống tại sân trường. Giờ tan học sẽ điều chỉnh về 16:45. Kính mong phụ huynh lưu ý đón con đúng giờ.")
                    .audienceType(com.school.backend.enums.AudienceType.GRADE)
                    .targetId("3")
                    .notificationType(com.school.backend.enums.NotificationType.ANNOUNCEMENT)
                    .sender(adminUser)
                    .senderName("Cô Lê Thu Hà (GVCN)")
                    .build();
            notificationRepository.save(n2);

            com.school.backend.entity.Notification n3 = com.school.backend.entity.Notification.builder()
                    .title("Lịch khám sức khỏe định kỳ học sinh")
                    .body("Trạm y tế học đường sẽ tổ chức khám sức khỏe tổng quát (mắt, răng hàm mặt, chiều cao, cân nặng) cho học sinh lớp 3A vào thứ Tư tuần sau.")
                    .audienceType(com.school.backend.enums.AudienceType.CLASS)
                    .targetId("3A")
                    .notificationType(com.school.backend.enums.NotificationType.ANNOUNCEMENT)
                    .sender(adminUser)
                    .senderName("Y tế Học đường")
                    .build();
            notificationRepository.save(n3);

            com.school.backend.entity.Notification n4 = com.school.backend.entity.Notification.builder()
                    .title("Phát động phong trào thi đua chào mừng 20/11")
                    .body("Đoàn Đội trường Tiểu học & THCS Đại Việt phát động phong trào Hoa điểm 10 và Hội thi văn nghệ chào mừng Ngày Nhà giáo Việt Nam 20/11.")
                    .audienceType(com.school.backend.enums.AudienceType.ALL)
                    .notificationType(com.school.backend.enums.NotificationType.ANNOUNCEMENT)
                    .sender(adminUser)
                    .senderName("Đoàn Đội Trường")
                    .build();
            notificationRepository.save(n4);

            System.out.println("Seeded 4 sample notifications (ALL, GRADE, CLASS).");
        }
    }

    private void syncStudentRelations(Student student, SchoolClass sc, com.school.backend.entity.AcademicYear ay, Parent parent) {
        if (student == null || student.getId() == null) return;
        if (ay != null && sc != null && enrollmentRepository.findByStudentIdAndAcademicYearId(student.getId(), ay.getId()).isEmpty()) {
            Enrollment e = new Enrollment();
            e.setStudent(student);
            e.setSchoolClass(sc);
            e.setAcademicYear(ay);
            e.setEnrollmentDate(LocalDate.now());
            e.setStatus("ENROLLED");
            enrollmentRepository.save(e);
        }
        if (parent != null && guardianStudentRepository.findByGuardianIdAndStudentId(parent.getId(), student.getId()).isEmpty()) {
            GuardianStudent gs = new GuardianStudent();
            gs.setGuardian(parent);
            gs.setStudent(student);
            gs.setIsPrimary(true);
            gs.setRelationship("PARENT");
            guardianStudentRepository.save(gs);
        }
    }

    private void seedSubjectMarks(Student student, com.school.backend.entity.Subject subject,
                                  com.school.backend.entity.AcademicYear year, int semester,
                                  double[] txScores, double gkScore, double ckScore) {
        if (student == null || student.getId() == null || subject == null || year == null) return;
        for (int i = 0; i < txScores.length; i++) {
            int txIdx = i + 1;
            if (marksRepository.findByStudentIdAndSubjectIdAndSemesterAndAcademicYearIdAndExamTypeAndTxIndex(
                    student.getId(), subject.getId(), semester, year.getId(), ExamType.THUONG_XUYEN, txIdx).isEmpty()) {
                Marks m = new Marks();
                m.setStudent(student);
                m.setSubject(subject);
                m.setAcademicYear(year);
                m.setSemester(semester);
                m.setExamType(ExamType.THUONG_XUYEN);
                m.setTxIndex(txIdx);
                m.setScore(BigDecimal.valueOf(txScores[i]));
                m.setMaxScore(BigDecimal.valueOf(10.0));
                marksRepository.save(m);
            }
        }
        if (marksRepository.findByStudentIdAndSubjectIdAndSemesterAndAcademicYearIdAndExamTypeAndTxIndex(
                student.getId(), subject.getId(), semester, year.getId(), ExamType.GIUA_KY, null).isEmpty()) {
            Marks m = new Marks();
            m.setStudent(student);
            m.setSubject(subject);
            m.setAcademicYear(year);
            m.setSemester(semester);
            m.setExamType(ExamType.GIUA_KY);
            m.setScore(BigDecimal.valueOf(gkScore));
            m.setMaxScore(BigDecimal.valueOf(10.0));
            marksRepository.save(m);
        }
        if (marksRepository.findByStudentIdAndSubjectIdAndSemesterAndAcademicYearIdAndExamTypeAndTxIndex(
                student.getId(), subject.getId(), semester, year.getId(), ExamType.CUOI_KY, null).isEmpty()) {
            Marks m = new Marks();
            m.setStudent(student);
            m.setSubject(subject);
            m.setAcademicYear(year);
            m.setSemester(semester);
            m.setExamType(ExamType.CUOI_KY);
            m.setScore(BigDecimal.valueOf(ckScore));
            m.setMaxScore(BigDecimal.valueOf(10.0));
            marksRepository.save(m);
        }
    }
}
