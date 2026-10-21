package com.school.backend.repository;

import com.school.backend.entity.Marks;
import com.school.backend.enums.ExamType;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface MarksRepository extends JpaRepository<Marks, Long> {

    /** Lấy tất cả điểm của một học sinh (backward compat). */
    List<Marks> findByStudentId(Long studentId);

    /** Lấy tất cả điểm của một học sinh theo năm học. */
    List<Marks> findByStudentIdAndAcademicYearId(Long studentId, Long academicYearId);

    /** Lấy điểm của một học sinh theo năm học và học kỳ. */
    List<Marks> findByStudentIdAndAcademicYearIdAndSemester(
            Long studentId, Long academicYearId, int semester);

    List<Marks> findByExamId(Long examId);

    /** Dùng cho upsert bulk upload (backward compat với dữ liệu cũ). */
    Optional<Marks> findByStudentIdAndExamIdAndSubjectId(
            Long studentId, Long examId, Long subjectId);

    /** Dùng cho upsert cột điểm chuẩn TT22 (có txIndex). */
    Optional<Marks> findByStudentIdAndSubjectIdAndSemesterAndAcademicYearIdAndExamTypeAndTxIndex(
            Long studentId, Long subjectId, int semester,
            Long academicYearId, ExamType examType, Integer txIndex);

    /** Dùng cho upsert cột điểm chuẩn TT22 (GK, CK không có txIndex). */
    Optional<Marks> findByStudentIdAndSubjectIdAndSemesterAndAcademicYearIdAndExamType(
            Long studentId, Long subjectId, int semester,
            Long academicYearId, ExamType examType);
}

