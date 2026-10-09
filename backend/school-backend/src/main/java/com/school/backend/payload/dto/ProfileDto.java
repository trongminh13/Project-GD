package com.school.backend.payload.dto;

import lombok.Data;

@Data
public class ProfileDto {
    private String name;
    private String phone;
    private String email;
    private String address;
    private String role;
}
