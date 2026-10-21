package com.school.backend.repository;

import com.school.backend.entity.TeachingAssignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TeachingAssignmentRepository extends JpaRepository<TeachingAssignment, Long> {
    List<TeachingAssignment> findByTeacherIdAndAcademicYearIsCurrentTrue(Long teacherId);
    List<TeachingAssignment> findBySchoolClassIdAndAcademicYearIsCurrentTrue(Long classId);
    List<TeachingAssignment> findByTeacherIdAndSchoolClassIdAndAcademicYearIsCurrentTrue(Long teacherId, Long classId);
    List<TeachingAssignment> findByTeacherIdAndSchoolClassIdAndSubjectIdAndAcademicYearIsCurrentTrue(Long teacherId, Long classId, Long subjectId);
    List<TeachingAssignment> findByTeacherId(Long teacherId);
}
