package com.school.backend.repository;

import com.school.backend.entity.GuardianStudent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface GuardianStudentRepository extends JpaRepository<GuardianStudent, Long> {
    List<GuardianStudent> findByGuardianId(Long guardianId);
    List<GuardianStudent> findByStudentId(Long studentId);
    Optional<GuardianStudent> findByGuardianIdAndStudentId(Long guardianId, Long studentId);

    @Query("SELECT gs.student.id FROM GuardianStudent gs WHERE gs.guardian.id = :guardianId")
    List<Long> findStudentIdsByGuardianId(@Param("guardianId") Long guardianId);
}
