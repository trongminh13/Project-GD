package com.school.backend.repository;

import com.school.backend.entity.Material;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MaterialRepository extends JpaRepository<Material, Long> {
    List<Material> findByCreatedByTeacherIdOrderByCreatedAtDesc(Long teacherId);
    List<Material> findBySubjectId(Long subjectId);
    boolean existsByTitle(String title);
}
