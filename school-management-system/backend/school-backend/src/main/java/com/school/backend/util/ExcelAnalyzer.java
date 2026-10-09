package com.school.backend.util;

import org.apache.poi.ss.usermodel.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.io.FileInputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Stream;

@Component
public class ExcelAnalyzer implements CommandLineRunner {

    @Override
    public void run(String... args) throws Exception {
        // Only run if specifically asked or we can add a flag,
        // but for now let's just print and ignore errors if files don't exist

        System.out.println("====== EXCEL ANALYSIS STARTED ======");

        String excelPath = "d:/misc/Java/Student Management System/Excels";

        try (Stream<Path> paths = Files.walk(Paths.get(excelPath))) {
            paths.filter(Files::isRegularFile)
                    .filter(p -> p.toString().endsWith(".xlsx"))
                    .forEach(this::analyzeFile);
        } catch (Exception e) {
            System.err.println("Error inspecting folder: " + e.getMessage());
        }

        System.out.println("====== EXCEL ANALYSIS COMPLETED ======");
    }

    private void analyzeFile(Path path) {
        System.out.println("\nFile: " + path.getFileName());
        try (FileInputStream fis = new FileInputStream(path.toFile());
                Workbook workbook = WorkbookFactory.create(fis)) {

            Sheet sheet = workbook.getSheetAt(0);
            Row headerRow = sheet.getRow(0);

            if (headerRow != null) {
                System.out.println("Columns Found:");
                for (Cell cell : headerRow) {
                    System.out.println(" - " + cell.toString());
                }
            } else {
                System.out.println(" - [Empty or No Header Row]");
            }

            System.out.println("Total Estimated Rows: " + sheet.getLastRowNum());

        } catch (Exception e) {
            System.out.println(" - Error reading file: " + e.getMessage());
        }
    }
}
