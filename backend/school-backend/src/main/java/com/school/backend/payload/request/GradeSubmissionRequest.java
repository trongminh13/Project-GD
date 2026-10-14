package com.school.backend.payload.request;

import lombok.Data;
import java.util.List;

@Data
public class GradeSubmissionRequest {
    private String teacherFeedback;
    private List<AnswerGradeRequest> answerGrades;
}
