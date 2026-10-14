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

    @Override
    public void run(String... args) throws Exception {
        // Excel import on startup is disabled. Use the Admin Dashboard > Bulk Import feature instead.
        if (studentRepository.count() == 0) {
            System.out.println("No students found. Please use the Admin Dashboard > Bulk Import to load student data.");
        } else {
            System.out.println(
                    "Students already exist in database (" + studentRepository.count() + "). Skipping import.");
        }
        // Create or Update Admin to ensure password is known
        User admin = userRepository.findByUsername("admin").orElse(new User());
        admin.setUsername("admin");
        admin.setPassword(passwordEncoder.encode("admin123"));
        admin.setRole(Role.ADMIN);
        userRepository.save(admin);
        System.out.println("Admin user updated/created: admin / admin123");

        // Create Teacher
        User teacherUser = userRepository.findByUsername("T001").orElseGet(() -> {
            User teacher = new User();
            teacher.setUsername("T001");
            teacher.setPassword(passwordEncoder.encode("teacher123"));
            teacher.setRole(Role.TEACHER);
            return userRepository.save(teacher);
        });

        if (teacherRepository.findByUserId(teacherUser.getId()).isEmpty()) {
            Teacher devTeacher = new Teacher();
            devTeacher.setUser(teacherUser);
            devTeacher.setName("Rajesh Sharma");
            devTeacher.setEmail("teacher@ashadeep.edu");
            devTeacher.setPhone("9876543210");
            devTeacher.setQualification("M.Sc Mathematics, B.Ed");
            devTeacher.setSubjectSpecialization("Mathematics");
            devTeacher = teacherRepository.save(devTeacher);

            List<SchoolClass> classes = schoolClassRepository.findAll();
            if (!classes.isEmpty() && classes.get(0).getClassTeacher() == null) {
                SchoolClass sc = classes.get(0);
                sc.setClassTeacher(devTeacher);
                schoolClassRepository.save(sc);
            }
            System.out.println("Teacher profile created & linked: T001 (Rajesh Sharma)");
        }

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
    }
}
