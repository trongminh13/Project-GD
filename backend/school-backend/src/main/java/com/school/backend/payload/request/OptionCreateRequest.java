package com.school.backend.payload.request;

import lombok.Data;

@Data
public class OptionCreateRequest {
    private Integer optionOrder;
    private String content;
    private Boolean isCorrect = false;
}
