# Test Cases — SEC: Phân quyền ReBAC & Kiểm soát Truy cập

**Module:** SEC  
**Tổng số test case:** 54  
**Tham chiếu:** `quan-he-du-lieu.md`, `qa/01-endpoint-inventory.md`, `SchoolAccessPolicy.java`, `SecurityReBACTest.java`  
**Mục tiêu:** Kiểm tra triệt để ma trận quan hệ (của mình, của lớp mình, của người khác, của lớp khác) và phát hiện các lỗ hổng IDOR/BOLA.

---

## 1. Xác thực cơ bản & Token (TC-SEC-001 .. TC-SEC-005)

### TC-SEC-001 — Gọi endpoint quản trị không có Authorization header
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #8 (`POST /api/academic-years`)
- **Endpoint / Màn hình:** `POST /api/academic-years`
- **Tiền điều kiện:** Không gửi kèm token
- **Dữ liệu vào:** `{"yearName":"2026-2027","startDate":"2026-09-01","endDate":"2027-05-31"}`
- **Các bước:**
  1. Gửi request `POST /api/academic-years` không có header `Authorization`
- **Kết quả mong đợi:** HTTP 401 Unauthorized
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-002 — Gọi endpoint với Token hết hạn
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** JWT Security filter
- **Endpoint / Màn hình:** `GET /api/profile`
- **Tiền điều kiện:** Token JWT được ký hợp lệ nhưng thời gian `exp` đã quá hạn (>24h)
- **Dữ liệu vào:** Header `Authorization: Bearer <EXPIRED_JWT_TOKEN>`
- **Các bước:**
  1. Gửi request `GET /api/profile` kèm token hết hạn
- **Kết quả mong đợi:** HTTP 401 Unauthorized; thông báo lỗi token expired
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-003 — Gọi endpoint với Token bị chỉnh sửa chữ ký (Tampered JWT)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Bảo mật
- **Tham chiếu:** `JwtUtils.java`
- **Endpoint / Màn hình:** `GET /api/profile`
- **Tiền điều kiện:** Token JWT bị sửa payload hoặc chữ ký giả mạo
- **Dữ liệu vào:** Header `Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.invalid.signature`
- **Các bước:**
  1. Gửi request `GET /api/profile` với token giả mạo
- **Kết quả mong đợi:** HTTP 401 Unauthorized
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-004 — Học sinh gọi endpoint của Admin / Quản trị
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `StudentSecurityMatrixTest.java`
- **Endpoint / Màn hình:** `POST /api/classes`, `POST /api/students`, `POST /api/teachers`
- **Tiền điều kiện:** Đăng nhập với tài khoản STUDENT `hs_3a_01`
- **Dữ liệu vào:** Token của STUDENT
- **Các bước:**
  1. Gọi `POST /api/classes` tạo lớp
  2. Gọi `POST /api/students` tạo học sinh
  3. Gọi `POST /api/teachers` tạo giáo viên
- **Kết quả mong đợi:** 100% trả về HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-005 — Giáo viên gọi endpoint chỉ dành cho Admin
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #8, #9, #13, #70
- **Endpoint / Màn hình:** `POST /api/academic-years`, `POST /api/admin/migration/upload-excel`
- **Tiền điều kiện:** Đăng nhập với tài khoản TEACHER `gv_chunhiem_3a`
- **Dữ liệu vào:** Token của TEACHER
- **Các bước:**
  1. Gọi `POST /api/academic-years`
  2. Gọi `POST /api/admin/migration/upload-excel`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

## 2. ReBAC Enrollment & Lịch sử lớp (TC-SEC-006 .. TC-SEC-011)

