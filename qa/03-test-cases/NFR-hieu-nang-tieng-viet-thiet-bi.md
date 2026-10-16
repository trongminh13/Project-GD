# Test Cases — NFR: Phi Chức Năng (Hiệu năng, Tiếng Việt, Thiết bị & Bảo mật Dữ liệu Trẻ)

**Module:** NFR  
**Tổng số test case:** 9  
**Tham chiếu:** Spec UI/UX Phase 1, `quan-he-du-lieu.md`, Quy chuẩn Bảo mật Trẻ em (Mục 8 & Mục 6.11)

---

### TC-NFR-001 — Chuẩn hóa và lưu trữ chính xác tiếng Việt có dấu (Unicode NFC vs NFD)
- **Module:** NFR
- **Ưu tiên:** P0
- **Loại:** Toàn vẹn dữ liệu / Ngôn ngữ
- **Tham chiếu:** Mục 6.11 ("Tiếng Việt: chữ có dấu... hiển thị đúng và lưu đúng")
- **Endpoint / Màn hình:** Nhập liệu họ tên, đề bài, câu trả lời điền ngắn, nhận xét
- **Tiền điều kiện:** Bàn phím gõ tiếng Việt (Unikey / EVKey / Gboard)
- **Dữ liệu vào:** Chuỗi chứa đầy đủ nguyên âm và thanh điệu: `"Trần Nguyễn Hoàng Khánh Đăng — Trường Tiểu học & THCS Ánh Sáng"`
- **Các bước:**
  1. Nhập chuỗi trên vào form và lưu lại
  2. Tải lại dữ liệu qua API
- **Kết quả mong đợi:** Dữ liệu lưu trong PostgreSQL ở dạng UTF-8 NFC chuẩn; giao diện hiển thị sắc nét, không bị lỗi font, không mất dấu thanh
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NFR-002 — Họ và tên người dùng rất dài (> 50 ký tự) không làm vỡ bố cục
- **Module:** NFR
- **Ưu tiên:** P2
- **Loại:** Biên giao diện
- **Tham chiếu:** Mục 6.11 ("tên dài")
- **Endpoint / Màn hình:** Thẻ học sinh, Bảng điểm danh, Header trang chủ
- **Tiền điều kiện:** Học sinh có tên: `"Công Tằng Tôn Nữ Long Hoa Nữ Kiều Diễm Trang"` (45 ký tự)
- **Dữ liệu vào:** Xem hồ sơ học sinh trên
- **Các bước:**
  1. Mở xem danh sách học sinh và thẻ điểm danh
- **Kết quả mong đợi:** Tên được tự động xuống dòng hoặc hiển thị dấu ba chấm `...` tinh tế, không bị đè chữ lên icon hoặc đẩy các nút bấm ra ngoài màn hình
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NFR-003 — Chống tấn công XSS / HTML Tag Injection trong dữ liệu người dùng nhập
- **Module:** NFR
- **Ưu tiên:** P0
- **Loại:** Bảo mật
- **Tham chiếu:** An toàn thông tin ứng dụng
- **Endpoint / Màn hình:** Ô lý do nghỉ phép, Đề bài tập, Bình luận của giáo viên
- **Tiền điều kiện:** Người dùng cố tình chèn mã script
- **Dữ liệu vào:** `<script>alert('XSS')</script><b onmouseover=alert(1)>Test</b>`
- **Các bước:**
  1. Nhập chuỗi trên vào lý do xin nghỉ phép
  2. Phụ huynh và Giáo viên mở xem chi tiết đơn nghỉ
- **Kết quả mong đợi:** Ứng dụng encode an toàn mã HTML/script; hiển thị dưới dạng văn bản thô (plain text), tuyệt đối không thực thi mã độc
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NFR-004 — Bảo vệ dữ liệu cá nhân của trẻ: Không ghi log nhạy cảm
- **Module:** NFR
- **Ưu tiên:** P0
- **Loại:** Bảo mật / Riêng tư
- **Tham chiếu:** Mục 6.11 & Quy tắc số 8 ("Dữ liệu cá nhân của trẻ: không xuất hiện trong log hay phản hồi lỗi")
- **Endpoint / Màn hình:** Toàn bộ hệ thống backend (Log files: `application.log`, Console)
- **Tiền điều kiện:** Thực hiện import học sinh hoặc truy vấn thông tin học sinh
- **Dữ liệu vào:** Hồ sơ học sinh chứa CCCD/Aadhaar, địa chỉ nhà, số điện thoại phụ huynh
- **Các bước:**
  1. Gọi API lấy thông tin học sinh và import học sinh
  2. Kiểm tra log backend tại `backend/school-backend/logs` hoặc console stdout
