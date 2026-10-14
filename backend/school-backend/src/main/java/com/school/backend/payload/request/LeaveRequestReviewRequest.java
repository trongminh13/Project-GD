package com.school.backend.payload.request;

import lombok.Data;

@Data
public class LeaveRequestReviewRequest {
    private String decision; // APPROVED or REJECTED
    private String teacherNote;
}
