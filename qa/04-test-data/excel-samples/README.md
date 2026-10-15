# Danh mục Tệp Excel Mẫu Kiểm thử (Excel Test Samples)

Thư mục này chứa các tệp bảng tính Excel (`.xlsx`) nhị phân thực tế, được sinh ra từ Apache POI đúng cấu trúc theo `ExcelHelper.java` để kiểm thử toàn diện chức năng Import Học sinh (`POST /api/upload/students`) và kiểm thử tính toàn vẹn cơ sở dữ liệu.

---

## Danh sách tệp và Mục đích kiểm thử

| Tên tệp | Cấu trúc dữ liệu | Mục đích kiểm thử | Test case tương ứng |
|---|---|---|---|
| `01-valid-students.xlsx` | 5 dòng dữ liệu đầy đủ 7 cột chuẩn: `Admission No`, `Name`, `Roll No`, `Grade`, `Section`, `Parent Name`, `Parent Phone` | Kiểm thử Happy Path: Toàn bộ 5 học sinh và tài khoản người dùng được tạo thành công | TC-IMP-001 |
| `02-one-error-middle.xlsx` | 3 dòng: Dòng 1 hợp lệ, Dòng 2 rỗng `Admission No`, Dòng 3 hợp lệ | Kiểm thử tính nguyên tử (Atomicity / Rollback): Phát hiện lỗi ở dòng 2 và rollback 100% CSDL | TC-IMP-002, TC-IMP-012 |
| `03-multiple-errors.xlsx` | 5 dòng: Dòng 2 thiếu Name, Dòng 4 thiếu RollNo, Dòng 5 thiếu Parent Name | Kiểm thử Pre-validation trả về danh sách chi tiết tất cả các dòng lỗi cùng lúc | TC-IMP-003 |
| `04-internal-duplicate.xlsx` | 3 dòng: Dòng 1 và Dòng 3 trùng nhau mã `Admission No` (`ADM20264001`) | Kiểm thử phát hiện trùng lặp ngay trong nội bộ tệp Excel | TC-IMP-004 |
| `05-db-duplicate.xlsx` | 1 dòng học sinh mang `Admission No = ADM20260001` đã tồn tại sẵn trong CSDL | Kiểm thử vi phạm ràng buộc duy nhất với dữ liệu đang có | TC-IMP-005 |
| `06-missing-columns.xlsx` | Chỉ có 3 cột: `Admission No`, `Name`, `Roll No` (thiếu Grade, Section, Parent) | Kiểm thử từ chối tệp thiếu các cột bắt buộc | TC-IMP-006 |
| `07-invalid-headers.xlsx` | Dòng tiêu đề bị viết sai ngôn ngữ / thứ tự | Kiểm thử kiểm tra cấu trúc header hợp lệ | TC-IMP-007 |
| `08-empty-file.xlsx` | Chỉ có 1 dòng tiêu đề duy nhất, không có dòng dữ liệu học sinh nào | Kiểm thử tệp rỗng không có dữ liệu để xử lý | TC-IMP-008 |
| `11-vietnamese-accents.xlsx` | 3 dòng dữ liệu chứa tên tiếng Việt có dấu đầy đủ và ký tự Unicode phức tạp | Kiểm thử mã hóa ký tự UTF-8 không bị vỡ font hoặc biến dạng chuỗi | TC-IMP-011, TC-NFR-001 |
