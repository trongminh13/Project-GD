package com.school.backend.service;

import com.school.backend.entity.*;
import com.school.backend.enums.Role;
import com.school.backend.exception.ExcelValidationException;
import com.school.backend.payload.response.ImportRowError;
import com.school.backend.repository.*;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.util.*;

@Service
public class BulkImportService {

    private static final Logger log = LoggerFactory.getLogger(BulkImportService.class);
    private static final int MAX_ROWS_LIMIT = 2000;

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

    public static class StagedStudentRow {
        public String sheetName;
        public int rowNum;
        public String admNo;
        public String name;
        public String rollNo;
        public String grade;
        public String section;
        public String parentName;
        public String primaryPhone;
    }

    @Transactional(rollbackFor = Exception.class)
    public int save(MultipartFile file) {
        List<StagedStudentRow> stagedRows = new ArrayList<>();
        List<ImportRowError> validationErrors = new ArrayList<>();

        // 1. Chống rò rỉ tài nguyên: Dùng try-with-resources để tự động đóng file & workbook
        try (InputStream is = file.getInputStream();
             Workbook workbook = new XSSFWorkbook(is)) {

            int totalRows = 0;
            for (int sheetIndex = 0; sheetIndex < workbook.getNumberOfSheets(); sheetIndex++) {
                Sheet sheet = workbook.getSheetAt(sheetIndex);
                totalRows += (sheet.getLastRowNum() + 1);
            }

            if (totalRows > MAX_ROWS_LIMIT) {
                throw new ExcelValidationException(
                        "Tệp vượt quá giới hạn tối đa cho phép (" + MAX_ROWS_LIMIT + " dòng). Vui lòng chia nhỏ tệp.",
                        List.of(new ImportRowError("General", 0, "file", String.valueOf(totalRows), "Tổng số dòng vượt quá giới hạn " + MAX_ROWS_LIMIT)));
            }

            // PHA 1: Pre-validation toàn diện trên bộ nhớ (Không ghi vào DB)
            validateAndExtract(workbook, stagedRows, validationErrors);

        } catch (IOException e) {
            throw new IllegalArgumentException("Không thể đọc tệp Excel: " + e.getMessage(), e);
        }

        // Nếu có bất kỳ lỗi nào ở bất kỳ dòng nào, ném Exception trả về toàn bộ lỗi, DB không bị đụng tới
        if (!validationErrors.isEmpty()) {
            throw new ExcelValidationException("Tệp Excel chứa " + validationErrors.size() + " lỗi dữ liệu. Vui lòng kiểm tra và sửa lại.", validationErrors);
        }

        // PHA 2: Atomic Batch Commit (Ghi DB nguyên tử)
        return persistBatch(stagedRows);
    }

    private void validateAndExtract(Workbook workbook, List<StagedStudentRow> stagedRows, List<ImportRowError> errors) {
        Map<String, Integer> seenAdmNosInFile = new HashMap<>();

        for (int sheetIndex = 0; sheetIndex < workbook.getNumberOfSheets(); sheetIndex++) {
            Sheet sheet = workbook.getSheetAt(sheetIndex);
            String sheetName = sheet.getSheetName();

            int headerRowIndex = -1;
            Map<String, Integer> columnMap = new HashMap<>();

            for (int i = 0; i < Math.min(20, sheet.getLastRowNum() + 1); i++) {
                Row row = sheet.getRow(i);
                if (row != null) {
                    Map<String, Integer> tempMap = extractColumnMap(row);
                    if (tempMap.containsKey("name")) {
                        headerRowIndex = i;
                        columnMap = tempMap;
                        break;
                    }
                }
            }

            if (headerRowIndex == -1) {
                continue;
            }

            for (int i = headerRowIndex + 1; i <= sheet.getLastRowNum(); i++) {
                Row currentRow = sheet.getRow(i);
                if (currentRow == null) continue;

                int rowDisplay = i + 1;
                String name = getSafeCellValue(currentRow, columnMap.get("name"));
                String admNo = getSafeCellValue(currentRow, columnMap.get("admNo"));
                String rollNo = getSafeCellValue(currentRow, columnMap.get("rollNo"));
                String classNameRaw = getSafeCellValue(currentRow, columnMap.get("class"));
                String gradeRaw = getSafeCellValue(currentRow, columnMap.get("grade"));
                String sectionRaw = getSafeCellValue(currentRow, columnMap.get("section"));
                String parentName = getSafeCellValue(currentRow, columnMap.get("parentName"));
                String parentPhone = getSafeCellValue(currentRow, columnMap.get("phone"));

                // Bỏ qua dòng hoàn toàn trống
                if (name.isEmpty() && admNo.isEmpty() && parentPhone.isEmpty()) {
                    continue;
                }

                // Kiểm tra 1: Tên học sinh không được rỗng
                if (name.isEmpty()) {
                    errors.add(new ImportRowError(sheetName, rowDisplay, "name", "", "Họ và tên học sinh không được để trống"));
                }

                String primaryPhone = extractPrimaryPhone(parentPhone);

                // Tự động sinh mã admission number từ SĐT nếu thiếu
                if (admNo.isEmpty()) {
                    if (!primaryPhone.isEmpty() && primaryPhone.length() >= 7) {
                        admNo = "ADM" + primaryPhone.substring(0, 7);
                    } else if (!primaryPhone.isEmpty()) {
                        admNo = "ADM" + primaryPhone;
                    } else {
                        errors.add(new ImportRowError(sheetName, rowDisplay, "admissionNumber", "", "Thiếu mã học sinh và không có số điện thoại phụ huynh để tạo mã"));
                    }
                }

                // Kiểm tra 2: Trùng lặp mã học sinh trong nội bộ file Excel
                if (!admNo.isEmpty()) {
                    if (seenAdmNosInFile.containsKey(admNo)) {
                        errors.add(new ImportRowError(sheetName, rowDisplay, "admissionNumber", admNo,
                                "Mã học sinh bị trùng lặp với dòng " + seenAdmNosInFile.get(admNo) + " trong tệp"));
                    } else {
                        seenAdmNosInFile.put(admNo, rowDisplay);
                    }

                    // Kiểm tra 3: Trùng lặp mã học sinh với CSDL hiện có
                    if (studentRepository.findByAdmissionNumber(admNo).isPresent()) {
                        errors.add(new ImportRowError(sheetName, rowDisplay, "admissionNumber", admNo,
                                "Mã học sinh đã tồn tại trong hệ thống"));
                    }

                    // Kiểm tra 4: Trùng lặp username tài khoản học sinh
                    if (userRepository.findByUsername(admNo).isPresent()) {
                        errors.add(new ImportRowError(sheetName, rowDisplay, "admissionNumber", admNo,
                                "Tài khoản đăng nhập đã tồn tại trong hệ thống"));
                    }
                }

                // Xác định khối lớp và phân ban
                String finalGrade;
                String finalSection;
                if (!classNameRaw.isEmpty()) {
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
                    String sheetClass = sheetName.trim();
                    if (sheetClass.toLowerCase().startsWith("class ")) {
                        sheetClass = sheetClass.substring(6).trim();
                    }
                    finalGrade = sheetClass;
                    finalSection = "A";
                }

                StagedStudentRow staged = new StagedStudentRow();
                staged.sheetName = sheetName;
                staged.rowNum = rowDisplay;
                staged.admNo = admNo;
                staged.name = name;
                staged.rollNo = rollNo.isEmpty() ? "0" : rollNo;
                staged.grade = finalGrade;
                staged.section = finalSection;
                staged.parentName = parentName;
                staged.primaryPhone = primaryPhone;
                stagedRows.add(staged);
            }
        }
    }

