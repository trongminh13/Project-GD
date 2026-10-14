package com.school.backend.payload.request;

import lombok.Data;
import java.util.List;

@Data
public class SubmissionSubmitRequest {
    private List<AnswerSubmitRequest> answers;
}
