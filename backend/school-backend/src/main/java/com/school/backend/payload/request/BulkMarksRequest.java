package com.school.backend.payload.request;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.school.backend.enums.ExamType;
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

    /** Năm học liên kết – nếu null sẽ tự động gán năm học hiện tại */
    private Long academicYearId;

    /** Học kỳ (1 hoặc 2, mặc định 1) */
    private Integer semester = 1;

    /** Loại điểm: THUONG_XUYEN, GIUA_KY, CUOI_KY, NHAN_XET (mặc định THUONG_XUYEN) */
    private ExamType examType = ExamType.THUONG_XUYEN;

    /** Thứ tự cột điểm thường xuyên (1, 2, 3...) */
    private Integer txIndex;

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
