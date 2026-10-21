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

    /** Loại cột điểm: THUONG_XUYEN / GIUA_KY / CUOI_KY / NHAN_XET */
    private String examType;

    /** Học kỳ: 1 hoặc 2 */
    private Integer semester;

    /** Thứ tự cột TX trong học kỳ */
    private Integer txIndex;

    /** Năm học tên, ví dụ: "2024-2025" */
    private String academicYear;

    /** Nhận xét (Tiểu học lớp 1-3) */
    private String comment;
}

