package com.school.backend.util;

import com.school.backend.entity.Parent;
import com.school.backend.entity.Teacher;
import com.school.backend.entity.SchoolClass;
import com.school.backend.repository.TeacherRepository;
import com.school.backend.repository.SchoolClassRepository;
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
    }
}
