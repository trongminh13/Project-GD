package com.school.backend.service;

import com.school.backend.entity.Parent;
import com.school.backend.entity.SchoolClass;
import com.school.backend.entity.Student;
import com.school.backend.entity.User;
import com.school.backend.enums.Role;
import com.school.backend.repository.ParentRepository;
import com.school.backend.repository.SchoolClassRepository;
import com.school.backend.repository.StudentRepository;
import com.school.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.io.InputStream;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class DataMigrationService {

    private final UserRepository userRepository;
    private final ParentRepository parentRepository;
    private final StudentRepository studentRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public String processExcelData(InputStream inputStream) {
        int studentCount = 0;
        int parentCount = 0;
        int updatedCount = 0;
        int skippedCount = 0;

        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            // Iterate through every sheet in the Excel file
            for (int sheetIndex = 0; sheetIndex < workbook.getNumberOfSheets(); sheetIndex++) {
                Sheet sheet = workbook.getSheetAt(sheetIndex);
                String sheetName = sheet.getSheetName();
                log.info("Processing Sheet: " + sheetName);

                int headerRowIndex = -1;
                java.util.Map<String, Integer> columnMap = new java.util.HashMap<>();

                // Dynamically find the header row by scanning first 20 rows
                for (int i = 0; i < Math.min(20, sheet.getLastRowNum() + 1); i++) {
                    Row row = sheet.getRow(i);
                    if (row != null) {
                        java.util.Map<String, Integer> tempMap = extractColumnMap(row);
                        // Require at least 2 recognized columns for a valid header row
                        // to avoid matching random text like "Student Name: John"
                        if (tempMap.containsKey("name") && tempMap.size() >= 2) {
                            headerRowIndex = i;
                            columnMap = tempMap;
                            break;
                        }
                    }
                }

                // Fallback: if we only found 'name' column (size 1), still use it
                if (headerRowIndex == -1) {
                    for (int i = 0; i < Math.min(20, sheet.getLastRowNum() + 1); i++) {
                        Row row = sheet.getRow(i);
                        if (row != null) {
                            java.util.Map<String, Integer> tempMap = extractColumnMap(row);
                            if (tempMap.containsKey("name")) {
                                headerRowIndex = i;
                                columnMap = tempMap;
                                break;
                            }
                        }
                    }
                }

                if (headerRowIndex == -1) {
                    log.warn("Could not find a valid header row containing Name in sheet: " + sheetName);
                    continue; // Skip this sheet
                }

                log.info("Found header row at index {} in sheet '{}'. Column map: {}", headerRowIndex, sheetName, columnMap);

                // Process data rows below the header
                for (int i = headerRowIndex + 1; i <= sheet.getLastRowNum(); i++) {
                    Row row = sheet.getRow(i);
                    if (row == null)
                        continue;

                    // Log raw values of first data row for debugging
                    if (i == headerRowIndex + 1) {
                        StringBuilder sb = new StringBuilder("First data row values: ");
                        for (int c = 0; c < row.getLastCellNum(); c++) {
                            Cell cell = row.getCell(c);
                            sb.append("[").append(c).append("]='").append(getCellValueAsString(cell)).append("' ");
                        }
                        log.info(sb.toString());
                    }

                    try {
                        String admNo = getSafeCellValueAsString(row, columnMap.get("admNo"));
                        String studentName = getSafeCellValueAsString(row, columnMap.get("name"));

                        // Skip rows with both admNo and Name empty (could be gap between sections)
                        if (admNo.isEmpty() && studentName.isEmpty())
                            continue;

                        // Skip rows with no student name
                        if (studentName.isEmpty()) {
                            skippedCount++;
                            continue;
                        }

                        String classNameRaw = getSafeCellValueAsString(row, columnMap.get("class"));
                        String grade = getSafeCellValueAsString(row, columnMap.get("grade"));
                        String section = getSafeCellValueAsString(row, columnMap.get("section"));
                        String rollNoRaw = getSafeCellValueAsString(row, columnMap.get("rollNo"));
                        String parentName = getSafeCellValueAsString(row, columnMap.get("parentName"));
                        String phoneRaw = getSafeCellValueAsString(row, columnMap.get("phone"));

                        // Extract phone early (needed for admission number fallback)
                        String primaryPhone = extractPrimaryPhone(phoneRaw);

                        // If no admission number, generate one from first 7 digits of phone number
                        if (admNo.isEmpty()) {
                            if (!primaryPhone.isEmpty() && primaryPhone.length() >= 7) {
                                admNo = "ADM" + primaryPhone.substring(0, 7);
                                log.info("Generated admission number {} for student {} from phone", admNo, studentName);
                            } else if (!primaryPhone.isEmpty()) {
                                admNo = "ADM" + primaryPhone;
                                log.info("Generated admission number {} for student {} from phone", admNo, studentName);
                            } else {
                                // Skip students with no admission number AND no phone
                                log.warn("Skipping student {} - no admission number and no phone", studentName);
                                skippedCount++;
                                continue;
                            }
                        }

                        // 1. Process Class (fallback to SheetName if class col is missing)
                        SchoolClass schoolClass;
                        if (!classNameRaw.isEmpty()) {
                            schoolClass = resolveSchoolClass(classNameRaw);
                        } else if (!grade.isEmpty()) {
                            schoolClass = resolveSchoolClass(grade + " " + (section.isEmpty() ? "A" : section));
                        } else {
                            // Deduce class from sheet name (e.g., "Nursery", "L.K.G", "Class 1")
                            schoolClass = resolveSchoolClass(sheetName);
                        }

                        if (schoolClass == null) {
                            log.warn("Skipping student {} - could not resolve class (classNameRaw={}, grade={}, sheetName={})",
                                    studentName, classNameRaw, grade, sheetName);
                            skippedCount++;
                            continue;
                        }

                        // 2. Process Parent (Extract First Phone)
                        Parent parent = null;
                        if (!primaryPhone.isEmpty()) {
                            parent = resolveParent(primaryPhone, parentName);
                            if (parent.getId() == null) {
                                parentCount++; // New parent created
                                parent = parentRepository.save(parent);
                            }
                        }

                        // 3. Process Student (Update if exists to prevent duplicates)
                        Optional<Student> existingStudent = studentRepository.findByAdmissionNumber(admNo);
                        Student student;
                        if (existingStudent.isPresent()) {
                            student = existingStudent.get();
                            updatedCount++;
                        } else {
                            student = new Student();
                            student.setAdmissionNumber(admNo);
                            studentCount++;
                        }

                        student.setName(studentName);
                        student.setRollNo(rollNoRaw.isEmpty() ? "0" : rollNoRaw);
                        student.setSchoolClass(schoolClass);

                        if (parent != null) {
                            student.setParent(parent);
                        }

                        studentRepository.save(student);

                    } catch (Exception e) {
                        log.error("Error processing row " + i + " in sheet " + sheetName + ": " + e.getMessage(), e);
                        skippedCount++;
                    }
                }
            }

            log.info("Import complete: {} inserted, {} updated, {} skipped, {} parents registered",
                    studentCount, updatedCount, skippedCount, parentCount);

            return "Import Success! Inserted " + studentCount + " new students, Updated " + updatedCount
                    + " existing students, Skipped " + skippedCount + " rows, and registered " + parentCount + " parents.";

        } catch (Exception e) {
            log.error("Failed to parse Excel file", e);
            return "Error parsing Excel: " + e.getMessage();
        }
    }

    private java.util.Map<String, Integer> extractColumnMap(Row headerRow) {
        java.util.Map<String, Integer> map = new java.util.HashMap<>();
        for (Cell cell : headerRow) {
            if (cell == null)
                continue;
            String header = getCellValueAsString(cell).trim().toLowerCase().replaceAll("[\\n\\r]", "");
            int colIdx = cell.getColumnIndex();

            if (header.contains("adm") || header.contains("admission")) {
                map.put("admNo", colIdx);
            } else if (header.contains("father") || header.contains("mother") || header.contains("parent")) {
                if (!map.containsKey("parentName")) {
                    map.put("parentName", colIdx);
                }
            } else if (header.contains("student name") || header.equals("student")
                    || header.equals("students") || header.contains("name")) {
                // Only match exact "student"/"students" (not "Student Details" etc.)
                map.put("name", colIdx);
            } else if (header.contains("class")) {
                map.put("class", colIdx);
            } else if (header.contains("grade")) {
                map.put("grade", colIdx);
            } else if (header.contains("section") || header.contains("sec")) {
                map.put("section", colIdx);
            } else if (header.contains("roll")) {
                map.put("rollNo", colIdx);
            } else if (header.contains("contact") || header.contains("phone") || header.contains("mobile")
                    || header.contains("no.")) {
                // Ensure it's not "Adm. No." or "S.No."
                if (!header.contains("adm") && !header.contains("s.no") && !header.contains("serial")) {
                    map.put("phone", colIdx);
                }
            }
        }
        return map;
    }

    private SchoolClass resolveSchoolClass(String classNameRaw) {
        if (classNameRaw == null || classNameRaw.isEmpty())
            return null;

        String grade = classNameRaw.trim();
        String section = "A"; // default

        // Remove "Class - " or "Class " prefix if present from sheet naming
        if (grade.toLowerCase().startsWith("class - ")) {
            grade = grade.substring(8).trim();
        } else if (grade.toLowerCase().startsWith("class ")) {
            grade = grade.substring(6).trim();
        }

        if (grade.contains(" ") && !grade.toLowerCase().contains("l.k.g") && !grade.toLowerCase().contains("u.k.g")) {
            String[] parts = grade.split(" ", 2);
            grade = parts[0];
            section = parts[1].trim();
        }

        SchoolClass sc = schoolClassRepository.findByGradeAndSection(grade, section).orElse(null);

        if (sc == null) {
            sc = new SchoolClass();
            sc.setGrade(grade.isEmpty() ? "Unknown" : grade);
            sc.setSection(section);
            sc = schoolClassRepository.save(sc);
        }
        return sc;
    }

    private Parent resolveParent(String phone, String parentName) {
        Optional<Parent> existing = parentRepository.findByPhone(phone);
        if (existing.isPresent()) {
            Parent p = existing.get();
            // Update name if it was previously empty/generic and we have a new real name
            if ((p.getName().equals("Parent") || p.getName().isEmpty()) && parentName != null
                    && !parentName.isEmpty()) {
                p.setName(parentName);
                return parentRepository.save(p);
            }
            return p;
        }

        // Create User for Parent
        User user = new User();
        user.setUsername(phone);
        user.setPassword(passwordEncoder.encode("123456")); // Default password
        user.setRole(Role.PARENT);
        user = userRepository.save(user);

        // Create Parent
        Parent parent = new Parent();
        parent.setPhone(phone);
        parent.setName(parentName == null || parentName.isEmpty() ? "Parent" : parentName);
        parent.setUser(user);

        return parent; // saved in process loop
    }

    private String extractPrimaryPhone(String phoneRaw) {
        if (phoneRaw == null || phoneRaw.isEmpty())
            return "";

        // Strip non-digits except commas and slashes
        String cleaned = phoneRaw.replaceAll("[^0-9,/]", "");

        String[] parts = cleaned.split("[,/]");
        if (parts.length > 0) {
            String first = parts[0].trim();
            if (first.length() > 10) {
                // Just in case there are country codes, take last 10 digits
                return first.substring(first.length() - 10);
            }
            return first;
        }
        return cleaned;
    }

    private String getSafeCellValueAsString(Row row, Integer colIdx) {
        if (colIdx == null || colIdx < 0)
            return "";
        Cell cell = row.getCell(colIdx);
        return getCellValueAsString(cell);
    }

    private String getCellValueAsString(Cell cell) {
        if (cell == null)
            return "";
        try {
            switch (cell.getCellType()) {
                case STRING:
                    return cell.getStringCellValue().trim();
                case NUMERIC:
                    double val = cell.getNumericCellValue();
                    if (val == Math.floor(val)) {
                        return String.valueOf((long) val);
                    }
                    return String.valueOf(val);
                case BOOLEAN:
                    return String.valueOf(cell.getBooleanCellValue());
                case FORMULA:
                    try {
                        return cell.getStringCellValue().trim();
                    } catch (Exception e) {
                        return String.valueOf((long) cell.getNumericCellValue());
                    }
                default:
                    return "";
            }
        } catch (Exception e) {
            return "";
        }
    }
}
