package com.school.backend.repository;

import com.school.backend.entity.Attendance;
import com.school.backend.enums.AttendanceStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AttendanceRepository extends JpaRepository<Attendance, Long> {
    List<Attendance> findByStudentId(Long studentId);
    List<Attendance> findByDate(LocalDate date);
    Optional<Attendance> findByStudentIdAndDate(Long studentId, LocalDate date);
    long countByStudentIdAndStatus(Long studentId, AttendanceStatus status);
}
