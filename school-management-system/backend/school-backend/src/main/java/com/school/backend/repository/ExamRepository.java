package com.school.backend.repository;

import com.school.backend.entity.Exam;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ExamRepository extends JpaRepository<Exam, Long> {
    // Add custom query methods if needed
}
