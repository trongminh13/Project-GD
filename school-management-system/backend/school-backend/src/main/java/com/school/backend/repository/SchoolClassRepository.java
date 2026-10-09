package com.school.backend.repository;

import com.school.backend.entity.SchoolClass;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface SchoolClassRepository extends JpaRepository<SchoolClass, Long> {
    Optional<SchoolClass> findByGradeAndSection(String grade, String section);
}
