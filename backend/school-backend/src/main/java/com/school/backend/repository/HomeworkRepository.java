package com.school.backend.repository;

import com.school.backend.entity.Homework;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HomeworkRepository extends JpaRepository<Homework, Long> {
    List<Homework> findByCreatedByTeacherIdOrderByCreatedAtDesc(Long teacherId);
    List<Homework> findBySubjectId(Long subjectId);
}
