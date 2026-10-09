package com.school.backend.payload;

import lombok.Data;

@Data
public class RazorpayVerifyRequest {
    private Long studentId;
    private Long feeStructureId;

    private String razorpayOrderId;
    private String razorpayPaymentId;
    private String razorpaySignature;
}
