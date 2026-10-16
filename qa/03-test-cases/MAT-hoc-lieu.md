# Test Cases — MAT: Học liệu và Quản lý Tệp

**Module:** MAT  
**Tổng số test case:** 11  
**Tham chiếu:** `quan-he-du-lieu.md` Mục 2.4, `qa/01-endpoint-inventory.md` (#40..#43), `MaterialController.java`, `MaterialService.java`, `SecurityReBACTest.java`

---

### TC-MAT-001 — Giáo viên tạo học liệu mới ở trạng thái Nháp (DRAFT)
- **Module:** MAT
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `MaterialController.java` `POST /api/teacher/materials`
- **Endpoint / Màn hình:** `POST /api/teacher/materials`
- **Tiền điều kiện:** GV `gv_chunhiem_3a` đăng nhập; Môn Toán (ID 1)
- **Dữ liệu vào:**
  ```json
  {
    "title": "Tài liệu ôn tập Hình học không gian",
    "description": "Các công thức tính thể tích và diện tích",
    "subjectId": 1,
    "status": "DRAFT",
    "targetClassIds": [1],
    "fileIds": []
  }
  ```
- **Các bước:**
  1. Gửi request tạo học liệu
- **Kết quả mong đợi:** HTTP 200 OK; học liệu được lưu với trạng thái `DRAFT`; chưa xuất bản cho học sinh
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-MAT-002 — Giáo viên tạo và xuất bản học liệu trực tiếp (PUBLISHED)
- **Module:** MAT
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `MaterialController.java`
- **Endpoint / Màn hình:** `POST /api/teacher/materials`
- **Tiền điều kiện:** GV dạy môn Toán lớp 3A (ID 1)
- **Dữ liệu vào:**
  ```json
  {
    "title": "Slide bài giảng Phép nhân số có 2 chữ số",
    "description": "Bài học ngày 15/10",
    "subjectId": 1,
    "status": "PUBLISHED",
    "targetClassIds": [1],
    "fileIds": [1]
  }
  ```
- **Các bước:**
  1. Gửi request tạo với `status = "PUBLISHED"`
- **Kết quả mong đợi:** HTTP 200 OK; học liệu chuyển sang `PUBLISHED`; học sinh lớp 3A có thể xem ngay
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-MAT-003 — Phân phối học liệu cho nhiều lớp đồng thời (Multi-class Distribution)
- **Module:** MAT
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** Mục 6.6 ("phân phối lớp")
- **Endpoint / Màn hình:** `POST /api/teacher/materials`
- **Tiền điều kiện:** GV phụ trách môn Toán cho cả 2 lớp 3A (classId = 1) và 3B (classId = 2)
- **Dữ liệu vào:** `"targetClassIds": [1, 2]`
- **Các bước:**
  1. Gửi request phân phối học liệu cho 2 lớp
- **Kết quả mong đợi:** HTTP 200 OK; học sinh của cả lớp 3A và lớp 3B đều thấy học liệu này trong portal
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-MAT-004 — Giáo viên xem danh sách học liệu do mình quản lý
- **Module:** MAT
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #41 (`GET /api/teacher/materials`)
- **Endpoint / Màn hình:** `GET /api/teacher/materials`
- **Tiền điều kiện:** GV đã tạo 3 học liệu (1 Draft, 2 Published)
- **Dữ liệu vào:** Token GV
- **Các bước:**
  1. Gọi `GET /api/teacher/materials`
- **Kết quả mong đợi:** HTTP 200 OK; trả về đúng 3 học liệu của GV này, hiển thị rõ trạng thái và số lượng lớp được chia sẻ
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-MAT-005 — Học sinh xem danh sách học liệu trong Portal của mình
- **Module:** MAT
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #42 (`GET /api/student-portal/materials`)
- **Endpoint / Màn hình:** `GET /api/student-portal/materials`
- **Tiền điều kiện:** Học sinh `hs_3a_01` học lớp 3A; Lớp 3A được gán 2 học liệu PUBLISHED
- **Dữ liệu vào:** Token STUDENT
- **Các bước:**
  1. Gọi `GET /api/student-portal/materials`
- **Kết quả mong đợi:** HTTP 200 OK; danh sách trả về 2 học liệu kèm tên file và link download
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-MAT-006 — Học sinh không thấy học liệu của lớp khác
- **Module:** MAT
- **Ưu tiên:** P0
- **Loại:** Phân quyền / Cách ly dữ liệu
- **Tham chiếu:** Mục 6.6 ("Chỉ học sinh thuộc lớp được xuất bản mới thấy")
- **Endpoint / Màn hình:** `GET /api/student-portal/materials`
- **Tiền điều kiện:** Học sinh `hs_3b_01` học lớp 3B; Học liệu X chỉ gán cho lớp 3A
- **Dữ liệu vào:** Token của `hs_3b_01`
- **Các bước:**
  1. Gọi `GET /api/student-portal/materials`
- **Kết quả mong đợi:** Danh sách trả về KHÔNG chứa học liệu X
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-MAT-007 — Học liệu ở trạng thái Nháp (DRAFT) không xuất hiện trong Portal học sinh
- **Module:** MAT
- **Ưu tiên:** P0
- **Loại:** Phân quyền trạng thái
- **Tham chiếu:** `MaterialService.java` (`status = PUBLISHED` filter)
- **Endpoint / Màn hình:** `GET /api/student-portal/materials`
- **Tiền điều kiện:** Học liệu Y gán cho lớp 3A nhưng GV để trạng thái `DRAFT`
- **Dữ liệu vào:** Token học sinh lớp 3A
- **Các bước:**
  1. Gọi `GET /api/student-portal/materials`
- **Kết quả mong đợi:** Học liệu Y không xuất hiện trong danh sách của học sinh
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-MAT-008 — Tải tệp học liệu đính kèm (File Download Stream)
- **Module:** MAT
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #43 (`GET /api/materials/files/{fileId}/download`)
- **Endpoint / Màn hình:** `GET /api/materials/files/{fileId}/download`
- **Tiền điều kiện:** File ID 1 tồn tại trên disk (`storage/materials/...`); Học sinh lớp 3A có quyền
- **Dữ liệu vào:** `fileId = 1`
- **Các bước:**
  1. Gửi request download file
- **Kết quả mong đợi:** HTTP 200 OK; Header `Content-Type: application/pdf`, `Content-Disposition: attachment; filename="de_cuong.pdf"`; nội dung file tải về nguyên vẹn
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-MAT-009 — Tải file có tên chứa tiếng Việt có dấu và ký tự đặc biệt
- **Module:** MAT
- **Ưu tiên:** P1
- **Loại:** Mã hóa / Tiếng Việt
- **Tham chiếu:** Mục 6.6 ("tên tệp có ký tự tiếng Việt và đặc biệt")
- **Endpoint / Màn hình:** `GET /api/materials/files/{fileId}/download`
- **Tiền điều kiện:** File được đặt tên `"Đề_Cương_Ôn_Tập_Học_Kỳ_1_(Toán_3A).pdf"`
- **Dữ liệu vào:** `fileId = 2`
- **Các bước:**
  1. Tải file về
- **Kết quả mong đợi:** HTTP 200 OK; tên file khi lưu trên máy khách hiển thị đúng nguyên vẹn tiếng Việt có dấu (Header `filename*=UTF-8''...`), không bị mã hóa URL hoặc lỗi font
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-MAT-010 — Chặn upload file học liệu vượt quá dung lượng tối đa (> 50MB)
- **Module:** MAT
- **Ưu tiên:** P1
- **Loại:** Giới hạn / Hiệu năng
- **Tham chiếu:** Mục 6.6 ("Tệp lớn")
- **Endpoint / Màn hình:** Màn hình upload tài liệu Flutter & API upload
- **Tiền điều kiện:** File video/tài liệu nặng 75MB
- **Dữ liệu vào:** File 75MB
- **Các bước:**
  1. Gửi request upload file vượt dung lượng
- **Kết quả mong đợi:** HTTP 413 Payload Too Large hoặc HTTP 400 Bad Request; thông báo "Kích thước tệp vượt quá giới hạn cho phép (tối đa 50MB)"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-MAT-011 — Cập nhật phiên bản mới của tệp học liệu (File Versioning)
- **Module:** MAT
- **Ưu tiên:** P2
- **Loại:** Chức năng
- **Tham chiếu:** Mục 6.6 ("Phiên bản tệp")
- **Endpoint / Màn hình:** Giao diện quản lý học liệu của GV
- **Tiền điều kiện:** Học liệu X đã có file đính kèm v1
- **Dữ liệu vào:** GV upload file mới v2 thay thế
- **Các bước:**
  1. Cập nhật file đính kèm cho học liệu
  2. Học sinh tải lại file
- **Kết quả mong đợi:** File tải về là phiên bản mới nhất v2; file cũ được lưu trữ hoặc xóa an toàn, không bị xung đột cache
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —
