package com.school.backend.service;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.client.RestTemplate;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Service
public class OtpService {

    @Value("${school.app.fast2smsKey}")
    private String apiKey;

    private final Map<String, String> otpStorage = new HashMap<>();

    public String generateOtp(String phone) {
        // Generate 6 digit OTP
        String otp = String.format("%06d", new Random().nextInt(999999));

        // Store in memory (production: use Redis)
        otpStorage.put(phone, otp);

        // =========================================
        // TEMPORARY: VERY VISIBLE CONSOLE LOG FOR DEV
        // =========================================
        System.out.println("\n\n**************************************************");
        System.out.println("  OTP FOR PHONE " + phone + " IS: [" + otp + "]");
        System.out.println("**************************************************\n\n");

        // Send SMS via Fast2SMS
        sendSms(phone, otp);

        return otp;
    }

    private void sendSms(String phone, String otp) {
        try {
            String url = "https://www.fast2sms.com/dev/bulkV2?authorization=" + apiKey +
                    "&variables_values=" + otp +
                    "&route=otp&numbers=" + phone;

            RestTemplate restTemplate = new RestTemplate();
            String response = restTemplate.getForObject(url, String.class);
            System.out.println("Fast2SMS Response: " + response);

        } catch (Exception e) {
            System.err.println("Error sending SMS: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public boolean validateOtp(String phone, String otp) {
        if (otpStorage.containsKey(phone)) {
            String storedOtp = otpStorage.get(phone);
            if (storedOtp.equals(otp)) {
                otpStorage.remove(phone); // OTP used, discard it
                return true;
            }
        }
        return false;
    }
}
