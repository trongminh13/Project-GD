package com.school.backend.payload.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Dữ liệu điểm học bạ của một môn trong cả năm học.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubjectMarkbookDto {

    private Long subjectId;
    private String subjectName;

    /** Điểm HK1 (null nếu chưa nhập). */
    private SemesterMarkDto semester1;

    /** Điểm HK2 (null nếu chưa nhập). */
    private SemesterMarkDto semester2;

    /**
     * Điểm trung bình cả năm (TT22/2021):
     * DTB_nam = (DTB_HK1 + DTB_HK2×2) / 3
     */
    private BigDecimal yearAvg;

    /**
     * Xếp loại học lực môn:
     * - Tiểu học: "Hoàn thành tốt" / "Hoàn thành" / "Chưa hoàn thành"
     * - THCS: "Giỏi" / "Khá" / "Trung bình" / "Yếu" / "Kém"
     * - THPT: "Xuất sắc" / "Giỏi" / "Khá" / "Trung bình" / "Yếu" / "Kém"
     */
    private String academicClassification;
}
