package com.school.backend.payload;

import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.Data;

@Data
public class RazorpayVerifyRequest {
    private Long studentId;
    private Long feeStructureId;

    @JsonAlias("orderId")
    private String razorpayOrderId;

    @JsonAlias("paymentId")
    private String razorpayPaymentId;

    @JsonAlias("signature")
    private String razorpaySignature;
}
