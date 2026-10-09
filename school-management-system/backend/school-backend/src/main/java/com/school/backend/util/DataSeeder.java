package com.school.backend.util;

import com.school.backend.entity.Parent;
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

    @Override
    public void run(String... args) throws Exception {
        // Only run Excel import if no students exist (prevents duplicates on restart)
        if (studentRepository.count() == 0) {
            try {
                java.io.File file = new java.io.File(
                        "d:/misc/Java/Student Management System/St. james Convent School Student details.xlsx");
                if (file.exists()) {
                    System.out.println("Starting direct data migration from known Excel file...");
                    String result = dataMigrationService.processExcelData(new java.io.FileInputStream(file));
                    System.out.println("Migration Result: " + result);
                }
            } catch (Exception e) {
                System.err.println("Migration on startup failed: " + e.getMessage());
            }
        } else {
            System.out.println(
                    "Students already exist in database (" + studentRepository.count() + "). Skipping Excel import.");
        }
        // Create or Update Admin to ensure password is known
        User admin = userRepository.findByUsername("admin").orElse(new User());
        admin.setUsername("admin");
        admin.setPassword(passwordEncoder.encode("admin123"));
        admin.setRole(Role.ADMIN);
        userRepository.save(admin);
        System.out.println("Admin user updated/created: admin / admin123");

        // Create Teacher
        if (userRepository.findByUsername("T001").isEmpty()) {
            User teacher = new User();
            teacher.setUsername("T001");
            teacher.setPassword(passwordEncoder.encode("teacher123"));
            teacher.setRole(Role.TEACHER);
            userRepository.save(teacher);
            System.out.println("Teacher user created: T001 / teacher123");
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
