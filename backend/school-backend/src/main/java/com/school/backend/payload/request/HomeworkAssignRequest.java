package com.school.backend.payload.request;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class HomeworkAssignRequest {
    private Long classId;
    private LocalDateTime dueDate;
    private Boolean allowLateSubmission = true;
}
