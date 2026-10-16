package com.school.backend.service;

import com.school.backend.entity.AcademicYear;
import com.school.backend.entity.Enrollment;
import com.school.backend.entity.GuardianStudent;
import com.school.backend.entity.Parent;
import com.school.backend.entity.SchoolClass;
import com.school.backend.entity.Student;
import com.school.backend.payload.request.StudentCreateRequest;
import com.school.backend.repository.AcademicYearRepository;
import com.school.backend.repository.EnrollmentRepository;
import com.school.backend.repository.GuardianStudentRepository;
import com.school.backend.repository.ParentRepository;
import com.school.backend.repository.SchoolClassRepository;
import com.school.backend.repository.StudentRepository;
import com.school.backend.repository.UserRepository;
import com.school.backend.entity.User;
import com.school.backend.enums.Role;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class StudentService {

    private static final Logger log = LoggerFactory.getLogger(StudentService.class);

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private ParentRepository parentRepository;

    @Autowired
    private SchoolClassRepository schoolClassRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AcademicYearRepository academicYearRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private GuardianStudentRepository guardianStudentRepository;

    public Page<Student> getAllStudents(Pageable pageable) {
        return studentRepository.findAll(pageable);
    }

    public Optional<Student> getStudentById(Long id) {
        return studentRepository.findById(id);
    }

    /**
     * Dual-Read: Ưu tiên đọc danh sách con từ bảng quan hệ guardian_students.
     * Nếu thiếu dữ liệu, ghi log cảnh báo WARN rõ ràng và fallback về students.parent_id cũ.
     */
    public List<Student> getMyWards(String username) {
        Parent parent = parentRepository.findByPhone(username)
                .orElseThrow(() -> new RuntimeException("Parent profile not found for phone: " + username));
        
        List<Long> studentIds = guardianStudentRepository.findStudentIdsByGuardianId(parent.getId());
        if (studentIds != null && !studentIds.isEmpty()) {
            return studentRepository.findAllById(studentIds);
        }

        log.warn("[DUAL-READ FALLBACK DETECTED] Parent phone={} (id={}) has NO records in guardian_students! Falling back to legacy students.parent_id. Please run reconciliation audit!", username, parent.getId());
        return studentRepository.findByParentId(parent.getId());
    }

    @Transactional
    public Student saveStudent(Student student) {
        ensureRequiredFields(student);
        Student saved = studentRepository.save(student);
        syncEnrollmentAndGuardian(saved);
        return saved;
    }

    @Transactional
    public Student createStudentFromRequest(StudentCreateRequest req) {
        Student student = new Student();
        student.setName(req.getName() != null && !req.getName().isBlank() ? req.getName() : "Student");
        student.setRollNo(req.getRollNo());
        student.setAdmissionNumber(req.getAdmissionNumber());
        student.setGender(req.getGender() != null ? req.getGender() : "Male");
        student.setDob(req.getDob());
        student.setAddress(req.getAddress());
        student.setPhotoUrl(req.getPhotoUrl());
        student.setAadhaarMasked(req.getAadhaar());

        // Resolve SchoolClass
        if (req.getClassId() != null) {
            schoolClassRepository.findById(req.getClassId()).ifPresent(student::setSchoolClass);
        } else if (req.getClassName() != null && !req.getClassName().isBlank()) {
            List<SchoolClass> classes = schoolClassRepository.findAll();
            for (SchoolClass c : classes) {
                if (req.getClassName().equalsIgnoreCase(c.getGrade()) ||
                    req.getClassName().equalsIgnoreCase(c.getGrade() + "-" + c.getSection()) ||
                    req.getClassName().equalsIgnoreCase(c.getGrade() + " " + c.getSection())) {
                    student.setSchoolClass(c);
                    break;
                }
            }
        }

        // Resolve Parent
        if (req.getParentId() != null) {
            parentRepository.findById(req.getParentId()).ifPresent(student::setParent);
        } else if (req.getMobileNumber() != null && !req.getMobileNumber().isBlank() && !req.getMobileNumber().equals("0")) {
            Parent parent = parentRepository.findByPhone(req.getMobileNumber())
                    .orElseGet(() -> {
                        Parent newP = new Parent();
                        newP.setName(req.getFatherName() != null ? req.getFatherName() : "Parent");
                        newP.setPhone(req.getMobileNumber());
                        return parentRepository.save(newP);
                    });
            student.setParent(parent);
        }

        ensureRequiredFields(student);

        // Auto-create Student User account if not exists
        if (student.getUser() == null) {
            String username = student.getAdmissionNumber();
            String rawPass = (req.getInitialPassword() != null && !req.getInitialPassword().isBlank())
                    ? req.getInitialPassword()
                    : (username + "@School");
            User studentUser = userRepository.findByUsername(username).orElseGet(() -> {
                User newUser = new User();
                newUser.setUsername(username);
                newUser.setPassword(passwordEncoder.encode(rawPass));
                newUser.setRole(Role.STUDENT);
                newUser.setMustChangePassword(true);
                return userRepository.save(newUser);
            });
            student.setUser(studentUser);
        }

        Student saved = studentRepository.save(student);
        syncEnrollmentAndGuardian(saved);
        return saved;
    }

    /**
     * Dual-Write: Đồng bộ bản ghi sang Enrollments và GuardianStudents
     */
    private void syncEnrollmentAndGuardian(Student student) {
        if (student == null || student.getId() == null) return;

        // 1. Đồng bộ Enrollment cho năm học hiện tại
        if (student.getSchoolClass() != null) {
            AcademicYear currentYear = academicYearRepository.findByIsCurrentTrue()
                    .orElseGet(() -> {
                        AcademicYear fallback = new AcademicYear();
                        fallback.setName("2026-2027");
                        fallback.setStartDate(java.time.LocalDate.of(2026, 9, 1));
                        fallback.setEndDate(java.time.LocalDate.of(2027, 6, 30));
                        fallback.setIsCurrent(true);
                        return academicYearRepository.save(fallback);
                    });

            enrollmentRepository.findByStudentIdAndAcademicYearId(student.getId(), currentYear.getId())
                    .ifPresentOrElse(
                            existing -> {
                                existing.setSchoolClass(student.getSchoolClass());
                                enrollmentRepository.save(existing);
                            },
                            () -> {
                                Enrollment enrollment = new Enrollment();
                                enrollment.setStudent(student);
                                enrollment.setSchoolClass(student.getSchoolClass());
                                enrollment.setAcademicYear(currentYear);
                                enrollment.setStatus("ENROLLED");
                                enrollmentRepository.save(enrollment);
                            }
                    );
        }

        // 2. Đồng bộ GuardianStudent (mặc định relationship = GUARDIAN, isPrimary = true)
        if (student.getParent() != null) {
            guardianStudentRepository.findByGuardianIdAndStudentId(student.getParent().getId(), student.getId())
                    .ifPresentOrElse(
                            existing -> {
                                existing.setIsPrimary(true);
                                guardianStudentRepository.save(existing);
                            },
                            () -> {
                                GuardianStudent gs = new GuardianStudent();
                                gs.setGuardian(student.getParent());
                                gs.setStudent(student);
                                gs.setRelationship("GUARDIAN");
                                gs.setIsPrimary(true);
                                guardianStudentRepository.save(gs);
                            }
                    );
        }
    }

    /**
     * Reconciliation Audit: Đối soát dữ liệu giữa 2 nguồn sự thật
     */
    public Map<String, Object> reconcileCoreFoundationsData() {
        Map<String, Object> report = new LinkedHashMap<>();

        // 1. Audit Phụ huynh - Học sinh
        List<Student> studentsWithLegacyParent = studentRepository.findAll().stream()
                .filter(s -> s.getParent() != null)
                .collect(Collectors.toList());

        List<Long> unlinkedStudentFromGuardian = new ArrayList<>();
        for (Student s : studentsWithLegacyParent) {
            boolean hasGs = guardianStudentRepository.findByGuardianIdAndStudentId(s.getParent().getId(), s.getId()).isPresent();
            if (!hasGs) {
                unlinkedStudentFromGuardian.add(s.getId());
            }
        }

        report.put("legacy_students_with_parent_count", studentsWithLegacyParent.size());
        report.put("guardian_students_total_links", guardianStudentRepository.count());
        report.put("missing_in_guardian_students", unlinkedStudentFromGuardian);
        report.put("parent_relationship_synced", unlinkedStudentFromGuardian.isEmpty());

        // 2. Audit Lớp học - Enrollment
        AcademicYear currentYear = academicYearRepository.findByIsCurrentTrue().orElse(null);
        List<Student> studentsWithLegacyClass = studentRepository.findAll().stream()
                .filter(s -> s.getSchoolClass() != null)
                .collect(Collectors.toList());

        List<Long> unlinkedStudentFromEnrollment = new ArrayList<>();
        if (currentYear != null) {
            for (Student s : studentsWithLegacyClass) {
                boolean hasEnr = enrollmentRepository.findByStudentIdAndAcademicYearId(s.getId(), currentYear.getId()).isPresent();
                if (!hasEnr) {
                    unlinkedStudentFromEnrollment.add(s.getId());
                }
            }
        }

        report.put("current_academic_year", currentYear != null ? currentYear.getName() : "NONE");
        report.put("legacy_students_with_class_count", studentsWithLegacyClass.size());
        report.put("current_year_enrollments_count", currentYear != null ? enrollmentRepository.findAll().stream().filter(e -> e.getAcademicYear().getId().equals(currentYear.getId())).count() : 0);
        report.put("missing_in_enrollments", unlinkedStudentFromEnrollment);
        report.put("class_enrollment_synced", unlinkedStudentFromEnrollment.isEmpty());

        report.put("overall_status", unlinkedStudentFromGuardian.isEmpty() && unlinkedStudentFromEnrollment.isEmpty() ? "HEALTHY_AND_SYNCHRONIZED" : "DESYNCHRONIZED");

        return report;
    }

    private void ensureRequiredFields(Student student) {
        if (student.getRollNo() == null || student.getRollNo().isBlank()) {
            student.setRollNo(String.valueOf(studentRepository.count() + 1));
        }
        if (student.getAdmissionNumber() == null || student.getAdmissionNumber().isBlank()) {
            student.setAdmissionNumber("ADM" + (1000 + studentRepository.count() + 1));
        }
    }

    public void deleteStudent(Long id) {
        studentRepository.deleteById(id);
    }

    @Transactional
    public int cleanupDuplicates() {
        List<Student> allStudents = studentRepository.findAll();
        int deletedCount = 0;

        Map<String, List<Student>> grouped = allStudents.stream()
                .collect(Collectors.groupingBy(s -> {
                    String name = s.getName() != null ? s.getName().trim().toLowerCase() : "";
                    Long classId = s.getSchoolClass() != null ? s.getSchoolClass().getId() : 0L;
                    return name + "|" + classId;
                }));

        for (Map.Entry<String, List<Student>> entry : grouped.entrySet()) {
            List<Student> duplicates = entry.getValue();
            if (duplicates.size() > 1) {
                duplicates.sort(Comparator.comparingLong(Student::getId));
                for (int i = 1; i < duplicates.size(); i++) {
                    studentRepository.deleteById(duplicates.get(i).getId());
                    deletedCount++;
                }
            }
        }

        return deletedCount;
    }
}
