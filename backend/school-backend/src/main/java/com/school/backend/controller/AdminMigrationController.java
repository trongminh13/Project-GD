package com.school.backend.controller;

import com.school.backend.service.DataMigrationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/admin/migration")
@RequiredArgsConstructor
public class AdminMigrationController {

    private final DataMigrationService dataMigrationService;

    @GetMapping("/ping")
    @PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<String> ping(jakarta.servlet.http.HttpServletRequest request) {
        System.out.println("PING DEBUG - Authorization Header: " + request.getHeader("Authorization"));
        return ResponseEntity.ok("pong");
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
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error processing file: " + e.getMessage());
        }
    }
}
