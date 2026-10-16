package com.school.backend.controller;

import com.school.backend.entity.Submission;
import com.school.backend.payload.request.SubmissionSubmitRequest;
import com.school.backend.service.StudentHomeworkService;
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
@RequestMapping("/api/student-portal/homework")
public class StudentHomeworkController {

    @Autowired
    private StudentHomeworkService studentHomeworkService;

    @GetMapping
    @PreAuthorize("hasAuthority('STUDENT')")
    public ResponseEntity<List<Map<String, Object>>> getMyAssignments() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(studentHomeworkService.getMyAssignments(auth.getName()));
    }

    @GetMapping("/{assignmentId}/take")
    @PreAuthorize("hasAuthority('STUDENT')")
    public ResponseEntity<Map<String, Object>> getAssignmentForTaking(@PathVariable Long assignmentId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(studentHomeworkService.getAssignmentForTaking(assignmentId, auth.getName()));
    }

    @PostMapping("/submissions/{submissionId}/draft")
    @PreAuthorize("hasAuthority('STUDENT')")
    public ResponseEntity<Submission> saveDraft(
            @PathVariable Long submissionId,
            @RequestBody SubmissionSubmitRequest req) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(studentHomeworkService.saveDraft(submissionId, req, auth.getName()));
    }

    @PostMapping("/submissions/{submissionId}/submit")
    @PreAuthorize("hasAuthority('STUDENT')")
    public ResponseEntity<Submission> submitHomework(
            @PathVariable Long submissionId,
            @RequestBody SubmissionSubmitRequest req) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(studentHomeworkService.submitHomework(submissionId, req, auth.getName()));
    }
}
