package com.school.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
@Entity
@Table(name = "answers", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"submission_id", "question_id"})
})
public class Answer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "submission_id", nullable = false)
    @JsonIgnore
    private Submission submission;

    @ManyToOne
    @JoinColumn(name = "question_id", nullable = false)
    private Question question;

    @Column(name = "answer_text", columnDefinition = "TEXT")
    private String answerText;

    @Column(name = "is_auto_graded", nullable = false)
    private Boolean isAutoGraded = false;

    private Double score;

    @Column(name = "teacher_note", columnDefinition = "TEXT")
    private String teacherNote;

    @OneToMany(mappedBy = "answer", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<AnswerOption> selectedOptions = new ArrayList<>();
}
