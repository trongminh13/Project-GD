package com.school.backend.payload.response;

import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
public class ImportRowError {
    private String sheet;
    private int row;
    private String field;
    private String value;
    private String message;

    public ImportRowError(String sheet, int row, String field, String value, String message) {
        this.sheet = sheet;
        this.row = row;
        this.field = field;
        this.value = value;
        this.message = message;
    }
}
