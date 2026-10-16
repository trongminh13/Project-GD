package com.school.backend.payload.request;

import lombok.Data;
import java.time.LocalDate;

@Data
public class StudentCreateRequest {
    private String name;
    private String admissionNumber;
    private String rollNo;
    private Long classId;
    private String className;
    private Long parentId;
    private String fatherName;
    private String motherName;
    private String mobileNumber;
    private String gender;
    private LocalDate dob;
    private String address;
    private String aadhaar;
    private String photoUrl;
    private String initialPassword;
}
