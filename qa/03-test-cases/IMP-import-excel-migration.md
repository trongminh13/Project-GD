# Test Cases — IMP: Import Excel và Di chuyển Dữ liệu

**Module:** IMP  
**Tổng số test case:** 17  
**Tham chiếu:** `quan-he-du-lieu.md`, `qa/01-endpoint-inventory.md` (#14, #67, #68, #69, #70), `BulkImportController.java`, `BulkImportService.java`, `TransactionRollbackRealTest.java`  
**Quy tắc bất biến:** Khi import thất bại, CSDL phải được rollback 100% — tuyệt đối không tồn tại bản ghi mồ côi trong `users` hay `students`.

---

### TC-IMP-001 — Upload file Excel hợp lệ đầy đủ các cột (Happy Path)
- **Module:** IMP
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `BulkImportController.java` `POST /api/upload/students`; `TransactionRollbackRealTest.java` (TC-RB-02)
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** Admin đăng nhập; Lớp 3A (Grade 3, Section A) đã tồn tại trong DB; File `01-valid-students.xlsx` chứa 5 học sinh hợp lệ
- **Dữ liệu vào:** File multipart `file = 01-valid-students.xlsx`
- **Các bước:**
  1. Gửi request `POST /api/upload/students` đính kèm file
  2. Kiểm tra số lượng bản ghi trong bảng `students` và `users`
- **Kết quả mong đợi:** HTTP 200 OK; thông báo "Imported 5 students"; 5 bản ghi học sinh được tạo với đúng `class_id`, 5 tài khoản User với role `STUDENT` và password mã hóa BCrypt
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-002 — File Excel có một dòng sai ở giữa (Rollback tính nguyên tử)
- **Module:** IMP
- **Ưu tiên:** P0
- **Loại:** Lỗi / Toàn vẹn dữ liệu
- **Tham chiếu:** `TransactionRollbackRealTest.java` (TC-RB-01); Mục 6.7
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** File `02-one-error-middle.xlsx` gồm 3 dòng: Dòng 1 hợp lệ, Dòng 2 thiếu ngày sinh hoặc lớp không tồn tại, Dòng 3 hợp lệ
- **Dữ liệu vào:** File multipart `file = 02-one-error-middle.xlsx`
- **Các bước:**
  1. Đếm số lượng học sinh trong DB trước khi upload
  2. Gửi request upload file
  3. Đếm lại số lượng học sinh và users trong DB sau khi request kết thúc
- **Kết quả mong đợi:**
  - HTTP 400 Bad Request
  - JSON body chứa `success: false`, mảng `errors` chỉ rõ: `row: 2`, `message: "..."`
  - Số lượng bản ghi trong DB không thay đổi (dòng 1 không bị lọt vào DB)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-003 — File Excel có nhiều dòng sai đồng thời
- **Module:** IMP
- **Ưu tiên:** P1
- **Loại:** Lỗi
- **Tham chiếu:** `ExcelValidationException.java`
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** File `03-multiple-errors.xlsx` có lỗi ở dòng 2 (email sai cú pháp), dòng 4 (số điện thoại không hợp lệ), dòng 5 (thiếu tên)
- **Dữ liệu vào:** File multipart `file = 03-multiple-errors.xlsx`
- **Các bước:**
  1. Upload file
- **Kết quả mong đợi:** HTTP 400 Bad Request; danh sách `errors` trả về đầy đủ cả 3 lỗi tương ứng với các dòng 2, 4, 5 (không dừng lại ngay ở lỗi đầu tiên)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-004 — Trùng RollNo hoặc Username ngay trong nội bộ file Excel
- **Module:** IMP
- **Ưu tiên:** P0
- **Loại:** Lỗi / Ràng buộc duy nhất
- **Tham chiếu:** Mục 6.7 ("trùng tên đăng nhập hoặc mã học sinh trong file")
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** File `04-internal-duplicate.xlsx` có dòng 2 và dòng 5 cùng mang `RollNo = "HS001"` hoặc cùng số điện thoại
- **Dữ liệu vào:** File multipart `file = 04-internal-duplicate.xlsx`
- **Các bước:**
  1. Gửi request upload
- **Kết quả mong đợi:** HTTP 400 Bad Request; báo lỗi dòng 5: "Mã học sinh/Tên đăng nhập bị trùng với dòng 2 trong file"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-005 — Trùng AdmissionNumber hoặc Username với dữ liệu đã có trong CSDL
- **Module:** IMP
- **Ưu tiên:** P0
- **Loại:** Lỗi / Ràng buộc CSDL
- **Tham chiếu:** Mục 6.7 ("trùng với dữ liệu đã có")
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** Học sinh với `admission_number = "ADM_2026_01"` đã tồn tại trong DB
- **Dữ liệu vào:** File `05-db-duplicate.xlsx` chứa học sinh mới nhưng dùng lại admission_number trên
- **Các bước:**
  1. Upload file
- **Kết quả mong đợi:** HTTP 400 Bad Request; báo lỗi dòng chứa mã bị trùng; toàn bộ transaction bị hủy
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-006 — File Excel thiếu các cột bắt buộc
- **Module:** IMP
- **Ưu tiên:** P1
- **Loại:** Lỗi cấu trúc
- **Tham chiếu:** `ExcelHelper.java`
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** File `06-missing-columns.xlsx` chỉ có 3 cột: Name, RollNo, Phone (thiếu Grade, Section, DOB, Address)
- **Dữ liệu vào:** File multipart `file = 06-missing-columns.xlsx`
- **Các bước:**
  1. Upload file
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo "File Excel thiếu các cột bắt buộc: Grade, Section, DOB"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-007 — Tiêu đề cột (Header) bị sai chính tả hoặc sai thứ tự
- **Module:** IMP
- **Ưu tiên:** P1
- **Loại:** Lỗi định dạng
- **Tham chiếu:** `ExcelHelper.java`
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** Cột `Admission Number` bị sửa thành `Ma Hoc Sinh` hoặc viết sai ký tự
- **Dữ liệu vào:** File `07-invalid-headers.xlsx`
- **Các bước:**
  1. Upload file
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo tiêu đề cột không đúng quy chuẩn mẫu của trường
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-008 — File Excel rỗng (chỉ có header hoặc sheet trống)
- **Module:** IMP
- **Ưu tiên:** P1
- **Loại:** Biên
- **Tham chiếu:** Mục 6.7 ("file rỗng")
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** File `08-empty-file.xlsx` chỉ chứa dòng tiêu đề dòng 1, không có dữ liệu từ dòng 2
- **Dữ liệu vào:** File `08-empty-file.xlsx`
- **Các bước:**
  1. Upload file
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo "File Excel không có dữ liệu học sinh"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-009 — Upload tệp tin sai định dạng (không phải Excel .xlsx / .xls)
- **Module:** IMP
- **Ưu tiên:** P1
- **Loại:** Lỗi loại tệp
- **Tham chiếu:** `BulkImportController.java` L28
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** Tệp `sample.pdf` hoặc `sample.csv`
- **Dữ liệu vào:** `file = sample.pdf`
- **Các bước:**
  1. Gửi request multipart với tệp PDF
- **Kết quả mong đợi:** HTTP 400 Bad Request; body: `{"message":"Please upload an excel file!"}`
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-010 — File Excel vượt giới hạn số dòng (> 2000 dòng)
- **Module:** IMP
- **Ưu tiên:** P1
- **Loại:** Giới hạn / Hiệu năng
- **Tham chiếu:** `01-endpoint-inventory.md` #67; `BulkImportService.java`
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** File `10-large-2500-rows.xlsx` chứa 2500 dòng dữ liệu
- **Dữ liệu vào:** File multipart chứa 2500 dòng
- **Các bước:**
  1. Upload file
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo số dòng vượt quá giới hạn tối đa cho phép (2000 dòng/lần)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-011 — Tên học sinh và địa chỉ chứa tiếng Việt có dấu và ký tự đặc biệt
- **Module:** IMP
- **Ưu tiên:** P0
- **Loại:** Mã hóa / Tiếng Việt
- **Tham chiếu:** Mục 6.7 & Mục 6.11
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** File `11-vietnamese-accents.xlsx` chứa tên: "Nguyễn Trần Hoàng Đăng Khôi", địa chỉ "Số 45/12A Đường Đinh Bộ Lĩnh, Phường 26, Quận Bình Thạnh, TP. Hồ Chí Minh"
- **Dữ liệu vào:** File `11-vietnamese-accents.xlsx`
- **Các bước:**
  1. Upload file hợp lệ
  2. Truy vấn lại API `GET /api/students/{id}`
- **Kết quả mong đợi:** HTTP 200 OK; dữ liệu trả về và hiển thị trên giao diện hiển thị đúng 100% tiếng Việt có dấu, không bị lỗi font dạng `???` hoặc ký tự rác `Ã¬...`
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-012 — Xác minh không có bản ghi mồ côi (Orphan Record Check) khi xảy ra lỗi ở dòng cuối
- **Module:** IMP
- **Ưu tiên:** P0
- **Loại:** Toàn vẹn dữ liệu
- **Tham chiếu:** `TransactionRollbackRealTest.java` (TC-RB-01)
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** File có 10 dòng, dòng 1..9 hợp lệ, dòng 10 sai cấu trúc
- **Dữ liệu vào:** File lỗi ở dòng 10
- **Các bước:**
  1. Upload file
  2. Truy vấn trực tiếp DB: `SELECT count(*) FROM users WHERE role='STUDENT'` và `SELECT count(*) FROM students`
- **Kết quả mong đợi:** Cả 2 bảng đều không tăng bất kỳ bản ghi nào so với trước khi upload; không có tài khoản user nào được tạo dở dang
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-013 — Ô Excel chứa công thức tính toán (Formula Cells) hoặc định dạng ngày tháng đa dạng
- **Module:** IMP
- **Ưu tiên:** P2
- **Loại:** Biên định dạng
- **Tham chiếu:** `ExcelHelper.java` (Cell type handling: NUMERIC, FORMULA, STRING)
- **Endpoint / Màn hình:** `POST /api/upload/students`
- **Tiền điều kiện:** File có cột RollNo được tạo bằng công thức `="HS" & TEXT(ROW()-1, "000")`, ngày sinh định dạng `dd/MM/yyyy`
- **Dữ liệu vào:** File `13-formula-cells.xlsx`
- **Các bước:**
  1. Upload file
- **Kết quả mong đợi:** HTTP 200 OK; hệ thống lấy giá trị chuỗi đã được tính toán từ công thức, đọc đúng ngày tháng
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-014 — Chạy API dọn dẹp bản ghi trùng lặp (`DELETE /api/students/cleanup-duplicates`)
- **Module:** IMP
- **Ưu tiên:** P1
- **Loại:** Quản trị dữ liệu
- **Tham chiếu:** `01-endpoint-inventory.md` #14 (`StudentController.java`)
- **Endpoint / Màn hình:** `DELETE /api/students/cleanup-duplicates`
- **Tiền điều kiện:** Admin đăng nhập; DB có 2 bản ghi học sinh trùng mã do migration cũ
- **Dữ liệu vào:** Token Admin
- **Các bước:**
  1. Gọi `DELETE /api/students/cleanup-duplicates`
- **Kết quả mong đợi:** HTTP 200 OK; xóa bản ghi dư thừa, giữ lại bản ghi có liên kết hợp lệ; trả về số lượng bản ghi đã dọn dẹp
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-015 — Kiểm tra sức khỏe module Migration (Ping)
- **Module:** IMP
- **Ưu tiên:** P2
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #68 (`GET /api/admin/migration/ping`)
- **Endpoint / Màn hình:** `GET /api/admin/migration/ping`
- **Tiền điều kiện:** Admin đăng nhập
- **Dữ liệu vào:** Token Admin
- **Các bước:**
  1. Gọi `GET /api/admin/migration/ping`
- **Kết quả mong đợi:** HTTP 200 OK; body: `{"status":"UP","module":"DataMigrationService"}`
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-016 — Báo cáo đối soát dữ liệu sau migration (Reconciliation Report)
- **Module:** IMP
- **Ưu tiên:** P0
- **Loại:** Đối soát dữ liệu
- **Tham chiếu:** `01-endpoint-inventory.md` #69 (`GET /api/admin/migration/reconciliation`)
- **Endpoint / Màn hình:** `GET /api/admin/migration/reconciliation`
- **Tiền điều kiện:** Hệ thống đã thực hiện import hoặc migration dữ liệu
- **Dữ liệu vào:** Token Admin
- **Các bước:**
  1. Gọi `GET /api/admin/migration/reconciliation`
- **Kết quả mong đợi:** HTTP 200 OK; báo cáo tổng số bản ghi của các bảng `classes`, `students`, `parents`, `teachers`, `users`, phát hiện các liên kết thiếu (unlinked parents, unlinked students)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-IMP-017 — Upload file Excel di chuyển dữ liệu hệ thống cũ (Data Migration)
- **Module:** IMP
- **Ưu tiên:** P0
- **Loại:** Di chuyển dữ liệu
- **Tham chiếu:** `01-endpoint-inventory.md` #70 (`POST /api/admin/migration/upload-excel`)
- **Endpoint / Màn hình:** `POST /api/admin/migration/upload-excel`
- **Tiền điều kiện:** Admin đăng nhập; file `migration_legacy_data.xlsx` chứa đầy đủ các sheet: Classes, Students, Parents, GuardianRelations
- **Dữ liệu vào:** File multipart `file = migration_legacy_data.xlsx`
- **Các bước:**
  1. Upload file qua endpoint migration
- **Kết quả mong đợi:** HTTP 200 OK; di chuyển thành công toàn bộ dữ liệu cấu trúc cũ sang cấu trúc mới, tự động map quan hệ `guardian_students`
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —
