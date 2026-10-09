package com.school.backend.entity;

import com.school.backend.util.EncryptedStringConverter;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "teachers")
public class Teacher {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", referencedColumnName = "id")
    private User user;

    @Column(nullable = false)
    private String name;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(nullable = false, unique = true)
    private String email;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(nullable = false)
    private String phone;

    private String qualification;

    @Column(name = "subject_specialization")
    private String subjectSpecialization;

    @Column(name = "photo_url")
    private String photoUrl;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
