package com.school.backend.controller;

import com.school.backend.entity.Material;
import com.school.backend.payload.request.MaterialCreateRequest;
import com.school.backend.service.MaterialService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api")
public class MaterialController {

    @Autowired
    private MaterialService materialService;

    @PostMapping("/teacher/materials")
    @PreAuthorize("hasAuthority('TEACHER') or hasAuthority('ADMIN')")
    public ResponseEntity<Material> createMaterial(@RequestBody MaterialCreateRequest req) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(materialService.createMaterial(req, auth.getName()));
    }

    @GetMapping("/teacher/materials")
    @PreAuthorize("hasAuthority('TEACHER') or hasAuthority('ADMIN')")
    public ResponseEntity<List<Material>> getMyMaterials() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(materialService.getMyMaterials(auth.getName()));
    }

    @GetMapping("/student-portal/materials")
    @PreAuthorize("hasAuthority('STUDENT')")
    public ResponseEntity<List<Map<String, Object>>> getMaterialsForStudent() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(materialService.getMaterialsForStudent(auth.getName()));
    }

    @GetMapping("/materials/files/{fileId}/download")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('STUDENT') or hasAuthority('PARENT')")
    public ResponseEntity<?> downloadMaterialFile(@PathVariable Long fileId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return materialService.downloadFile(fileId, auth);
    }
}
