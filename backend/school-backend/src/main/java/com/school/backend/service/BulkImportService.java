package com.school.backend.service;

import com.school.backend.entity.*;
import com.school.backend.enums.Role;
import com.school.backend.repository.*;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Service
public class BulkImportService {
    @Autowired
    StudentRepository studentRepository;
    @Autowired
    SchoolClassRepository classRepository;
    @Autowired
    ParentRepository parentRepository;
    @Autowired
    UserRepository userRepository;
    @Autowired
    PasswordEncoder encoder;

    @Transactional
    public void save(MultipartFile file) {
        try {
            Workbook workbook = new XSSFWorkbook(file.getInputStream());
            List<Student> allStudents = new ArrayList<>();

            // Process ALL sheets (not just the first one)
            for (int sheetIndex = 0; sheetIndex < workbook.getNumberOfSheets(); sheetIndex++) {
                Sheet sheet = workbook.getSheetAt(sheetIndex);
                String sheetName = sheet.getSheetName();
                System.out.println("Processing sheet: " + sheetName);

                // Dynamically find header row (scan first 20 rows)
                int headerRowIndex = -1;
                java.util.Map<String, Integer> columnMap = new java.util.HashMap<>();

                for (int i = 0; i < Math.min(20, sheet.getLastRowNum() + 1); i++) {
                    Row row = sheet.getRow(i);
                    if (row != null) {
                        java.util.Map<String, Integer> tempMap = extractColumnMap(row);
                        // Only require 'name' column - admission number can be generated
                        if (tempMap.containsKey("name")) {
                            headerRowIndex = i;
                            columnMap = tempMap;
                            break;
                        }
                    }
                }

                if (headerRowIndex == -1) {
                    System.out.println("Skipping sheet '" + sheetName + "' - no header with 'Name' column found");
                    continue;
                }

                System.out.println("Found header at row " + headerRowIndex + " in sheet '" + sheetName + "'");

                // Process data rows
                for (int i = headerRowIndex + 1; i <= sheet.getLastRowNum(); i++) {
                    Row currentRow = sheet.getRow(i);
                    if (currentRow == null) continue;

                    try {
                        String admNo = getSafeCellValue(currentRow, columnMap.get("admNo"));
                        String name = getSafeCellValue(currentRow, columnMap.get("name"));
                        String rollNo = getSafeCellValue(currentRow, columnMap.get("rollNo"));
                        String classNameRaw = getSafeCellValue(currentRow, columnMap.get("class"));
                        String gradeRaw = getSafeCellValue(currentRow, columnMap.get("grade"));
                        String sectionRaw = getSafeCellValue(currentRow, columnMap.get("section"));
                        String parentName = getSafeCellValue(currentRow, columnMap.get("parentName"));
                        String parentPhone = getSafeCellValue(currentRow, columnMap.get("phone"));

                        // Skip empty rows
                        if (name.isEmpty()) continue;

                        // Extract primary phone
                        String primaryPhone = extractPrimaryPhone(parentPhone);

                        // Generate admission number from phone if missing
                        if (admNo.isEmpty()) {
                            if (!primaryPhone.isEmpty() && primaryPhone.length() >= 7) {
                                admNo = "ADM" + primaryPhone.substring(0, 7);
                            } else if (!primaryPhone.isEmpty()) {
                                admNo = "ADM" + primaryPhone;
                            } else {
                                // Skip students with no admission number AND no phone
                                continue;
                            }
                        }

                        // Determine class
                        String finalGrade;
                        String finalSection;
                        if (!classNameRaw.isEmpty()) {
                            // Remove "Class " prefix if present
                            String cleaned = classNameRaw.trim();
                            if (cleaned.toLowerCase().startsWith("class ")) {
                                cleaned = cleaned.substring(6).trim();
                            }
                            if (cleaned.contains(" ")) {
                                String[] parts = cleaned.split(" ", 2);
                                finalGrade = parts[0];
                                finalSection = parts[1].trim();
                            } else {
                                finalGrade = cleaned;
                                finalSection = sectionRaw.isEmpty() ? "A" : sectionRaw;
                            }
                        } else if (!gradeRaw.isEmpty()) {
                            finalGrade = gradeRaw;
                            finalSection = sectionRaw.isEmpty() ? "A" : sectionRaw;
                        } else {
                            // Use sheet name as class
                            String sheetClass = sheetName.trim();
                            if (sheetClass.toLowerCase().startsWith("class ")) {
                                sheetClass = sheetClass.substring(6).trim();
                            }
                            finalGrade = sheetClass;
                            finalSection = "A";
                        }

                        // 1. Check/Create Class
                        SchoolClass schoolClass = classRepository.findByGradeAndSection(finalGrade, finalSection)
                                .orElseGet(() -> {
                                    SchoolClass newClass = new SchoolClass();
                                    newClass.setGrade(finalGrade);
                                    newClass.setSection(finalSection);
                                    return classRepository.save(newClass);
                                });

                        // 2. Check/Create Parent
                        Parent parent = null;
                        if (!primaryPhone.isEmpty()) {
                            final String phone = primaryPhone;
                            final String pName = parentName.isEmpty() ? "Parent" : parentName;
                            parent = parentRepository.findByPhone(phone)
                                    .orElseGet(() -> {
                                        // Create User for Parent
                                        User user = new User();
                                        user.setUsername(phone);
                                        user.setPassword(encoder.encode("123456"));
                                        user.setRole(Role.PARENT);
                                        userRepository.save(user);

                                        Parent newParent = new Parent();
                                        newParent.setName(pName);
                                        newParent.setPhone(phone);
                                        newParent.setUser(user);
                                        return parentRepository.save(newParent);
                                    });
                        }

                        // 3. Create Student if not exists
                        if (studentRepository.findByAdmissionNumber(admNo).isEmpty()) {
                            Student student = new Student();
                            student.setAdmissionNumber(admNo);
                            student.setName(name);
                            student.setRollNo(rollNo.isEmpty() ? "0" : rollNo);
                            student.setSchoolClass(schoolClass);
                            if (parent != null) {
                                student.setParent(parent);
                            }
                            allStudents.add(student);
                        }
                    } catch (Exception e) {
                        System.err.println("Error processing row " + i + " in sheet " + sheetName + ": " + e.getMessage());
                    }
                }
            }

            studentRepository.saveAll(allStudents);
            workbook.close();
            System.out.println("Import completed: " + allStudents.size() + " students imported");

        } catch (IOException e) {
            throw new RuntimeException("Failed to parse Excel file: " + e.getMessage());
        }
    }

