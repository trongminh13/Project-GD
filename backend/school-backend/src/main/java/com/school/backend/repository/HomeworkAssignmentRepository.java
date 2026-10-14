package com.school.backend.repository;

import com.school.backend.entity.HomeworkAssignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HomeworkAssignmentRepository extends JpaRepository<HomeworkAssignment, Long> {
    List<HomeworkAssignment> findBySchoolClassIdAndStatus(Long classId, String status);
    List<HomeworkAssignment> findBySchoolClassIdIn(List<Long> classIds);
    List<HomeworkAssignment> findByAssignedByTeacherIdOrderByAssignedAtDesc(Long teacherId);
    Optional<HomeworkAssignment> findByHomeworkIdAndSchoolClassId(Long homeworkId, Long classId);
}
