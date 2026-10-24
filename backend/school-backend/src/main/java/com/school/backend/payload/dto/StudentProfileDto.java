package com.school.backend.payload.dto;

import com.school.backend.enums.EducationLevel;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StudentProfileDto {
    private Long id;
    private String admissionNumber;
    private String name;
    private String rollNo;
    private String grade;
    private String section;
    private LocalDate dob;
    private String gender;
    private String photoUrl;
    @Builder.Default
    private EducationLevel educationLevel = EducationLevel.PRIMARY;

    @Builder.Default
    private String educationLevelName = "Tiểu học";

    @Builder.Default
    private String schoolName = "Trường Tiểu học Đại Việt";

    private String homeroomTeacherName;

    public StudentProfileDto(Long id, String admissionNumber, String name, String rollNo,
            String grade, String section, LocalDate dob, String gender, String photoUrl) {
        this.id = id;
        this.admissionNumber = admissionNumber;
        this.name = name;
        this.rollNo = rollNo;
        this.grade = grade;
        this.section = section;
        this.dob = dob;
        this.gender = gender;
        this.photoUrl = photoUrl;
        this.educationLevel = EducationLevel.fromGrade(grade);
        this.educationLevelName = this.educationLevel != null ? this.educationLevel.getDisplayName() : "Tiểu học";
        this.schoolName = this.educationLevel != null ? this.educationLevel.getDefaultSchoolName()
                : "Trường Tiểu học Đại Việt";
    }

    public StudentProfileDto(Long id, String admissionNumber, String name, String rollNo,
            String grade, String section, LocalDate dob, String gender, String photoUrl,
            String homeroomTeacherName) {
        this(id, admissionNumber, name, rollNo, grade, section, dob, gender, photoUrl);
        this.homeroomTeacherName = homeroomTeacherName;
    }
}
