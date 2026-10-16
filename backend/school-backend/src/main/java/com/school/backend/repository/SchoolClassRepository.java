package com.school.backend.repository;

import com.school.backend.entity.SchoolClass;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface SchoolClassRepository extends JpaRepository<SchoolClass, Long> {
    Optional<SchoolClass> findByGradeAndSection(String grade, String section);
    List<SchoolClass> findByHomeroomTeacherId(Long teacherId);
    List<SchoolClass> findByClassTeacherId(Long teacherId);
}
