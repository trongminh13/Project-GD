package com.school.backend.util;

import com.school.backend.enums.EducationLevel;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * Helper tính điểm trung bình và xếp loại học lực theo đúng quy chế
 * đánh giá của Bộ GD&ĐT Việt Nam:
 * - Thông tư 22/2021: THCS và THPT
 * - Thông tư 27/2020: Tiểu học
 */
public class MarksCalculationHelper {

    private MarksCalculationHelper() { /* utility class */ }

    /**
     * Tính điểm trung bình môn một học kỳ (THCS/THPT).
     * <p>
     * Công thức TT22/2021:
     * DTB_HK = (ΣTX×1 + GK×2 + CK×3) / (countTX + 2 + 3)
     * <p>
     * Nếu thiếu GK hoặc CK thì bỏ qua hệ số tương ứng.
     *
     * @param txScores danh sách điểm TX (có thể rỗng/null entry)
     * @param gkScore  điểm giữa kỳ (null nếu chưa có)
     * @param ckScore  điểm cuối kỳ (null nếu chưa có)
     * @return điểm trung bình, null nếu không đủ dữ liệu tính
     */
    public static BigDecimal calcSemesterAvg(
            List<BigDecimal> txScores,
            BigDecimal gkScore,
            BigDecimal ckScore) {

        BigDecimal totalWeight = BigDecimal.ZERO;
        BigDecimal totalScore = BigDecimal.ZERO;

        // TX hệ số 1
        if (txScores != null) {
            for (BigDecimal tx : txScores) {
                if (tx != null) {
                    totalScore = totalScore.add(tx);
                    totalWeight = totalWeight.add(BigDecimal.ONE);
                }
            }
        }

        // GK hệ số 2
        if (gkScore != null) {
            totalScore = totalScore.add(gkScore.multiply(BigDecimal.valueOf(2)));
            totalWeight = totalWeight.add(BigDecimal.valueOf(2));
        }

        // CK hệ số 3
        if (ckScore != null) {
            totalScore = totalScore.add(ckScore.multiply(BigDecimal.valueOf(3)));
            totalWeight = totalWeight.add(BigDecimal.valueOf(3));
        }

        if (totalWeight.compareTo(BigDecimal.ZERO) == 0) {
            return null;
        }

        return totalScore.divide(totalWeight, 1, RoundingMode.HALF_UP);
    }

    /**
     * Tính điểm trung bình môn cả năm (THCS/THPT).
     * <p>
     * Công thức TT22/2021:
     * DTB_nam = (DTB_HK1 + DTB_HK2×2) / 3
     *
     * @param hk1Avg điểm TB học kỳ 1 (null nếu chưa có)
     * @param hk2Avg điểm TB học kỳ 2 (null nếu chưa có)
     * @return điểm TB cả năm, null nếu không đủ dữ liệu
     */
    public static BigDecimal calcYearAvg(BigDecimal hk1Avg, BigDecimal hk2Avg) {
        if (hk1Avg == null && hk2Avg == null) {
            return null;
        }
        if (hk1Avg == null) {
            return hk2Avg;
        }
        if (hk2Avg == null) {
            return hk1Avg;
        }
        // HK1×1 + HK2×2 / 3
        BigDecimal total = hk1Avg.add(hk2Avg.multiply(BigDecimal.valueOf(2)));
        return total.divide(BigDecimal.valueOf(3), 1, RoundingMode.HALF_UP);
    }

    /**
     * Xếp loại học lực môn/tổng theo cấp học.
     * <p>
     * Tiểu học (TT27/2020):
     *   - Chỉ áp dụng với môn có điểm số (lớp 4-5).
     *   - ≥ 9.0 → "Hoàn thành tốt"; ≥ 5.0 → "Hoàn thành"; < 5.0 → "Chưa hoàn thành"
     * <p>
     * THCS/THPT (TT22/2021):
     *   - ≥ 9.0 → "Xuất sắc" (chỉ THPT)
     *   - ≥ 8.0 → "Giỏi"
     *   - ≥ 6.5 → "Khá"
     *   - ≥ 5.0 → "Trung bình"
     *   - ≥ 3.5 → "Yếu"
     *   - < 3.5 → "Kém"
     *
     * @param avg   điểm trung bình (null → trả "Chưa có điểm")
     * @param level cấp học
     * @return chuỗi xếp loại học lực
     */
    public static String classifyAcademic(BigDecimal avg, EducationLevel level) {
        if (avg == null) {
            return "Chưa có điểm";
        }

        double val = avg.doubleValue();

        switch (level) {
            case PRIMARY:
                if (val >= 9.0) return "Hoàn thành tốt";
                if (val >= 5.0) return "Hoàn thành";
                return "Chưa hoàn thành";

            case SECONDARY:
            case HIGH_SCHOOL:
            default:
                if (val >= 8.0) return "Tốt";
                if (val >= 6.5) return "Khá";
                if (val >= 5.0) return "Đạt";
                return "Chưa đạt";
        }
    }

