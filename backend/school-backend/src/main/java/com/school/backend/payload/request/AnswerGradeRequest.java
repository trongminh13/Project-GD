package com.school.backend.payload.request;

import lombok.Data;

@Data
public class AnswerGradeRequest {
    private Long answerId;
    private Double score;
    private String teacherNote;
}
