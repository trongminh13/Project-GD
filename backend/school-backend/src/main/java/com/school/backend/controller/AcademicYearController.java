package com.school.backend.controller;

import com.school.backend.entity.AcademicYear;
import com.school.backend.repository.AcademicYearRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/academic-years")
public class AcademicYearController {

    @Autowired
    private AcademicYearRepository academicYearRepository;

    @GetMapping
    public ResponseEntity<List<AcademicYear>> getAll() {
        return ResponseEntity.ok(academicYearRepository.findAll());
    }

    @GetMapping("/current")
    public ResponseEntity<AcademicYear> getCurrent() {
        return academicYearRepository.findByIsCurrentTrue()
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<AcademicYear> create(@RequestBody AcademicYear academicYear) {
        if (Boolean.TRUE.equals(academicYear.getIsCurrent())) {
            academicYearRepository.findByIsCurrentTrue().ifPresent(curr -> {
                curr.setIsCurrent(false);
                academicYearRepository.save(curr);
            });
        }
        return ResponseEntity.ok(academicYearRepository.save(academicYear));
    }

    @PutMapping("/{id}/set-current")
    @PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<?> setCurrent(@PathVariable Long id) {
        return academicYearRepository.findById(id).map(target -> {
            academicYearRepository.findAll().forEach(ay -> {
                if (ay.getId().equals(id)) {
                    ay.setIsCurrent(true);
                } else if (Boolean.TRUE.equals(ay.getIsCurrent())) {
                    ay.setIsCurrent(false);
                }
                academicYearRepository.save(ay);
            });
            return ResponseEntity.ok(target);
        }).orElse(ResponseEntity.notFound().build());
    }
}
