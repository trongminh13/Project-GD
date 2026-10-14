package com.school.backend.repository;

import com.school.backend.entity.AttendanceSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface AttendanceSessionRepository extends JpaRepository<AttendanceSession, Long> {
    Optional<AttendanceSession> findBySchoolClassIdAndDateAndLessonSlotIsNull(Long classId, LocalDate date);
    Optional<AttendanceSession> findBySchoolClassIdAndDateAndLessonSlot(Long classId, LocalDate date, Integer lessonSlot);
    List<AttendanceSession> findBySchoolClassIdAndDateBetween(Long classId, LocalDate start, LocalDate end);
}
