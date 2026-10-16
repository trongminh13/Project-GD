# Test Cases — AUTH: Đăng nhập và Phiên

**Module:** AUTH  
**Tổng số test case:** 15  
**Nguồn:** AuthController.java (khóa 5 lần sai, TTL JWT 24h, rate limit OTP 60s)

---

### TC-AUTH-001 — Đăng nhập thành công với vai trò ADMIN
- **Module:** AUTH
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** AuthController.java `/api/auth/signin`
- **Endpoint / Màn hình:** `POST /api/auth/signin`
- **Tiền điều kiện:** Tài khoản ADMIN `admin` tồn tại và chưa bị khóa
- **Dữ liệu vào:** `{"username":"admin","password":"<admin_password>"}`
- **Các bước:**
  1. Gọi `POST http://localhost:8081/api/auth/signin` với body trên
- **Kết quả mong đợi:** HTTP 200; body chứa `token` (JWT), `type:"Bearer"`, `roles:["ADMIN"]`; màn hình điều hướng sang Admin Dashboard
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-002 — Đăng nhập sai mật khẩu (chưa bị khóa)
- **Module:** AUTH
- **Ưu tiên:** P0
- **Loại:** Lỗi
- **Tham chiếu:** AuthController.java L112-L114, `failedAttempts < 5`
- **Endpoint / Màn hình:** `POST /api/auth/signin`
- **Tiền điều kiện:** Tài khoản TEACHER `gv_chunhiem_3a` tồn tại; `failedAttempts = 0`
- **Dữ liệu vào:** `{"username":"gv_chunhiem_3a","password":"WRONG_PASSWORD"}`
- **Các bước:**
  1. Gọi `POST /api/auth/signin` với mật khẩu sai
- **Kết quả mong đợi:** HTTP 401; thông báo lỗi **không** tiết lộ "tài khoản tồn tại" hay "mật khẩu sai"; `failedAttempts` tăng lên 1
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-003 — Tài khoản bị khóa sau 5 lần sai liên tiếp
- **Module:** AUTH
- **Ưu tiên:** P0
- **Loại:** Bảo mật / Biên
- **Tham chiếu:** AuthController.java L112-L115 `if (currentAttempts >= 5) → setLockTime`
- **Endpoint / Màn hình:** `POST /api/auth/signin`
- **Tiền điều kiện:** Tài khoản PARENT `ph_con_3a` tồn tại; vai trò không phải ADMIN
- **Dữ liệu vào:** `{"username":"ph_con_3a","password":"WRONG_PASSWORD"}` — lặp 5 lần
- **Các bước:**
  1. Gọi `POST /api/auth/signin` với mật khẩu sai 5 lần liên tiếp
  2. Lần thứ 6 dùng **mật khẩu đúng**
- **Kết quả mong đợi:** Lần 6: HTTP 401; thông báo tài khoản bị khóa, kèm số phút còn lại (≈ 15 phút); không cho đăng nhập ngay cả khi mật khẩu đúng
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-004 — ADMIN không bị khóa khi nhập sai nhiều lần
- **Module:** AUTH
- **Ưu tiên:** P0
- **Loại:** Bảo mật / Biên
- **Tham chiếu:** AuthController.java L70 `user.getRole() != Role.ADMIN` — ADMIN miễn khóa
- **Endpoint / Màn hình:** `POST /api/auth/signin`
- **Tiền điều kiện:** Tài khoản ADMIN `admin` tồn tại
- **Dữ liệu vào:** `{"username":"admin","password":"WRONG_PASSWORD"}` — lặp 6 lần
- **Các bước:**
  1. Gọi 6 lần với mật khẩu sai
  2. Lần 7 dùng mật khẩu đúng
