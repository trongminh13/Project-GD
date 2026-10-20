package com.school.backend.payload.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDto {
    private Long id;
    private String title;
    private String content;
    private String audience;
    private String date;
    private String time;
    private String sender;
    private Boolean isRead;
    private String type;
    private String dataPayload;

    public String getBody() {
        return content;
    }
}
