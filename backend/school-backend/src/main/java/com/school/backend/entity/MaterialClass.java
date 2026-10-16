package com.school.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "material_classes", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"material_id", "class_id"})
})
public class MaterialClass {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "material_id", nullable = false)
    @JsonIgnore
    private Material material;

    @ManyToOne
    @JoinColumn(name = "class_id", nullable = false)
    private SchoolClass schoolClass;

    @CreationTimestamp
    @Column(name = "published_at", updatable = false)
    private LocalDateTime publishedAt;
}
