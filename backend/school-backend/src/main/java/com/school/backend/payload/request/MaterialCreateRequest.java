package com.school.backend.payload.request;

import lombok.Data;
import java.util.List;

@Data
public class MaterialCreateRequest {
    private Long subjectId;
    private String title;
    private String description;
    private String status = "PUBLISHED";
    private List<Long> targetClassIds;
    private String fileName;
    private String fileUrl;
}
