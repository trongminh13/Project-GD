package com.school.backend.service;

import com.school.backend.enums.EducationLevel;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

public class EducationLevelTest {

    private StudentPortalService studentPortalService;

    @BeforeEach
    public void setUp() {
        studentPortalService = new StudentPortalService();
    }

    @Test
    @DisplayName("TC-LEVEL-01: Map grade 1..5 to EducationLevel.PRIMARY")
    public void testMapPrimaryGrades() {
        assertEquals(EducationLevel.PRIMARY, EducationLevel.fromGrade("1"));
        assertEquals(EducationLevel.PRIMARY, EducationLevel.fromGrade("3"));
        assertEquals(EducationLevel.PRIMARY, EducationLevel.fromGrade("5"));
        assertEquals(EducationLevel.PRIMARY, EducationLevel.fromGrade("3A"));
        assertEquals(EducationLevel.PRIMARY, EducationLevel.fromGrade("Lớp 4B"));
    }

    @Test
    @DisplayName("TC-LEVEL-02: Map grade 6..9 to EducationLevel.SECONDARY")
    public void testMapSecondaryGrades() {
        assertEquals(EducationLevel.SECONDARY, EducationLevel.fromGrade("6"));
        assertEquals(EducationLevel.SECONDARY, EducationLevel.fromGrade("7A"));
        assertEquals(EducationLevel.SECONDARY, EducationLevel.fromGrade("8-B"));
        assertEquals(EducationLevel.SECONDARY, EducationLevel.fromGrade("9"));
    }

    @Test
    @DisplayName("TC-LEVEL-03: Map grade 10..12 to EducationLevel.HIGH_SCHOOL")
    public void testMapHighSchoolGrades() {
        assertEquals(EducationLevel.HIGH_SCHOOL, EducationLevel.fromGrade("10"));
        assertEquals(EducationLevel.HIGH_SCHOOL, EducationLevel.fromGrade("10A1"));
        assertEquals(EducationLevel.HIGH_SCHOOL, EducationLevel.fromGrade("11-C"));
        assertEquals(EducationLevel.HIGH_SCHOOL, EducationLevel.fromGrade("12"));
    }

    @Test
    @DisplayName("TC-LEVEL-04: Null or empty grade gracefully fallbacks to PRIMARY")
    public void testFallbackGrade() {
        assertEquals(EducationLevel.PRIMARY, EducationLevel.fromGrade(null));
        assertEquals(EducationLevel.PRIMARY, EducationLevel.fromGrade(""));
        assertEquals(EducationLevel.PRIMARY, EducationLevel.fromGrade("   "));
        assertEquals(EducationLevel.PRIMARY, EducationLevel.fromGrade("ABC"));
    }

    @Test
    @DisplayName("TC-LEVEL-05: Evaluate marks for PRIMARY level (Thông tư 27/2020: HTT, HT, CHT)")
    public void testPrimaryGradeCalculation() {
        // >= 80%: Hoàn thành tốt
        assertEquals("Hoàn thành tốt (HTT)", studentPortalService.calculateGrade(BigDecimal.valueOf(9), BigDecimal.valueOf(10), EducationLevel.PRIMARY));
        assertEquals("Hoàn thành tốt (HTT)", studentPortalService.calculateGrade(BigDecimal.valueOf(8), BigDecimal.valueOf(10), EducationLevel.PRIMARY));

        // 50% - 79%: Hoàn thành
        assertEquals("Hoàn thành (HT)", studentPortalService.calculateGrade(BigDecimal.valueOf(6.5), BigDecimal.valueOf(10), EducationLevel.PRIMARY));
        assertEquals("Hoàn thành (HT)", studentPortalService.calculateGrade(BigDecimal.valueOf(5), BigDecimal.valueOf(10), EducationLevel.PRIMARY));

        // < 50%: Chưa hoàn thành
        assertEquals("Chưa hoàn thành (CHT)", studentPortalService.calculateGrade(BigDecimal.valueOf(4.5), BigDecimal.valueOf(10), EducationLevel.PRIMARY));
    }

    @Test
    @DisplayName("TC-LEVEL-06: Evaluate marks for SECONDARY & HIGH_SCHOOL level (Thông tư 22/2021: Tốt, Khá, Đạt, Chưa đạt)")
    public void testSecondaryAndHighSchoolGradeCalculation() {
        // >= 80%: Tốt
        assertEquals("Tốt", studentPortalService.calculateGrade(BigDecimal.valueOf(8.5), BigDecimal.valueOf(10), EducationLevel.SECONDARY));
        assertEquals("Tốt", studentPortalService.calculateGrade(BigDecimal.valueOf(10), BigDecimal.valueOf(10), EducationLevel.HIGH_SCHOOL));

        // 65% - 79%: Khá
        assertEquals("Khá", studentPortalService.calculateGrade(BigDecimal.valueOf(7.0), BigDecimal.valueOf(10), EducationLevel.SECONDARY));

        // 50% - 64%: Đạt
        assertEquals("Đạt", studentPortalService.calculateGrade(BigDecimal.valueOf(5.5), BigDecimal.valueOf(10), EducationLevel.HIGH_SCHOOL));

        // < 50%: Chưa đạt
        assertEquals("Chưa đạt", studentPortalService.calculateGrade(BigDecimal.valueOf(3.5), BigDecimal.valueOf(10), EducationLevel.SECONDARY));

        // Null / edge case: N/A
        assertEquals("N/A", studentPortalService.calculateGrade(null, BigDecimal.valueOf(10), EducationLevel.HIGH_SCHOOL));
        assertEquals("N/A", studentPortalService.calculateGrade(BigDecimal.valueOf(5), BigDecimal.ZERO, EducationLevel.SECONDARY));
    }

    @Test
    @DisplayName("TC-LEVEL-07: Verify default school names for each education level")
    public void testDefaultSchoolNames() {
        assertEquals("Trường Tiểu học Astra", EducationLevel.PRIMARY.getDefaultSchoolName());
        assertEquals("Trường THCS Astra", EducationLevel.SECONDARY.getDefaultSchoolName());
        assertEquals("Trường THPT Astra", EducationLevel.HIGH_SCHOOL.getDefaultSchoolName());
    }

    @Test
    @DisplayName("TC-LEVEL-08: Verify fullName and shortName for each education level")
    public void testFullNameAndShortName() {
        assertEquals("Tiểu học", EducationLevel.PRIMARY.getFullName());
        assertEquals("Tiểu học", EducationLevel.PRIMARY.getShortName());

        assertEquals("Trung học cơ sở", EducationLevel.SECONDARY.getFullName());
        assertEquals("THCS", EducationLevel.SECONDARY.getShortName());

        assertEquals("Trung học phổ thông", EducationLevel.HIGH_SCHOOL.getFullName());
        assertEquals("THPT", EducationLevel.HIGH_SCHOOL.getShortName());
    }

    @Test
    @DisplayName("TC-LEVEL-09: Verify StudentProfileDto @Builder.Default fallback initialization")
    public void testStudentProfileDtoBuilderDefaults() {
        com.school.backend.payload.dto.StudentProfileDto dto = com.school.backend.payload.dto.StudentProfileDto.builder()
                .id(100L)
                .name("Nguyễn Văn A")
                .build();

        assertNotNull(dto.getEducationLevel());
        assertEquals(EducationLevel.PRIMARY, dto.getEducationLevel());
        assertEquals("Tiểu học", dto.getEducationLevelName());
        assertEquals("Trường Tiểu học Astra", dto.getSchoolName());
    }
}
