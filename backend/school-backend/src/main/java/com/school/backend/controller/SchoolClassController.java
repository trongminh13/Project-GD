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

    @PostMapping
    @PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<SchoolClass> createClass(@RequestBody SchoolClass schoolClass) {
        if (schoolClass.getSection() == null || schoolClass.getSection().isBlank()) {
            schoolClass.setSection("A");
        }
        SchoolClass saved = schoolClassRepository.save(schoolClass);
        return ResponseEntity.ok(saved);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<SchoolClass> updateClass(@PathVariable Long id, @RequestBody SchoolClass updated) {
        return schoolClassRepository.findById(id)
                .map(existing -> {
                    if (updated.getGrade() != null) existing.setGrade(updated.getGrade());
                    if (updated.getSection() != null) existing.setSection(updated.getSection());
                    if (updated.getClassTeacher() != null) existing.setClassTeacher(updated.getClassTeacher());
                    return ResponseEntity.ok(schoolClassRepository.save(existing));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<Void> deleteClass(@PathVariable Long id) {
        if (schoolClassRepository.existsById(id)) {
            schoolClassRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
