package com.school.backend.entity;

import com.school.backend.util.EncryptedLocalDateConverter;
import com.school.backend.util.EncryptedStringConverter;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "students")
public class Student {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", referencedColumnName = "id")
    private User user;

    @Column(name = "admission_number", unique = true, nullable = false)
    private String admissionNumber;

    @Column(nullable = false)
    private String name;

    @Column(name = "roll_no", nullable = false)
    private String rollNo;

    @ManyToOne
    @JoinColumn(name = "class_id", referencedColumnName = "id")
    private SchoolClass schoolClass;

    @ManyToOne
    @JoinColumn(name = "parent_id", referencedColumnName = "id")
    private Parent parent;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "aadhaar_masked")
    private String aadhaarMasked;

    @Convert(converter = EncryptedLocalDateConverter.class)
    private LocalDate dob;
    private String gender;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(columnDefinition = "TEXT")
    private String address;

    @Column(name = "photo_url")
    private String photoUrl;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
