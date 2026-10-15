# BUG-005 — Route debug SMS gọi trực tiếp Fast2SMS thật tiềm ẩn rủi ro cước phí và rò rỉ API key

- **Mức độ:** Trung bình
- **Module:** NOTI / SEC
- **Môi trường / thiết bị / phiên bản:** localhost:8081 / Spring Boot 3.5
- **Test case liên quan:** TC-NOTI-008, TC-NFR-008
- **Ngày phát hiện:** 2026-10-15
- **Người phát hiện:** AI QA Senior

---

## Các bước tái hiện

1. Kiểm tra mã nguồn `DebugController.java`:
```java
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
```

## Kết quả thực tế

- Endpoint `/api/test/sms` nằm trong source code sản phẩm.
- Khi Admin gọi URL này, hệ thống sẽ thực hiện HTTP GET thực tế tới `fast2sms.com` và trừ tiền tài khoản SMS thật.
- URL chứa API key trực tiếp trên query string (`authorization=` + apiKey).

## Kết quả mong đợi

- Môi trường kiểm thử (test/dev) phải sử dụng mock service hoặc conditional bean (`@Profile("!prod")` trả về giả lập SMS).
- Không truyền API key nhạy cảm trên query param của URL ra bên ngoài.
- Tắt hoặc loại bỏ controller này khi đóng gói lên production.

## Bằng chứng

- File: `backend/school-backend/src/main/java/com/school/backend/controller/DebugController.java` dòng 16-31

## Trạng thái

- [x] **Mới** — Phát hiện, chưa giao cho developer
- [ ] **Đã giao** — Developer đang xử lý
- [ ] **Đã sửa** — Developer báo sửa xong
- [ ] **Đã kiểm tra lại** — QA chạy lại, xác nhận sửa đúng
- [ ] **Đóng** — Đã xác nhận, không còn tái hiện được
