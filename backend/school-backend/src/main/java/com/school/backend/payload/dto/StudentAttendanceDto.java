package com.school.backend.payload.dto;

import com.school.backend.enums.AttendanceStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StudentAttendanceDto {
    private LocalDate date;
    private AttendanceStatus status;
}
