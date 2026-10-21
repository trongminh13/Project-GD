package com.school.backend.enums;

/**
 * Loại cột điểm theo quy chế đánh giá của Bộ GD&ĐT Việt Nam:
 * - Thông tư 22/2021: áp dụng cho THCS và THPT
 * - Thông tư 27/2020: áp dụng cho Tiểu học
 */
public enum ExamType {

    /**
     * Điểm thường xuyên (TX) – hệ số 1.
     * THCS: mỗi HK có 4 cột TX / môn.
     * THPT: mỗi HK có 6 cột TX / môn (môn 2 tiết/tuần) hoặc 3-4 cột.
     */
    THUONG_XUYEN("Thường xuyên", 1),

    /**
     * Điểm giữa kỳ (GK) – hệ số 2.
     * Mỗi học kỳ có 1 cột giữa kỳ.
     */
    GIUA_KY("Giữa kỳ", 2),

    /**
     * Điểm cuối kỳ (CK) – hệ số 3.
     * Mỗi học kỳ có 1 cột cuối kỳ.
     */
    CUOI_KY("Cuối kỳ", 3),

    /**
     * Nhận xét – dành cho Tiểu học lớp 1-3 (TT27/2020).
     * Không có điểm số, chỉ có comment "Đạt" / "Chưa đạt".
     */
    NHAN_XET("Nhận xét", 0);

    private final String displayName;
    private final int coefficient;

    ExamType(String displayName, int coefficient) {
        this.displayName = displayName;
        this.coefficient = coefficient;
    }

    public String getDisplayName() {
        return displayName;
    }

    public int getCoefficient() {
        return coefficient;
    }
}