- **Kết quả mong đợi:** Lần 7: HTTP 200, đăng nhập thành công (ADMIN không bị khóa)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-005 — Tài khoản tự mở khóa sau 15 phút
- **Module:** AUTH
- **Ưu tiên:** P1
- **Loại:** Chức năng / Biên
- **Tham chiếu:** AuthController.java L71 `plusMinutes(15)`
- **Endpoint / Màn hình:** `POST /api/auth/signin`
- **Tiền điều kiện:** Tài khoản `ph_con_3a` đã bị khóa (có `lockTime` trong DB)
- **Dữ liệu vào:** Đăng nhập với mật khẩu đúng sau khi `lockTime + 15 phút` đã qua
- **Các bước:**
  1. Chờ hoặc cập nhật `lockTime` trong DB về `now() - 16 phút`
  2. Đăng nhập với mật khẩu đúng
- **Kết quả mong đợi:** HTTP 200, token trả về, `failedAttempts` reset về 0
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-006 — Đăng nhập với ô trống
- **Module:** AUTH
- **Ưu tiên:** P1
- **Loại:** Biên / Lỗi
- **Tham chiếu:** AuthController.java — `@Valid @RequestBody LoginRequest`
- **Endpoint / Màn hình:** `POST /api/auth/signin`
- **Tiền điều kiện:** Không cần
- **Dữ liệu vào:** `{"username":"","password":""}` và `{}` (thiếu field)
- **Các bước:**
  1. Gửi body với username và password rỗng
  2. Gửi body không có field
- **Kết quả mong đợi:** HTTP 400; không leak stack trace
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-007 — Đăng nhập đúng → mỗi vai trò vào đúng màn hình
- **Module:** AUTH
- **Ưu tiên:** P1
- **Loại:** Chức năng / Giao diện
- **Tham chiếu:** `main.dart` routing theo role
- **Endpoint / Màn hình:** Màn hình Splash → Login → Dashboard
- **Tiền điều kiện:** Tài khoản đủ 5 vai trò: ADMIN, TEACHER, PARENT, STUDENT, + TEACHER (bộ môn)
- **Dữ liệu vào:** Credential từng vai trò
- **Các bước:**
  1. Mở app Flutter
  2. Đăng nhập với ADMIN → kiểm tra màn hình Admin Dashboard
  3. Đăng xuất, đăng nhập với TEACHER → kiểm tra Teacher Dashboard
  4. Lặp cho PARENT, STUDENT
- **Kết quả mong đợi:** Mỗi vai trò hiển thị đúng màn hình home tương ứng; menu/nav bar khớp với vai trò
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-008 — Đổi mật khẩu thành công
- **Module:** AUTH
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** AuthController.java `/api/auth/change-password`
- **Endpoint / Màn hình:** `POST /api/auth/change-password`
- **Tiền điều kiện:** Đăng nhập với PARENT `ph_con_3a`, có token JWT hợp lệ
- **Dữ liệu vào:** `{"oldPassword":"<pw_cu>","newPassword":"NewPw@2026","confirmPassword":"NewPw@2026"}`
- **Các bước:**
  1. Đăng nhập lấy token
  2. Gọi `POST /api/auth/change-password` với token và body trên
  3. Đăng nhập lại với mật khẩu mới
- **Kết quả mong đợi:** HTTP 200; đăng nhập lại với mật khẩu mới thành công; mật khẩu cũ không còn dùng được
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-009 — Đổi mật khẩu với mật khẩu cũ sai → tăng failedAttempts
- **Module:** AUTH
- **Ưu tiên:** P0
- **Loại:** Bảo mật / Biên
- **Tham chiếu:** AuthController.java L154-L157
- **Endpoint / Màn hình:** `POST /api/auth/change-password`
- **Tiền điều kiện:** Token hợp lệ của PARENT `ph_con_3a`
- **Dữ liệu vào:** `{"oldPassword":"WRONG","newPassword":"NewPw@2026","confirmPassword":"NewPw@2026"}`
- **Các bước:**
  1. Gọi 5 lần liên tiếp với oldPassword sai
- **Kết quả mong đợi:** Sau lần thứ 5: tài khoản bị khóa 15 phút (brute-force protection qua change-password)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-010 — Đổi mật khẩu không có token → 401
- **Module:** AUTH
- **Ưu tiên:** P0
- **Loại:** Bảo mật
- **Tham chiếu:** AuthController.java — yêu cầu xác thực
- **Endpoint / Màn hình:** `POST /api/auth/change-password`
- **Tiền điều kiện:** Không có token
- **Dữ liệu vào:** Request không có `Authorization` header
- **Các bước:**
  1. Gọi `POST /api/auth/change-password` không có header
- **Kết quả mong đợi:** HTTP 401 hoặc 403
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-011 — OTP: rate limit 60 giây
- **Module:** AUTH
- **Ưu tiên:** P1
- **Loại:** Bảo mật / Biên
- **Tham chiếu:** AuthController.java `send-otp` — rate limit 60s/lần, 5/giờ
- **Endpoint / Màn hình:** `POST /api/auth/send-otp`
- **Tiền điều kiện:** Số điện thoại `ph_con_3a` đăng ký trong hệ thống
- **Dữ liệu vào:** `{"phone":"<so_dien_thoai>"}`
- **Các bước:**
  1. Gọi lần 1
  2. Gọi lần 2 ngay sau (< 60 giây)
- **Kết quả mong đợi:** Lần 2: HTTP 429 hoặc 400 với thông báo "Vui lòng đợi trước khi gửi lại OTP"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-012 — OTP: số điện thoại không tồn tại trong hệ thống
- **Module:** AUTH
- **Ưu tiên:** P1
- **Loại:** Lỗi / Bảo mật
- **Tham chiếu:** AuthController.java `send-otp`
- **Endpoint / Màn hình:** `POST /api/auth/send-otp`
- **Tiền điều kiện:** Số điện thoại không tồn tại
- **Dữ liệu vào:** `{"phone":"0900000000"}`
- **Các bước:**
  1. Gọi `POST /api/auth/send-otp` với SĐT không có trong DB
- **Kết quả mong đợi:** HTTP 400 hoặc 200 với thông báo chung (không tiết lộ SĐT có tồn tại hay không — bảo vệ thông tin người dùng)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-013 — OTP: xác thực thành công → nhận token
- **Module:** AUTH
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** AuthController.java `verify-otp`
- **Endpoint / Màn hình:** `POST /api/auth/verify-otp`
- **Tiền điều kiện:** Đã gọi `send-otp` thành công; OTP hợp lệ trong khoảng thời gian
- **Dữ liệu vào:** `{"phone":"<so_dien_thoai>","otp":"<otp_dung>"}`
- **Các bước:**
  1. Gọi `send-otp`
  2. Gọi `verify-otp` với OTP đúng
- **Kết quả mong đợi:** HTTP 200; token JWT trả về; vai trò PARENT
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-014 — STUDENT gọi GET /api/profile → 403
- **Module:** AUTH / SEC
- **Ưu tiên:** P1
- **Loại:** Phân quyền
- **Tham chiếu:** ProfileController.java — `@PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT')")` — thiếu STUDENT
- **Endpoint / Màn hình:** `GET /api/profile`
- **Tiền điều kiện:** Token STUDENT `hs_3a_01`
- **Dữ liệu vào:** Token hợp lệ của STUDENT
- **Các bước:**
  1. Đăng nhập với STUDENT lấy token
  2. Gọi `GET /api/profile` với token đó
- **Kết quả mong đợi:** HTTP 403 — ⚠️ Nếu 403 là hành vi **đúng chủ định** thì ghi Pass; nếu STUDENT cần xem profile thì đây là **lỗi thiếu endpoint**
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-AUTH-015 — Token hết hạn → 401
- **Module:** AUTH
- **Ưu tiên:** P0
- **Loại:** Bảo mật
- **Tham chiếu:** `jwtExpirationMs=86400000` (24h)
- **Endpoint / Màn hình:** Bất kỳ endpoint cần auth
- **Tiền điều kiện:** Token JWT đã hết hạn (giả lập hoặc chờ 24h)
- **Dữ liệu vào:** Token cũ (expired)
- **Các bước:**
  1. Tạo token với `exp` đã qua (dùng jwt.io decode/modify nếu có secret)
  2. Gọi `GET /api/profile` với token hết hạn
- **Kết quả mong đợi:** HTTP 401; không trả về dữ liệu
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —
