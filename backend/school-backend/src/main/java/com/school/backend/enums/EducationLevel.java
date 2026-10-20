package com.school.backend.enums;

/**
 * Định nghĩa các cấp bậc học theo hệ thống giáo dục Việt Nam:
 * - PRIMARY: Tiểu học (Lớp 1 đến Lớp 5)
 * - SECONDARY: Trung học cơ sở / THCS (Lớp 6 đến Lớp 9)
 * - HIGH_SCHOOL: Trung học phổ thông / THPT (Lớp 10 đến Lớp 12)
 */
public enum EducationLevel {
    PRIMARY("Tiểu học", "Cấp 1"),
    SECONDARY("THCS", "Cấp 2"),
    HIGH_SCHOOL("THPT", "Cấp 3");

    private final String displayName;
    private final String levelLabel;

    EducationLevel(String displayName, String levelLabel) {
        this.displayName = displayName;
        this.levelLabel = levelLabel;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getLevelLabel() {
        return levelLabel;
    }

    /**
     * Suy diễn cấp bậc học dựa trên khối lớp (grade).
     * Hỗ trợ các định dạng như: "1", "3", "10", "3A", "10-A1".
     */
    public static EducationLevel fromGrade(String gradeStr) {
        if (gradeStr == null || gradeStr.trim().isEmpty()) {
            return PRIMARY;
        }

        // Tách phần số từ chuỗi grade (ví dụ "10A1" -> "10")
        String numericOnly = gradeStr.replaceAll("[^0-9]", "");
        if (numericOnly.isEmpty()) {
            return PRIMARY;
        }

        try {
            int grade = Integer.parseInt(numericOnly);
            if (grade <= 5) {
                return PRIMARY;
            } else if (grade <= 9) {
                return SECONDARY;
            } else {
                return HIGH_SCHOOL;
            }
        } catch (NumberFormatException e) {
            return PRIMARY;
        }
    }
}
