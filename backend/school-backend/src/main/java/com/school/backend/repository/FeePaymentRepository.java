package com.school.backend.repository;

import com.school.backend.entity.FeePayment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface FeePaymentRepository extends JpaRepository<FeePayment, Long> {
    List<FeePayment> findByStudentId(Long studentId);
    List<FeePayment> findByStatus(String status);
}
