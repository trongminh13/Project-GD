package com.school.backend.util;

import com.school.backend.entity.SchoolClass;
import com.school.backend.entity.Student;
import com.school.backend.entity.Parent;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class ExcelHelper {
    public static String TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    static String[] HEADERs = { "Admission No", "Name", "Roll No", "Grade", "Section", "Parent Name", "Parent Phone" };

    public static boolean hasExcelFormat(MultipartFile file) {
        return TYPE.equals(file.getContentType());
    }
    
    // We will return a DTO or a structured object, but for simplicity let's return a list of a custom DTO
    // to keep it decoupled from Entities in the helper if possible, or just parse to a raw list of maps.
    // For now, let's keep it simple and parse directly in Service or return List<String[]>
}
