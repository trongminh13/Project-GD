package com.school.backend.controller;

import com.school.backend.exception.ExcelValidationException;
import com.school.backend.payload.response.MessageResponse;
import com.school.backend.service.BulkImportService;
import com.school.backend.util.ExcelHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.LinkedHashMap;
import java.util.Map;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/upload")
public class BulkImportController {

    @Autowired
    BulkImportService fileService;

    @PostMapping("/students")
    @PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<?> uploadFile(@RequestParam("file") MultipartFile file) {
        if (!ExcelHelper.hasExcelFormat(file)) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new MessageResponse("Please upload an excel file!"));
        }

        try {
            int count = fileService.save(file);
            String message = "Uploaded the file successfully: " + file.getOriginalFilename() + ". Imported " + count + " students.";
            return ResponseEntity.status(HttpStatus.OK).body(new MessageResponse(message));
        } catch (ExcelValidationException e) {
            Map<String, Object> errorBody = new LinkedHashMap<>();
            errorBody.put("success", false);
            errorBody.put("message", e.getMessage());
            errorBody.put("errors", e.getErrors());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorBody);
        } catch (Exception e) {
            String message = "Could not upload the file: " + file.getOriginalFilename() + "! Error: " + e.getMessage();
            return ResponseEntity.status(HttpStatus.EXPECTATION_FAILED).body(new MessageResponse(message));
        }
    }
}