### TC-SEC-006 — Phụ huynh xem Enrollment của con mình
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #26, `EnrollmentController.java`
- **Endpoint / Màn hình:** `GET /api/enrollments/student/{studentId}`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` có quan hệ `guardian_students` với học sinh ID 1 (`hs_3a_01`)
- **Dữ liệu vào:** `studentId = 1`
- **Các bước:**
  1. Đăng nhập với `ph_con_3a`
  2. Gọi `GET /api/enrollments/student/1`
- **Kết quả mong đợi:** HTTP 200 OK; trả về danh sách ghi danh lớp của học sinh 1
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-007 — Phụ huynh xem Enrollment của con người khác (IDOR)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `quan-he-du-lieu.md` Mục 2.3; `SecurityReBACTest.java` L486
- **Endpoint / Màn hình:** `GET /api/enrollments/student/{studentId}`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` KHÔNG có liên kết giám hộ với học sinh ID 2 (`hs_3b_01`)
- **Dữ liệu vào:** `studentId = 2`
- **Các bước:**
  1. Đăng nhập với `ph_con_3a`
  2. Gọi `GET /api/enrollments/student/2`
- **Kết quả mong đợi:** HTTP 403 Forbidden; không được lộ thông tin lớp của học sinh 2
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-008 — Học sinh xem Enrollment của chính mình
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #26
- **Endpoint / Màn hình:** `GET /api/enrollments/student/{studentId}`
- **Tiền điều kiện:** Học sinh `hs_3a_01` có studentId = 1
- **Dữ liệu vào:** `studentId = 1`
- **Các bước:**
  1. Đăng nhập với `hs_3a_01`
  2. Gọi `GET /api/enrollments/student/1`
- **Kết quả mong đợi:** HTTP 200 OK
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-009 — Học sinh xem Enrollment của bạn học cùng lớp / khác lớp (IDOR)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `SecurityReBACTest.java` L502
- **Endpoint / Màn hình:** `GET /api/enrollments/student/{studentId}`
- **Tiền điều kiện:** Học sinh `hs_3a_01` (studentId = 1); học sinh khác ID = 2
- **Dữ liệu vào:** `studentId = 2`
- **Các bước:**
  1. Đăng nhập với `hs_3a_01`
  2. Gọi `GET /api/enrollments/student/2`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-010 — Giáo viên xem Enrollment của học sinh lớp mình phụ trách
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `EnrollmentController.java`
- **Endpoint / Màn hình:** `GET /api/enrollments/student/{studentId}`
- **Tiền điều kiện:** GV `gv_chunhiem_3a` chủ nhiệm lớp 3A; học sinh ID 1 học lớp 3A
- **Dữ liệu vào:** `studentId = 1`
- **Các bước:**
  1. Đăng nhập với `gv_chunhiem_3a`
  2. Gọi `GET /api/enrollments/student/1`
- **Kết quả mong đợi:** HTTP 200 OK
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-011 — Giáo viên xem danh sách Enrollment theo lớp mình không dạy
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #27 (`GET /api/enrollments/class/{classId}`)
- **Endpoint / Màn hình:** `GET /api/enrollments/class/{classId}`
- **Tiền điều kiện:** GV `gv_lop_khac` không dạy và không chủ nhiệm lớp ID 1 (lớp 3A)
- **Dữ liệu vào:** `classId = 1`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `GET /api/enrollments/class/1`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

## 3. ReBAC Điểm danh & Nghỉ phép (TC-SEC-012 .. TC-SEC-025)

### TC-SEC-012 — Phụ huynh xem điểm danh con mình
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #28
- **Endpoint / Màn hình:** `GET /api/attendance/student/{studentId}`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` giám hộ học sinh ID 1
- **Dữ liệu vào:** `studentId = 1`
- **Các bước:**
  1. Gọi `GET /api/attendance/student/1`
- **Kết quả mong đợi:** HTTP 200 OK
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-013 — Phụ huynh xem điểm danh con người khác (IDOR)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `quan-he-du-lieu.md` Mục 2.3
- **Endpoint / Màn hình:** `GET /api/attendance/student/{studentId}`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` không giám hộ học sinh ID 2
- **Dữ liệu vào:** `studentId = 2`
- **Các bước:**
  1. Đăng nhập với `ph_con_3a`
  2. Gọi `GET /api/attendance/student/2`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-014 — Học sinh gọi API điểm danh trực tiếp qua studentId
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #28; Role STUDENT bị cấm tại AttendanceController
- **Endpoint / Màn hình:** `GET /api/attendance/student/{studentId}`
- **Tiền điều kiện:** Đăng nhập với STUDENT `hs_3a_01`
- **Dữ liệu vào:** `studentId = 1`
- **Các bước:**
  1. Gọi `GET /api/attendance/student/1`
- **Kết quả mong đợi:** HTTP 403 Forbidden (Học sinh chỉ được gọi qua `/api/student-portal/attendance`)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-015 — Giáo viên xem điểm danh học sinh lớp mình phụ trách
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `AttendanceService.java`
- **Endpoint / Màn hình:** `GET /api/attendance/student/{studentId}`
- **Tiền điều kiện:** GV `gv_chunhiem_3a` dạy học sinh ID 1
- **Dữ liệu vào:** `studentId = 1`
- **Các bước:**
  1. Gọi `GET /api/attendance/student/1`
- **Kết quả mong đợi:** HTTP 200 OK
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-016 — Giáo viên xem điểm danh học sinh lớp mình không dạy (IDOR)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `quan-he-du-lieu.md` Mục 2.2
- **Endpoint / Màn hình:** `GET /api/attendance/student/{studentId}`
- **Tiền điều kiện:** GV `gv_lop_khac` không dạy học sinh ID 1
- **Dữ liệu vào:** `studentId = 1`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `GET /api/attendance/student/1`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-017 — Giáo viên điểm danh hàng loạt cho lớp mình không dạy (Bulk Attendance BOLA)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #30; `AttendanceController.java`
- **Endpoint / Màn hình:** `POST /api/attendance/bulk`
- **Tiền điều kiện:** GV `gv_lop_khac` không dạy lớp 3A (classId = 1)
- **Dữ liệu vào:** `{"classId":1,"date":"2026-10-15","records":[{"studentId":1,"status":"PRESENT"}]}`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `POST /api/attendance/bulk`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** Ứng viên lỗi #3 trong `01-endpoint-inventory.md`

---

### TC-SEC-018 — Giáo viên điểm danh đơn lẻ cho học sinh lớp khác
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #31 (`POST /api/attendance/mark`)
- **Endpoint / Màn hình:** `POST /api/attendance/mark`
- **Tiền điều kiện:** GV `gv_lop_khac` không phụ trách học sinh 1
- **Dữ liệu vào:** `{"studentId":1,"date":"2026-10-15","status":"PRESENT"}`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `POST /api/attendance/mark`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** Ứng viên lỗi #4 trong `01-endpoint-inventory.md`

---

### TC-SEC-019 — Giáo viên Chủ nhiệm duyệt đơn nghỉ phép của học sinh lớp mình
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `SecurityReBACTest.java` L519; `SchoolAccessPolicy.java`
- **Endpoint / Màn hình:** `PUT /api/leave-requests/{id}/review`
- **Tiền điều kiện:** Đơn nghỉ ID 1 thuộc học sinh lớp 3A; `gv_chunhiem_3a` là GVCN lớp 3A
- **Dữ liệu vào:** `{"status":"APPROVED","rejectionReason":null}`
- **Các bước:**
  1. Đăng nhập với `gv_chunhiem_3a`
  2. Gọi `PUT /api/leave-requests/1/review`
