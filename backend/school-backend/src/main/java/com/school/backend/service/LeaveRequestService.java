package com.school.backend.service;

import com.school.backend.entity.*;
import com.school.backend.enums.AttendanceStatus;
import com.school.backend.payload.request.LeaveRequestCreateRequest;
import com.school.backend.payload.request.LeaveRequestReviewRequest;
import com.school.backend.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class LeaveRequestService {

    private static final Logger log = LoggerFactory.getLogger(LeaveRequestService.class);

    @Autowired
    private LeaveRequestRepository leaveRequestRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private ParentRepository parentRepository;

    @Autowired
    private GuardianStudentRepository guardianStudentRepository;

    @Autowired
    private TeacherRepository teacherRepository;

    @Autowired
    private SchoolClassRepository schoolClassRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private AttendanceSessionRepository attendanceSessionRepository;

    @Autowired
    private AttendanceRecordRepository attendanceRecordRepository;

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private TeachingAssignmentRepository teachingAssignmentRepository;

    @Transactional
    public LeaveRequest submitLeaveRequest(LeaveRequestCreateRequest req, String guardianPhone) {
        if (req == null || req.getStudentId() == null || req.getStartDate() == null || req.getEndDate() == null) {
            throw new IllegalArgumentException("Thông tin đơn xin nghỉ phép không được để trống.");
        }

        LocalDate start = LocalDate.parse(req.getStartDate().trim());
        LocalDate end = LocalDate.parse(req.getEndDate().trim());

        if (end.isBefore(start)) {
            throw new IllegalArgumentException("Ngày kết thúc nghỉ không thể trước ngày bắt đầu nghỉ.");
        }

        Parent guardian = parentRepository.findByPhone(guardianPhone)
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ phụ huynh không tồn tại trong hệ thống."));

        Student student = studentRepository.findById(req.getStudentId())
                .orElseThrow(() -> new IllegalArgumentException("Học sinh không tồn tại trong hệ thống."));

        // 1. ReBAC Security: Kiểm tra quyền phụ huynh
        boolean isAuthorized = guardianStudentRepository.findByGuardianIdAndStudentId(guardian.getId(), student.getId()).isPresent();
        if (!isAuthorized) {
            log.warn("[LEAVE-REQUEST REBAC] Guardian {} is not linked via guardian_students. Checking legacy parent_id.", guardianPhone);
            isAuthorized = student.getParent() != null && student.getParent().getId().equals(guardian.getId());
        }

        if (!isAuthorized) {
            throw new AccessDeniedException("Bạn không phải là người giám hộ của học sinh này.");
        }

        // 2. Overlap Check: Chặn nộp đơn trùng lặp khoảng ngày
        List<LeaveRequest> overlaps = leaveRequestRepository.findOverlappingRequests(student.getId(), start, end);
        if (!overlaps.isEmpty()) {
            LeaveRequest existing = overlaps.get(0);
            throw new IllegalArgumentException(String.format(
                    "Đã tồn tại đơn xin nghỉ phép trong khoảng thời gian này (%s đến %s, trạng thái: %s).",
                    existing.getStartDate(), existing.getEndDate(), existing.getStatus()));
        }

        LeaveRequest lr = new LeaveRequest();
        lr.setStudent(student);
        lr.setSubmittedByGuardian(guardian);
        lr.setStartDate(start);
        lr.setEndDate(end);
        lr.setReason(req.getReason() != null ? req.getReason().trim() : "Nghỉ phép gia đình");
        lr.setStatus("PENDING");

        return leaveRequestRepository.save(lr);
    }

    @Transactional
    public LeaveRequest reviewLeaveRequest(Long leaveRequestId, LeaveRequestReviewRequest req, String teacherUsername) {
        if (req == null || req.getDecision() == null || req.getDecision().isBlank()) {
            throw new IllegalArgumentException("Vui lòng cung cấp quyết định duyệt (APPROVED hoặc REJECTED).");
        }

        LeaveRequest lr = leaveRequestRepository.findById(leaveRequestId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn xin nghỉ phép với ID: " + leaveRequestId));

        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Tài khoản giáo viên không tồn tại trong hệ thống."));

        Student student = lr.getStudent();
        SchoolClass studentClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                .map(Enrollment::getSchoolClass)
                .orElse(student.getSchoolClass());

        if (studentClass == null) {
            throw new AccessDeniedException("Học sinh chưa được phân vào lớp học.");
        }

        // ReBAC Security: Chỉ Giáo viên Chủ nhiệm của lớp mới được duyệt
        boolean isHomeroom = studentClass.getEffectiveHomeroomTeacher() != null
                && studentClass.getEffectiveHomeroomTeacher().getId().equals(teacher.getId());

        if (!isHomeroom) {
            throw new AccessDeniedException("Chỉ giáo viên chủ nhiệm của lớp mới có quyền duyệt đơn xin nghỉ phép này.");
        }

        String decision = req.getDecision().trim().toUpperCase();
        if (!decision.equals("APPROVED") && !decision.equals("REJECTED")) {
            throw new IllegalArgumentException("Quyết định không hợp lệ. Chỉ chấp nhận APPROVED hoặc REJECTED.");
        }

        lr.setStatus(decision);
        lr.setReviewedByTeacher(teacher);
        lr.setTeacherNote(req.getTeacherNote());
        lr.setReviewedAt(LocalDateTime.now());

        LeaveRequest saved = leaveRequestRepository.save(lr);

        // 3. Tự động đồng bộ Điểm danh sang "LEAVE" (Có phép) khi duyệt APPROVED
        if (decision.equals("APPROVED")) {
            syncAttendanceOnApprovedLeave(saved, studentClass);
        }

        return saved;
    }

    private void syncAttendanceOnApprovedLeave(LeaveRequest lr, SchoolClass schoolClass) {
        Student student = lr.getStudent();
        LocalDate curr = lr.getStartDate();
        LocalDate end = lr.getEndDate();

        while (!curr.isAfter(end)) {
            final LocalDate date = curr;

            // 1. Đồng bộ sang attendance_sessions & attendance_records
            attendanceSessionRepository.findBySchoolClassIdAndDateAndLessonSlotIsNull(schoolClass.getId(), date)
                    .ifPresent(session -> {
                        AttendanceRecord record = attendanceRecordRepository.findBySessionIdAndStudentId(session.getId(), student.getId())
                                .orElseGet(() -> {
                                    AttendanceRecord r = new AttendanceRecord();
                                    r.setSession(session);
                                    r.setStudent(student);
                                    return r;
                                });
                        record.setStatus(AttendanceStatus.LEAVE);
                        record.setLeaveRequest(lr);
                        record.setRemark("Nghỉ có phép: " + lr.getReason());
                        attendanceRecordRepository.save(record);
                    });

            // 2. Dual-Write đồng bộ sang bảng attendance cũ
            Attendance legacy = attendanceRepository.findByStudentIdAndDate(student.getId(), date)
                    .orElseGet(() -> {
                        Attendance a = new Attendance();
                        a.setStudent(student);
                        a.setDate(date);
                        return a;
                    });
            legacy.setStatus(AttendanceStatus.LEAVE);
            attendanceRepository.save(legacy);

            curr = curr.plusDays(1);
        }
    }

    public List<LeaveRequest> getGuardianLeaveRequests(String guardianPhone) {
        Parent guardian = parentRepository.findByPhone(guardianPhone)
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ phụ huynh không tồn tại."));
        return leaveRequestRepository.findBySubmittedByGuardianIdOrderByCreatedAtDesc(guardian.getId());
    }

    public List<LeaveRequest> getPendingRequestsForTeacher(String teacherUsername) {
        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

        List<SchoolClass> homeroomClasses = schoolClassRepository.findByHomeroomTeacherId(teacher.getId());
        if (homeroomClasses.isEmpty()) {
            homeroomClasses = schoolClassRepository.findByClassTeacherId(teacher.getId());
        }

        List<LeaveRequest> pendingList = new ArrayList<>();
        for (SchoolClass sc : homeroomClasses) {
            pendingList.addAll(leaveRequestRepository.findByClassIdAndStatus(sc.getId(), "PENDING"));
        }
        return pendingList;
    }

    public List<LeaveRequest> getStudentLeaveRequests(Long studentId, String currentUsername, boolean isAdmin, boolean isTeacher, boolean isParent) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new IllegalArgumentException("Học sinh không tồn tại với ID: " + studentId));

        if (isAdmin) {
            return leaveRequestRepository.findByStudentIdOrderByCreatedAtDesc(studentId);
        }

        if (isParent) {
            boolean isAuthorized = false;
            Optional<Parent> parentOpt = parentRepository.findByPhone(currentUsername);
            if (parentOpt.isPresent()) {
                isAuthorized = guardianStudentRepository.findByGuardianIdAndStudentId(parentOpt.get().getId(), studentId).isPresent();
            }
            if (!isAuthorized) {
                isAuthorized = student.getParent() != null
                        && student.getParent().getPhone() != null
                        && student.getParent().getPhone().equals(currentUsername);
            }
            if (!isAuthorized) {
                throw new AccessDeniedException("Bạn không có quyền xem đơn nghỉ phép của học sinh này.");
            }
            return leaveRequestRepository.findByStudentIdOrderByCreatedAtDesc(studentId);
        }

        if (isTeacher) {
            Teacher teacher = teacherRepository.findByUserUsername(currentUsername)
                    .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));
            SchoolClass studentClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                    .map(Enrollment::getSchoolClass)
                    .orElse(student.getSchoolClass());

            if (studentClass == null) {
                throw new AccessDeniedException("Học sinh chưa được phân lớp.");
            }

            boolean isHomeroom = studentClass.getEffectiveHomeroomTeacher() != null
                    && studentClass.getEffectiveHomeroomTeacher().getId().equals(teacher.getId());

            boolean isSubjectTeacher = teachingAssignmentRepository
                    .findByTeacherIdAndAcademicYearIsCurrentTrue(teacher.getId()).stream()
                    .anyMatch(ta -> ta.getSchoolClass().getId().equals(studentClass.getId()));

            if (!isHomeroom && !isSubjectTeacher) {
                throw new AccessDeniedException("Bạn không phụ trách lớp của học sinh này.");
            }

            return leaveRequestRepository.findByStudentIdOrderByCreatedAtDesc(studentId);
        }

        throw new AccessDeniedException("Quyền truy cập không hợp lệ.");
    }
}
