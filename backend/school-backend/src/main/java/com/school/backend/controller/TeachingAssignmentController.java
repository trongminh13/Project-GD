package com.school.backend.controller;

import com.school.backend.entity.TeachingAssignment;
import com.school.backend.repository.TeachingAssignmentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/teaching-assignments")
public class TeachingAssignmentController {

    @Autowired
    private TeachingAssignmentRepository teachingAssignmentRepository;

    @GetMapping("/teacher/{teacherId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER')")
    public ResponseEntity<List<TeachingAssignment>> getByTeacher(@PathVariable Long teacherId) {
        return ResponseEntity.ok(teachingAssignmentRepository.findByTeacherIdAndAcademicYearIsCurrentTrue(teacherId));
    }

    @GetMapping("/class/{classId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER')")
    public ResponseEntity<List<TeachingAssignment>> getByClass(@PathVariable Long classId) {
        return ResponseEntity.ok(teachingAssignmentRepository.findBySchoolClassIdAndAcademicYearIsCurrentTrue(classId));
    }
}
