package com.school.backend.exception;

import com.school.backend.payload.response.ImportRowError;
import lombok.Getter;

import java.util.List;

@Getter
public class ExcelValidationException extends RuntimeException {
    private final List<ImportRowError> errors;

    public ExcelValidationException(String message, List<ImportRowError> errors) {
        super(message);
        this.errors = errors;
    }
}
