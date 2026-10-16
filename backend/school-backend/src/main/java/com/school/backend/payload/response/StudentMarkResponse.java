package com.school.backend.payload.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StudentMarkResponse {
    private Long id;
    private Long studentId;
    private String studentName;
    private Long examId;
    private String examName;
    private Long subjectId;
    private String subject;
    private BigDecimal marksObtained;
    private BigDecimal maxMarks;
    private String grade;
}
