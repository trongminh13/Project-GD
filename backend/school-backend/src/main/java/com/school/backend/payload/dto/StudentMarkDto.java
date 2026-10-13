package com.school.backend.payload.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StudentMarkDto {
    private String examName;
    private String subjectName;
    private BigDecimal score;
    private BigDecimal maxScore;
    private String grade;
}
