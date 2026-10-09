package com.school.backend.payload;

import com.school.backend.entity.FeePayment;
import com.school.backend.entity.FeeStructure;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class FeeStatement {
    private List<FeeStructure> pendingFees;
    private List<FeePayment> paidFees;
    private BigDecimal totalPending;
}
