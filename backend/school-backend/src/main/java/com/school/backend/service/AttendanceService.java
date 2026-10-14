package com.school.backend.service;

import com.school.backend.entity.*;
import com.school.backend.enums.AttendanceStatus;
import com.school.backend.payload.request.BulkAttendanceRequest;
import com.school.backend.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class AttendanceService {

    private static final Logger log = LoggerFactory.getLogger(AttendanceService.class);

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private ParentRepository parentRepository;

    @Autowired
    private GuardianStudentRepository guardianStudentRepository;

    @Autowired
    private TeacherRepository teacherRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private TeachingAssignmentRepository teachingAssignmentRepository;

    @Autowired
    private AttendanceSessionRepository attendanceSessionRepository;

    @Autowired
    private AttendanceRecordRepository attendanceRecordRepository;

    @Autowired
    private LeaveRequestRepository leaveRequestRepository;

    public List<Attendance> getAttendanceByStudent(Long studentId) {
        return attendanceRepository.findByStudentId(studentId);
    }

    public List<Attendance> getAttendanceByStudentSecure(Long studentId, String currentUsername, boolean isParent, boolean isTeacher) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        if (isParent) {
            boolean isAuthorized = false;
            // 1. ReBAC: Kiểm tra qua bảng nối guardian_students
            Optional<Parent> parentOpt = parentRepository.findByPhone(currentUsername);
            if (parentOpt.isPresent()) {
                isAuthorized = guardianStudentRepository.findByGuardianIdAndStudentId(parentOpt.get().getId(), studentId).isPresent();
            }
            // 2. Fallback: Kiểm tra qua cột parent_id cũ có ghi log cảnh báo
            if (!isAuthorized) {
                log.warn("[DUAL-READ FALLBACK] Checking legacy parent_id for parent={} on studentId={}", currentUsername, studentId);
                isAuthorized = student.getParent() != null
                        && student.getParent().getPhone() != null
                        && student.getParent().getPhone().equals(currentUsername);
            }
            if (!isAuthorized) {
                throw new AccessDeniedException("Bạn không có quyền xem điểm danh của học sinh này.");
            }
        } else if (isTeacher) {
            verifyTeacherAuthorizedForStudent(student, currentUsername);
        }

        return attendanceRepository.findByStudentId(studentId);
    }

    public void verifyTeacherAuthorizedForStudent(Student student, String teacherUsername) {
        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Tài khoản giáo viên không tồn tại trong hệ thống."));

        SchoolClass studentClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                .map(Enrollment::getSchoolClass)
                .orElse(student.getSchoolClass());

        if (studentClass == null) {
            throw new AccessDeniedException("Học sinh chưa được phân vào lớp học.");
        }

        // 1. GV Chủ nhiệm lớp
        boolean isHomeroom = studentClass.getEffectiveHomeroomTeacher() != null
                && studentClass.getEffectiveHomeroomTeacher().getId().equals(teacher.getId());

        if (isHomeroom) {
            return;
        }

        // 2. GV có phân công giảng dạy (teaching_assignments) lớp này
        boolean isAssigned = !teachingAssignmentRepository
                .findByTeacherIdAndSchoolClassIdAndAcademicYearIsCurrentTrue(teacher.getId(), studentClass.getId())
                .isEmpty();

        if (!isAssigned) {
            throw new AccessDeniedException("Giáo viên không có phân công giảng dạy hoặc chủ nhiệm lớp của học sinh này.");
        }
    }

    public Attendance markAttendance(Attendance attendance) {
        return attendanceRepository.save(attendance);
    }

    @Transactional
    public List<Attendance> saveBulkAttendance(BulkAttendanceRequest request, String currentUsername, boolean isTeacher) {
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

        Teacher callingTeacher = null;
        if (isTeacher && currentUsername != null) {
            callingTeacher = teacherRepository.findByUserUsername(currentUsername).orElse(null);
        }

        List<Attendance> savedList = new ArrayList<>();
        for (BulkAttendanceRequest.Record rec : request.getRecords()) {
            if (rec.getStudentId() == null) continue;

            Student student = studentRepository.findById(rec.getStudentId()).orElse(null);
            if (student == null) continue;

            if (isTeacher) {
                verifyTeacherAuthorizedForStudent(student, currentUsername);
            }

            SchoolClass studentClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                    .map(Enrollment::getSchoolClass)
                    .orElse(student.getSchoolClass());

            AttendanceStatus status = parseStatus(rec.getStatus());

            // Tự động kiểm tra đơn xin nghỉ phép APPROVED trên ngày này
            LeaveRequest approvedLeave = null;
            List<LeaveRequest> approvedList = leaveRequestRepository.findApprovedRequestsOnDate(student.getId(), targetDate);
            if (!approvedList.isEmpty()) {
                approvedLeave = approvedList.get(0);
                status = AttendanceStatus.LEAVE; // Tự động chuyển thành Có phép
            }

            // 1. Dual-Write: Lưu phiên điểm danh (attendance_sessions)
            if (studentClass != null) {
                Optional<AttendanceSession> sessionOpt = attendanceSessionRepository
                        .findBySchoolClassIdAndDateAndLessonSlotIsNull(studentClass.getId(), targetDate);

                AttendanceSession session;
                if (sessionOpt.isPresent()) {
                    session = sessionOpt.get();
                } else {
                    AttendanceSession s = new AttendanceSession();
                    s.setSchoolClass(studentClass);
                    s.setDate(targetDate);
                    s.setStatus("SUBMITTED");
                    if (callingTeacher != null) {
                        s.setSubmittedByTeacher(callingTeacher);
                    }
                    session = attendanceSessionRepository.save(s);
                }

                if (callingTeacher != null && session.getSubmittedByTeacher() == null) {
                    session.setSubmittedByTeacher(callingTeacher);
                    attendanceSessionRepository.save(session);
                }

                // Lưu chi tiết học sinh (attendance_records)
                Optional<AttendanceRecord> recordOpt = attendanceRecordRepository.findBySessionIdAndStudentId(session.getId(), student.getId());
                AttendanceRecord record;
                if (recordOpt.isPresent()) {
                    record = recordOpt.get();
                } else {
                    record = new AttendanceRecord();
                    record.setSession(session);
                    record.setStudent(student);
                }

                record.setStatus(status);
                record.setLeaveRequest(approvedLeave);
                record.setRemark(approvedLeave != null ? "Nghỉ có phép: " + approvedLeave.getReason() : rec.getStatus());
                attendanceRecordRepository.save(record);
            }

            // 2. Dual-Write: Lưu bảng attendance cũ để tương thích ngược
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
