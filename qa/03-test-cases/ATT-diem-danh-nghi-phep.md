# Test Cases — ATT: Điểm danh và Nghỉ phép

**Module:** ATT  
**Tổng số test case:** 17  
**Tham chiếu:** `quan-he-du-lieu.md` Mục 2.3 & 2.4, `qa/01-endpoint-inventory.md`, `AttendanceController.java`, `LeaveRequestController.java`

---

### TC-ATT-001 — Điểm danh hàng loạt đầy đủ danh sách học sinh của lớp
- **Module:** ATT
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `AttendanceController.java` `POST /api/attendance/bulk`
- **Endpoint / Màn hình:** `POST /api/attendance/bulk`
- **Tiền điều kiện:** GVCN `gv_chunhiem_3a` đăng nhập; Lớp 3A có 5 học sinh (ID: 1, 2, 3, 4, 5)
- **Dữ liệu vào:**
  ```json
  {
    "classId": 1,
    "date": "2026-10-15",
    "records": [
      {"studentId": 1, "status": "PRESENT"},
      {"studentId": 2, "status": "PRESENT"},
      {"studentId": 3, "status": "ABSENT", "remarks": "Nghỉ không phép"},
      {"studentId": 4, "status": "LATE"},
      {"studentId": 5, "status": "PRESENT"}
    ]
  }
  ```
- **Các bước:**
  1. Gửi request `POST /api/attendance/bulk` với dữ liệu trên
- **Kết quả mong đợi:** HTTP 200 OK; trả về xác nhận đã ghi nhận điểm danh cho 5 học sinh; DB lưu chính xác trạng thái
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-002 — Điểm danh hàng loạt thiếu học sinh trong danh sách gửi lên
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Biên
- **Tham chiếu:** `AttendanceService.java`
- **Endpoint / Màn hình:** `POST /api/attendance/bulk`
- **Tiền điều kiện:** Lớp 3A có 5 học sinh; GV chỉ gửi 3 học sinh (thiếu ID 4, 5)
- **Dữ liệu vào:** `{"classId":1,"date":"2026-10-15","records":[{"studentId":1,"status":"PRESENT"},{"studentId":2,"status":"PRESENT"},{"studentId":3,"status":"ABSENT"}]}`
- **Các bước:**
  1. Gửi request `POST /api/attendance/bulk` thiếu 2 học sinh
- **Kết quả mong đợi:** HTTP 200 OK; 3 học sinh được cập nhật; 2 học sinh còn lại giữ nguyên trạng thái chưa ghi nhận (UNMARKED), không bị tự động đánh vắng
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-003 — Gửi lại điểm danh trong cùng một ngày (Idempotency / Update)
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `AttendanceService.java` (UPSERT logic theo unique key: student_id + date)
- **Endpoint / Màn hình:** `POST /api/attendance/bulk`
- **Tiền điều kiện:** Học sinh ID 1 ban đầu được đánh `ABSENT` vào ngày 2026-10-15
- **Dữ liệu vào:** Gửi lại với `{"studentId": 1, "status": "PRESENT", "remarks": "Đến muộn đã vào lớp"}`
- **Các bước:**
  1. Lần 1: Gọi điểm danh `ABSENT` cho HS 1
  2. Lần 2: Gọi điểm danh lại `PRESENT` cho HS 1 trong cùng ngày
- **Kết quả mong đợi:** HTTP 200 OK; trạng thái của HS 1 cập nhật thành `PRESENT`; số lượng bản ghi trong DB không bị nhân đôi
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-004 — Phân biệt trạng thái "Chưa ghi nhận" (UNMARKED) và "Vắng mặt" (ABSENT)
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** Spec UI/UX Phase 1 Mục Điểm danh
- **Endpoint / Màn hình:** `GET /api/attendance/student/{studentId}` & Màn hình Điểm danh Flutter
- **Tiền điều kiện:** Hôm nay ngày mới chưa điểm danh
- **Dữ liệu vào:** `studentId = 1`
- **Các bước:**
  1. Phụ huynh / Giáo viên mở màn hình điểm danh trước khi GV bấm gửi
- **Kết quả mong đợi:** Giao diện hiển thị rõ nhãn màu xám "Chưa ghi nhận" (hoặc không có icon vắng); tỉ lệ chuyên cần không bị trừ điểm vắng khi chưa điểm danh
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-005 — Điểm danh đơn lẻ qua `/api/attendance/mark`
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #31
- **Endpoint / Màn hình:** `POST /api/attendance/mark`
- **Tiền điều kiện:** GV dạy lớp 3A
- **Dữ liệu vào:** `{"studentId":1,"date":"2026-10-15","status":"EXCUSED","remarks":"Có giấy bác sĩ"}`
- **Các bước:**
  1. Gọi `POST /api/attendance/mark`
