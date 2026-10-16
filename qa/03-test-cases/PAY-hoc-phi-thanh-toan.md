# Test Cases — PAY: Học phí và Thanh toán

**Module:** PAY  
**Tổng số test case:** 11  
**Tham chiếu:** `quan-he-du-lieu.md`, `qa/01-endpoint-inventory.md` (#62..#66), `FeeController.java`, `FeeService.java`, `TransactionRollbackRealTest.java` (TC-RB-04)  
**Quy tắc:** Chỉ chạy trên sandbox / test mode của cổng thanh toán. Tuyệt đối không dùng thông tin thẻ thật.

---

### TC-PAY-001 — Phụ huynh xem sao kê học phí của con mình (Fee Statement)
- **Module:** PAY
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #62 (`GET /api/fees/statement/{studentId}`)
- **Endpoint / Màn hình:** `GET /api/fees/statement/{studentId}`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` đăng nhập; Học sinh ID 1 có các khoản phí học kỳ 1
- **Dữ liệu vào:** `studentId = 1`
- **Các bước:**
  1. Gửi request `GET /api/fees/statement/1`
- **Kết quả mong đợi:** HTTP 200 OK; trả về chi tiết các khoản phí: học phí, tiền ăn, phụ phí, tổng số tiền phải nộp, số tiền đã nộp và số dư nợ
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-PAY-002 — Sao kê học phí khi học sinh không có khoản nợ nào (Zero Due)
- **Module:** PAY
- **Ưu tiên:** P1
- **Loại:** Chức năng / Biên
- **Tham chiếu:** `FeeService.java`
- **Endpoint / Màn hình:** `GET /api/fees/statement/{studentId}`
- **Tiền điều kiện:** Học sinh đã đóng đủ 100% học phí
- **Dữ liệu vào:** `studentId = 1`
- **Các bước:**
  1. Gọi API xem sao kê
- **Kết quả mong đợi:** HTTP 200 OK; tổng dư nợ = 0; trạng thái hiển thị "Đã hoàn thành nghĩa vụ học phí"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-PAY-003 — Phụ huynh xem sao kê khi học sinh chưa được gán biểu phí
- **Module:** PAY
- **Ưu tiên:** P1
- **Loại:** Biên
- **Tham chiếu:** `FeeService.java`
- **Endpoint / Màn hình:** `GET /api/fees/statement/{studentId}`
- **Tiền điều kiện:** Học sinh mới chuyển vào, chưa có biểu phí
- **Dữ liệu vào:** `studentId = 3`
- **Các bước:**
  1. Gọi API xem sao kê
- **Kết quả mong đợi:** HTTP 200 OK; danh sách khoản phí rỗng `[]`; không gây crash NullPointerException
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-PAY-004 — Phụ huynh tạo đơn thanh toán trực tuyến Razorpay (Create Order)
- **Module:** PAY
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #63 (`POST /api/fees/create-order`)
- **Endpoint / Màn hình:** `POST /api/fees/create-order`
- **Tiền điều kiện:** Phụ huynh đăng nhập; Con có khoản nợ 5,000,000 VND
- **Dữ liệu vào:**
  ```json
  {
    "studentId": 1,
    "amount": 5000000,
    "currency": "INR",
    "receipt": "RECEIPT_HS001_HK1"
  }
  ```
- **Các bước:**
  1. Gửi request tạo đơn hàng
- **Kết quả mong đợi:** HTTP 200 OK; trả về `orderId` từ Razorpay Sandbox (bắt đầu bằng `order_...`)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-PAY-005 — Tạo đơn với số tiền âm hoặc bằng 0 (Invalid Amount)
- **Module:** PAY
- **Ưu tiên:** P0
- **Loại:** Biên / Lỗi
- **Tham chiếu:** Validation `RazorpayOrderRequest`
- **Endpoint / Màn hình:** `POST /api/fees/create-order`
- **Tiền điều kiện:** Phụ huynh đăng nhập
- **Dữ liệu vào:** `{"studentId": 1, "amount": -100000}`
- **Các bước:**
  1. Gửi request tạo order với amount âm
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo "Số tiền thanh toán phải lớn hơn 0"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-PAY-006 — Tạo đơn vượt quá tổng số tiền học phí còn nợ
- **Module:** PAY
- **Ưu tiên:** P1
- **Loại:** Nghiệp vụ
- **Tham chiếu:** `FeeService.java`
- **Endpoint / Màn hình:** `POST /api/fees/create-order`
- **Tiền điều kiện:** Học sinh chỉ còn nợ 1,000,000 VND
- **Dữ liệu vào:** `{"studentId": 1, "amount": 10000000}` (gấp 10 lần số nợ)
- **Các bước:**
  1. Gửi request tạo order
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo số tiền thanh toán không được vượt quá số tiền nợ hiện tại
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-PAY-007 — Xác thực thanh toán thành công với chữ ký HMAC hợp lệ (Verify Payment)
- **Module:** PAY
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #64 (`POST /api/fees/verify-payment`)
- **Endpoint / Màn hình:** `POST /api/fees/verify-payment`
- **Tiền điều kiện:** Đã tạo order `order_test_123`
- **Dữ liệu vào:**
  ```json
  {
    "razorpayOrderId": "order_test_123",
    "razorpayPaymentId": "pay_test_456",
    "razorpaySignature": "<HMAC_SHA256_VALID_SIGNATURE>",
    "studentId": 1,
    "amount": 5000000
  }
  ```
- **Các bước:**
  1. Gửi request xác thực thanh toán
- **Kết quả mong đợi:** HTTP 200 OK; tạo bản ghi `FeePayment` trạng thái `PAID`; dư nợ của học sinh giảm tương ứng; trả về biên lai
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-PAY-008 — Xác thực thanh toán với chữ ký giả mạo (Invalid Signature / Tampered Payment)
- **Module:** PAY
- **Ưu tiên:** P0
- **Loại:** Bảo mật
- **Tham chiếu:** `FeeService.java` (Utils.verifyPaymentSignature)
- **Endpoint / Màn hình:** `POST /api/fees/verify-payment`
- **Tiền điều kiện:** Order `order_test_123` tồn tại
- **Dữ liệu vào:** Chữ ký `razorpaySignature = "FAKE_TAMPERED_SIGNATURE"`
- **Các bước:**
  1. Gửi request verify với chữ ký sai
- **Kết quả mong đợi:** HTTP 400 Bad Request; "Payment verification failed: Signature mismatch"; dư nợ học sinh KHÔNG bị giảm
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-PAY-009 — Kiểm tra tính bất biến / Idempotency khi bấm thanh toán hai lần (Double Verification)
- **Module:** PAY
- **Ưu tiên:** P0
- **Loại:** Toàn vẹn dữ liệu / Idempotency
- **Tham chiếu:** `TransactionRollbackRealTest.java` (TC-RB-04)
- **Endpoint / Màn hình:** `POST /api/fees/verify-payment`
- **Tiền điều kiện:** Mã `razorpayPaymentId = "pay_test_456"` đã được verify thành công lần 1
- **Dữ liệu vào:** Gửi lại y nguyên request xác thực với cùng paymentId đó
- **Các bước:**
  1. Gửi request verify lần 2
- **Kết quả mong đợi:** Hệ thống nhận diện payment đã được xử lý -> Không trừ thêm tiền vào dư nợ lần thứ 2; trả về bản ghi thanh toán hiện có mà không sinh bản ghi duplicate
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-PAY-010 — Đóng ứng dụng khi đang ở cổng thanh toán hoặc mạng bị gián đoạn
- **Module:** PAY
- **Ưu tiên:** P1
- **Loại:** Biên / Tích hợp UI
- **Tham chiếu:** Mục 6.8 ("đóng ứng dụng giữa chừng")
- **Endpoint / Màn hình:** Màn hình thanh toán Flutter
- **Tiền điều kiện:** Người dùng mở WebView Razorpay nhưng tắt app trước khi hoàn tất
- **Dữ liệu vào:** Kill app khi đang ở màn hình cổng thanh toán
- **Các bước:**
  1. Mở lại ứng dụng sau khi kill app
  2. Kiểm tra sao kê học phí
- **Kết quả mong đợi:** Trạng thái khoản phí vẫn giữ nguyên là CHƯA THANH TOÁN (Pending/Due); không có giao dịch treo nào tự động ghi nhận là đã nộp
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-PAY-011 — Quản trị viên ghi nhận nộp tiền mặt thủ công (`POST /api/fees/pay`)
- **Module:** PAY
- **Ưu tiên:** P1
- **Loại:** Chức năng Admin
- **Tham chiếu:** `01-endpoint-inventory.md` #66 (`POST /api/fees/pay`)
- **Endpoint / Màn hình:** `POST /api/fees/pay`
- **Tiền điều kiện:** Admin đăng nhập; Phụ huynh đến trường đóng tiền mặt
- **Dữ liệu vào:**
  ```json
  {
    "studentId": 1,
    "amount": 2000000,
    "paymentMethod": "CASH",
    "remarks": "Thu tiền mặt tại phòng kế toán, phiếu thu PT-0012"
  }
  ```
- **Các bước:**
  1. Admin gửi request ghi nhận thanh toán
- **Kết quả mong đợi:** HTTP 200 OK; ghi nhận thanh toán thành công; cập nhật giảm nợ ngay lập tức
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —
