package com.school.backend.service;

import com.school.backend.entity.*;
import com.school.backend.payload.request.BulkMarksRequest;
import com.school.backend.payload.response.StudentMarkResponse;
import com.school.backend.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class MarksService {

    private static final Logger log = LoggerFactory.getLogger(MarksService.class);

    @Autowired
    private MarksRepository marksRepository;

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
    private ExamRepository examRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    public void verifyTeacherAuthorizedForStudent(Student student, String teacherUsername) {
        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Tài khoản giáo viên không tồn tại trong hệ thống."));

        SchoolClass studentClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                .map(Enrollment::getSchoolClass)
                .orElse(student.getSchoolClass());

        if (studentClass == null) {
            throw new AccessDeniedException("Học sinh chưa được phân vào lớp học.");
        }

        // 1. GV Chủ nhiệm
        boolean isHomeroom = studentClass.getEffectiveHomeroomTeacher() != null
                && studentClass.getEffectiveHomeroomTeacher().getId().equals(teacher.getId());

        if (isHomeroom) {
            return;
        }

        // 2. Phân công giảng dạy
        boolean isAssigned = !teachingAssignmentRepository
                .findByTeacherIdAndSchoolClassIdAndAcademicYearIsCurrentTrue(teacher.getId(), studentClass.getId())
                .isEmpty();

        if (!isAssigned) {
            throw new AccessDeniedException("Giáo viên không có phân công giảng dạy hoặc chủ nhiệm lớp của học sinh này.");
        }
    }

    @Transactional
    public List<Marks> saveBulkMarks(BulkMarksRequest request, String currentUsername, boolean isTeacher) {
        if (request == null || request.getRecords() == null || request.getRecords().isEmpty()) {
            return new ArrayList<>();
        }

        // 1. Resolve Exam
        Exam exam = null;
        if (request.getExamId() != null) {
            exam = examRepository.findById(request.getExamId()).orElse(null);
        } else if (request.getAssessmentId() != null) {
            try {
                Long parsedId = Long.parseLong(request.getAssessmentId());
                exam = examRepository.findById(parsedId).orElse(null);
            } catch (NumberFormatException ignored) {}
        }

        if (exam == null) {
            String examName = (request.getAssessmentId() != null && !request.getAssessmentId().isBlank())
                    ? "Assessment " + request.getAssessmentId()
                    : "Regular Assessment";
            List<Exam> existingExams = examRepository.findAll();
            if (!existingExams.isEmpty()) {
                exam = existingExams.get(0);
            } else {
                exam = new Exam();
                exam.setName(examName);
                exam = examRepository.save(exam);
            }
        }

        // 2. Resolve Subject
        Subject subject = null;
        if (request.getSubjectId() != null) {
            subject = subjectRepository.findById(request.getSubjectId()).orElse(null);
        } else if (request.getSubject() != null && !request.getSubject().isBlank()) {
            subject = subjectRepository.findByName(request.getSubject())
                    .orElseGet(() -> {
                        Subject newSub = new Subject();
                        newSub.setName(request.getSubject());
                        return subjectRepository.save(newSub);
                    });
        }

        if (subject == null) {
            List<Subject> existingSubjects = subjectRepository.findAll();
            if (!existingSubjects.isEmpty()) {
                subject = existingSubjects.get(0);
            } else {
                Subject defaultSub = new Subject();
                defaultSub.setName("General");
                subject = subjectRepository.save(defaultSub);
            }
        }

        BigDecimal maxScore = request.getMaxMarks() != null ? request.getMaxMarks() : BigDecimal.valueOf(100.00);

        List<Marks> savedMarks = new ArrayList<>();
        for (BulkMarksRequest.Record rec : request.getRecords()) {
            if (rec.getStudentId() == null) continue;

            Student student = studentRepository.findById(rec.getStudentId()).orElse(null);
            if (student == null) continue;

            if (isTeacher) {
                verifyTeacherAuthorizedForStudent(student, currentUsername);
            }

            Marks mark = marksRepository.findByStudentIdAndExamIdAndSubjectId(student.getId(), exam.getId(), subject.getId())
                    .orElse(new Marks());

            mark.setStudent(student);
            mark.setExam(exam);
            mark.setSubject(subject);
            mark.setScore(rec.getMarksObtained());
            mark.setMaxScore(maxScore);

            savedMarks.add(marksRepository.save(mark));
        }

        return savedMarks;
    }

    public List<StudentMarkResponse> getMarksByStudentId(Long studentId, String currentUsername, boolean isParent, boolean isTeacher) {
        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Student not found"));

        if (isParent) {
            boolean isAuthorized = false;
            // 1. ReBAC: Kiểm tra qua bảng nối guardian_students
            Optional<Parent> parentOpt = parentRepository.findByPhone(currentUsername);
            if (parentOpt.isPresent()) {
                isAuthorized = guardianStudentRepository.findByGuardianIdAndStudentId(parentOpt.get().getId(), studentId).isPresent();
            }
            // 2. Fallback: Kiểm tra qua cột parent_id cũ có ghi log
            if (!isAuthorized) {
                log.warn("[DUAL-READ FALLBACK] Checking legacy parent_id for parent={} on studentId={}", currentUsername, studentId);
                isAuthorized = student.getParent() != null
                        && student.getParent().getPhone() != null
                        && student.getParent().getPhone().equals(currentUsername);
            }
            if (!isAuthorized) {
                throw new AccessDeniedException("Bạn không có quyền xem điểm của học sinh này.");
            }
        } else if (isTeacher) {
            verifyTeacherAuthorizedForStudent(student, currentUsername);
        }

        List<Marks> marksList = marksRepository.findByStudentId(studentId);
        return marksList.stream().map(m -> {
            BigDecimal maxScore = m.getMaxScore() != null ? m.getMaxScore() : BigDecimal.valueOf(100.00);
            String grade = calculateGrade(m.getScore(), maxScore);

            return StudentMarkResponse.builder()
                    .id(m.getId())
                    .studentId(student.getId())
                    .studentName(student.getName())
                    .examId(m.getExam() != null ? m.getExam().getId() : null)
                    .examName(m.getExam() != null ? m.getExam().getName() : "N/A")
                    .subjectId(m.getSubject() != null ? m.getSubject().getId() : null)
                    .subject(m.getSubject() != null ? m.getSubject().getName() : "N/A")
                    .marksObtained(m.getScore())
                    .maxMarks(maxScore)
                    .grade(grade)
                    .build();
        }).collect(Collectors.toList());
    }

    private String calculateGrade(BigDecimal score, BigDecimal maxScore) {
        if (score == null || maxScore == null || maxScore.compareTo(BigDecimal.ZERO) <= 0) {
            return "N/A";
        }
        BigDecimal percentage = score.multiply(BigDecimal.valueOf(100)).divide(maxScore, 2, RoundingMode.HALF_UP);
        if (percentage.compareTo(BigDecimal.valueOf(90)) >= 0) return "A+";
        if (percentage.compareTo(BigDecimal.valueOf(80)) >= 0) return "A";
        if (percentage.compareTo(BigDecimal.valueOf(70)) >= 0) return "B";
        if (percentage.compareTo(BigDecimal.valueOf(60)) >= 0) return "C";
        if (percentage.compareTo(BigDecimal.valueOf(50)) >= 0) return "D";
        return "F";
    }
}
