package com.school.backend.payload.request;

import lombok.Data;

@Data
public class LeaveRequestCreateRequest {
    private Long studentId;
    private String startDate; // yyyy-MM-dd
    private String endDate;   // yyyy-MM-dd
    private String reason;
}
