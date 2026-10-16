package com.school.backend.controller;

import com.school.backend.entity.LeaveRequest;
import com.school.backend.payload.request.LeaveRequestCreateRequest;
import com.school.backend.payload.request.LeaveRequestReviewRequest;
import com.school.backend.service.LeaveRequestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/leave-requests")
public class LeaveRequestController {

    @Autowired
    private LeaveRequestService leaveRequestService;

    @PostMapping
    @PreAuthorize("hasAuthority('PARENT')")
    public ResponseEntity<LeaveRequest> submitLeaveRequest(@RequestBody LeaveRequestCreateRequest req) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        LeaveRequest created = leaveRequestService.submitLeaveRequest(req, auth.getName());
        return ResponseEntity.ok(created);
    }

    @GetMapping("/my-requests")
    @PreAuthorize("hasAuthority('PARENT')")
    public ResponseEntity<List<LeaveRequest>> getMyRequests() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(leaveRequestService.getGuardianLeaveRequests(auth.getName()));
    }

    @GetMapping("/pending")
    @PreAuthorize("hasAuthority('TEACHER')")
    public ResponseEntity<List<LeaveRequest>> getPendingRequestsForTeacher() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return ResponseEntity.ok(leaveRequestService.getPendingRequestsForTeacher(auth.getName()));
    }

    @PutMapping("/{id}/review")
    @PreAuthorize("hasAuthority('TEACHER')")
    public ResponseEntity<LeaveRequest> reviewLeaveRequest(
            @PathVariable Long id,
            @RequestBody LeaveRequestReviewRequest req) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        LeaveRequest reviewed = leaveRequestService.reviewLeaveRequest(id, req, auth.getName());
        return ResponseEntity.ok(reviewed);
    }

    @GetMapping("/student/{studentId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT')")
    public ResponseEntity<List<LeaveRequest>> getStudentRequests(@PathVariable Long studentId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isAdmin = auth.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ADMIN"));
        boolean isTeacher = auth.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("TEACHER"));
        boolean isParent = auth.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("PARENT"));
        return ResponseEntity.ok(leaveRequestService.getStudentLeaveRequests(studentId, auth.getName(), isAdmin, isTeacher, isParent));
    }
}
