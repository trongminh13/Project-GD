package com.school.backend.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.security.SecureRandom;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class OtpService {

    private static final Logger log = LoggerFactory.getLogger(OtpService.class);
    private static final long OTP_TTL_MS = 5 * 60 * 1000L; // 5 phút hết hạn
    private static final int MAX_VERIFY_ATTEMPTS = 5; // Tối đa 5 lần thử xác minh

    @Value("${school.app.fast2smsKey:}")
    private String apiKey;

    private static class OtpEntry {
        final String code;
        final long createdAt;
        int attempts;

        OtpEntry(String code) {
            this.code = code;
            this.createdAt = System.currentTimeMillis();
            this.attempts = 0;
        }

        boolean isExpired() {
            return (System.currentTimeMillis() - createdAt) > OTP_TTL_MS;
        }
    }

    private final Map<String, OtpEntry> otpStorage = new ConcurrentHashMap<>();
    private final SecureRandom secureRandom = new SecureRandom();

    public String generateOtp(String phone) {
        cleanExpiredEntries();

        // Tạo mã OTP 6 chữ số ngẫu nhiên an toàn (000000 - 999999)
        String otp = String.format("%06d", secureRandom.nextInt(1_000_000));

        // Lưu vào bộ nhớ với timestamp và đếm số lần thử
        otpStorage.put(phone, new OtpEntry(otp));

        // Mask SĐT khi ghi log bảo vệ thông tin cá nhân (PII)
        String maskedPhone = (phone != null && phone.length() > 4)
                ? "****" + phone.substring(phone.length() - 4)
                : "****";
        log.info("Generated OTP for phone {} (valid for 5 minutes)", maskedPhone);

        // DEV MODE log: Hiển thị mã OTP trực tiếp trên console để phục vụ kiểm thử cục bộ
        log.info("🔔 [DEV MODE] Mã OTP cho SĐT {}: [{}] (hiệu lực: 5 phút)", phone, otp);

        // Gửi SMS
        sendSms(phone, otp);

        return otp;
    }

    private void sendSms(String phone, String otp) {
        if (apiKey == null || apiKey.trim().isEmpty() || apiKey.contains("placeholder") || apiKey.contains("test")) {
            log.info("🔔 [DEV MODE] Bỏ qua gửi SMS thật ra mạng ngoài. Sử dụng mã OTP [{}] ở trên để kiểm thử.", otp);
            return;
        }

        try {
            String url = "https://www.fast2sms.com/dev/bulkV2?authorization=" + apiKey +
                    "&variables_values=" + otp +
                    "&route=otp&numbers=" + phone;

            RestTemplate restTemplate = new RestTemplate();
            String response = restTemplate.getForObject(url, String.class);
            log.info("Fast2SMS dispatch completed for recipient.");
        } catch (Exception e) {
            log.error("Failed to dispatch SMS via Fast2SMS: {}", e.getMessage());
        }
    }

    public boolean validateOtp(String phone, String otp) {
        if (phone == null || otp == null) {
            return false;
        }

        OtpEntry entry = otpStorage.get(phone);
        if (entry == null) {
            log.warn("OTP validation failed: No active OTP found for phone.");
            return false;
        }

        // Kiểm tra thời hạn hiệu lực (TTL)
        if (entry.isExpired()) {
            otpStorage.remove(phone);
            log.warn("OTP validation failed: OTP expired for phone.");
            return false;
        }

        // Kiểm tra số lần thử xác minh chống Brute-Force
        entry.attempts++;
        if (entry.attempts > MAX_VERIFY_ATTEMPTS) {
            otpStorage.remove(phone);
            log.warn("OTP validation failed: Exceeded maximum verification attempts ({}). OTP invalidated.", MAX_VERIFY_ATTEMPTS);
            return false;
        }

        // So khớp mã OTP
        if (entry.code.equals(otp)) {
            otpStorage.remove(phone); // Đã sử dụng thành công, hủy mã ngay lập tức (One-Time)
            log.info("OTP validated successfully.");
            return true;
        }

        log.warn("OTP mismatch for phone. Attempt {}/{}", entry.attempts, MAX_VERIFY_ATTEMPTS);
        return false;
    }

    private void cleanExpiredEntries() {
        otpStorage.entrySet().removeIf(e -> e.getValue().isExpired());
    }
}