- **Kết quả mong đợi:** HTTP 200 OK; lưu đúng trạng thái `EXCUSED`
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-006 — Phụ huynh nộp đơn xin nghỉ phép hợp lệ
- **Module:** ATT
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `LeaveRequestController.java` `POST /api/leave-requests`
- **Endpoint / Màn hình:** `POST /api/leave-requests`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` giám hộ học sinh ID 1
- **Dữ liệu vào:**
  ```json
  {
    "studentId": 1,
    "startDate": "2026-10-20",
    "endDate": "2026-10-22",
    "reason": "Cháu bị sốt xuất huyết, gia đình xin phép cho nghỉ điều trị tại nhà"
  }
  ```
- **Các bước:**
  1. Đăng nhập với `ph_con_3a`
  2. Gửi request tạo đơn nghỉ
- **Kết quả mong đợi:** HTTP 201 Created hoặc 200 OK; đơn được lưu với trạng thái `PENDING`; có `id` đơn mới
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-007 — Nộp đơn nghỉ phép có ngày kết thúc trước ngày bắt đầu (Invalid Date Range)
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Lỗi / Biên
- **Tham chiếu:** Spec Phụ huynh xin nghỉ phép; `LeaveRequestService.java`
- **Endpoint / Màn hình:** `POST /api/leave-requests`
- **Tiền điều kiện:** Phụ huynh đăng nhập hợp lệ
- **Dữ liệu vào:** `{"studentId":1,"startDate":"2026-10-25","endDate":"2026-10-20","reason":"Nghỉ việc gia đình"}`
- **Các bước:**
  1. Gửi request với `endDate < startDate`
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo lỗi "Ngày kết thúc không được trước ngày bắt đầu"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-008 — Nộp đơn nghỉ phép để trống lý do
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Lỗi
- **Tham chiếu:** Validation model `LeaveRequestCreateRequest`
- **Endpoint / Màn hình:** `POST /api/leave-requests`
- **Tiền điều kiện:** Phụ huynh đăng nhập
- **Dữ liệu vào:** `{"studentId":1,"startDate":"2026-10-20","endDate":"2026-10-21","reason":""}`
- **Các bước:**
  1. Gửi request với `reason` rỗng hoặc chỉ có khoảng trắng
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo trường lý do bắt buộc nhập
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-009 — Nộp đơn nghỉ phép trùng khoảng ngày với đơn đang chờ duyệt (Duplicate Date Range)
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Nghiệp vụ / Biên
- **Tham chiếu:** `LeaveRequestService.java`
- **Endpoint / Màn hình:** `POST /api/leave-requests`
- **Tiền điều kiện:** Đã có đơn PENDING từ ngày 2026-10-20 đến 2026-10-22
- **Dữ liệu vào:** Nộp tiếp đơn mới từ 2026-10-21 đến 2026-10-23 cho cùng học sinh
- **Các bước:**
  1. Nộp đơn thứ 2 trùng ngày
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo "Đã tồn tại đơn xin nghỉ trong khoảng thời gian này"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-010 — Nộp đơn nghỉ phép trùng khoảng ngày với đơn đã duyệt (APPROVED)
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Nghiệp vụ / Biên
- **Tham chiếu:** `LeaveRequestService.java`
- **Endpoint / Màn hình:** `POST /api/leave-requests`
- **Tiền điều kiện:** Đã có đơn APPROVED từ 2026-10-20 đến 2026-10-22
- **Dữ liệu vào:** Nộp đơn mới ngày 2026-10-20
- **Các bước:**
  1. Gửi request tạo đơn trùng ngày đã duyệt
- **Kết quả mong đợi:** HTTP 400 Bad Request; từ chối tạo trùng
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-011 — Phụ huynh xem danh sách đơn nghỉ của mình
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #33 (`GET /api/leave-requests/my-requests`)
- **Endpoint / Màn hình:** `GET /api/leave-requests/my-requests`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` có 2 đơn nghỉ đã tạo
- **Dữ liệu vào:** Token của `ph_con_3a`
- **Các bước:**
  1. Gọi `GET /api/leave-requests/my-requests`
- **Kết quả mong đợi:** HTTP 200 OK; trả về đúng 2 đơn của các con do phụ huynh này giám hộ; không lẫn đơn của phụ huynh khác
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-012 — Giáo viên chủ nhiệm xem danh sách đơn chờ duyệt của lớp mình
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #34 (`GET /api/leave-requests/pending`)
- **Endpoint / Màn hình:** `GET /api/leave-requests/pending`
- **Tiền điều kiện:** Lớp 3A có 2 đơn PENDING; GVCN `gv_chunhiem_3a` đăng nhập
- **Dữ liệu vào:** Token của GVCN
- **Các bước:**
  1. Gọi `GET /api/leave-requests/pending`
