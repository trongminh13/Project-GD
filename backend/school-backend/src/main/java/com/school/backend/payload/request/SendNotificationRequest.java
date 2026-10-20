package com.school.backend.payload.request;

import com.school.backend.enums.AudienceType;
import com.school.backend.enums.NotificationType;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SendNotificationRequest {

    @NotBlank(message = "Tiêu đề thông báo không được để trống")
    private String title;

    @NotBlank(message = "Nội dung thông báo không được để trống")
    private String body;

    @Builder.Default
    private AudienceType audienceType = AudienceType.ALL;

    private String targetId; // Mã khối (ví dụ "3"), mã lớp (ví dụ "10A1"), hoặc username

    @Builder.Default
    private NotificationType notificationType = NotificationType.ANNOUNCEMENT;

    private String dataPayload;
}
