package com.school.backend.controller;

import com.school.backend.payload.dto.StudentAttendanceDto;
import com.school.backend.payload.dto.StudentMarkDto;
import com.school.backend.payload.dto.StudentProfileDto;
import com.school.backend.security.services.UserDetailsImpl;
import com.school.backend.service.StudentPortalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/student-portal")
public class StudentPortalController {

    @Autowired
    private StudentPortalService studentPortalService;

    private Long getCurrentUserId() {
        UserDetailsImpl user = (UserDetailsImpl) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        return user.getId();
    }

    @GetMapping("/profile")
    @PreAuthorize("hasAuthority('STUDENT')")
    public ResponseEntity<StudentProfileDto> getMyProfile() {
        return ResponseEntity.ok(studentPortalService.getProfileByUserId(getCurrentUserId()));
    }

    @GetMapping("/attendance")
    @PreAuthorize("hasAuthority('STUDENT')")
    public ResponseEntity<List<StudentAttendanceDto>> getMyAttendance(
            @RequestParam(required = false) Integer month,
            @RequestParam(required = false) Integer year) {
        return ResponseEntity.ok(studentPortalService.getAttendanceByUserId(getCurrentUserId(), month, year));
    }

    @GetMapping("/marks")
    @PreAuthorize("hasAuthority('STUDENT')")
    public ResponseEntity<List<StudentMarkDto>> getMyMarks() {
        return ResponseEntity.ok(studentPortalService.getMarksByUserId(getCurrentUserId()));
    }
}