- **Kết quả mong đợi:** HTTP 200 OK; đơn chuyển sang `APPROVED`
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-020 — Giáo viên Bộ môn (không chủ nhiệm) duyệt đơn nghỉ phép (ReBAC Privilege Escalation)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `quan-he-du-lieu.md` Mục 2.2; `SecurityReBACTest.java` L519
- **Endpoint / Màn hình:** `PUT /api/leave-requests/{id}/review`
- **Tiền điều kiện:** `gv_bomon_3a` dạy Toán lớp 3A nhưng KHÔNG PHẢI chủ nhiệm
- **Dữ liệu vào:** `{"status":"APPROVED"}`
- **Các bước:**
  1. Đăng nhập với `gv_bomon_3a`
  2. Gọi `PUT /api/leave-requests/1/review`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-021 — Giáo viên lớp khác duyệt đơn nghỉ phép
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `SchoolAccessPolicy.java`
- **Endpoint / Màn hình:** `PUT /api/leave-requests/{id}/review`
- **Tiền điều kiện:** `gv_lop_khac` không dạy lớp 3A
- **Dữ liệu vào:** `{"status":"REJECTED","rejectionReason":"Lý do sai"}`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `PUT /api/leave-requests/1/review`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-022 — Phụ huynh nộp đơn nghỉ phép cho con người khác (IDOR)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `LeaveRequestController.java`
- **Endpoint / Màn hình:** `POST /api/leave-requests`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` không có liên kết giám hộ với học sinh ID 2
- **Dữ liệu vào:** `{"studentId":2,"startDate":"2026-10-20","endDate":"2026-10-21","reason":"Nghỉ ốm"}`
- **Các bước:**
  1. Đăng nhập với `ph_con_3a`
  2. Gọi `POST /api/leave-requests`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-023 — Học sinh tự nộp đơn nghỉ phép
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `LeaveRequestController.java` (`@PreAuthorize("hasRole('PARENT')")`)
- **Endpoint / Màn hình:** `POST /api/leave-requests`
- **Tiền điều kiện:** Đăng nhập với STUDENT `hs_3a_01`
- **Dữ liệu vào:** `{"studentId":1,"startDate":"2026-10-20","endDate":"2026-10-21","reason":"Nghỉ phép"}`
- **Các bước:**
  1. Gọi `POST /api/leave-requests`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-024 — Phụ huynh xem lịch sử đơn nghỉ của con người khác
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #36
- **Endpoint / Màn hình:** `GET /api/leave-requests/student/{studentId}`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` không giám hộ học sinh ID 2
- **Dữ liệu vào:** `studentId = 2`
- **Các bước:**
  1. Đăng nhập với `ph_con_3a`
  2. Gọi `GET /api/leave-requests/student/2`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-025 — Giáo viên xem danh sách đơn chờ của lớp khác
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #34 (`GET /api/leave-requests/pending`)
- **Endpoint / Màn hình:** `GET /api/leave-requests/pending`
- **Tiền điều kiện:** GV `gv_lop_khac` không chủ nhiệm lớp 3A
- **Dữ liệu vào:** Token của `gv_lop_khac`
- **Các bước:**
  1. Gọi `GET /api/leave-requests/pending`
- **Kết quả mong đợi:** HTTP 200 OK nhưng mảng trả về rỗng `[]` (không chứa đơn của lớp 3A)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

## 4. ReBAC Bảng điểm (TC-SEC-026 .. TC-SEC-029)

