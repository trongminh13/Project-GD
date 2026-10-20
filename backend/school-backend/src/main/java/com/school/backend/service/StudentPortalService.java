package com.school.backend.service;

import com.school.backend.enums.EducationLevel;
import com.school.backend.entity.Attendance;
import com.school.backend.entity.Enrollment;
import com.school.backend.entity.Marks;
import com.school.backend.entity.SchoolClass;
import com.school.backend.entity.Student;
import com.school.backend.payload.dto.StudentAttendanceDto;
import com.school.backend.payload.dto.StudentMarkDto;
import com.school.backend.payload.dto.StudentProfileDto;
import com.school.backend.repository.AttendanceRepository;
import com.school.backend.repository.EnrollmentRepository;
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

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    private Student getStudentByUserId(Long userId) {
        return studentRepository.findByUserId(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Không tìm thấy hồ sơ học sinh liên kết với tài khoản này."));
    }

    public StudentProfileDto getProfileByUserId(Long userId) {
        Student student = getStudentByUserId(userId);
        
        // Dual-Read: Ưu tiên lấy lớp từ bản ghi enrollment của năm học hiện tại
        SchoolClass activeClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                .map(Enrollment::getSchoolClass)
                .orElse(student.getSchoolClass());

        String gradeStr = activeClass != null ? activeClass.getGrade() : null;
        EducationLevel level = EducationLevel.fromGrade(gradeStr);

        return StudentProfileDto.builder()
                .id(student.getId())
                .admissionNumber(student.getAdmissionNumber())
                .name(student.getName())
                .rollNo(student.getRollNo())
                .grade(gradeStr)
                .section(activeClass != null ? activeClass.getSection() : null)
                .dob(student.getDob())
                .gender(student.getGender())
                .photoUrl(student.getPhotoUrl())
                .educationLevel(level)
                .educationLevelName(level.getDisplayName())
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
        SchoolClass activeClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                .map(Enrollment::getSchoolClass)
                .orElse(student.getSchoolClass());
        EducationLevel level = EducationLevel.fromGrade(activeClass != null ? activeClass.getGrade() : null);

        List<Marks> marksList = marksRepository.findByStudentId(student.getId());

        return marksList.stream()
                .map(m -> StudentMarkDto.builder()
                        .examName(m.getExam() != null ? m.getExam().getName() : "N/A")
                        .subjectName(m.getSubject() != null ? m.getSubject().getName() : "N/A")
                        .score(m.getScore())
                        .maxScore(m.getMaxScore())
                        .grade(calculateGrade(m.getScore(), m.getMaxScore(), level))
                        .build())
                .collect(Collectors.toList());
    }

    public String calculateGrade(java.math.BigDecimal score, java.math.BigDecimal maxScore) {
        return calculateGrade(score, maxScore, EducationLevel.PRIMARY);
    }

    public String calculateGrade(java.math.BigDecimal score, java.math.BigDecimal maxScore, EducationLevel level) {
        if (score == null || maxScore == null || maxScore.compareTo(java.math.BigDecimal.ZERO) <= 0) {
            return "N/A";
        }
        java.math.BigDecimal percentage = score.multiply(java.math.BigDecimal.valueOf(100)).divide(maxScore, 2, RoundingMode.HALF_UP);
        if (level == EducationLevel.PRIMARY) {
            // Thông tư 27/2020/TT-BGDĐT: Đánh giá định lượng kết hợp nhận xét mức độ hoàn thành
            if (percentage.compareTo(java.math.BigDecimal.valueOf(80)) >= 0) return "Hoàn thành tốt (HTT)";
            if (percentage.compareTo(java.math.BigDecimal.valueOf(50)) >= 0) return "Hoàn thành (HT)";
            return "Chưa hoàn thành (CHT)";
        } else {
            // Thông tư 22/2021/TT-BGDĐT: Đánh giá học sinh THCS và THPT
            if (percentage.compareTo(java.math.BigDecimal.valueOf(80)) >= 0) return "Tốt";
            if (percentage.compareTo(java.math.BigDecimal.valueOf(65)) >= 0) return "Khá";
            if (percentage.compareTo(java.math.BigDecimal.valueOf(50)) >= 0) return "Đạt";
            return "Chưa đạt";
        }
    }
}
