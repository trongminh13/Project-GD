package com.school.backend.service;

import com.school.backend.entity.*;
import com.school.backend.payload.request.*;
import com.school.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class HomeworkService {

    @Autowired
    private HomeworkRepository homeworkRepository;

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private QuestionOptionRepository questionOptionRepository;

    @Autowired
    private HomeworkAssignmentRepository homeworkAssignmentRepository;

    @Autowired
    private SubmissionRepository submissionRepository;

    @Autowired
    private AnswerRepository answerRepository;

    @Autowired
    private TeacherRepository teacherRepository;

    @Autowired
    private SubjectRepository subjectRepository;

    @Autowired
    private SchoolClassRepository schoolClassRepository;

    @Autowired
    private TeachingAssignmentRepository teachingAssignmentRepository;

    @Transactional
    public Homework createHomework(HomeworkCreateRequest req, String teacherUsername) {
        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

        Subject subject = subjectRepository.findById(req.getSubjectId())
                .orElseThrow(() -> new IllegalArgumentException("Môn học không tồn tại."));

        Homework hw = new Homework();
        hw.setSubject(subject);
        hw.setCreatedByTeacher(teacher);
        hw.setTitle(req.getTitle());
        hw.setDescription(req.getDescription());
        hw.setNotes(req.getNotes());
        hw.setTotalPoints(req.getTotalPoints() != null ? req.getTotalPoints() : 10.0);

        List<Question> questions = new ArrayList<>();
        if (req.getQuestions() != null) {
            int order = 1;
            for (QuestionCreateRequest qReq : req.getQuestions()) {
                Question q = new Question();
                q.setHomework(hw);
                q.setQuestionOrder(qReq.getQuestionOrder() != null ? qReq.getQuestionOrder() : order++);
                q.setQuestionType(qReq.getQuestionType());
                q.setContent(qReq.getContent());
                q.setPoints(qReq.getPoints() != null ? qReq.getPoints() : 1.0);
                q.setCorrectAnswerText(qReq.getCorrectAnswerText());
                q.setExplanation(qReq.getExplanation());

                List<QuestionOption> options = new ArrayList<>();
                if (qReq.getOptions() != null) {
                    int optOrder = 1;
                    for (OptionCreateRequest optReq : qReq.getOptions()) {
                        QuestionOption opt = new QuestionOption();
                        opt.setQuestion(q);
                        opt.setOptionOrder(optReq.getOptionOrder() != null ? optReq.getOptionOrder() : optOrder++);
                        opt.setContent(optReq.getContent());
                        opt.setIsCorrect(optReq.getIsCorrect() != null ? optReq.getIsCorrect() : false);
                        options.add(opt);
                    }
                }
                q.setOptions(options);
                questions.add(q);
            }
        }
        hw.setQuestions(questions);
        return homeworkRepository.save(hw);
    }

    public List<Homework> getMyCreatedHomework(String teacherUsername) {
        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));
        return homeworkRepository.findByCreatedByTeacherIdOrderByCreatedAtDesc(teacher.getId());
    }

    public Homework getHomeworkDetails(Long homeworkId, String teacherUsername) {
        Homework hw = homeworkRepository.findById(homeworkId)
                .orElseThrow(() -> new NoSuchElementException("Bài tập không tồn tại."));
        return hw;
    }

    @Transactional
    public HomeworkAssignment assignHomework(Long homeworkId, HomeworkAssignRequest req, String teacherUsername) {
        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

        Homework hw = homeworkRepository.findById(homeworkId)
                .orElseThrow(() -> new NoSuchElementException("Bài tập không tồn tại."));

        SchoolClass sc = schoolClassRepository.findById(req.getClassId())
                .orElseThrow(() -> new IllegalArgumentException("Lớp học không tồn tại."));

        // ReBAC Security Check:
        // Giáo viên phải được phân công dạy môn này cho lớp trong năm hiện tại,
        // HOẶC là giáo viên chủ nhiệm của lớp.
        boolean isHomeroom = sc.getEffectiveHomeroomTeacher() != null
                && sc.getEffectiveHomeroomTeacher().getId().equals(teacher.getId());

        boolean isAssignedSubject = teachingAssignmentRepository
                .findByTeacherIdAndSchoolClassIdAndAcademicYearIsCurrentTrue(teacher.getId(), sc.getId())
                .stream().anyMatch(ta -> ta.getSubject().getId().equals(hw.getSubject().getId()));

        if (!isHomeroom && !isAssignedSubject) {
            throw new AccessDeniedException("Bạn không được phân công dạy môn " + hw.getSubject().getName()
                    + " cho lớp " + sc.getName() + " và không phải GVCN của lớp này.");
        }

        HomeworkAssignment assignment = homeworkAssignmentRepository
                .findByHomeworkIdAndSchoolClassId(hw.getId(), sc.getId())
                .orElse(new HomeworkAssignment());

        assignment.setHomework(hw);
        assignment.setSchoolClass(sc);
        assignment.setAssignedByTeacher(teacher);
        assignment.setDueDate(req.getDueDate());
        assignment.setStatus("ACTIVE");
        assignment.setAllowLateSubmission(req.getAllowLateSubmission() != null ? req.getAllowLateSubmission() : true);

        return homeworkAssignmentRepository.save(assignment);
    }

    public List<HomeworkAssignment> getTeacherAssignments(String teacherUsername) {
        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));
        return homeworkAssignmentRepository.findByAssignedByTeacherIdOrderByAssignedAtDesc(teacher.getId());
    }

    public List<Submission> getSubmissionsForAssignment(Long assignmentId, String teacherUsername) {
        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

        HomeworkAssignment assignment = homeworkAssignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new NoSuchElementException("Lần giao bài không tồn tại."));

        // ReBAC Check:
        SchoolClass sc = assignment.getSchoolClass();
        boolean isHomeroom = sc.getEffectiveHomeroomTeacher() != null
                && sc.getEffectiveHomeroomTeacher().getId().equals(teacher.getId());
        boolean isAssignedSubject = teachingAssignmentRepository
                .findByTeacherIdAndSchoolClassIdAndAcademicYearIsCurrentTrue(teacher.getId(), sc.getId())
                .stream().anyMatch(ta -> ta.getSubject().getId().equals(assignment.getHomework().getSubject().getId()));

        if (!isHomeroom && !isAssignedSubject) {
            throw new AccessDeniedException("Bạn không có quyền xem bài làm của lớp này.");
        }

        return submissionRepository.findByAssignmentIdOrderByStartedAtAsc(assignmentId);
    }

    public Submission getSubmissionDetails(Long submissionId, String teacherUsername) {
        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

        Submission sub = submissionRepository.findById(submissionId)
                .orElseThrow(() -> new NoSuchElementException("Bài làm không tồn tại."));

        SchoolClass sc = sub.getAssignment().getSchoolClass();
        boolean isHomeroom = sc.getEffectiveHomeroomTeacher() != null
                && sc.getEffectiveHomeroomTeacher().getId().equals(teacher.getId());
        boolean isAssignedSubject = teachingAssignmentRepository
                .findByTeacherIdAndSchoolClassIdAndAcademicYearIsCurrentTrue(teacher.getId(), sc.getId())
                .stream().anyMatch(ta -> ta.getSubject().getId().equals(sub.getAssignment().getHomework().getSubject().getId()));

        if (!isHomeroom && !isAssignedSubject) {
            throw new AccessDeniedException("Bạn không có quyền chấm bài làm của lớp này.");
        }

        return sub;
    }

    @Transactional
    public Submission gradeSubmission(Long submissionId, GradeSubmissionRequest req, String teacherUsername) {
        Submission sub = getSubmissionDetails(submissionId, teacherUsername);
        Teacher teacher = teacherRepository.findByUserUsername(teacherUsername)
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ giáo viên không tồn tại."));

        sub.setTeacherFeedback(req.getTeacherFeedback());

        if (req.getAnswerGrades() != null) {
            for (AnswerGradeRequest ag : req.getAnswerGrades()) {
                Answer ans = answerRepository.findById(ag.getAnswerId())
                        .orElseThrow(() -> new NoSuchElementException("Câu trả lời không tồn tại."));
                if (ans.getSubmission().getId().equals(sub.getId())) {
                    ans.setScore(ag.getScore());
                    ans.setTeacherNote(ag.getTeacherNote());
                    answerRepository.save(ans);
                }
            }
        }

        // Tính điểm tổng final_score = autoScore + điểm tự luận
        List<Answer> allAnswers = answerRepository.findBySubmissionId(sub.getId());
        double total = 0.0;
        for (Answer a : allAnswers) {
            if (a.getScore() != null) {
                total += a.getScore();
            }
        }

        sub.setFinalScore(Math.round(total * 100.0) / 100.0);
        sub.setStatus("GRADED");
        sub.setGradedByTeacher(teacher);
        sub.setGradedAt(LocalDateTime.now());

        return submissionRepository.save(sub);
    }
}
