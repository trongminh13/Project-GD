package com.school.backend.payload.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeviceTokenRequest {

    @NotBlank(message = "Device token không được để trống")
    private String deviceToken;

    @NotBlank(message = "Platform không được để trống (ANDROID, IOS, WEB)")
    private String platform;

    private String deviceName;
}
