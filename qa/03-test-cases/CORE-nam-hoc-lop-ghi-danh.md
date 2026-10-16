# Test Cases — CORE: Năm học, Lớp, Ghi danh & Liên kết

**Module:** CORE  
**Tổng số test case:** 17  
**Tham chiếu:** `quan-he-du-lieu.md` Mục 1 & 2.1; `AcademicYearController.java`, `SchoolClassController.java`, `StudentController.java`, `EnrollmentController.java`, `TeachingAssignmentController.java`

---

### TC-CORE-001 — Lấy danh sách tất cả năm học
- **Module:** CORE
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #6 (`GET /api/academic-years`)
- **Endpoint / Màn hình:** `GET /api/academic-years`
- **Tiền điều kiện:** DB đã có ít nhất 2 năm học
- **Dữ liệu vào:** Token người dùng
- **Các bước:**
  1. Gửi request `GET /api/academic-years`
- **Kết quả mong đợi:** HTTP 200 OK; danh sách năm học kèm ngày bắt đầu, ngày kết thúc và cờ `isCurrent`
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-002 — Lấy thông tin năm học hiện tại (Current Academic Year)
- **Module:** CORE
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #7 (`GET /api/academic-years/current`)
- **Endpoint / Màn hình:** `GET /api/academic-years/current`
- **Tiền điều kiện:** Năm học 2026-2027 được đặt `is_current = true`
- **Dữ liệu vào:** Không
- **Các bước:**
  1. Gọi `GET /api/academic-years/current`
- **Kết quả mong đợi:** HTTP 200 OK; chỉ trả về đúng 1 năm học hiện tại
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-003 — Admin tạo năm học mới
- **Module:** CORE
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #8 (`POST /api/academic-years`)
- **Endpoint / Màn hình:** `POST /api/academic-years`
- **Tiền điều kiện:** Admin đăng nhập
- **Dữ liệu vào:**
  ```json
  {
    "yearName": "2027-2028",
    "startDate": "2027-09-01",
    "endDate": "2028-05-31"
  }
  ```
- **Các bước:**
  1. Admin gửi request tạo năm học mới
- **Kết quả mong đợi:** HTTP 201 Created hoặc 200 OK; lưu thành công năm học mới
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-004 — Đặt năm học hiện tại (Đảm bảo duy nhất 1 năm học hiện tại)
- **Module:** CORE
- **Ưu tiên:** P0
- **Loại:** Toàn vẹn dữ liệu / Nghiệp vụ
- **Tham chiếu:** Mục 6.3 ("Một năm học hiện tại duy nhất"); `01-endpoint-inventory.md` #9
- **Endpoint / Màn hình:** `PUT /api/academic-years/{id}/set-current`
- **Tiền điều kiện:** Năm học A đang `is_current = true`
- **Dữ liệu vào:** Gọi đặt năm học B (ID 2) làm hiện tại
- **Các bước:**
  1. Gửi request `PUT /api/academic-years/2/set-current`
  2. Truy vấn DB: `SELECT count(*) FROM academic_years WHERE is_current = true`
- **Kết quả mong đợi:** HTTP 200 OK; Năm học A tự động chuyển về `is_current = false`; Năm học B chuyển thành `true`; Tổng số năm học hiện tại trong DB luôn luôn = 1
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-005 — Lấy danh sách toàn bộ học sinh
- **Module:** CORE
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #10 (`GET /api/students`)
- **Endpoint / Màn hình:** `GET /api/students`
- **Tiền điều kiện:** Admin hoặc Giáo viên đăng nhập
- **Dữ liệu vào:** Token
- **Các bước:**
  1. Gọi `GET /api/students`
