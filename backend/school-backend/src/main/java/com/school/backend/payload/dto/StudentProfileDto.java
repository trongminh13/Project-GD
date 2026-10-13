package com.school.backend.payload.dto;

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
}
