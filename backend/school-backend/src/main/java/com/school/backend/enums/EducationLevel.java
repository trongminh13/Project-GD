package com.school.backend.enums;

/**
 * Định nghĩa các cấp bậc học theo hệ thống giáo dục Việt Nam:
 * - PRIMARY: Tiểu học (Lớp 1 đến Lớp 5)
 * - SECONDARY: Trung học cơ sở / THCS (Lớp 6 đến Lớp 9)
 * - HIGH_SCHOOL: Trung học phổ thông / THPT (Lớp 10 đến Lớp 12)
 */
public enum EducationLevel {
    PRIMARY("Tiểu học", "Tiểu học", "Cấp 1", "Trường Tiểu học Đại Việt"),
    SECONDARY("Trung học cơ sở", "THCS", "Cấp 2", "Trường THCS Đại Việt"),
    HIGH_SCHOOL("Trung học phổ thông", "THPT", "Cấp 3", "Trường THPT Đại Việt");

    private final String fullName;
    private final String shortName;
    private final String levelLabel;
    private final String defaultSchoolName;

    EducationLevel(String fullName, String shortName, String levelLabel, String defaultSchoolName) {
        this.fullName = fullName;
        this.shortName = shortName;
        this.levelLabel = levelLabel;
        this.defaultSchoolName = defaultSchoolName;
    }

    public String getDisplayName() {
        return shortName;
    }

    public String getFullName() {
        return fullName;
    }

    public String getShortName() {
        return shortName;
    }

    public String getLevelLabel() {
        return levelLabel;
    }

    public String getDefaultSchoolName() {
        return defaultSchoolName;
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
