package com.school.backend.service;

import com.school.backend.entity.Attendance;
import com.school.backend.entity.Student;
import com.school.backend.enums.AttendanceStatus;
import com.school.backend.payload.request.BulkAttendanceRequest;
import com.school.backend.repository.AttendanceRepository;
import com.school.backend.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
public class AttendanceService {

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private StudentRepository studentRepository;

    public List<Attendance> getAttendanceByStudent(Long studentId) {
        return attendanceRepository.findByStudentId(studentId);
    }

    public List<Attendance> getAttendanceByStudentSecure(Long studentId, String currentUsername, boolean isParent) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        if (isParent) {
            boolean isOwnChild = student.getParent() != null
                    && student.getParent().getPhone() != null
                    && student.getParent().getPhone().equals(currentUsername);
            if (!isOwnChild) {
                throw new AccessDeniedException("Bạn không có quyền xem điểm danh của học sinh này.");
            }
        }

        return attendanceRepository.findByStudentId(studentId);
    }

    public Attendance markAttendance(Attendance attendance) {
        return attendanceRepository.save(attendance);
    }

    @Transactional
    public List<Attendance> saveBulkAttendance(BulkAttendanceRequest request) {
        if (request == null || request.getRecords() == null || request.getRecords().isEmpty()) {
            return new ArrayList<>();
        }

        LocalDate targetDate = LocalDate.now();
        if (request.getDate() != null && !request.getDate().isBlank()) {
            try {
                String dateStr = request.getDate().trim();
                if (dateStr.length() >= 10) {
                    targetDate = LocalDate.parse(dateStr.substring(0, 10));
                }
            } catch (Exception ignored) {}
        }

        List<Attendance> savedList = new ArrayList<>();
        for (BulkAttendanceRequest.Record rec : request.getRecords()) {
            if (rec.getStudentId() == null) continue;

            Student student = studentRepository.findById(rec.getStudentId()).orElse(null);
            if (student == null) continue;

            AttendanceStatus status = parseStatus(rec.getStatus());

            Attendance attendance = attendanceRepository.findByStudentIdAndDate(student.getId(), targetDate)
                    .orElse(new Attendance());

            attendance.setStudent(student);
            attendance.setDate(targetDate);
            attendance.setStatus(status);

            savedList.add(attendanceRepository.save(attendance));
        }

        return savedList;
    }

    private AttendanceStatus parseStatus(String statusStr) {
        if (statusStr == null || statusStr.isBlank()) {
            return AttendanceStatus.PRESENT;
        }
        String s = statusStr.trim().toUpperCase();
        if (s.contains("ABSENT")) return AttendanceStatus.ABSENT;
        if (s.contains("LATE")) return AttendanceStatus.LATE;
        if (s.contains("LEAVE")) return AttendanceStatus.LEAVE;
        return AttendanceStatus.PRESENT;
    }
}
