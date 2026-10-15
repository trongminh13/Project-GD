# Danh sách Tài khoản Kiểm thử theo Vai trò (Test Accounts)

**Quy tắc an toàn:** Tuyệt đối không ghi mật khẩu thật, khóa bí mật hoặc thông tin sản xuất vào tài liệu này. Mật khẩu trong môi trường kiểm thử được cấp phát qua biến môi trường hoặc script khởi tạo seed.

---

## 1. Bảng phân bổ Tài khoản theo Vai trò & Lớp học

| Vai trò (Role) | Mã định danh (Username) | Họ và tên hiển thị | Lớp phụ trách / Học | Quan hệ dữ liệu | Mục đích kiểm thử |
|---|---|---|---|---|---|
| **ADMIN** | `admin` | Quản trị viên Hệ thống | Toàn trường | Quyền cao nhất | Quản trị, cấu hình năm học, import Excel, migration |
| **TEACHER (GVCN 3A)** | `gv_chunhiem_3a` | Cô Nguyễn Thị Lan | Lớp 3A | GVCN Lớp 3A; dạy Toán 3A | Điểm danh lớp 3A, duyệt đơn nghỉ phép 3A, chấm bài 3A |
| **TEACHER (Bộ môn 3A)** | `gv_bomon_3a` | Thầy Trần Văn Bình | Lớp 3A | Giáo viên bộ môn Tiếng Việt 3A; không chủ nhiệm | Nhập điểm Tiếng Việt 3A, giao bài 3A; kiểm tra chặn quyền duyệt đơn nghỉ |
| **TEACHER (Lớp khác)** | `gv_lop_khac` | Cô Lê Thị Hương | Lớp 3B | GVCN Lớp 3B; không liên quan lớp 3A | Kiểm tra chặn quyền xem/chấm/điểm danh chéo lớp (Cross-class ReBAC) |
| **PARENT (Có con 3A)** | `ph_con_3a` | Ông Hoàng Văn Hùng | Phụ huynh | Giám hộ học sinh `hs_3a_01` (Lớp 3A) | Xem điểm, điểm danh con, nộp đơn nghỉ, thanh toán học phí |
| **PARENT (2 con)** | `ph_nhieu_con` | Bà Phạm Thị Dung | Phụ huynh | Giám hộ `hs_3a_02` (3A) và `hs_3b_02` (3B) | Kiểm tra chuyển đổi hồ sơ nhiều con trên ứng dụng Flutter |
| **PARENT (Lớp khác)** | `ph_con_khac` | Ông Vũ Đình Tuấn | Phụ huynh | Giám hộ `hs_3b_01` (Lớp 3B) | Kiểm tra chặn IDOR xem điểm, học phí con người khác |
| **STUDENT (Lớp 3A)** | `hs_3a_01` | Em Hoàng Khánh Đăng | Lớp 3A | Học sinh lớp 3A (RollNo: 01) | Làm bài tập, lưu nháp, xem điểm, tải học liệu 3A |
| **STUDENT (Lớp 3A)** | `hs_3a_02` | Em Hoàng Minh Khôi | Lớp 3A | Học sinh lớp 3A (RollNo: 02) | Kiểm tra làm bài tập song song trong cùng lớp |
| **STUDENT (Lớp 3B)** | `hs_3b_01` | Em Vũ Tuấn Kiệt | Lớp 3B | Học sinh lớp 3B (RollNo: 01) | Kiểm tra chặn truy cập học liệu và bài tập của lớp 3A |
| **STUDENT (Khóa)** | `hs_bi_khoa` | Em Đặng Văn Lâm | Lớp 3A | Đã nhập sai mật khẩu 5 lần | Kiểm tra từ chối đăng nhập khi tài khoản bị khóa 15 phút |
| **STUDENT (Đổi pass)** | `hs_can_doi_pass` | Em Lê Thanh Thảo | Lớp 3A | Cờ `must_change_password = true` | Kiểm tra ép buộc đổi mật khẩu lần đầu trước khi dùng các API khác |

---

## 2. Token Header mẫu khi gọi API tự động

```http
Authorization: Bearer {{token_admin}}
Authorization: Bearer {{token_teacher_cn_3a}}
Authorization: Bearer {{token_teacher_bm_3a}}
Authorization: Bearer {{token_teacher_khac}}
Authorization: Bearer {{token_parent_3a}}
Authorization: Bearer {{token_student_3a}}
Authorization: Bearer {{token_student_3b}}
```
