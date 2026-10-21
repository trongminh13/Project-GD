package com.school.backend.payload.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

/**
 * Dữ liệu điểm số một học kỳ của một môn học.
 * Cấu trúc theo Thông tư 22/2021 (THCS/THPT).
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SemesterMarkDto {

    private Integer semester;   // 1 hoặc 2

    /** Danh sách điểm thường xuyên, theo thứ tự txIndex. */
    private List<BigDecimal> txScores;

    /** Điểm giữa kỳ (GK, hệ số 2). */
    private BigDecimal gkScore;

    /** Điểm cuối kỳ (CK, hệ số 3). */
    private BigDecimal ckScore;

    /**
     * Điểm trung bình học kỳ (tính theo công thức TT22):
     * DTB_HK = (ΣTX + GK×2 + CK×3) / (countTX + 2 + 3)
     */
    private BigDecimal avg;

    /** Nhận xét văn bản (dùng cho Tiểu học lớp 1-3). */
    private List<String> comments;
}