- **Kết quả mong đợi:** HTTP 200 OK; danh sách hiển thị đúng 2 đơn kèm tên học sinh, ngày nghỉ, lý do
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-013 — GVCN duyệt đơn nghỉ (APPROVED) và tự động đồng bộ điểm danh có phép (EXCUSED)
- **Module:** ATT
- **Ưu tiên:** P0
- **Loại:** Chức năng tích hợp
- **Tham chiếu:** Mục 6.4 ("Sau khi duyệt, bản ghi điểm danh các ngày nghỉ chuyển sang Có phép, và phụ huynh thấy kết quả")
- **Endpoint / Màn hình:** `PUT /api/leave-requests/{id}/review`
- **Tiền điều kiện:** Đơn nghỉ ID 1 (nghỉ ngày 2026-10-20 đến 2026-10-21) đang `PENDING`
- **Dữ liệu vào:** `{"status":"APPROVED"}`
- **Các bước:**
  1. GVCN gọi `PUT /api/leave-requests/1/review` với status `APPROVED`
  2. Kiểm tra bản ghi điểm danh ngày 2026-10-20 và 2026-10-21 của học sinh đó
- **Kết quả mong đợi:**
  - HTTP 200 OK; trạng thái đơn thành `APPROVED`
  - Các ngày 2026-10-20 và 2026-10-21 tự động được ghi nhận điểm danh `EXCUSED` (Có phép)
  - Phụ huynh xem thấy trạng thái `Đã duyệt`
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-014 — GVCN từ chối đơn nghỉ kèm lý do bắt buộc (REJECTED)
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `LeaveRequestReviewRequest.java`
- **Endpoint / Màn hình:** `PUT /api/leave-requests/{id}/review`
- **Tiền điều kiện:** Đơn ID 2 đang `PENDING`
- **Dữ liệu vào:** `{"status":"REJECTED","rejectionReason":"Trùng ngày thi học kỳ của trường, không giải quyết nghỉ phép"}`
- **Các bước:**
  1. GVCN gọi duyệt đơn từ chối kèm lý do
- **Kết quả mong đợi:** HTTP 200 OK; trạng thái đơn chuyển sang `REJECTED`; `rejectionReason` được lưu lại để phụ huynh đọc
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-015 — Duyệt lại đơn đã được duyệt hoặc đã từ chối (Double Review Protection)
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Biên / Nghiệp vụ
- **Tham chiếu:** `LeaveRequestService.java`
- **Endpoint / Màn hình:** `PUT /api/leave-requests/{id}/review`
- **Tiền điều kiện:** Đơn ID 1 đã ở trạng thái `APPROVED`
- **Dữ liệu vào:** `{"status":"REJECTED","rejectionReason":"Đổi ý"}`
- **Các bước:**
  1. GVCN gửi lại request review cho đơn ID 1 đã duyệt
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo "Đơn xin nghỉ phép đã được xử lý trước đó, không thể thay đổi trạng thái"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-016 — Giáo viên nhập điểm hàng loạt cho lớp phụ trách
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #37 (`POST /api/marks/bulk`)
- **Endpoint / Màn hình:** `POST /api/marks/bulk`
- **Tiền điều kiện:** GV `gv_bomon_3a` dạy môn Toán (ID 1) lớp 3A (ID 1)
- **Dữ liệu vào:**
  ```json
  {
    "classId": 1,
    "subjectId": 1,
    "marks": [
      {"studentId": 1, "score": 8.5, "examType": "MIDTERM"},
      {"studentId": 2, "score": 9.0, "examType": "MIDTERM"}
    ]
  }
  ```
- **Các bước:**
  1. Đăng nhập với `gv_bomon_3a`
  2. Gửi request `POST /api/marks/bulk`
- **Kết quả mong đợi:** HTTP 200 OK; điểm được lưu thành công
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-ATT-017 — Học sinh xem lịch sử điểm danh của chính mình
- **Module:** ATT
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #58 (`GET /api/student-portal/attendance`)
- **Endpoint / Màn hình:** `GET /api/student-portal/attendance`
- **Tiền điều kiện:** Đăng nhập với STUDENT `hs_3a_01`
- **Dữ liệu vào:** Token của STUDENT
- **Các bước:**
  1. Gọi `GET /api/student-portal/attendance`
- **Kết quả mong đợi:** HTTP 200 OK; trả về đúng lịch sử điểm danh và tổng số ngày có mặt/vắng của chính học sinh này
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —
