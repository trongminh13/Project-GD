package com.school.backend.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "classes", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"grade", "section"})
})
public class SchoolClass {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String grade;

    @Column(nullable = false)
    private String section;

    @OneToOne
    @JoinColumn(name = "class_teacher_id", referencedColumnName = "id")
    private Teacher classTeacher;

    @ManyToOne
    @JoinColumn(name = "homeroom_teacher_id", referencedColumnName = "id")
    private Teacher homeroomTeacher;

    public Teacher getEffectiveHomeroomTeacher() {
        return homeroomTeacher != null ? homeroomTeacher : classTeacher;
    }

    public String getName() {
        return (grade != null ? grade : "") + (section != null && !section.isEmpty() ? " " + section : "");
    }
}
