package com.school.backend.payload.request;

import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class BulkMarksRequest {
    private String className;
    private Long examId;
    private String assessmentId;
    private Long subjectId;
    private String subject;
    private BigDecimal maxMarks;

    @JsonAlias({"marks", "records"})
    private List<Record> records;

    @Data
    public static class Record {
        @JsonAlias({"studentId", "id"})
        private Long studentId;
        private BigDecimal marksObtained;
        private String remarks;
    }
}
