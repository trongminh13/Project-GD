package com.school.backend.repository;

import com.school.backend.entity.Marks;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface MarksRepository extends JpaRepository<Marks, Long> {
    List<Marks> findByStudentId(Long studentId);
    List<Marks> findByExamId(Long examId);
    Optional<Marks> findByStudentIdAndExamIdAndSubjectId(Long studentId, Long examId, Long subjectId);
}