    private int persistBatch(List<StagedStudentRow> stagedRows) {
        List<Student> allStudents = new ArrayList<>();
        Map<String, SchoolClass> classCache = new HashMap<>();
        Map<String, Parent> parentCache = new HashMap<>();

        for (StagedStudentRow staged : stagedRows) {
            // 1. Phân giải/Tạo lớp học
            String classKey = staged.grade + "_" + staged.section;
            SchoolClass schoolClass = classCache.computeIfAbsent(classKey, k ->
                    classRepository.findByGradeAndSection(staged.grade, staged.section)
                            .orElseGet(() -> {
                                SchoolClass newClass = new SchoolClass();
                                newClass.setGrade(staged.grade);
                                newClass.setSection(staged.section);
                                return classRepository.save(newClass);
                            })
            );

            // 2. Phân giải/Tạo phụ huynh
            Parent parent = null;
            if (!staged.primaryPhone.isEmpty()) {
                final String phone = staged.primaryPhone;
                final String pName = (staged.parentName != null && !staged.parentName.isEmpty()) ? staged.parentName : "Parent";
                parent = parentCache.computeIfAbsent(phone, pKey ->
                        parentRepository.findByPhone(phone)
                                .orElseGet(() -> {
                                    User user = userRepository.findByUsername(phone).orElseGet(() -> {
                                        User u = new User();
                                        u.setUsername(phone);
                                        u.setPassword(encoder.encode("123456"));
                                        u.setRole(Role.PARENT);
                                        return userRepository.save(u);
                                    });

                                    Parent newParent = new Parent();
                                    newParent.setName(pName);
                                    newParent.setPhone(phone);
                                    newParent.setUser(user);
                                    return parentRepository.save(newParent);
                                })
                );
            }

            // 3. Tạo tài khoản User cho Học sinh
            final String studentAdmNo = staged.admNo;
            User studentUser = userRepository.findByUsername(studentAdmNo).orElseGet(() -> {
                User newUser = new User();
                newUser.setUsername(studentAdmNo);
                String tempPass = com.school.backend.util.PasswordGeneratorUtil.generateRandomPassword();
                newUser.setPassword(encoder.encode(tempPass));
                newUser.setRole(Role.STUDENT);
                newUser.setMustChangePassword(true);
                return userRepository.save(newUser);
            });

            // 4. Khởi tạo đối tượng Student
            Student student = new Student();
            student.setAdmissionNumber(staged.admNo);
            student.setName(staged.name);
            student.setRollNo(staged.rollNo);
            student.setSchoolClass(schoolClass);
            student.setUser(studentUser);
            if (parent != null) {
                student.setParent(parent);
            }

            allStudents.add(student);
        }

        studentRepository.saveAll(allStudents);
        log.info("Bulk import completed successfully: {} students imported", allStudents.size());
        return allStudents.size();
    }

    private Map<String, Integer> extractColumnMap(Row headerRow) {
        Map<String, Integer> map = new HashMap<>();
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
