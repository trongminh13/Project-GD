package com.school.backend.payload.request;

import lombok.Data;
import java.util.List;

@Data
public class BulkAttendanceRequest {
    private Long classId;
    private String className;
    private String date;
    private List<Record> records;

    @Data
    public static class Record {
        private Long studentId;
        private String status;
    }
}