### TC-SEC-026 — Giáo viên nhập điểm cho lớp mình không phụ trách (BOLA)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #37; `MarksController.java`
- **Endpoint / Màn hình:** `POST /api/marks/bulk`
- **Tiền điều kiện:** GV `gv_lop_khac` không dạy môn ID 1 tại lớp ID 1
- **Dữ liệu vào:** `{"classId":1,"subjectId":1,"marks":[{"studentId":1,"score":9.5}]}`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `POST /api/marks/bulk`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-027 — Phụ huynh xem điểm của con người khác (IDOR)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #38 (`GET /api/marks/student/{studentId}`)
- **Endpoint / Màn hình:** `GET /api/marks/student/{studentId}`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` không giám hộ học sinh ID 2
- **Dữ liệu vào:** `studentId = 2`
- **Các bước:**
  1. Đăng nhập với `ph_con_3a`
  2. Gọi `GET /api/marks/student/2`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-028 — Học sinh xem điểm của học sinh khác qua endpoint quản lý
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #38
- **Endpoint / Màn hình:** `GET /api/marks/student/{studentId}`
- **Tiền điều kiện:** Đăng nhập với STUDENT `hs_3a_01`
- **Dữ liệu vào:** `studentId = 2`
- **Các bước:**
  1. Gọi `GET /api/marks/student/2`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-029 — Giáo viên xem điểm của học sinh lớp mình không dạy
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #38
- **Endpoint / Màn hình:** `GET /api/marks/student/{studentId}`
- **Tiền điều kiện:** GV `gv_lop_khac` không dạy học sinh ID 1
- **Dữ liệu vào:** `studentId = 1`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `GET /api/marks/student/1`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

## 5. ReBAC Học liệu & File tải trực tiếp (TC-SEC-030 .. TC-SEC-037)

### TC-SEC-030 — Học sinh đúng lớp tải file học liệu đã xuất bản (PUBLISHED)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `SecurityReBACTest.java` L611
- **Endpoint / Màn hình:** `GET /api/materials/files/{fileId}/download`
- **Tiền điều kiện:** Học sinh `hs_3a_01` học lớp 3A; file ID 1 thuộc học liệu gán cho lớp 3A ở trạng thái `PUBLISHED`
- **Dữ liệu vào:** `fileId = 1`
- **Các bước:**
  1. Đăng nhập với `hs_3a_01`
  2. Gọi `GET /api/materials/files/1/download`
- **Kết quả mong đợi:** HTTP 200 OK kèm stream file
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-031 — Học sinh khác lớp tải file học liệu (IDOR File Download)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `quan-he-du-lieu.md` Mục 2.4; `SecurityReBACTest.java` L611
- **Endpoint / Màn hình:** `GET /api/materials/files/{fileId}/download`
- **Tiền điều kiện:** Học sinh `hs_3b_01` học lớp 3B; file ID 1 chỉ gán cho lớp 3A
- **Dữ liệu vào:** `fileId = 1`
- **Các bước:**
  1. Đăng nhập với `hs_3b_01`
  2. Gọi `GET /api/materials/files/1/download`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-032 — Học sinh tải file học liệu đang ở trạng thái Nháp (DRAFT)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `SchoolAccessPolicy.java`
- **Endpoint / Màn hình:** `GET /api/materials/files/{fileId}/download`
- **Tiền điều kiện:** File ID 2 thuộc học liệu gán lớp 3A nhưng ở trạng thái `DRAFT`
- **Dữ liệu vào:** `fileId = 2`
- **Các bước:**
  1. Đăng nhập với `hs_3a_01`
  2. Gọi `GET /api/materials/files/2/download`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-033 — Phụ huynh có con học lớp nhận học liệu tải file
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `SecurityReBACTest.java` L653
- **Endpoint / Màn hình:** `GET /api/materials/files/{fileId}/download`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` có con học lớp 3A; file ID 1 gán cho lớp 3A
- **Dữ liệu vào:** `fileId = 1`
- **Các bước:**
  1. Đăng nhập với `ph_con_3a`
  2. Gọi `GET /api/materials/files/1/download`
- **Kết quả mong đợi:** HTTP 200 OK
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-034 — Phụ huynh lớp khác tải file học liệu
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `SecurityReBACTest.java` L653
- **Endpoint / Màn hình:** `GET /api/materials/files/{fileId}/download`
- **Tiền điều kiện:** Phụ huynh `ph_con_khac` không có con học lớp 3A
- **Dữ liệu vào:** `fileId = 1`
- **Các bước:**
  1. Đăng nhập với `ph_con_khac`
  2. Gọi `GET /api/materials/files/1/download`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-035 — Giáo viên bộ môn dạy lớp nhận học liệu tải file
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `SecurityReBACTest.java` L694
- **Endpoint / Màn hình:** `GET /api/materials/files/{fileId}/download`
- **Tiền điều kiện:** GV `gv_bomon_3a` dạy lớp 3A
- **Dữ liệu vào:** `fileId = 1`
- **Các bước:**
  1. Đăng nhập với `gv_bomon_3a`
  2. Gọi `GET /api/materials/files/1/download`
