package com.school.backend.service;

import com.school.backend.entity.Attendance;
import com.school.backend.repository.AttendanceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class AttendanceService {
    @Autowired
    private AttendanceRepository attendanceRepository;

    public List<Attendance> getAttendanceByStudent(Long studentId) {
        return attendanceRepository.findByStudentId(studentId);
    }

    public Attendance markAttendance(Attendance attendance) {
        return attendanceRepository.save(attendance);
    }
}
