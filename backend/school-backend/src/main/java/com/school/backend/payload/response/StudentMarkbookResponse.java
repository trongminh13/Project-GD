package com.school.backend.payload.response;

import com.school.backend.payload.dto.SubjectMarkbookDto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

/**
 * Response học bạ đầy đủ của một học sinh trong một năm học.
 * Bao gồm điểm tất cả các môn, điểm trung bình chung và xếp loại học lực.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StudentMarkbookResponse {

    private Long studentId;
    private String studentName;
    private String studentAdmissionNumber;

    /** Tên năm học, ví dụ: "2024-2025". */
    private String academicYear;

    /** Cấp học: "PRIMARY", "SECONDARY", "HIGH_SCHOOL". */
    private String educationLevel;

    /** Tên cấp học tiếng Việt: "Tiểu học", "THCS", "THPT". */
    private String educationLevelDisplayName;

    /** Tên lớp, ví dụ: "10A1". */
    private String className;

    /** Tên trường. */
    private String schoolName;

    /** Danh sách điểm theo từng môn học. */
    private List<SubjectMarkbookDto> subjects;

    /**
     * Điểm trung bình chung cả năm (trung bình cộng DTB_nam tất cả các môn).
     */
    private BigDecimal overallAvg;

    /**
     * Xếp loại học lực tổng:
     * - Tiểu học: "Hoàn thành tốt" / "Hoàn thành" / "Chưa hoàn thành"
     * - THCS: "Giỏi" / "Khá" / "Trung bình" / "Yếu" / "Kém"
     * - THPT: "Xuất sắc" / "Giỏi" / "Khá" / "Trung bình" / "Yếu" / "Kém"
     */
    private String overallClassification;

    /**
     * Hạnh kiểm (conduct): "Tốt" / "Khá" / "Trung bình" / "Yếu".
     * Chưa tự động tính – do giáo viên chủ nhiệm nhập thủ công.
     */
    private String conduct;

    /**
     * Danh hiệu khen thưởng (TT 22/2021): "Học sinh Xuất sắc", "Học sinh Giỏi" hoặc null.
     */
    private String honorTitle;
}
