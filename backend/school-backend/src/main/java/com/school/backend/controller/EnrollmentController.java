package com.school.backend.controller;

import com.school.backend.entity.Enrollment;
import com.school.backend.repository.EnrollmentRepository;
import com.school.backend.security.SchoolAccessPolicy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/enrollments")
public class EnrollmentController {

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private SchoolAccessPolicy accessPolicy;

    @GetMapping("/student/{studentId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT') or hasAuthority('STUDENT')")
    public ResponseEntity<List<Enrollment>> getByStudent(@PathVariable Long studentId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        accessPolicy.verifyCanAccessStudent(auth, studentId);
        return ResponseEntity.ok(enrollmentRepository.findByStudentId(studentId));
    }

    @GetMapping("/class/{classId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER')")
    public ResponseEntity<List<Enrollment>> getByClass(@PathVariable Long classId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (!accessPolicy.isAdmin(auth)) {
            accessPolicy.verifyTeacherCanAssignClass(auth, classId, null);
        }
        return ResponseEntity.ok(enrollmentRepository.findBySchoolClassIdAndAcademicYearIsCurrentTrue(classId));
    }
}
