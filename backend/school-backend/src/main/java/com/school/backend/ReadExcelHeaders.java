package com.school.backend;

import java.io.File;
import java.io.FileInputStream;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

public class ReadExcelHeaders {
    public static void main(String[] args) {
        try {
            FileInputStream file = new FileInputStream(new File("St. james Convent School Student details.xlsx"));
            Workbook workbook = new XSSFWorkbook(file);
            Sheet sheet = workbook.getSheetAt(0);

            Row headerRow = sheet.getRow(0);
            if (headerRow != null) {
                System.out.println("--- EXCEL HEADERS ---");
                for (int i = 0; i < headerRow.getLastCellNum(); i++) {
                    System.out.println("Col " + i + ": " + headerRow.getCell(i).toString());
                }
            } else {
                System.out.println("No header row found.");
            }

            // Print out first data row just in case
            Row dataRow = sheet.getRow(1);
            if (dataRow != null) {
                System.out.println("\n--- FIRST DATA ROW ---");
                for (int i = 0; i < dataRow.getLastCellNum(); i++) {
                    System.out.println(
                            "Col " + i + ": " + (dataRow.getCell(i) != null ? dataRow.getCell(i).toString() : "NULL"));
                }
            }

            workbook.close();
            file.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
