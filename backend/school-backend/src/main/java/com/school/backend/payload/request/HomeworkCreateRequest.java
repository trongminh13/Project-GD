package com.school.backend.payload.request;

import lombok.Data;
import java.util.List;

@Data
public class HomeworkCreateRequest {
    private Long subjectId;
    private String title;
    private String description;
    private String notes;
    private Double totalPoints = 10.0;
    private List<QuestionCreateRequest> questions;
}