- **Kết quả mong đợi:** Không có log nào in rõ số CCCD không mask, không in mật khẩu hoặc thông tin cá nhân nhạy cảm; số CCCD phải được che định dạng `XXXX-XXXX-1234`
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NFR-005 — Che giấu thông tin kỹ thuật trong phản hồi lỗi (Error Sanitization)
- **Module:** NFR
- **Ưu tiên:** P0
- **Loại:** Bảo mật
- **Tham chiếu:** Mục 6.11
- **Endpoint / Màn hình:** Các phản hồi lỗi 400, 404, 500
- **Tiền điều kiện:** Cố tình gây lỗi (gửi JSON hỏng cú pháp, id không tồn tại)
- **Dữ liệu vào:** Gửi payload lỗi cú pháp
- **Các bước:**
  1. Gửi request lỗi tới API
  2. Kiểm tra JSON response
- **Kết quả mong đợi:** Phản hồi thông báo lỗi rõ ràng và thân thiện; KHÔNG để lộ StackTrace Java, tên bảng/cột CSDL, câu lệnh SQL hoặc phiên bản thư viện
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NFR-006 — Thời gian phản hồi của API (Response Time P95 Benchmark)
- **Module:** NFR
- **Ưu tiên:** P1
- **Loại:** Hiệu năng
- **Tham chiếu:** Mục 6.11 & Mục 8.8
- **Endpoint / Màn hình:** `GET /api/academic-years/current`, `GET /api/classes`, `GET /api/student-portal/homework`
- **Tiền điều kiện:** Môi trường dev/test, mạng nội bộ
- **Dữ liệu vào:** Đo thời gian phản hồi cho 100 requests liên tiếp
- **Các bước:**
  1. Dùng curl hoặc script kiểm tra thời gian hoàn tất request
- **Kết quả mong đợi:** 95% số request (P95) hoàn tất trong thời gian <= 500ms; không có request nào bị timeout hoặc treo quá 3 giây
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NFR-007 — Khả năng xử lý đồng thời cơ bản (Concurrency Load Test)
- **Module:** NFR
- **Ưu tiên:** P1
- **Loại:** Hiệu năng / Tải
- **Tham chiếu:** Mục 6.11
- **Endpoint / Màn hình:** `POST /api/attendance/bulk` và `POST /api/student-portal/homework/submissions/{id}/draft`
- **Tiền điều kiện:** Giả lập 20 người dùng đồng thời gửi request trong cùng 1 giây
- **Dữ liệu vào:** 20 concurrent requests
- **Các bước:**
  1. Gửi đồng thời 20 requests
- **Kết quả mong đợi:** 100% request được xử lý thành công (HTTP 200), không có lỗi deadlock trong DB, không rò rỉ kết nối connection pool HikariCP
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NFR-008 — Tương thích trên phiên bản hệ điều hành cũ (Android 11 / API 30)
- **Module:** NFR
- **Ưu tiên:** P1
- **Loại:** Khả năng tương thích thiết bị
- **Tham chiếu:** Mục 2.2 Kế hoạch kiểm thử (Android 11)
- **Endpoint / Màn hình:** Toàn bộ ứng dụng Flutter
- **Tiền điều kiện:** Máy ảo hoặc thiết bị thật chạy Android 11
- **Dữ liệu vào:** Cài đặt file APK debug
- **Các bước:**
  1. Cài đặt và khởi chạy ứng dụng trên Android 11
  2. Đăng nhập và thao tác các tính năng chính
- **Kết quả mong đợi:** Ứng dụng khởi động bình thường, không crash khi render font, không crash khi mở camera/file picker để đính kèm bài tập
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-NFR-009 — Tương thích trên thiết bị màn hình nhỏ (Small Screen <= 6 inch)
- **Module:** NFR
- **Ưu tiên:** P2
- **Loại:** Khả năng tương thích thiết bị
- **Tham chiếu:** Mục 2.2 Kế hoạch kiểm thử
- **Endpoint / Màn hình:** Màn hình Làm bài kiểm tra & Bảng điểm
- **Tiền điều kiện:** Thiết bị màn hình 5.5 inch (720x1280)
- **Dữ liệu vào:** Mở ứng dụng
- **Các bước:**
  1. Thao tác trên màn hình nhỏ
- **Kết quả mong đợi:** Không bị tràn màn hình (No overflow errors), các nút bấm điều hướng trang sau/trang trước của câu hỏi luôn hiển thị trong tầm nhìn
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —
