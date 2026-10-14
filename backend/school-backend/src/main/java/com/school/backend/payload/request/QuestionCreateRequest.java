package com.school.backend.payload.request;

import lombok.Data;
import java.util.List;

@Data
public class QuestionCreateRequest {
    private Integer questionOrder;
    private String questionType; // SINGLE_CHOICE, MULTIPLE_CHOICE, TRUE_FALSE, ESSAY
    private String content;
    private Double points = 1.0;
    private String correctAnswerText;
    private String explanation;
    private List<OptionCreateRequest> options;
}
