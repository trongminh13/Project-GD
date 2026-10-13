package com.school.backend.service;

import com.school.backend.entity.Attendance;
import com.school.backend.entity.Marks;
import com.school.backend.entity.Student;
import com.school.backend.payload.dto.StudentAttendanceDto;
import com.school.backend.payload.dto.StudentMarkDto;
import com.school.backend.payload.dto.StudentProfileDto;
import com.school.backend.repository.AttendanceRepository;
import com.school.backend.repository.MarksRepository;
import com.school.backend.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.YearMonth;
import java.math.RoundingMode;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class StudentPortalService {

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private MarksRepository marksRepository;

    private Student getStudentByUserId(Long userId) {
        return studentRepository.findByUserId(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Không tìm thấy hồ sơ học sinh liên kết với tài khoản này."));
    }

    public StudentProfileDto getProfileByUserId(Long userId) {
        Student student = getStudentByUserId(userId);
        return StudentProfileDto.builder()
                .id(student.getId())
                .admissionNumber(student.getAdmissionNumber())
                .name(student.getName())
                .rollNo(student.getRollNo())
                .grade(student.getSchoolClass() != null ? student.getSchoolClass().getGrade() : null)
                .section(student.getSchoolClass() != null ? student.getSchoolClass().getSection() : null)
                .dob(student.getDob())
                .gender(student.getGender())
                .photoUrl(student.getPhotoUrl())
                .build();
    }

    public List<StudentAttendanceDto> getAttendanceByUserId(Long userId, Integer month, Integer year) {
        Student student = getStudentByUserId(userId);
        List<Attendance> attendances;

        if (month != null && year != null) {
            YearMonth ym = YearMonth.of(year, month);
            LocalDate start = ym.atDay(1);
            LocalDate end = ym.atEndOfMonth();
            attendances = attendanceRepository.findByStudentIdAndDateBetween(student.getId(), start, end);
        } else {
            attendances = attendanceRepository.findByStudentId(student.getId());
        }

        return attendances.stream()
                .map(a -> StudentAttendanceDto.builder()
                        .date(a.getDate())
                        .status(a.getStatus())
                        .build())
                .collect(Collectors.toList());
    }

    public List<StudentMarkDto> getMarksByUserId(Long userId) {
        Student student = getStudentByUserId(userId);
        List<Marks> marksList = marksRepository.findByStudentId(student.getId());

        return marksList.stream()
                .map(m -> StudentMarkDto.builder()
                        .examName(m.getExam() != null ? m.getExam().getName() : "N/A")
                        .subjectName(m.getSubject() != null ? m.getSubject().getName() : "N/A")
                        .score(m.getScore())
                        .maxScore(m.getMaxScore())
                        .grade(calculateGrade(m.getScore(), m.getMaxScore()))
                        .build())
                .collect(Collectors.toList());
    }

    private String calculateGrade(java.math.BigDecimal score, java.math.BigDecimal maxScore) {
        if (score == null || maxScore == null || maxScore.compareTo(java.math.BigDecimal.ZERO) <= 0) {
            return "N/A";
        }
        java.math.BigDecimal percentage = score.multiply(java.math.BigDecimal.valueOf(100)).divide(maxScore, 2, RoundingMode.HALF_UP);
        if (percentage.compareTo(java.math.BigDecimal.valueOf(90)) >= 0) return "A+";
        if (percentage.compareTo(java.math.BigDecimal.valueOf(80)) >= 0) return "A";
        if (percentage.compareTo(java.math.BigDecimal.valueOf(70)) >= 0) return "B";
        if (percentage.compareTo(java.math.BigDecimal.valueOf(60)) >= 0) return "C";
        if (percentage.compareTo(java.math.BigDecimal.valueOf(50)) >= 0) return "D";
        return "F";
    }
}
