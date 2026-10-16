package com.school.backend.repository;

import com.school.backend.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.List;

public interface StudentRepository extends JpaRepository<Student, Long> {
    Optional<Student> findByAdmissionNumber(String admissionNumber);
    Optional<Student> findByUserId(Long userId);
    List<Student> findBySchoolClassId(Long classId);
    List<Student> findByParentId(Long parentId);
}
