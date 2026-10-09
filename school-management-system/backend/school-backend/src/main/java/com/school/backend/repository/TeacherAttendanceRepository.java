package com.school.backend.repository;

import com.school.backend.entity.TeacherAttendance;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface TeacherAttendanceRepository extends JpaRepository<TeacherAttendance, Long> {
    List<TeacherAttendance> findByTeacherId(Long teacherId);
    List<TeacherAttendance> findByDate(LocalDate date);
    Optional<TeacherAttendance> findByTeacherIdAndDate(Long teacherId, LocalDate date);
}