    private java.util.Map<String, Integer> extractColumnMap(Row headerRow) {
        java.util.Map<String, Integer> map = new java.util.HashMap<>();
        for (Cell cell : headerRow) {
            if (cell == null) continue;
            String header = getCellValue(cell).trim().toLowerCase().replaceAll("[\\n\\r]", "");
            int colIdx = cell.getColumnIndex();

            if (header.contains("adm") || header.contains("admission")) {
                map.put("admNo", colIdx);
            } else if (header.contains("name") || header.contains("student")) {
                map.put("name", colIdx);
            } else if (header.contains("class")) {
                map.put("class", colIdx);
            } else if (header.contains("grade")) {
                map.put("grade", colIdx);
            } else if (header.contains("section") || header.contains("sec")) {
                map.put("section", colIdx);
            } else if (header.contains("roll")) {
                map.put("rollNo", colIdx);
            } else if (header.contains("father") || header.contains("mother") || header.contains("parent")) {
                if (!map.containsKey("parentName")) {
                    map.put("parentName", colIdx);
                }
            } else if (header.contains("phone") || header.contains("mobile") || header.contains("contact") || header.contains("no.")) {
                if (!header.contains("adm") && !header.contains("s.no") && !header.contains("serial")) {
                    map.put("phone", colIdx);
                }
            }
        }
        return map;
    }

    private String extractPrimaryPhone(String phoneRaw) {
        if (phoneRaw == null || phoneRaw.isEmpty()) return "";
        String cleaned = phoneRaw.replaceAll("[^0-9,/]", "");
        String[] parts = cleaned.split("[,/]");
        if (parts.length > 0) {
            String first = parts[0].trim();
            if (first.length() > 10) {
                return first.substring(first.length() - 10);
            }
            return first;
        }
        return cleaned;
    }

    private String getSafeCellValue(Row row, Integer colIdx) {
        if (colIdx == null || colIdx < 0) return "";
        Cell cell = row.getCell(colIdx);
        if (cell == null) return "";
        DataFormatter formatter = new DataFormatter();
        return formatter.formatCellValue(cell).trim();
    }

    private String getCellValue(Cell cell) {
        if (cell == null) return "";
        DataFormatter formatter = new DataFormatter();
        return formatter.formatCellValue(cell);
    }
}
