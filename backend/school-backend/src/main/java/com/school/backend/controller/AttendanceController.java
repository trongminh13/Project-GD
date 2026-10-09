package com.school.backend.controller;

import com.school.backend.entity.Attendance;
import com.school.backend.service.AttendanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
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
    public List<Attendance> getStudentAttendance(@PathVariable Long studentId) {
        return attendanceService.getAttendanceByStudent(studentId);
    }

    @PostMapping("/mark")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER')")
    public Attendance markAttendance(@RequestBody Attendance attendance) {
        return attendanceService.markAttendance(attendance);
    }
}
