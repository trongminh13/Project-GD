package com.school.backend.entity;

import com.school.backend.enums.ExamType;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "marks", uniqueConstraints = {
        @UniqueConstraint(columnNames = {
                "student_id", "subject_id", "semester", "academic_year_id", "exam_type", "tx_index"
        })
})
public class Marks {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    /**
     * Giữ liên kết exam để backward-compat với dữ liệu cũ.
     * Với cột TX/GK/CK thuần túy, exam có thể null.
     */
    @ManyToOne
    @JoinColumn(name = "exam_id", nullable = true)
    private Exam exam;

    @ManyToOne
    @JoinColumn(name = "subject_id", nullable = false)
    private Subject subject;

    // Điểm số (null nếu là nhận xét cấp 1 lớp 1-3)
    private BigDecimal score;

    @Column(name = "max_score")
    private BigDecimal maxScore;

    /**
     * Loại cột điểm: THUONG_XUYEN, GIUA_KY, CUOI_KY, NHAN_XET.
     * Mặc định THUONG_XUYEN để backward-compat với dữ liệu cũ.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "exam_type", nullable = false)
    private ExamType examType = ExamType.THUONG_XUYEN;

    /**
     * Học kỳ: 1 hoặc 2.
     */
    @Column(name = "semester", nullable = false)
    private Integer semester = 1;

    /**
     * Thứ tự cột TX trong học kỳ (1, 2, 3, 4...).
     * Chỉ có ý nghĩa khi examType = THUONG_XUYEN.
     */
    @Column(name = "tx_index")
    private Integer txIndex;

    /**
     * Năm học liên kết – dùng để query học bạ theo năm.
     */
    @ManyToOne
    @JoinColumn(name = "academic_year_id")
    private AcademicYear academicYear;

    /**
     * Nhận xét văn bản (dùng cho Tiểu học lớp 1-3, examType = NHAN_XET).
     * Ví dụ: "Đạt", "Chưa đạt", hoặc nhận xét chi tiết của GV.
     */
    @Column(name = "comment", length = 500)
    private String comment;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
