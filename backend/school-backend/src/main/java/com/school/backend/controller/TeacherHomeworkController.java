package com.school.backend.controller;

import com.school.backend.entity.Homework;
import com.school.backend.entity.HomeworkAssignment;
import com.school.backend.entity.Submission;
import com.school.backend.payload.request.GradeSubmissionRequest;
import com.school.backend.payload.request.HomeworkAssignRequest;
import com.school.backend.payload.request.HomeworkCreateRequest;
import com.school.backend.service.HomeworkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/teacher/homework")
public class TeacherHomeworkController {

    @Autowired
    private HomeworkService homeworkService;

    @PostMapping
    @PreAuthorize("hasAuthority('TEACHER') or hasAuthority('ADMIN')")
    public ResponseEntity<Homework> createHomework(@RequestBody HomeworkCreateRequest req) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(homeworkService.createHomework(req, auth.getName()));
    }

    @GetMapping
    @PreAuthorize("hasAuthority('TEACHER') or hasAuthority('ADMIN')")
    public ResponseEntity<List<Homework>> getMyCreatedHomework() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(homeworkService.getMyCreatedHomework(auth.getName()));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('TEACHER') or hasAuthority('ADMIN')")
    public ResponseEntity<Homework> getHomeworkDetails(@PathVariable Long id) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(homeworkService.getHomeworkDetails(id, auth.getName()));
    }

    @PostMapping("/{id}/assign")
    @PreAuthorize("hasAuthority('TEACHER') or hasAuthority('ADMIN')")
    public ResponseEntity<HomeworkAssignment> assignHomework(
            @PathVariable Long id,
            @RequestBody HomeworkAssignRequest req) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(homeworkService.assignHomework(id, req, auth.getName()));
    }

    @GetMapping("/assignments")
    @PreAuthorize("hasAuthority('TEACHER') or hasAuthority('ADMIN')")
    public ResponseEntity<List<HomeworkAssignment>> getTeacherAssignments() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(homeworkService.getTeacherAssignments(auth.getName()));
    }

    @GetMapping("/assignments/{assignmentId}/submissions")
    @PreAuthorize("hasAuthority('TEACHER') or hasAuthority('ADMIN')")
    public ResponseEntity<List<Submission>> getSubmissionsForAssignment(@PathVariable Long assignmentId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(homeworkService.getSubmissionsForAssignment(assignmentId, auth.getName()));
    }

    @GetMapping("/submissions/{submissionId}")
    @PreAuthorize("hasAuthority('TEACHER') or hasAuthority('ADMIN')")
    public ResponseEntity<Submission> getSubmissionDetails(@PathVariable Long submissionId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(homeworkService.getSubmissionDetails(submissionId, auth.getName()));
    }

    @PutMapping("/submissions/{submissionId}/grade")
    @PreAuthorize("hasAuthority('TEACHER') or hasAuthority('ADMIN')")
    public ResponseEntity<Submission> gradeSubmission(
            @PathVariable Long submissionId,
            @RequestBody GradeSubmissionRequest req) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(homeworkService.gradeSubmission(submissionId, req, auth.getName()));
    }
}
