package com.school.backend.entity;

import com.school.backend.enums.FeeType;
import jakarta.persistence.*;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Entity
@Table(name = "fee_structure", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"class_id", "fee_type"})
})
public class FeeStructure {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "class_id", nullable = false)
    private SchoolClass schoolClass;

    @Enumerated(EnumType.STRING)
    @Column(name = "fee_type", nullable = false)
    private FeeType feeType;

    @Column(nullable = false)
    private BigDecimal amount;

    @Column(name = "due_month")
    private Integer dueMonth;
}
