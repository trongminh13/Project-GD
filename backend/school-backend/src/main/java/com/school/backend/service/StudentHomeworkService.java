package com.school.backend.service;

import com.school.backend.entity.*;
import com.school.backend.payload.request.AnswerSubmitRequest;
import com.school.backend.payload.request.SubmissionSubmitRequest;
import com.school.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.Normalizer;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class StudentHomeworkService {

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EnrollmentRepository enrollmentRepository;

    @Autowired
    private HomeworkAssignmentRepository homeworkAssignmentRepository;

    @Autowired
    private SubmissionRepository submissionRepository;

    @Autowired
    private AnswerRepository answerRepository;

    @Autowired
    private AnswerOptionRepository answerOptionRepository;

    @Autowired
    private QuestionRepository questionRepository;

    @Autowired
    private QuestionOptionRepository questionOptionRepository;

    private Student getStudentByUser(String studentUsername) {
        User user = userRepository.findByUsername(studentUsername)
                .orElseThrow(() -> new AccessDeniedException("Người dùng không tồn tại."));
        return studentRepository.findByUserId(user.getId())
                .orElseThrow(() -> new AccessDeniedException("Hồ sơ học sinh không tồn tại."));
    }

    public List<Map<String, Object>> getMyAssignments(String studentUsername) {
        Student student = getStudentByUser(studentUsername);

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
            map.put("allowLateSubmission", ha.getAllowLateSubmission());

            if (subOpt.isPresent()) {
                Submission sub = subOpt.get();
                map.put("submissionId", sub.getId());
                map.put("submissionStatus", sub.getStatus()); // IN_PROGRESS, SUBMITTED, GRADED
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

    @Transactional
    public Map<String, Object> getAssignmentForTaking(Long assignmentId, String studentUsername) {
        Student student = getStudentByUser(studentUsername);
        HomeworkAssignment ha = homeworkAssignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new NoSuchElementException("Lần giao bài không tồn tại."));

        SchoolClass studentClass = enrollmentRepository.findByStudentIdAndAcademicYearIsCurrentTrue(student.getId())
                .map(Enrollment::getSchoolClass)
                .orElse(student.getSchoolClass());

        if (studentClass == null || !studentClass.getId().equals(ha.getSchoolClass().getId())) {
            throw new AccessDeniedException("Học sinh không thuộc lớp học được giao bài tập này.");
        }

        Submission sub = submissionRepository.findByAssignmentIdAndStudentId(ha.getId(), student.getId())
                .orElseGet(() -> {
                    Submission newSub = new Submission();
                    newSub.setAssignment(ha);
                    newSub.setStudent(student);
                    newSub.setAttemptNumber(1);
                    newSub.setStatus("IN_PROGRESS");
                    newSub.setStartedAt(LocalDateTime.now());
                    return submissionRepository.save(newSub);
                });

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("assignmentId", ha.getId());
        response.put("dueDate", ha.getDueDate());
        response.put("allowLateSubmission", ha.getAllowLateSubmission());
        response.put("homeworkTitle", ha.getHomework().getTitle());
        response.put("homeworkDescription", ha.getHomework().getDescription());
        response.put("subjectName", ha.getHomework().getSubject().getName());
        response.put("totalPoints", ha.getHomework().getTotalPoints());
        response.put("submissionId", sub.getId());
        response.put("submissionStatus", sub.getStatus());
        response.put("isLate", sub.getIsLate());
        response.put("autoScore", sub.getAutoScore());
        response.put("finalScore", sub.getFinalScore());
        response.put("teacherFeedback", sub.getTeacherFeedback());

        // Lấy câu hỏi (CHỈ trả về isCorrect nếu trạng thái đã GRADED hoặc SUBMITTED)
        boolean showAnswers = "GRADED".equals(sub.getStatus()) || "SUBMITTED".equals(sub.getStatus());
        List<Map<String, Object>> questionsList = new ArrayList<>();
        for (Question q : ha.getHomework().getQuestions()) {
            Map<String, Object> qMap = new LinkedHashMap<>();
            qMap.put("id", q.getId());
            qMap.put("questionOrder", q.getQuestionOrder());
            qMap.put("questionType", q.getQuestionType());
            qMap.put("content", q.getContent());
            qMap.put("points", q.getPoints());
            if (showAnswers) {
                qMap.put("correctAnswerText", q.getCorrectAnswerText());
                qMap.put("explanation", q.getExplanation());
            }

            List<Map<String, Object>> optList = new ArrayList<>();
            for (QuestionOption opt : q.getOptions()) {
                Map<String, Object> optMap = new LinkedHashMap<>();
                optMap.put("id", opt.getId());
                optMap.put("optionOrder", opt.getOptionOrder());
                optMap.put("content", opt.getContent());
                if (showAnswers) {
                    optMap.put("isCorrect", opt.getIsCorrect());
                }
                optList.add(optMap);
            }
            qMap.put("options", optList);
            questionsList.add(qMap);
        }
        response.put("questions", questionsList);

        // Lấy các câu trả lời học sinh đã lưu trước đó
        List<Answer> savedAnswers = answerRepository.findBySubmissionId(sub.getId());
        List<Map<String, Object>> answerList = new ArrayList<>();
        for (Answer a : savedAnswers) {
            Map<String, Object> aMap = new LinkedHashMap<>();
            aMap.put("questionId", a.getQuestion().getId());
            aMap.put("answerText", a.getAnswerText());
            aMap.put("score", a.getScore());
            aMap.put("teacherNote", a.getTeacherNote());
            List<Long> selectedOptIds = a.getSelectedOptions().stream()
                    .map(ao -> ao.getOption().getId())
                    .collect(Collectors.toList());
            aMap.put("selectedOptionIds", selectedOptIds);
            answerList.add(aMap);
        }
        response.put("savedAnswers", answerList);

        return response;
    }

    @Transactional
    public Submission saveDraft(Long submissionId, SubmissionSubmitRequest req, String studentUsername) {
        Student student = getStudentByUser(studentUsername);
        Submission sub = submissionRepository.findById(submissionId)
                .orElseThrow(() -> new NoSuchElementException("Bài làm không tồn tại."));

        if (!sub.getStudent().getId().equals(student.getId())) {
            throw new AccessDeniedException("Bạn không thể sửa bài làm của người khác.");
        }
        if ("SUBMITTED".equals(sub.getStatus()) || "GRADED".equals(sub.getStatus())) {
            throw new IllegalStateException("Bài tập đã nộp, không thể lưu nháp.");
        }

        saveAnswersFromRequest(sub, req);
        return submissionRepository.save(sub);
    }

    @Transactional
    public Submission submitHomework(Long submissionId, SubmissionSubmitRequest req, String studentUsername) {
        Student student = getStudentByUser(studentUsername);
        Submission sub = submissionRepository.findById(submissionId)
                .orElseThrow(() -> new NoSuchElementException("Bài làm không tồn tại."));

        if (!sub.getStudent().getId().equals(student.getId())) {
            throw new AccessDeniedException("Bạn không thể nộp bài làm của người khác.");
        }
        if ("SUBMITTED".equals(sub.getStatus()) || "GRADED".equals(sub.getStatus())) {
            throw new IllegalStateException("Bài tập đã nộp trước đó.");
        }

        HomeworkAssignment ha = sub.getAssignment();
        LocalDateTime now = LocalDateTime.now();
        if (now.isAfter(ha.getDueDate())) {
            if (!Boolean.TRUE.equals(ha.getAllowLateSubmission())) {
                throw new IllegalArgumentException("Đã quá thời hạn nộp bài tập và không cho phép nộp muộn.");
            }
            sub.setIsLate(true);
        } else {
            sub.setIsLate(false);
        }

        // Lưu câu trả lời từ request
        saveAnswersFromRequest(sub, req);

        // Chạy thuật toán Tự động chấm điểm (Auto-Grading)
        double autoScore = 0.0;
        boolean hasEssay = false;

        List<Question> questions = ha.getHomework().getQuestions();
        for (Question q : questions) {
            Optional<Answer> ansOpt = answerRepository.findBySubmissionIdAndQuestionId(sub.getId(), q.getId());
            if (ansOpt.isEmpty()) {
                continue;
            }
            Answer ans = ansOpt.get();

            if ("SINGLE_CHOICE".equals(q.getQuestionType()) || "TRUE_FALSE".equals(q.getQuestionType())) {
                Optional<QuestionOption> correctOpt = q.getOptions().stream()
                        .filter(QuestionOption::getIsCorrect)
                        .findFirst();

                boolean isCorrect = false;
                if (correctOpt.isPresent() && !ans.getSelectedOptions().isEmpty()) {
                    Long selectedId = ans.getSelectedOptions().get(0).getOption().getId();
                    isCorrect = selectedId.equals(correctOpt.get().getId());
                }

                ans.setIsAutoGraded(true);
                ans.setScore(isCorrect ? q.getPoints() : 0.0);
                autoScore += ans.getScore();
                answerRepository.save(ans);

            } else if ("MULTIPLE_CHOICE".equals(q.getQuestionType())) {
                Set<Long> correctIds = q.getOptions().stream()
                        .filter(QuestionOption::getIsCorrect)
                        .map(QuestionOption::getId)
                        .collect(Collectors.toSet());

                Set<Long> selectedIds = ans.getSelectedOptions().stream()
                        .map(ao -> ao.getOption().getId())
                        .collect(Collectors.toSet());

                boolean isAllCorrect = correctIds.equals(selectedIds);
                ans.setIsAutoGraded(true);
                ans.setScore(isAllCorrect ? q.getPoints() : 0.0);
                autoScore += ans.getScore();
                answerRepository.save(ans);

            } else if ("SHORT_ANSWER".equals(q.getQuestionType())) {
                boolean isCorrect = checkShortAnswer(ans.getAnswerText(), q.getCorrectAnswerText());
                ans.setIsAutoGraded(true);
                ans.setScore(isCorrect ? q.getPoints() : 0.0);
                autoScore += ans.getScore();
                answerRepository.save(ans);

            } else if ("ESSAY".equals(q.getQuestionType())) {
                hasEssay = true;
                ans.setIsAutoGraded(false);
                ans.setScore(null); // chờ giáo viên chấm
                answerRepository.save(ans);
            }
        }

        sub.setAutoScore(Math.round(autoScore * 100.0) / 100.0);
        sub.setSubmittedAt(now);

        if (!hasEssay) {
            sub.setFinalScore(sub.getAutoScore());
            sub.setStatus("GRADED");
        } else {
            sub.setFinalScore(null);
            sub.setStatus("SUBMITTED");
        }

        return submissionRepository.save(sub);
    }

    private boolean checkShortAnswer(String studentAnswer, String correctAnswerText) {
        if (studentAnswer == null || correctAnswerText == null) return false;
        String normalizedStudent = Normalizer.normalize(studentAnswer.trim(), Normalizer.Form.NFC).replaceAll("\\s+", " ").toLowerCase();
        String[] possibleAnswers = correctAnswerText.split("\\|");
        for (String expected : possibleAnswers) {
            String normalizedExpected = Normalizer.normalize(expected.trim(), Normalizer.Form.NFC).replaceAll("\\s+", " ").toLowerCase();
            if (normalizedStudent.equals(normalizedExpected)) {
                return true;
            }
        }
        return false;
    }

    private void saveAnswersFromRequest(Submission sub, SubmissionSubmitRequest req) {
        if (req == null || req.getAnswers() == null) return;

        for (AnswerSubmitRequest aReq : req.getAnswers()) {
            Question question = questionRepository.findById(aReq.getQuestionId())
                    .orElseThrow(() -> new NoSuchElementException("Câu hỏi không tồn tại."));

            if (question.getHomework() == null || !question.getHomework().getId().equals(sub.getAssignment().getHomework().getId())) {
                throw new IllegalArgumentException("Câu hỏi ID " + aReq.getQuestionId() + " không thuộc bài tập này.");
            }

            Answer ans = answerRepository.findBySubmissionIdAndQuestionId(sub.getId(), question.getId())
                    .orElseGet(() -> {
                        Answer newAns = new Answer();
                        newAns.setSubmission(sub);
                        newAns.setQuestion(question);
                        return newAns;
                    });

            ans.setAnswerText(aReq.getAnswerText());
            ans.getSelectedOptions().clear();

            if (aReq.getSelectedOptionIds() != null) {
                for (Long optId : aReq.getSelectedOptionIds()) {
                    questionOptionRepository.findById(optId).ifPresent(opt -> {
                        if (opt.getQuestion() != null && opt.getQuestion().getId().equals(question.getId())) {
                            AnswerOption ao = new AnswerOption();
                            ao.setAnswer(ans);
                            ao.setOption(opt);
                            ans.getSelectedOptions().add(ao);
                        }
                    });
                }
            }
            answerRepository.save(ans);
        }
    }
}
