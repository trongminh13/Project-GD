package com.school.backend.repository;

import com.school.backend.entity.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EnrollmentRepository extends JpaRepository<Enrollment, Long> {
    Optional<Enrollment> findByStudentIdAndAcademicYearIsCurrentTrue(Long studentId);
    Optional<Enrollment> findByStudentIdAndAcademicYearId(Long studentId, Long academicYearId);
    List<Enrollment> findBySchoolClassIdAndAcademicYearIsCurrentTrue(Long classId);
    List<Enrollment> findBySchoolClassIdAndAcademicYearId(Long classId, Long academicYearId);
    List<Enrollment> findByStudentId(Long studentId);
}