- **Kết quả mong đợi:** HTTP 200 OK; danh sách học sinh có phân trang hoặc mảng đầy đủ
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-006 — Phụ huynh lấy danh sách con mình (My Wards)
- **Module:** CORE
- **Ưu tiên:** P0
- **Loại:** Chức năng / Quan hệ
- **Tham chiếu:** `01-endpoint-inventory.md` #11 (`GET /api/students/my-wards`)
- **Endpoint / Màn hình:** `GET /api/students/my-wards`
- **Tiền điều kiện:** Phụ huynh có 2 con trong bảng `guardian_students`
- **Dữ liệu vào:** Token phụ huynh
- **Các bước:**
  1. Gọi `GET /api/students/my-wards`
- **Kết quả mong đợi:** HTTP 200 OK; trả về đúng 2 học sinh liên kết với phụ huynh; không thừa học sinh khác
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-007 — Admin tạo hồ sơ học sinh mới thủ công
- **Module:** CORE
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #13 (`POST /api/students`)
- **Endpoint / Màn hình:** `POST /api/students`
- **Tiền điều kiện:** Admin đăng nhập; Lớp 3A tồn tại
- **Dữ liệu vào:**
  ```json
  {
    "name": "Trần Bảo Nam",
    "admissionNumber": "ADM20260099",
    "rollNo": "HS099",
    "dob": "2016-04-12",
    "gender": "MALE",
    "classId": 1,
    "address": "123 Lê Lợi, TP. HCM"
  }
  ```
- **Các bước:**
  1. Admin gửi request tạo học sinh
- **Kết quả mong đợi:** HTTP 201 Created; tạo bản ghi học sinh và tự động sinh tài khoản User (username = rollNo/phone)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-008 — Lấy danh sách giáo viên
- **Module:** CORE
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #16 (`GET /api/teachers`)
- **Endpoint / Màn hình:** `GET /api/teachers`
- **Tiền điều kiện:** Admin hoặc Giáo viên đăng nhập
- **Dữ liệu vào:** Token
- **Các bước:**
  1. Gọi `GET /api/teachers`
- **Kết quả mong đợi:** HTTP 200 OK; danh sách giáo viên kèm môn phụ trách và trình độ
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-009 — Admin tạo giáo viên mới
- **Module:** CORE
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #18 (`POST /api/teachers`)
- **Endpoint / Màn hình:** `POST /api/teachers`
- **Tiền điều kiện:** Admin đăng nhập
- **Dữ liệu vào:**
  ```json
  {
    "name": "Nguyễn Thị Mai",
    "email": "mai.nguyen@ashadeep.edu.vn",
    "phone": "0912345678",
    "qualification": "Thạc sĩ Sư phạm Toán",
    "subjectSpecialization": "Toán"
  }
  ```
- **Các bước:**
  1. Gửi request tạo giáo viên
- **Kết quả mong đợi:** HTTP 201 Created; tạo hồ sơ giáo viên và tài khoản User role `TEACHER`
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-010 — Lấy danh sách lớp học
- **Module:** CORE
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #19 (`GET /api/classes`)
- **Endpoint / Màn hình:** `GET /api/classes`
- **Tiền điều kiện:** Đăng nhập hợp lệ
- **Dữ liệu vào:** Token
- **Các bước:**
  1. Gọi `GET /api/classes`
- **Kết quả mong đợi:** HTTP 200 OK; danh sách các lớp (Grade + Section) kèm tên GVCN
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-011 — Admin tạo lớp học mới
- **Module:** CORE
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #21 (`POST /api/classes`)
- **Endpoint / Màn hình:** `POST /api/classes`
- **Tiền điều kiện:** Admin đăng nhập
- **Dữ liệu vào:**
  ```json
  {
    "grade": "3",
    "section": "C",
    "homeroomTeacherId": 1
  }
  ```
- **Các bước:**
  1. Gửi request tạo lớp mới
- **Kết quả mong đợi:** HTTP 201 Created; lớp 3C được tạo với GVCN ID 1
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-012 — Cập nhật thông tin lớp học và đổi GVCN
- **Module:** CORE
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #22 (`PUT /api/classes/{id}`)
- **Endpoint / Màn hình:** `PUT /api/classes/{id}`
- **Tiền điều kiện:** Lớp 3A đang có GVCN là GV 1
- **Dữ liệu vào:** `{"homeroomTeacherId": 2}`
- **Các bước:**
  1. Admin gửi request đổi GVCN sang GV 2
