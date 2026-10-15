# 08 — Danh mục Kiểm tra Phát hành (Release Checklist — Production Readiness)

**Mục tiêu:** Đảm bảo hệ thống đạt độ tin cậy, bảo mật và an toàn dữ liệu 100% trước khi triển khai lên môi trường sản xuất (Production).

---

## 1. Tiêu chí Tiên quyết về Chất lượng (Quality Gates)

- [ ] **100% Test Case mức P0 (Bảo mật, Dữ liệu, Thanh toán) đạt trạng thái PASS**
- [ ] **≥ 90% Test Case mức P1 đạt trạng thái PASS**
- [ ] **0 Bug mức Nghiêm trọng còn mở** (Bắt buộc sửa [BUG-002](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/07-bugs/BUG-002-attendance-bulk-missing-teacher-rebac.md))
- [ ] **0 Bug mức Cao còn mở** (Bắt buộc sửa [BUG-001](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/07-bugs/BUG-001-open-academic-year-endpoints.md))
- [ ] Tất cả hành vi "Chặn - chờ quyết định" đã được Product Owner phê duyệt chính thức

---

## 2. Bảo mật và Quyền riêng tư (Security & Privacy)

- [ ] **Khóa bí mật & Credentials:** Không có mật khẩu, JWT Secret, API Key (Razorpay, Fast2SMS) nào bị ghi cứng trong mã nguồn hoặc commit vào git
- [ ] **Vô hiệu hóa Route Debug:** Đã tắt endpoint `/api/test/sms` hoặc bọc `@Profile("dev")` để không xuất hiện trên production
- [ ] **HTTPS Enforced:** 100% lưu lượng truy cập qua giao thức HTTPS có chứng chỉ SSL hợp lệ (TLS 1.2 / 1.3)
- [ ] **Bảo vệ dữ liệu trẻ em:** Kiểm tra log hệ thống (`application.log`) không in thô số CCCD/Aadhaar, địa chỉ nhà hoặc mật khẩu
- [ ] **Chống tấn công Brute-force:** Khóa tài khoản sau 5 lần nhập sai trong 15 phút hoạt động ổn định

---

## 3. Cơ sở dữ liệu và Sao lưu (Database & Backup)

- [ ] **Migrations:** Toàn bộ script Flyway / Liquibase chạy an toàn, có khả năng chạy lại (idempotent)
- [ ] **Toàn vẹn khóa ngoại:** Bảng `guardian_students`, `attendance`, `homework_submissions` có ràng buộc khóa ngoại và index tối ưu
- [ ] **Chính sách Backup:** Cấu hình tự động sao lưu định kỳ hàng ngày (Automated daily snapshots) và đã diễn tập phục hồi thử
- [ ] **Không có dữ liệu mồ côi:** Chạy script đối soát [01-endpoint-inventory.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/01-endpoint-inventory.md) xác nhận không còn tài khoản rác

---

## 4. Cấu hình Vận hành & Hiệu năng (Ops & Performance)

- [ ] **Connection Pool:** Cấu hình HikariCP tối đa 30-50 kết nối, timeout 30s
- [ ] **Giới hạn dung lượng tải lên:** Cấu hình Spring `max-file-size: 50MB`, `max-request-size: 60MB`
- [ ] **Mức độ ghi Log:** Mức log đặt ở `INFO` hoặc `WARN` trên production; tắt SQL debug trace
- [ ] **Giám sát Sức khỏe (Health Check):** Spring Boot Actuator `/actuator/health` hoạt động phục vụ load balancer

---

## 5. Đóng gói Ứng dụng Di động (Mobile App Release)

- [ ] **Xóa Debug Banner:** Cờ `debugShowCheckedModeBanner: false` trong Flutter
- [ ] **Rút gọn mã (ProGuard / Obfuscation):** Đã bật cấu hình minify và làm rối mã nguồn khi build Android App Bundle (.aab) và iOS
- [ ] **Endpoint Production:** `BASE_URL` trong `.env` trỏ chính xác về domain chính thức của nhà trường
- [ ] **Tương thích hệ điều hành:** Đã kiểm thử smoke test trên Android 11, Android 14 và iOS mới nhất

---

## 6. Chữ ký Phê duyệt Phát hành (Sign-off)

| Vai trò | Họ và tên | Chữ ký | Ngày duyệt |
|---|---|---|---|
| **AI QA Senior** | Lead QA | *Đã xác nhận hồ sơ* | 2026-10-15 |
| **Backend Lead** | | | |
| **Mobile Lead** | | | |
| **Product Owner** | | | |
