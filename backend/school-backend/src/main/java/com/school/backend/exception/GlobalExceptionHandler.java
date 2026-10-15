package com.school.backend.exception;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> handleIllegalArgument(IllegalArgumentException ex) {
        log.warn("Validation error (IllegalArgumentException): {}", ex.getMessage());
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", false);
        body.put("message", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
    }

    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<Map<String, Object>> handleIllegalState(IllegalStateException ex) {
        log.warn("Business state error (IllegalStateException): {}", ex.getMessage());
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", false);
        body.put("message", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
    }

    @ExceptionHandler(ExcelValidationException.class)
    public ResponseEntity<Map<String, Object>> handleExcelValidation(ExcelValidationException ex) {
        log.warn("Excel validation failed: {} ({} errors)", ex.getMessage(), ex.getErrors().size());
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", false);
        body.put("message", ex.getMessage());
        body.put("errors", ex.getErrors());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
    }

    @ExceptionHandler(SecurityException.class)
    public ResponseEntity<Map<String, Object>> handleSecurityException(SecurityException ex) {
        log.error("Security violation detected: {}", ex.getMessage());
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", false);
        body.put("message", ex.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(body);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<Map<String, Object>> handleAccessDenied(AccessDeniedException ex) {
        log.warn("Access denied: {}", ex.getMessage());
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", false);
        body.put("message", ex.getMessage() != null ? ex.getMessage() : "Truy cập bị từ chối.");
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(body);
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<Map<String, Object>> handleAuthenticationException(AuthenticationException ex) {
        log.warn("Authentication failed: {}", ex.getMessage());
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", false);
        body.put("message", "Xác thực không thành công: " + ex.getMessage());
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(body);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = ex.getBindingResult().getFieldErrors().stream()
                .collect(Collectors.toMap(
                        FieldError::getField,
                        fe -> fe.getDefaultMessage() != null ? fe.getDefaultMessage() : "Giá trị không hợp lệ",
                        (msg1, msg2) -> msg1
                ));
        log.warn("Method argument validation failed: {}", errors);
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", false);
        body.put("message", "Dữ liệu gửi lên không hợp lệ.");
        body.put("errors", errors);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGeneralException(Exception ex) {
        log.error("Unhandled internal server error: ", ex);
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", false);
        body.put("message", "Đã xảy ra lỗi nội bộ hệ thống. Vui lòng thử lại sau.");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(body);
    }
}