- **Kết quả mong đợi:** HTTP 200 OK; GVCN của lớp 3A cập nhật thành GV 2; quyền duyệt đơn nghỉ phép của lớp 3A chuyển giao sang GV 2
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-013 — Quản lý danh mục môn học (Subject)
- **Module:** CORE
- **Ưu tiên:** P2
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #24 (`GET /api/subjects`)
- **Endpoint / Màn hình:** `GET /api/subjects`
- **Tiền điều kiện:** DB đã có danh mục môn học
- **Dữ liệu vào:** Token
- **Các bước:**
  1. Gọi `GET /api/subjects`
- **Kết quả mong đợi:** HTTP 200 OK; danh sách các môn: Toán, Tiếng Việt, Tiếng Anh, Tự nhiên & Xã hội,...
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-014 — Học sinh xem hồ sơ của chính mình (Student Portal Profile)
- **Module:** CORE
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #57 (`GET /api/student-portal/profile`)
- **Endpoint / Màn hình:** `GET /api/student-portal/profile`
- **Tiền điều kiện:** Học sinh `hs_3a_01` đăng nhập
- **Dữ liệu vào:** Token của STUDENT
- **Các bước:**
  1. Gọi `GET /api/student-portal/profile`
- **Kết quả mong đợi:** HTTP 200 OK; thông tin: Họ tên, Ngày sinh, Giới tính, Lớp, Mã học sinh, Tên GVCN
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-015 — Học sinh xem bảng điểm của chính mình (Student Portal Marks)
- **Module:** CORE
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #59 (`GET /api/student-portal/marks`)
- **Endpoint / Màn hình:** `GET /api/student-portal/marks`
- **Tiền điều kiện:** Học sinh đăng nhập
- **Dữ liệu vào:** Token của STUDENT
- **Các bước:**
  1. Gọi `GET /api/student-portal/marks`
- **Kết quả mong đợi:** HTTP 200 OK; chỉ trả về điểm các môn của chính học sinh này; kèm điểm trung bình
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-016 — Phân công giảng dạy theo giáo viên
- **Module:** CORE
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #71 (`GET /api/teaching-assignments/teacher/{teacherId}`)
- **Endpoint / Màn hình:** `GET /api/teaching-assignments/teacher/{teacherId}`
- **Tiền điều kiện:** GV 1 được phân công dạy Toán lớp 3A và 3B
- **Dữ liệu vào:** `teacherId = 1`
- **Các bước:**
  1. Gọi API phân công theo teacherId
- **Kết quả mong đợi:** HTTP 200 OK; trả về đúng 2 phân công lớp 3A và 3B
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-CORE-017 — Quan hệ Phụ huynh nhiều con & Học sinh nhiều phụ huynh
- **Module:** CORE
- **Ưu tiên:** P0
- **Loại:** Toàn vẹn dữ liệu
- **Tham chiếu:** Mục 6.3 ("phụ huynh nhiều con, học sinh nhiều phụ huynh"); Bảng `guardian_students`
- **Endpoint / Màn hình:** CSDL quan hệ `guardian_students`
- **Tiền điều kiện:** Phụ huynh P1 có con S1 và S2; Học sinh S1 có cả bố (P1) và mẹ (P2)
- **Dữ liệu vào:** Truy vấn liên kết giám hộ
- **Các bước:**
  1. Đăng nhập P1 gọi `GET /api/students/my-wards` -> Thấy S1 và S2
  2. Đăng nhập P2 gọi `GET /api/students/my-wards` -> Thấy S1
- **Kết quả mong đợi:** Cả 2 phụ huynh đều thấy con chung S1, P1 thấy thêm con S2; không có xung đột khóa chính hay mất dữ liệu
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —
