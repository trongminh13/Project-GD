package com.school.backend.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping("/api/test")
public class DebugController {

    @Value("${school.app.fast2smsKey}")
    private String apiKey;

    @GetMapping("/sms")
    @PreAuthorize("hasAuthority('ADMIN')")
    public ResponseEntity<?> testSms(@RequestParam String phone, @RequestParam String otp) {
        try {
            String url = "https://www.fast2sms.com/dev/bulkV2?authorization=" + apiKey +
                    "&variables_values=" + otp +
                    "&route=otp&numbers=" + phone;

            RestTemplate restTemplate = new RestTemplate();
            String response = restTemplate.getForObject(url, String.class);
            return ResponseEntity.ok("Fast2SMS Response: " + response);

        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error sending SMS: " + e.getMessage());
        }
    }
}
