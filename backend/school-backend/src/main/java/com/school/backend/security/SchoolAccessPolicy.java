package com.school.backend.security;

import com.school.backend.entity.*;
import com.school.backend.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

/**
 * Tập trung toàn bộ chính sách kiểm soát truy cập theo quan hệ (Relationship-Based Access Control - ReBAC).
 * Đảm bảo nguyên tắc bảo mật: Server-side Enforcement, chống tấn công BOLA / IDOR.
 */
@Component
public class SchoolAccessPolicy {

    private static final Logger log = LoggerFactory.getLogger(SchoolAccessPolicy.class);

    @Autowired
    private UserRepository userRepository;

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
    private TeachingAssignmentRepository teachingAssignmentRepository;

    @Autowired
    private HomeworkAssignmentRepository homeworkAssignmentRepository;

    @Autowired
    private SubmissionRepository submissionRepository;

    @Autowired
    private MaterialRepository materialRepository;

    @Autowired
    private MaterialFileRepository materialFileRepository;

    @Autowired
    private MaterialClassRepository materialClassRepository;

    @Autowired
    private LeaveRequestRepository leaveRequestRepository;

    public boolean isAdmin(Authentication auth) {
        if (auth == null) return false;
        return auth.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ADMIN"));
    }

    public boolean isTeacher(Authentication auth) {
        if (auth == null) return false;
        return auth.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("TEACHER"));
    }

    public boolean isParent(Authentication auth) {
        if (auth == null) return false;
        return auth.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("PARENT"));
    }

    public boolean isStudent(Authentication auth) {
        if (auth == null) return false;
        return auth.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("STUDENT"));
    }

    /**
     * Xác thực quyền truy cập dữ liệu của một học sinh:
     * - ADMIN: Toàn quyền
     * - STUDENT: Chỉ được xem chính mình
     * - PARENT: Chỉ được xem con ruột / học sinh mình giám hộ
     * - TEACHER: Chỉ được xem học sinh lớp mình chủ nhiệm hoặc có phân công giảng dạy
     */
    public Student verifyCanAccessStudent(Authentication auth, Long studentId) {
        if (auth == null) {
            throw new AccessDeniedException("Yêu cầu xác thực tài khoản.");
        }

        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy học sinh với ID: " + studentId));

        if (isAdmin(auth)) {
            return student;
        }

        String username = auth.getName();

        if (isStudent(auth)) {
            if (student.getUser() != null && username.equals(student.getUser().getUsername())) {
                return student;
            }
            throw new AccessDeniedException("Học sinh không có quyền xem thông tin của học sinh khác.");
        }

        if (isParent(auth)) {
            boolean isAuthorized = false;
            Optional<Parent> parentOpt = parentRepository.findByPhone(username)
                    .or(() -> parentRepository.findAll().stream()
                            .filter(p -> p.getUser() != null && username.equals(p.getUser().getUsername()))
                            .findFirst());

            if (parentOpt.isPresent()) {
                isAuthorized = guardianStudentRepository.findByGuardianIdAndStudentId(parentOpt.get().getId(), studentId).isPresent();
            }
            if (!isAuthorized) {
                // Fallback trường dữ liệu cũ
                isAuthorized = student.getParent() != null
                        && student.getParent().getPhone() != null
                        && student.getParent().getPhone().equals(username);
            }
            if (!isAuthorized) {
                throw new AccessDeniedException("Bạn không có quyền xem thông tin của học sinh này.");
            }
            return student;
        }

        if (isTeacher(auth)) {
            Teacher teacher = teacherRepository.findByUserUsername(username)
                    .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

            SchoolClass studentClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                    .map(Enrollment::getSchoolClass)
                    .orElse(student.getSchoolClass());

            if (studentClass == null) {
                throw new AccessDeniedException("Học sinh chưa được phân lớp học.");
            }

            boolean isHomeroom = studentClass.getEffectiveHomeroomTeacher() != null
                    && studentClass.getEffectiveHomeroomTeacher().getId().equals(teacher.getId());

            boolean isSubjectTeacher = teachingAssignmentRepository
                    .findByTeacherIdAndAcademicYearIsCurrentTrue(teacher.getId()).stream()
                    .anyMatch(ta -> ta.getSchoolClass().getId().equals(studentClass.getId()));

            if (!isHomeroom && !isSubjectTeacher) {
                throw new AccessDeniedException("Bạn không phụ trách lớp của học sinh này.");
            }
            return student;
        }

        throw new AccessDeniedException("Truy cập bị từ chối.");
    }

    /**
     * Xác thực quyền duyệt đơn xin nghỉ phép:
     * - ADMIN: Cho phép
     * - TEACHER: BẮT BUỘC phải là Giáo viên Chủ nhiệm của lớp học sinh đó.
     */
    public LeaveRequest verifyCanReviewLeaveRequest(Authentication auth, Long leaveRequestId) {
        if (auth == null) throw new AccessDeniedException("Yêu cầu xác thực tài khoản.");

        LeaveRequest lr = leaveRequestRepository.findById(leaveRequestId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn xin nghỉ phép với ID: " + leaveRequestId));

        if (isAdmin(auth)) return lr;

        if (isTeacher(auth)) {
            Teacher teacher = teacherRepository.findByUserUsername(auth.getName())
                    .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

            Student student = lr.getStudent();
            SchoolClass studentClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                    .map(Enrollment::getSchoolClass)
                    .orElse(student.getSchoolClass());

            if (studentClass == null) {
                throw new AccessDeniedException("Học sinh chưa được phân vào lớp học.");
            }

            boolean isHomeroom = studentClass.getEffectiveHomeroomTeacher() != null
                    && studentClass.getEffectiveHomeroomTeacher().getId().equals(teacher.getId());

            if (!isHomeroom) {
                throw new AccessDeniedException("Chỉ giáo viên chủ nhiệm của lớp mới có quyền duyệt đơn xin nghỉ phép.");
            }
            return lr;
        }

        throw new AccessDeniedException("Bạn không có quyền duyệt đơn xin nghỉ phép.");
    }

    /**
     * Xác thực quyền giao bài tập cho một lớp học:
     * Giáo viên phải là GVCN hoặc được phân công dạy môn đó cho lớp đó.
     */
    public void verifyTeacherCanAssignClass(Authentication auth, Long classId, Long subjectId) {
        if (isAdmin(auth)) return;

        Teacher teacher = teacherRepository.findByUserUsername(auth.getName())
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

        SchoolClass sc = schoolClassRepository.findById(classId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy lớp học với ID: " + classId));

        boolean isHomeroom = sc.getEffectiveHomeroomTeacher() != null
                && sc.getEffectiveHomeroomTeacher().getId().equals(teacher.getId());

        boolean isAssigned = teachingAssignmentRepository
                .findByTeacherIdAndAcademicYearIsCurrentTrue(teacher.getId()).stream()
                .anyMatch(ta -> ta.getSchoolClass().getId().equals(classId)
                        && (subjectId == null || ta.getSubject().getId().equals(subjectId)));

        if (!isHomeroom && !isAssigned) {
            throw new AccessDeniedException("Bạn không được phân công giảng dạy hoặc chủ nhiệm lớp này.");
        }
    }

    /**
     * Xác thực quyền quản lý/điểm danh của giáo viên đối với một lớp học (BUG-002 ReBAC):
     * Giáo viên phải là GVCN hoặc được phân công giảng dạy tại lớp đó.
     */
    public void verifyTeacherCanManageClassAttendance(Authentication auth, Long classId) {
        if (isAdmin(auth)) return;

        Teacher teacher = teacherRepository.findByUserUsername(auth.getName())
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

        SchoolClass sc = schoolClassRepository.findById(classId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy lớp học với ID: " + classId));

        boolean isHomeroom = sc.getEffectiveHomeroomTeacher() != null
                && sc.getEffectiveHomeroomTeacher().getId().equals(teacher.getId());

        boolean isAssigned = teachingAssignmentRepository
                .findByTeacherIdAndAcademicYearIsCurrentTrue(teacher.getId()).stream()
                .anyMatch(ta -> ta.getSchoolClass().getId().equals(classId));

        if (!isHomeroom && !isAssigned) {
            throw new AccessDeniedException("Bạn không có quyền điểm danh cho lớp học này.");
        }
    }

    /**
     * Xác thực quyền xem phân công giảng dạy của một giáo viên (BUG-003 IDOR):
     * - ADMIN: Xem mọi giáo viên
     * - TEACHER: Bắt buộc chỉ được xem của chính mình.
     */
    public void verifyCanAccessTeacherAssignments(Authentication auth, Long teacherId) {
        if (isAdmin(auth)) return;

        Teacher currentTeacher = teacherRepository.findByUserUsername(auth.getName())
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

        if (!currentTeacher.getId().equals(teacherId)) {
            throw new AccessDeniedException("Giáo viên chỉ có quyền xem phân công giảng dạy của chính mình.");
        }
    }

    /**
     * Xác thực quyền của giáo viên khi xem danh sách bài nộp hoặc chấm điểm bài tập:
     * Giáo viên phải là người giao bài, hoặc GVCN lớp đó, hoặc được phân công dạy lớp đó.
     */
    public HomeworkAssignment verifyTeacherCanAccessAssignment(Authentication auth, Long assignmentId) {
        HomeworkAssignment ha = homeworkAssignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đợt giao bài tập với ID: " + assignmentId));

        if (isAdmin(auth)) return ha;

        Teacher teacher = teacherRepository.findByUserUsername(auth.getName())
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

        boolean isCreator = ha.getAssignedByTeacher() != null
                && ha.getAssignedByTeacher().getId().equals(teacher.getId());

        SchoolClass sc = ha.getSchoolClass();
        boolean isHomeroom = sc.getEffectiveHomeroomTeacher() != null
                && sc.getEffectiveHomeroomTeacher().getId().equals(teacher.getId());

        boolean isAssigned = teachingAssignmentRepository
                .findByTeacherIdAndAcademicYearIsCurrentTrue(teacher.getId()).stream()
                .anyMatch(ta -> ta.getSchoolClass().getId().equals(sc.getId()));

        if (!isCreator && !isHomeroom && !isAssigned) {
            throw new AccessDeniedException("Bạn không có quyền quản lý bài tập của lớp này.");
        }

        return ha;
    }

    /**
     * Xác thực quyền của học sinh khi mở làm hoặc nộp bài tập:
     * Học sinh phải thuộc đúng lớp nhận đợt giao bài đó.
     */
    public Submission verifyStudentCanAccessSubmission(Authentication auth, Long submissionId) {
        Submission sub = submissionRepository.findById(submissionId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bài làm với ID: " + submissionId));

        if (isAdmin(auth)) return sub;

        Student student = sub.getStudent();
        if (student.getUser() == null || !auth.getName().equals(student.getUser().getUsername())) {
            throw new AccessDeniedException("Bạn không thể thao tác trên bài làm của học sinh khác.");
        }

        return sub;
    }

    /**
     * Xác thực quyền tải/xem tệp học liệu:
     * 1. Học liệu phải ở trạng thái PUBLISHED (trừ admin hoặc người soạn)
     * 2. Học sinh phải thuộc lớp được phân phối học liệu
     */
    public MaterialFile verifyCanDownloadMaterialFile(Authentication auth, Long fileId) {
        MaterialFile mf = materialFileRepository.findById(fileId)
                .orElseThrow(() -> new IllegalArgumentException("Tệp học liệu không tồn tại với ID: " + fileId));

        Material m = mf.getMaterial();
        if (isAdmin(auth)) return mf;

        String username = auth.getName();

        if (isTeacher(auth)) {
            if (m.getCreatedByTeacher() != null && m.getCreatedByTeacher().getUser() != null
                    && username.equals(m.getCreatedByTeacher().getUser().getUsername())) {
                return mf;
            }
            if (!"PUBLISHED".equals(m.getStatus())) {
                throw new AccessDeniedException("Học liệu này chưa được xuất bản.");
            }

            Teacher teacher = teacherRepository.findByUserUsername(username)
                    .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

            List<Long> distributedClassIds = materialClassRepository.findByMaterialId(m.getId()).stream()
                    .filter(mc -> mc.getSchoolClass() != null)
                    .map(mc -> mc.getSchoolClass().getId())
                    .toList();

            if (distributedClassIds.isEmpty()) {
                throw new AccessDeniedException("Học liệu này chưa được phân phối cho bất kỳ lớp học nào.");
            }

            boolean isHomeroom = schoolClassRepository.findByHomeroomTeacherId(teacher.getId()).stream()
                    .anyMatch(sc -> distributedClassIds.contains(sc.getId()))
                    || schoolClassRepository.findByClassTeacherId(teacher.getId()).stream()
                    .anyMatch(sc -> distributedClassIds.contains(sc.getId()));

            boolean isSubjectTeacher = teachingAssignmentRepository
                    .findByTeacherIdAndAcademicYearIsCurrentTrue(teacher.getId()).stream()
                    .filter(ta -> ta.getSchoolClass() != null)
                    .anyMatch(ta -> distributedClassIds.contains(ta.getSchoolClass().getId()));

            if (!isHomeroom && !isSubjectTeacher) {
                throw new AccessDeniedException("Học liệu này không được xuất bản cho bất kỳ lớp nào bạn phụ trách.");
            }

            return mf;
        }

        if (isStudent(auth)) {
            if (!"PUBLISHED".equals(m.getStatus())) {
                throw new AccessDeniedException("Học liệu này chưa được xuất bản.");
            }

            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new AccessDeniedException("Người dùng không tồn tại."));
            Student student = studentRepository.findByUserId(user.getId())
                    .orElseThrow(() -> new AccessDeniedException("Hồ sơ học sinh không tồn tại."));

            SchoolClass studentClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                    .map(Enrollment::getSchoolClass)
                    .orElse(student.getSchoolClass());

            if (studentClass == null) {
                throw new AccessDeniedException("Học sinh chưa được xếp lớp.");
            }

            boolean isDistributedToClass = materialClassRepository.findBySchoolClassId(studentClass.getId()).stream()
                    .anyMatch(mc -> mc.getMaterial().getId().equals(m.getId()));

            if (!isDistributedToClass) {
                throw new AccessDeniedException("Học liệu này không được xuất bản cho lớp của bạn.");
            }

            return mf;
        }

        if (isParent(auth)) {
            if (!"PUBLISHED".equals(m.getStatus())) {
                throw new AccessDeniedException("Học liệu này chưa được xuất bản.");
            }

            List<Long> distributedClassIds = materialClassRepository.findByMaterialId(m.getId()).stream()
                    .filter(mc -> mc.getSchoolClass() != null)
                    .map(mc -> mc.getSchoolClass().getId())
                    .toList();

            if (distributedClassIds.isEmpty()) {
                throw new AccessDeniedException("Học liệu này chưa được phân phối cho bất kỳ lớp học nào.");
            }

            Parent parent = parentRepository.findByPhone(username)
                    .or(() -> userRepository.findByUsername(username).flatMap(u -> parentRepository.findByUserId(u.getId())))
                    .orElseThrow(() -> new AccessDeniedException("Hồ sơ phụ huynh không tồn tại."));

            List<Long> studentIds = guardianStudentRepository.findStudentIdsByGuardianId(parent.getId());
            if (studentIds.isEmpty()) {
                studentIds = studentRepository.findAll().stream()
                        .filter(s -> s.getParent() != null && s.getParent().getId().equals(parent.getId()))
                        .map(Student::getId)
                        .toList();
            }

            if (studentIds.isEmpty()) {
                throw new AccessDeniedException("Bạn chưa được liên kết với học sinh nào.");
            }

            boolean hasChildInDistributedClass = studentIds.stream().anyMatch(stuId -> {
                SchoolClass sc = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(stuId)
                        .map(Enrollment::getSchoolClass)
                        .orElseGet(() -> studentRepository.findById(stuId).map(Student::getSchoolClass).orElse(null));
                return sc != null && distributedClassIds.contains(sc.getId());
            });

            if (!hasChildInDistributedClass) {
                throw new AccessDeniedException("Học liệu này không được xuất bản cho lớp của con bạn.");
            }

            return mf;
        }

        throw new AccessDeniedException("Bạn không có quyền tải tệp này.");
    }
}
