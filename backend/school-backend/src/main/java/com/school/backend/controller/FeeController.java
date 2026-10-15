package com.school.backend.controller;

import com.school.backend.entity.FeePayment;
import com.school.backend.service.FeeService;
import com.razorpay.RazorpayException;
import com.school.backend.payload.FeeStatement;
import com.school.backend.payload.RazorpayOrderRequest;
import com.school.backend.payload.RazorpayVerifyRequest;
import com.school.backend.security.SchoolAccessPolicy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/fees")
public class FeeController {
    @Autowired
    private FeeService feeService;

    @Autowired
    private SchoolAccessPolicy accessPolicy;

    @GetMapping("/statement/{studentId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('PARENT')")
    public ResponseEntity<FeeStatement> getFeeStatement(@PathVariable Long studentId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        accessPolicy.verifyCanAccessStudent(auth, studentId);
        return ResponseEntity.ok(feeService.getFeeStatement(studentId));
    }

    @PostMapping("/create-order")
    @PreAuthorize("hasAuthority('PARENT')")
    public ResponseEntity<?> createOrder(@RequestBody RazorpayOrderRequest request) {
        if (request == null || request.getStudentId() == null) {
            return ResponseEntity.badRequest().body("Student ID is required to create fee payment order");
        }
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        accessPolicy.verifyCanAccessStudent(auth, request.getStudentId());

        try {
            String orderId = feeService.createRazorpayOrder(request);
            Map<String, String> response = new HashMap<>();
            response.put("orderId", orderId);
            return ResponseEntity.ok(response);
        } catch (RazorpayException e) {
            return ResponseEntity.internalServerError().body("Error creating order: " + e.getMessage());
        }
    }

    @PostMapping("/verify-payment")
    @PreAuthorize("hasAuthority('PARENT')")
    public ResponseEntity<?> verifyPayment(@RequestBody RazorpayVerifyRequest request) {
        try {
            FeePayment payment = feeService.verifyRazorpayPayment(request);
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (payment != null && payment.getStudent() != null) {
                accessPolicy.verifyCanAccessStudent(auth, payment.getStudent().getId());
            }
            return ResponseEntity.ok(payment);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Payment verification failed: " + e.getMessage());
        }
    }

    @GetMapping("/student/{studentId}")
    @PreAuthorize("hasAuthority('ADMIN') or hasAuthority('PARENT')")
    public List<FeePayment> getStudentFees(@PathVariable Long studentId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        accessPolicy.verifyCanAccessStudent(auth, studentId);
        return feeService.getFeesByStudent(studentId);
    }

    @PostMapping("/pay")
    @PreAuthorize("hasAuthority('ADMIN')")
    public FeePayment payFee(@RequestBody FeePayment feePayment) {
        return feeService.saveFeePayment(feePayment);
    }
}
