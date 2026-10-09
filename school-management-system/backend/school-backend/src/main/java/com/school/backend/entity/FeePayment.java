package com.school.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Entity
@Table(name = "fee_payments")
public class FeePayment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @ManyToOne
    @JoinColumn(name = "fee_structure_id")
    private FeeStructure feeStructure;

    @Column(name = "amount_paid", nullable = false)
    private BigDecimal amountPaid;

    @CreationTimestamp
    @Column(name = "payment_date")
    private LocalDate paymentDate;

    @Column(name = "transaction_id")
    private String transactionId;

    private String status; // PENDING, PAID, LATE
    private String mode;   // CASH, ONLINE
}
