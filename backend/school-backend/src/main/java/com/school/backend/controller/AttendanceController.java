package com.school.backend.controller;

import com.school.backend.entity.Attendance;
import com.school.backend.payload.request.BulkAttendanceRequest;
import com.school.backend.service.AttendanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/attendance")
public class AttendanceController {

    @Autowired
    private AttendanceService attendanceService;

    @GetMapping("/student/{studentId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('PARENT') or hasAuthority('TEACHER')")
    public ResponseEntity<List<Attendance>> getStudentAttendance(@PathVariable Long studentId) {
        return handleGetAttendance(studentId);
    }

    @GetMapping("/{studentId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('PARENT') or hasAuthority('TEACHER')")
    public ResponseEntity<List<Attendance>> getStudentAttendanceAlias(@PathVariable Long studentId) {
        return handleGetAttendance(studentId);
    }

    @PostMapping("/bulk")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER')")
    public ResponseEntity<List<Attendance>> markBulkAttendance(@RequestBody BulkAttendanceRequest request) {
        List<Attendance> result = attendanceService.saveBulkAttendance(request);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/mark")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER')")
    public Attendance markAttendance(@RequestBody Attendance attendance) {
        return attendanceService.markAttendance(attendance);
    }

    private ResponseEntity<List<Attendance>> handleGetAttendance(Long studentId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isParent = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("PARENT"));
        List<Attendance> list = attendanceService.getAttendanceByStudentSecure(studentId, auth.getName(), isParent);
        return ResponseEntity.ok(list);
    }
}