    /**
     * Tính điểm trung bình chung tất cả các môn (dùng cho xếp loại học lực tổng).
     *
     * @param subjectAvgs danh sách DTB cả năm từng môn (bỏ qua null)
     * @return DTB chung, null nếu không có môn nào có điểm
     */
    public static BigDecimal calcOverallAvg(List<BigDecimal> subjectAvgs) {
        if (subjectAvgs == null || subjectAvgs.isEmpty()) {
            return null;
        }
        BigDecimal total = BigDecimal.ZERO;
        int count = 0;
        for (BigDecimal avg : subjectAvgs) {
            if (avg != null) {
                total = total.add(avg);
                count++;
            }
        }
        if (count == 0) return null;
        return total.divide(BigDecimal.valueOf(count), 1, RoundingMode.HALF_UP);
    }

    /**
     * Đánh giá kết quả học tập học kỳ / cả năm theo đúng Điều 9 Thông tư 22/2021/TT-BGDĐT.
     *
     * @param subjectAverages danh sách ĐTB các môn đánh giá bằng điểm số
     * @param countFailCommentSubjects số môn nhận xét bị Chưa đạt
     * @return 1 trong 4 mức chuẩn: "Tốt", "Khá", "Đạt", "Chưa đạt"
     */
    public static String evaluateAcademicResultTT22(
            List<BigDecimal> subjectAverages,
            int countFailCommentSubjects) {

        if (subjectAverages == null || subjectAverages.isEmpty()) {
            return "Chưa đủ điều kiện đánh giá";
        }

        List<BigDecimal> validScores = subjectAverages.stream()
                .filter(java.util.Objects::nonNull)
                .toList();

        if (validScores.isEmpty()) {
            return "Chưa có điểm";
        }

        double minScore = validScores.stream()
                .mapToDouble(BigDecimal::doubleValue)
                .min()
                .orElse(0.0);

        long countGte80 = validScores.stream()
                .filter(s -> s.doubleValue() >= 8.0)
                .count();

        long countGte65 = validScores.stream()
                .filter(s -> s.doubleValue() >= 6.5)
                .count();

        long countGte50 = validScores.stream()
                .filter(s -> s.doubleValue() >= 5.0)
                .count();

        int threshold = Math.min(6, validScores.size());

        // 1. Mức TỐT: 100% môn nhận xét Đạt, min >= 6.5, có >= 6 môn đạt >= 8.0
        if (countFailCommentSubjects == 0 && minScore >= 6.5 && countGte80 >= threshold) {
            return "Tốt";
        }

        // 2. Mức KHÁ: 100% môn nhận xét Đạt, min >= 5.0, có >= 6 môn đạt >= 6.5
        if (countFailCommentSubjects == 0 && minScore >= 5.0 && countGte65 >= threshold) {
            return "Khá";
        }

        // 3. Mức ĐẠT: Tối đa 1 môn nhận xét Chưa đạt, min >= 3.5, có >= 6 môn đạt >= 5.0
        if (countFailCommentSubjects <= 1 && minScore >= 3.5 && countGte50 >= threshold) {
            return "Đạt";
        }

        // 4. Mức CHƯA ĐẠT: Các trường hợp còn lại
        return "Chưa đạt";
    }

    /**
     * Xét danh hiệu khen thưởng học kỳ / cả năm theo đúng Điều 15 Thông tư 22/2021/TT-BGDĐT.
     * Bắt buộc kết quả rèn luyện (hạnh kiểm) phải được đánh giá mức TỐT.
     *
     * @param academicResult kết quả học tập ("Tốt", "Khá", "Đạt", "Chưa đạt")
     * @param conductResult kết quả rèn luyện ("Tốt", "Khá", "Đạt", "Chưa đạt")
     * @param subjectAverages danh sách ĐTB các môn điểm số
     * @return "Học sinh Xuất sắc", "Học sinh Giỏi", hoặc null
     */
    public static String evaluateHonorTitleTT22(
            String academicResult,
            String conductResult,
            List<BigDecimal> subjectAverages) {

        // Theo Điều 15 TT 22: Bắt buộc kết quả rèn luyện (hạnh kiểm) phải được đánh giá mức TỐT
        boolean isConductGood = conductResult != null && "Tốt".equalsIgnoreCase(conductResult.trim());
        boolean isAcademicGood = "Tốt".equalsIgnoreCase(academicResult != null ? academicResult.trim() : "");

        if (!isConductGood || !isAcademicGood) {
            return null;
        }

        if (subjectAverages != null && !subjectAverages.isEmpty()) {
            int threshold = Math.min(6, subjectAverages.size());
            long countGte90 = subjectAverages.stream()
                    .filter(java.util.Objects::nonNull)
                    .filter(s -> s.doubleValue() >= 9.0)
                    .count();

            if (countGte90 >= threshold) {
                return "Học sinh Xuất sắc";
            }
        }

        return "Học sinh Giỏi";
    }
}
