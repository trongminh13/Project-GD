package com.school.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "guardian_students", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"guardian_id", "student_id"})
})
public class GuardianStudent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "guardian_id", nullable = false)
    private Parent guardian;

    @ManyToOne
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    private String relationship = "PRIMARY";

    @Column(name = "is_primary")
    private Boolean isPrimary = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
