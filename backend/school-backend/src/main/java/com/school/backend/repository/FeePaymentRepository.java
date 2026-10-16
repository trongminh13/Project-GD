package com.school.backend.repository;

import com.school.backend.entity.FeePayment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface FeePaymentRepository extends JpaRepository<FeePayment, Long> {
    List<FeePayment> findByStudentId(Long studentId);
    List<FeePayment> findByStatus(String status);
    Optional<FeePayment> findFirstByTransactionId(String transactionId);
    List<FeePayment> findByTransactionId(String transactionId);
}
