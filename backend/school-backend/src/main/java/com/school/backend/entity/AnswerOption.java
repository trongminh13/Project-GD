package com.school.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "answer_options", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"answer_id", "option_id"})
})
public class AnswerOption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "answer_id", nullable = false)
    @JsonIgnore
    private Answer answer;

    @ManyToOne
    @JoinColumn(name = "option_id", nullable = false)
    private QuestionOption option;
}
