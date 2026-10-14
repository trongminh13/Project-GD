package com.school.backend.controller;

import com.school.backend.entity.Marks;
import com.school.backend.payload.request.BulkMarksRequest;
import com.school.backend.payload.response.StudentMarkResponse;
import com.school.backend.service.MarksService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/marks")
public class MarksController {

    @Autowired
    private MarksService marksService;

    @PostMapping("/bulk")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER')")
    public ResponseEntity<List<Marks>> uploadClassMarks(@RequestBody BulkMarksRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isTeacher = auth.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("TEACHER"));
        List<Marks> savedMarks = marksService.saveBulkMarks(request, auth.getName(), isTeacher);
        return ResponseEntity.ok(savedMarks);
    }

    @GetMapping("/student/{studentId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT')")
    public ResponseEntity<List<StudentMarkResponse>> getStudentMarks(@PathVariable Long studentId) {
        return handleGetMarks(studentId);
    }

    @GetMapping("/{studentId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT')")
    public ResponseEntity<List<StudentMarkResponse>> getStudentMarksAlias(@PathVariable Long studentId) {
        return handleGetMarks(studentId);
    }

    private ResponseEntity<List<StudentMarkResponse>> handleGetMarks(Long studentId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isParent = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("PARENT"));
        boolean isTeacher = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("TEACHER"));
        List<StudentMarkResponse> marks = marksService.getMarksByStudentId(studentId, auth.getName(), isParent, isTeacher);
        return ResponseEntity.ok(marks);
    }
}
