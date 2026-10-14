package com.school.backend.payload.request;

import lombok.Data;
import java.util.List;

@Data
public class AnswerSubmitRequest {
    private Long questionId;
    private String answerText;
    private List<Long> selectedOptionIds;
}
