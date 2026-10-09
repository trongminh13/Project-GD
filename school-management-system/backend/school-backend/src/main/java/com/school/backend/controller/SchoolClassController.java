package com.school.backend.controller;

import com.school.backend.entity.SchoolClass;
import com.school.backend.repository.SchoolClassRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.TimeUnit;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/classes")
public class SchoolClassController {

    @Autowired
    private SchoolClassRepository schoolClassRepository;

    @GetMapping
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT')")
    public ResponseEntity<List<SchoolClass>> getAllClasses() {
        List<SchoolClass> classes = schoolClassRepository.findAll();
        return ResponseEntity.ok()
                .cacheControl(CacheControl.maxAge(1, TimeUnit.HOURS).cachePublic())
                .body(classes);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT')")
    public ResponseEntity<SchoolClass> getClassById(@PathVariable Long id) {
        return schoolClassRepository.findById(id)
                .map(c -> ResponseEntity.ok()
                        .cacheControl(CacheControl.maxAge(1, TimeUnit.HOURS).cachePublic())
                        .body(c))
                .orElse(ResponseEntity.notFound().build());
    }
}
