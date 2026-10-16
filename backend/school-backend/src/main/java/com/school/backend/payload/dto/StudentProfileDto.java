package com.school.backend.payload.dto;

import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
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
    }
}
