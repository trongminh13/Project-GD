package com.school.backend.payload.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
public class StudentMarkDto {
    private String examName;
    private String subjectName;
    private BigDecimal score;
    private BigDecimal maxScore;
    private String grade;

    public StudentMarkDto(String examName, String subjectName, BigDecimal score, BigDecimal maxScore, String grade) {
        this.examName = examName;
        this.subjectName = subjectName;
        this.score = score;
        this.maxScore = maxScore;
        this.grade = grade;
    }
}
