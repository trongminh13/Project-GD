package com.school.backend.controller;

import com.school.backend.service.ParentHomeworkService;
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
@RequestMapping("/api/parent/wards")
public class ParentHomeworkController {

    @Autowired
    private ParentHomeworkService parentHomeworkService;

    @GetMapping("/{studentId}/homework")
    @PreAuthorize("hasAuthority('PARENT') or hasAuthority('ADMIN')")
    public ResponseEntity<List<Map<String, Object>>> getWardHomework(@PathVariable Long studentId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(parentHomeworkService.getWardHomework(studentId, auth.getName()));
    }
}
