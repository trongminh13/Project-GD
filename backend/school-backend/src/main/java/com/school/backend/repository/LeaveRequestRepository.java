package com.school.backend.repository;

import com.school.backend.entity.LeaveRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface LeaveRequestRepository extends JpaRepository<LeaveRequest, Long> {

    @Query("SELECT lr FROM LeaveRequest lr WHERE lr.student.id = :studentId " +
           "AND lr.status IN ('PENDING', 'APPROVED') " +
           "AND lr.startDate <= :endDate AND lr.endDate >= :startDate")
    List<LeaveRequest> findOverlappingRequests(@Param("studentId") Long studentId, 
                                               @Param("startDate") LocalDate startDate, 
                                               @Param("endDate") LocalDate endDate);

    @Query("SELECT lr FROM LeaveRequest lr WHERE lr.student.id = :studentId " +
           "AND lr.status = 'APPROVED' " +
           "AND lr.startDate <= :targetDate AND lr.endDate >= :targetDate")
    List<LeaveRequest> findApprovedRequestsOnDate(@Param("studentId") Long studentId, 
                                                  @Param("targetDate") LocalDate targetDate);

    List<LeaveRequest> findBySubmittedByGuardianIdOrderByCreatedAtDesc(Long guardianId);

    List<LeaveRequest> findByStudentIdOrderByCreatedAtDesc(Long studentId);

    @Query("SELECT lr FROM LeaveRequest lr WHERE lr.student.schoolClass.id = :classId AND lr.status = :status ORDER BY lr.createdAt DESC")
    List<LeaveRequest> findByClassIdAndStatus(@Param("classId") Long classId, @Param("status") String status);
}