- **Kết quả mong đợi:** HTTP 200 OK
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-036 — Giáo viên không liên quan tải file học liệu
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `SecurityReBACTest.java` L694
- **Endpoint / Màn hình:** `GET /api/materials/files/{fileId}/download`
- **Tiền điều kiện:** GV `gv_lop_khac` không soạn và không dạy lớp 3A
- **Dữ liệu vào:** `fileId = 1`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `GET /api/materials/files/1/download`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-037 — Tải file không tồn tại trên ổ cứng (Path Traversal / Missing File)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Bảo mật
- **Tham chiếu:** `SecurityReBACTest.java` L741
- **Endpoint / Màn hình:** `GET /api/materials/files/{fileId}/download`
- **Tiền điều kiện:** File ID 9999 có bản ghi trong DB nhưng không có file vật lý
- **Dữ liệu vào:** `fileId = 9999`
- **Các bước:**
  1. Gọi `GET /api/materials/files/9999/download`
- **Kết quả mong đợi:** HTTP 404 Not Found (tuyệt đối không được crash 500 hoặc sinh file giả)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

## 6. ReBAC Bài tập & Chấm điểm (TC-SEC-038 .. TC-SEC-049)

### TC-SEC-038 — Giáo viên xem bài tập do giáo viên khác tạo
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #46
- **Endpoint / Màn hình:** `GET /api/teacher/homework/{id}`
- **Tiền điều kiện:** Bài tập ID 1 do GV A tạo
- **Dữ liệu vào:** `id = 1`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `GET /api/teacher/homework/1`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-039 — Giáo viên giao bài tập cho lớp mình không phụ trách
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `SchoolAccessPolicy.java` `verifyTeacherCanAssignClass`
- **Endpoint / Màn hình:** `POST /api/teacher/homework/{id}/assign`
- **Tiền điều kiện:** GV `gv_lop_khac` không dạy lớp 3A (classId = 1)
- **Dữ liệu vào:** `{"classId":1,"dueDate":"2026-10-30T23:59:59","allowLateSubmission":false}`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `POST /api/teacher/homework/1/assign`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-040 — Giáo viên giao bài tập của người khác cho lớp mình
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `TeacherHomeworkController.java`
- **Endpoint / Màn hình:** `POST /api/teacher/homework/{id}/assign`
- **Tiền điều kiện:** Bài tập ID 1 do GV khác tạo
- **Dữ liệu vào:** `{"classId":2,...}`
- **Các bước:**
  1. Gọi `POST /api/teacher/homework/1/assign` với token GV không tạo bài
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-041 — Giáo viên xem bài nộp của assignment lớp khác (IDOR)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #49
- **Endpoint / Màn hình:** `GET /api/teacher/homework/assignments/{assignmentId}/submissions`
- **Tiền điều kiện:** Assignment ID 1 giao cho lớp 3A; `gv_lop_khac` không dạy lớp 3A
- **Dữ liệu vào:** `assignmentId = 1`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `GET /api/teacher/homework/assignments/1/submissions`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-042 — Giáo viên xem bài làm chi tiết (Submission) của lớp khác
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #50
- **Endpoint / Màn hình:** `GET /api/teacher/homework/submissions/{submissionId}`
- **Tiền điều kiện:** Submission ID 1 của học sinh lớp 3A
- **Dữ liệu vào:** `submissionId = 1`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `GET /api/teacher/homework/submissions/1`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-043 — Giáo viên chấm điểm bài nộp của lớp mình không dạy
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #51
- **Endpoint / Màn hình:** `PUT /api/teacher/homework/submissions/{submissionId}/grade`
- **Tiền điều kiện:** GV `gv_lop_khac` không phụ trách lớp có bài nộp ID 1
- **Dữ liệu vào:** `{"teacherComment":"Tốt","details":[{"questionId":1,"points":10}]}`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `PUT /api/teacher/homework/submissions/1/grade`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-044 — Học sinh mở bài tập của lớp khác (IDOR Assignment)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `quan-he-du-lieu.md` Mục 2.4; `01-endpoint-inventory.md` #53
- **Endpoint / Màn hình:** `GET /api/student-portal/homework/{assignmentId}/take`
- **Tiền điều kiện:** Học sinh `hs_3b_01` học lớp 3B; Assignment ID 1 giao cho lớp 3A
- **Dữ liệu vào:** `assignmentId = 1`
- **Các bước:**
  1. Đăng nhập với `hs_3b_01`
  2. Gọi `GET /api/student-portal/homework/1/take`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-045 — Kiểm tra rò rỉ đáp án đúng khi học sinh mở bài làm (Cheating Prevention)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Bảo mật
- **Tham chiếu:** Mục 6.2 ("Đáp án đúng không xuất hiện trong dữ liệu trả về khi học sinh đang làm bài")
- **Endpoint / Màn hình:** `GET /api/student-portal/homework/{assignmentId}/take`
- **Tiền điều kiện:** Học sinh `hs_3a_01` thuộc lớp nhận bài
- **Dữ liệu vào:** `assignmentId = 1`
- **Các bước:**
  1. Đăng nhập với `hs_3a_01`
  2. Gọi `GET /api/student-portal/homework/1/take`
  3. Kiểm tra toàn bộ JSON response (các trường `isCorrect`, `correctAnswer`, `correctOptions`, `explanation`)
- **Kết quả mong đợi:** HTTP 200 OK; các câu hỏi KHÔNG chứa bất kỳ trường nào tiết lộ đáp án đúng hoặc giải thích đáp án
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-046 — Học sinh nộp optionId không thuộc questionId (Tampering Injection)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Bảo mật / Biên
- **Tham chiếu:** Mục 6.2 ("Gửi optionId không thuộc questionId")
- **Endpoint / Màn hình:** `POST /api/student-portal/homework/submissions/{submissionId}/draft`
- **Tiền điều kiện:** Học sinh `hs_3a_01` đang làm bài submissionId = 1
- **Dữ liệu vào:** `{"answers":[{"questionId":1,"selectedOptionIds":[99999]}]}` (optionId 99999 của câu hỏi khác hoặc không tồn tại)
- **Các bước:**
  1. Gọi API lưu draft với optionId giả mạo
- **Kết quả mong đợi:** HTTP 400 Bad Request (hệ thống từ chối ghi nhận option không hợp lệ)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-047 — Học sinh sửa bài làm nháp của học sinh khác (IDOR Submission Draft)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `SchoolAccessPolicy.java` `verifyStudentCanAccessSubmission`
- **Endpoint / Màn hình:** `POST /api/student-portal/homework/submissions/{submissionId}/draft`
- **Tiền điều kiện:** Submission ID 2 của học sinh B; học sinh `hs_3a_01` (học sinh A) đang đăng nhập
- **Dữ liệu vào:** `submissionId = 2`
- **Các bước:**
  1. Đăng nhập với `hs_3a_01`
  2. Gọi `POST /api/student-portal/homework/submissions/2/draft` với body bài làm
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-048 — Học sinh nộp chính thức bài làm của học sinh khác (IDOR Submission Submit)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `SchoolAccessPolicy.java`
- **Endpoint / Màn hình:** `POST /api/student-portal/homework/submissions/{submissionId}/submit`
- **Tiền điều kiện:** Submission ID 2 của học sinh khác
- **Dữ liệu vào:** `submissionId = 2`
- **Các bước:**
  1. Đăng nhập với `hs_3a_01`
  2. Gọi `POST /api/student-portal/homework/submissions/2/submit`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-049 — Phụ huynh xem bài tập của học sinh khác (IDOR Parent Homework)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #56
- **Endpoint / Màn hình:** `GET /api/parent/wards/{studentId}/homework`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` không giám hộ học sinh ID 2
- **Dữ liệu vào:** `studentId = 2`
- **Các bước:**
  1. Đăng nhập với `ph_con_3a`
  2. Gọi `GET /api/parent/wards/2/homework`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

## 7. Profile & Phí & Phân công (TC-SEC-050 .. TC-SEC-054)

### TC-SEC-050 — Học sinh truy cập `/api/profile`
- **Module:** SEC
- **Ưu tiên:** P1
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #60 (`ProfileController.java`)
- **Endpoint / Màn hình:** `GET /api/profile`
- **Tiền điều kiện:** Đăng nhập với STUDENT `hs_3a_01`
- **Dữ liệu vào:** Token của STUDENT
- **Các bước:**
  1. Gọi `GET /api/profile`
- **Kết quả mong đợi:** Cần xác nhận: Hiện code chỉ cho `ADMIN, TEACHER, PARENT` (trả về 403). Nếu spec yêu cầu HS xem profile qua `/api/student-portal/profile`, thì 403 ở đây là đúng.
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-051 — Phụ huynh xem sao kê học phí của con người khác (IDOR Fee Statement)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #62 (`GET /api/fees/statement/{studentId}`)
- **Endpoint / Màn hình:** `GET /api/fees/statement/{studentId}`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` không giám hộ học sinh ID 2
- **Dữ liệu vào:** `studentId = 2`
- **Các bước:**
  1. Đăng nhập với `ph_con_3a`
  2. Gọi `GET /api/fees/statement/2`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-052 — Phụ huynh xem công nợ học phí của con người khác (IDOR Fee Student)
- **Module:** SEC
- **Ưu tiên:** P0
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #65 (`GET /api/fees/student/{studentId}`)
- **Endpoint / Màn hình:** `GET /api/fees/student/{studentId}`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` không giám hộ học sinh ID 2
- **Dữ liệu vào:** `studentId = 2`
- **Các bước:**
  1. Đăng nhập với `ph_con_3a`
  2. Gọi `GET /api/fees/student/2`
- **Kết quả mong đợi:** HTTP 403 Forbidden
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-SEC-053 — Giáo viên xem phân công giảng dạy của giáo viên khác
- **Module:** SEC
- **Ưu tiên:** P1
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #71 (`TeachingAssignmentController.java`)
- **Endpoint / Màn hình:** `GET /api/teaching-assignments/teacher/{teacherId}`
- **Tiền điều kiện:** GV `gv_chunhiem_3a` (teacherId = 1); GV khác ID = 2
- **Dữ liệu vào:** `teacherId = 2`
- **Các bước:**
  1. Đăng nhập với `gv_chunhiem_3a`
  2. Gọi `GET /api/teaching-assignments/teacher/2`
- **Kết quả mong đợi:** HTTP 403 Forbidden (hoặc chỉ trả về phân công công khai nếu trường cho phép; cần xác nhận)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** Ứng viên lỗi #6 trong `01-endpoint-inventory.md`

---

### TC-SEC-054 — Giáo viên xem phân công giảng dạy của lớp mình không dạy
- **Module:** SEC
- **Ưu tiên:** P1
- **Loại:** Phân quyền
- **Tham chiếu:** `01-endpoint-inventory.md` #72
- **Endpoint / Màn hình:** `GET /api/teaching-assignments/class/{classId}`
- **Tiền điều kiện:** GV `gv_lop_khac` không dạy lớp 3A (classId = 1)
- **Dữ liệu vào:** `classId = 1`
- **Các bước:**
  1. Đăng nhập với `gv_lop_khac`
  2. Gọi `GET /api/teaching-assignments/class/1`
- **Kết quả mong đợi:** HTTP 403 Forbidden (hoặc 200 nếu phân công theo thời khóa biểu công khai)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** Ứng viên lỗi #7 trong `01-endpoint-inventory.md`
