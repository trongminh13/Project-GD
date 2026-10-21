package com.school.backend.util;

import com.school.backend.enums.EducationLevel;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests cho MarksCalculationHelper.
 * Các test case theo đúng công thức Thông tư 22/2021 và Thông tư 27/2020.
 */
@DisplayName("MarksCalculationHelper – Công thức tính điểm theo TT22/TT27")
class MarksCalculationHelperTest {

    // ── calcSemesterAvg ──────────────────────────────────────────────────────

    @Test
    @DisplayName("TC-CALC-01: DTB HK1 THCS – 4 TX + 1 GK + 1 CK chuẩn")
    void testSemesterAvg_standardTHCS() {
        // 4 TX: 8, 7, 9, 8 → tổng TX = 32 (hệ số 1 mỗi cột)
        // GK: 7.5 (hệ số 2) → 15.0
        // CK: 8.0 (hệ số 3) → 24.0
        // Tổng = 32 + 15 + 24 = 71.0 / (4+2+3) = 71/9 ≈ 7.9
        List<BigDecimal> tx = Arrays.asList(
                bd(8), bd(7), bd(9), bd(8));
        BigDecimal gk = bd(7.5);
        BigDecimal ck = bd(8.0);

        BigDecimal result = MarksCalculationHelper.calcSemesterAvg(tx, gk, ck);

        assertNotNull(result);
        assertEquals(0, result.compareTo(bd(7.9)),
                "Kỳ vọng 7.9, thực tế: " + result);
    }

    @Test
    @DisplayName("TC-CALC-02: DTB HK khi chỉ có TX (chưa thi GK/CK)")
    void testSemesterAvg_txOnly() {
        List<BigDecimal> tx = Arrays.asList(bd(8), bd(9));
        BigDecimal result = MarksCalculationHelper.calcSemesterAvg(tx, null, null);
        // (8+9) / 2 = 8.5
        assertNotNull(result);
        assertEquals(0, result.compareTo(bd(8.5)));
    }

    @Test
    @DisplayName("TC-CALC-03: DTB HK với danh sách TX rỗng và đủ GK+CK")
    void testSemesterAvg_emptyTX() {
        BigDecimal result = MarksCalculationHelper.calcSemesterAvg(
                Collections.emptyList(), bd(6.0), bd(7.0));
        // (6×2 + 7×3) / (2+3) = (12+21)/5 = 33/5 = 6.6
        assertNotNull(result);
        assertEquals(0, result.compareTo(bd(6.6)));
    }

    @Test
    @DisplayName("TC-CALC-04: DTB HK khi tất cả điểm null → null")
    void testSemesterAvg_allNull() {
        BigDecimal result = MarksCalculationHelper.calcSemesterAvg(null, null, null);
        assertNull(result);
    }

    // ── calcYearAvg ──────────────────────────────────────────────────────────

    @Test
    @DisplayName("TC-CALC-05: DTB cả năm – TT22: (HK1 + HK2×2) / 3")
    void testYearAvg_standard() {
        // HK1 = 7.0, HK2 = 8.5 → (7.0 + 8.5×2) / 3 = 24/3 = 8.0
        BigDecimal result = MarksCalculationHelper.calcYearAvg(bd(7.0), bd(8.5));
        assertNotNull(result);
        assertEquals(0, result.compareTo(bd(8.0)));
    }

    @Test
    @DisplayName("TC-CALC-06: DTB năm khi chỉ có HK1 → trả về HK1")
    void testYearAvg_onlyHk1() {
        BigDecimal result = MarksCalculationHelper.calcYearAvg(bd(7.5), null);
        assertEquals(0, result.compareTo(bd(7.5)));
    }

    @Test
    @DisplayName("TC-CALC-07: DTB năm khi cả hai null → null")
    void testYearAvg_bothNull() {
        assertNull(MarksCalculationHelper.calcYearAvg(null, null));
    }

    // ── classifyAcademic ─────────────────────────────────────────────────────

    @Test
    @DisplayName("TC-CALC-08: Tiểu học – ≥9.0 → Hoàn thành tốt")
    void testClassifyPrimary_excellent() {
        assertEquals("Hoàn thành tốt",
                MarksCalculationHelper.classifyAcademic(bd(9.5), EducationLevel.PRIMARY));
    }

    @Test
    @DisplayName("TC-CALC-09: Tiểu học – 7.0 → Hoàn thành")
    void testClassifyPrimary_good() {
        assertEquals("Hoàn thành",
                MarksCalculationHelper.classifyAcademic(bd(7.0), EducationLevel.PRIMARY));
    }

    @Test
    @DisplayName("TC-CALC-10: Tiểu học – 4.0 → Chưa hoàn thành")
    void testClassifyPrimary_fail() {
        assertEquals("Chưa hoàn thành",
                MarksCalculationHelper.classifyAcademic(bd(4.0), EducationLevel.PRIMARY));
    }

    @Test
    @DisplayName("TC-CALC-11: THCS – 8.0 → Tốt")
    void testClassifySecondary_gioi() {
        assertEquals("Tốt",
                MarksCalculationHelper.classifyAcademic(bd(8.0), EducationLevel.SECONDARY));
    }

    @Test
    @DisplayName("TC-CALC-12: THCS – 6.5 → Khá")
    void testClassifySecondary_kha() {
        assertEquals("Khá",
                MarksCalculationHelper.classifyAcademic(bd(6.5), EducationLevel.SECONDARY));
    }

    @Test
    @DisplayName("TC-CALC-13: THCS – 5.0 → Đạt")
    void testClassifySecondary_tb() {
        assertEquals("Đạt",
                MarksCalculationHelper.classifyAcademic(bd(5.0), EducationLevel.SECONDARY));
    }

    @Test
    @DisplayName("TC-CALC-14: THCS – 3.5 → Chưa đạt")
    void testClassifySecondary_yeu() {
        assertEquals("Chưa đạt",
                MarksCalculationHelper.classifyAcademic(bd(3.5), EducationLevel.SECONDARY));
    }

    @Test
    @DisplayName("TC-CALC-15: THCS – 3.4 → Chưa đạt")
    void testClassifySecondary_kem() {
        assertEquals("Chưa đạt",
                MarksCalculationHelper.classifyAcademic(bd(3.4), EducationLevel.SECONDARY));
    }

    @Test
    @DisplayName("TC-CALC-16: THPT – 9.0 → Tốt")
    void testClassifyHighSchool_xuat_sac() {
        assertEquals("Tốt",
                MarksCalculationHelper.classifyAcademic(bd(9.0), EducationLevel.HIGH_SCHOOL));
    }

    @Test
    @DisplayName("TC-CALC-17: THPT – 8.5 → Tốt")
    void testClassifyHighSchool_gioi() {
        assertEquals("Tốt",
                MarksCalculationHelper.classifyAcademic(bd(8.5), EducationLevel.HIGH_SCHOOL));
    }

    @Test
    @DisplayName("TC-CALC-18: Điểm null → Chưa có điểm")
    void testClassify_nullScore() {
        assertEquals("Chưa có điểm",
                MarksCalculationHelper.classifyAcademic(null, EducationLevel.SECONDARY));
    }

    // ── calcOverallAvg ────────────────────────────────────────────────────────

    @Test
    @DisplayName("TC-CALC-19: ĐTB chung – trung bình cộng các môn")
    void testOverallAvg_standard() {
        List<BigDecimal> avgs = Arrays.asList(bd(8.0), bd(7.5), bd(9.0), bd(6.5));
        BigDecimal result = MarksCalculationHelper.calcOverallAvg(avgs);
        // (8.0 + 7.5 + 9.0 + 6.5) / 4 = 31 / 4 = 7.8
        assertNotNull(result);
        assertEquals(0, result.compareTo(bd(7.8)));
    }

    @Test
    @DisplayName("TC-CALC-20: ĐTB chung – bỏ qua null trong danh sách")
    void testOverallAvg_withNulls() {
        List<BigDecimal> avgs = Arrays.asList(bd(8.0), null, bd(6.0));
        BigDecimal result = MarksCalculationHelper.calcOverallAvg(avgs);
        // (8.0 + 6.0) / 2 = 7.0
        assertEquals(0, result.compareTo(bd(7.0)));
    }

    @Test
    @DisplayName("TC-CALC-21: ĐTB chung – danh sách rỗng → null")
    void testOverallAvg_empty() {
        assertNull(MarksCalculationHelper.calcOverallAvg(Collections.emptyList()));
    }

    // ── evaluateAcademicResultTT22 & evaluateHonorTitleTT22 ───────────────────

    @Test
    @DisplayName("TC-CALC-22: TT22 – Kết quả học tập mức TỐT (>=6 môn >=8.0, min >=6.5, 0 môn nhận xét fail)")
    void testEvaluateAcademicResultTT22_Tot() {
        List<BigDecimal> scores = Arrays.asList(
                bd(9.2), bd(8.5), bd(8.0), bd(8.2), bd(8.8), bd(9.0), bd(7.5), bd(6.8)
        );
        String result = MarksCalculationHelper.evaluateAcademicResultTT22(scores, 0);
        assertEquals("Tốt", result);
    }

    @Test
    @DisplayName("TC-CALC-23: TT22 – Kết quả học tập mức KHÁ (>=6 môn >=6.5, min >=5.0, 0 môn nhận xét fail)")
    void testEvaluateAcademicResultTT22_Kha() {
        List<BigDecimal> scores = Arrays.asList(
                bd(7.5), bd(7.0), bd(6.8), bd(6.5), bd(6.5), bd(7.2), bd(5.5), bd(5.0)
        );
        String result = MarksCalculationHelper.evaluateAcademicResultTT22(scores, 0);
        assertEquals("Khá", result);
    }

    @Test
    @DisplayName("TC-CALC-24: TT22 – Kết quả học tập mức ĐẠT (>=6 môn >=5.0, min >=3.5, 1 môn nhận xét fail)")
    void testEvaluateAcademicResultTT22_Dat() {
        List<BigDecimal> scores = Arrays.asList(
                bd(5.5), bd(5.0), bd(5.2), bd(6.0), bd(5.0), bd(5.5), bd(4.0), bd(3.8)
        );
        String result = MarksCalculationHelper.evaluateAcademicResultTT22(scores, 1);
        assertEquals("Đạt", result);
    }

    @Test
    @DisplayName("TC-CALC-25: TT22 – Kết quả học tập mức CHƯA ĐẠT (có môn dưới 3.5)")
    void testEvaluateAcademicResultTT22_ChuaDat() {
        List<BigDecimal> scores = Arrays.asList(
                bd(8.0), bd(8.5), bd(7.0), bd(6.5), bd(6.0), bd(7.0), bd(3.0)
        );
        String result = MarksCalculationHelper.evaluateAcademicResultTT22(scores, 0);
        assertEquals("Chưa đạt", result);
    }

    @Test
    @DisplayName("TC-CALC-26: TT22 – Khen thưởng Học sinh Xuất sắc (Học tập Tốt, Rèn luyện Tốt, >=6 môn >=9.0)")
    void testEvaluateHonorTitleTT22_XuatSac() {
        List<BigDecimal> scores = Arrays.asList(
                bd(9.5), bd(9.2), bd(9.0), bd(9.0), bd(9.1), bd(9.3), bd(8.5), bd(8.0)
        );
        String title = MarksCalculationHelper.evaluateHonorTitleTT22("Tốt", "Tốt", scores);
        assertEquals("Học sinh Xuất sắc", title);
    }

    @Test
    @DisplayName("TC-CALC-27: TT22 – Khen thưởng Học sinh Giỏi (Học tập Tốt, Rèn luyện Tốt, dưới 6 môn >=9.0)")
    void testEvaluateHonorTitleTT22_Gioi() {
        List<BigDecimal> scores = Arrays.asList(
                bd(9.5), bd(9.2), bd(8.5), bd(8.0), bd(8.2), bd(8.8), bd(8.0), bd(7.5)
        );
        String title = MarksCalculationHelper.evaluateHonorTitleTT22("Tốt", "Tốt", scores);
        assertEquals("Học sinh Giỏi", title);
    }

    @Test
    @DisplayName("TC-CALC-28: TT22 – Không danh hiệu nếu Học tập Khá hoặc Rèn luyện Khá")
    void testEvaluateHonorTitleTT22_None() {
        List<BigDecimal> scores = Arrays.asList(bd(8.5), bd(8.0), bd(7.5), bd(7.0));
        assertNull(MarksCalculationHelper.evaluateHonorTitleTT22("Khá", "Tốt", scores));
        assertNull(MarksCalculationHelper.evaluateHonorTitleTT22("Tốt", "Khá", scores));
    }

    @Test
    @DisplayName("TC-CALC-29: TT22 – Không cấp danh hiệu nếu chưa có Hạnh kiểm (conduct null)")
    void testEvaluateHonorTitleTT22_NullConduct() {
        List<BigDecimal> scores = Arrays.asList(bd(9.5), bd(9.2), bd(9.0), bd(9.0), bd(9.1), bd(9.3));
        assertNull(MarksCalculationHelper.evaluateHonorTitleTT22("Tốt", null, scores));
    }

    // ── helper ───────────────────────────────────────────────────────────────

    private static BigDecimal bd(double val) {
        return BigDecimal.valueOf(val);
    }
}
