package com.school.backend.payload;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class RazorpayOrderRequest {
    private Long studentId;
    private Long feeStructureId; // Identify which fee they are paying
    private BigDecimal amount;
}
