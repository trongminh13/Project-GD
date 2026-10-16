package com.school.backend.controller;

import com.school.backend.service.DataMigrationService;
import com.school.backend.service.StudentService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/admin/migration")
public class AdminMigrationController {

    private final DataMigrationService dataMigrationService;
    private final StudentService studentService;

    public AdminMigrationController(DataMigrationService dataMigrationService, StudentService studentService) {
        this.dataMigrationService = dataMigrationService;
        this.studentService = studentService;
    }

    @GetMapping("/ping")
    @PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<String> ping(jakarta.servlet.http.HttpServletRequest request) {
        return ResponseEntity.ok("pong");
    }

    @GetMapping("/reconciliation")
    @PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<Map<String, Object>> getReconciliationReport() {
        return ResponseEntity.ok(studentService.reconcileCoreFoundationsData());
    }

    @PostMapping("/upload-excel")
    @PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<String> uploadExcelMigration(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("Please upload a valid Excel file.");
        }

        try {
            String result = dataMigrationService.processExcelData(file.getInputStream());
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Error processing file: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error processing file: " + e.getMessage());
        }
    }
}
