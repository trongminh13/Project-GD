# Test Cases — NOTI: Thông báo và Sự kiện

**Module:** NOTI  
**Tổng số test case:** 8  
**Tham chiếu:** `SendNoticesScreen.dart`, `DebugController.java`, Spec UI/UX Thông báo

---

### TC-NOTI-001 — Quản trị viên gửi thông báo toàn trường (All Parents & Staff)
- **Module:** NOTI
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `SendNoticesScreen.dart`
- **Endpoint / Màn hình:** Màn hình `SendNoticesScreen`
- **Tiền điều kiện:** Admin đăng nhập
- **Dữ liệu vào:** Audience = "All Parents", Title = "Thông báo Lịch nghỉ Tết Nguyên Đán 2027", Message = "Nhà trường xin thông báo lịch nghỉ từ ngày 05/02/2027..."
- **Các bước:**
  1. Mở màn hình Send Notices
  2. Điền thông tin và bấm "Gửi thông báo"
- **Kết quả mong đợi:** Gửi thành công; tất cả phụ huynh trong trường đều nhận được thông báo trên thiết bị
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NOTI-002 — Gửi thông báo phân loại theo lớp cụ thể (Targeted Class Notice)
- **Module:** NOTI
- **Ưu tiên:** P1
- **Loại:** Chức năng / Phân quyền phạm vi
- **Tham chiếu:** Mục 6.9 ("Gửi theo phạm vi")
- **Endpoint / Màn hình:** Màn hình `SendNoticesScreen`
- **Tiền điều kiện:** Admin hoặc GVCN
- **Dữ liệu vào:** Audience = "Class 10 Only", Title = "Họp phụ huynh lớp 10", Message = "Thời gian: 8h00 sáng Chủ nhật..."
- **Các bước:**
  1. Gửi thông báo với đối tượng "Class 10 Only"
- **Kết quả mong đợi:** Phụ huynh có con học lớp 10 nhận được; phụ huynh lớp khác (lớp 12, lớp 3) không nhận được
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NOTI-003 — Gửi thông báo nội bộ cho Giáo viên và Nhân viên (Teachers & Staff Only)
- **Module:** NOTI
- **Ưu tiên:** P1
- **Loại:** Chức năng / Cách ly dữ liệu
- **Tham chiếu:** `SendNoticesScreen.dart`
- **Endpoint / Màn hình:** Màn hình `SendNoticesScreen`
- **Tiền điều kiện:** Admin đăng nhập
- **Dữ liệu vào:** Audience = "Teachers", Title = "Họp hội đồng sư phạm", Message = "Họp vào 14h00 chiều thứ 6"
- **Các bước:**
  1. Gửi thông báo
- **Kết quả mong đợi:** Chỉ tài khoản role `TEACHER` và `STAFF` nhận được; học sinh và phụ huynh không thấy
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NOTI-004 — Người dùng ngoài phạm vi không thấy thông báo trong danh sách
- **Module:** NOTI
- **Ưu tiên:** P0
- **Loại:** Phân quyền hiển thị
- **Tham chiếu:** Mục 6.9 ("người ngoài phạm vi không thấy")
- **Endpoint / Màn hình:** Màn hình Danh sách Thông báo Flutter
- **Tiền điều kiện:** Thông báo T1 chỉ gửi cho Lớp 12
- **Dữ liệu vào:** Đăng nhập phụ huynh lớp 10
- **Các bước:**
  1. Mở màn hình Thông báo
- **Kết quả mong đợi:** Danh sách thông báo không hiển thị thông báo T1
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NOTI-005 — Đánh dấu thông báo đã đọc (Mark as Read)
- **Module:** NOTI
- **Ưu tiên:** P2
- **Loại:** Chức năng UI
- **Tham chiếu:** Mục 6.9 ("đánh dấu đã đọc")
- **Endpoint / Màn hình:** Màn hình Chi tiết Thông báo
- **Tiền điều kiện:** Người dùng có 1 thông báo chưa đọc (chấm xanh / in đậm)
- **Dữ liệu vào:** Bấm vào xem chi tiết thông báo
- **Các bước:**
  1. Bấm mở thông báo
  2. Quay lại danh sách
- **Kết quả mong đợi:** Chấm xanh biến mất; thông báo chuyển sang trạng thái đã đọc; số lượng chưa đọc trên icon chuông giảm 1
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NOTI-006 — Bộ đếm số lượng thông báo chưa đọc trên biểu tượng chuông (Unread Badge)
- **Module:** NOTI
- **Ưu tiên:** P2
- **Loại:** Giao diện / Đồng bộ
- **Tham chiếu:** Mục 6.9 ("số chưa đọc")
- **Endpoint / Màn hình:** Thanh điều hướng trên cùng (AppBar Bell Icon)
- **Tiền điều kiện:** Người dùng có 3 thông báo mới chưa đọc
- **Dữ liệu vào:** Mở ứng dụng
- **Các bước:**
  1. Quan sát badge số trên icon chuông thông báo
- **Kết quả mong đợi:** Hiển thị badge số "3"; khi đọc hết 3 thông báo thì badge biến mất hoàn toàn
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NOTI-007 — Bật / tắt nhận thông báo đẩy trong Cài đặt (Push Notification Toggle)
- **Module:** NOTI
- **Ưu tiên:** P2
- **Loại:** Trải nghiệm người dùng
- **Tham chiếu:** Mục 6.9 ("thông báo đẩy bật hay tắt")
- **Endpoint / Màn hình:** Màn hình Cài đặt người dùng
- **Tiền điều kiện:** Người dùng chuyển toggle "Nhận thông báo đẩy" sang OFF
- **Dữ liệu vào:** Toggle OFF
- **Các bước:**
  1. Tắt nhận thông báo đẩy
  2. Admin gửi 1 thông báo mới
- **Kết quả mong đợi:** Thiết bị không rung / không hiện popup push notification; nhưng trong hòm thư ứng dụng vẫn lưu lại thông báo đó
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NOTI-008 — Kiểm tra bảo vệ endpoint debug SMS (`GET /api/test/sms`)
- **Module:** NOTI
- **Ưu tiên:** P0
- **Loại:** Bảo mật / Chi phí
- **Tham chiếu:** `DebugController.java`; `01-endpoint-inventory.md`
- **Endpoint / Màn hình:** `GET /api/test/sms`
- **Tiền điều kiện:** Môi trường test không được gọi API thật gây tốn chi phí SMS
- **Dữ liệu vào:** `phone=0912345678&otp=123456`
- **Các bước:**
  1. Gọi endpoint test SMS với role khác ADMIN -> Chặn 403
  2. Xác minh môi trường test: Mock dịch vụ hoặc vô hiệu hóa route này trước khi release
- **Kết quả mong đợi:** Role không phải ADMIN nhận HTTP 403 Forbidden; trên môi trường test không kích hoạt gửi SMS thật tốn cước phí
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —
