package com.school.backend.service;

import com.school.backend.entity.*;
import com.school.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@Service
public class ParentHomeworkService {

    @Autowired
    private ParentRepository parentRepository;

    @Autowired
    private GuardianStudentRepository guardianStudentRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private HomeworkAssignmentRepository homeworkAssignmentRepository;

    @Autowired
    private SubmissionRepository submissionRepository;

    public List<Map<String, Object>> getWardHomework(Long studentId, String parentUsername) {
        Parent parent = parentRepository.findByPhone(parentUsername)
                .or(() -> parentRepository.findAll().stream()
                        .filter(p -> p.getUser() != null && parentUsername.equals(p.getUser().getUsername()))
                        .findFirst())
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ phụ huynh không tồn tại."));

        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Học sinh không tồn tại."));

        // ReBAC Security: Kiểm tra phụ huynh có liên kết giám hộ với học sinh này
        boolean isLinked = guardianStudentRepository.findByGuardianIdAndStudentId(parent.getId(), studentId).isPresent();
        if (!isLinked) {
            // Fallback bảng cũ
            if (student.getParent() == null || !student.getParent().getId().equals(parent.getId())) {
                throw new AccessDeniedException("Bạn không phải người giám hộ hợp pháp của học sinh này.");
            }
        }

        SchoolClass studentClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                .map(Enrollment::getSchoolClass)
                .orElse(student.getSchoolClass());

        if (studentClass == null) {
            return Collections.emptyList();
        }

        List<HomeworkAssignment> assignments = homeworkAssignmentRepository
                .findBySchoolClassIdAndStatus(studentClass.getId(), "ACTIVE");

        List<Map<String, Object>> result = new ArrayList<>();
        for (HomeworkAssignment ha : assignments) {
            Optional<Submission> subOpt = submissionRepository.findByAssignmentIdAndStudentId(ha.getId(), student.getId());
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("assignmentId", ha.getId());
            map.put("homeworkId", ha.getHomework().getId());
            map.put("title", ha.getHomework().getTitle());
            map.put("description", ha.getHomework().getDescription());
            map.put("subjectName", ha.getHomework().getSubject().getName());
            map.put("teacherName", ha.getAssignedByTeacher().getName());
            map.put("dueDate", ha.getDueDate());

            if (subOpt.isPresent()) {
                Submission sub = subOpt.get();
                map.put("submissionId", sub.getId());
                map.put("submissionStatus", sub.getStatus());
                map.put("autoScore", sub.getAutoScore());
                map.put("finalScore", sub.getFinalScore());
                map.put("isLate", sub.getIsLate());
                map.put("submittedAt", sub.getSubmittedAt());
                map.put("teacherFeedback", sub.getTeacherFeedback());
            } else {
                map.put("submissionId", null);
                map.put("submissionStatus", "NOT_STARTED");
                map.put("autoScore", null);
                map.put("finalScore", null);
                map.put("isLate", false);
                map.put("submittedAt", null);
                map.put("teacherFeedback", null);
            }
            result.add(map);
        }
        return result;
    }
}
