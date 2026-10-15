# Mô tả Dữ liệu Kiểm thử Mẫu (Seed Data Specification)

**Mục đích:** Đặc tả tập dữ liệu tối thiểu cần có trong cơ sở dữ liệu kiểm thử `ashadeep_school_db` để 100% test case P0/P1 có thể thực thi độc lập và có thể tái lặp (reproducible).

---

## 1. Năm học (`academic_years`)

| ID | Tên năm học | Ngày bắt đầu | Ngày kết thúc | is_current | Ghi chú |
|---|---|---|---|---|---|
| 1 | `2025-2026` | `2025-09-01` | `2026-05-31` | `false` | Năm học cũ đã kết thúc |
| 2 | `2026-2027` | `2026-09-01` | `2027-05-31` | `true` | **Năm học hiện tại duy nhất** |
| 3 | `2027-2028` | `2027-09-01` | `2028-05-31` | `false` | Năm học tương lai |

---

## 2. Khối và Lớp học (`classes`)

| ID | Khối (Grade) | Lớp (Section) | GVCN (Homeroom Teacher) | Phòng học |
|---|---|---|---|---|
| 1 | `3` | `A` | Cô Nguyễn Thị Lan (ID: 1) | P.301 |
| 2 | `3` | `B` | Cô Lê Thị Hương (ID: 3) | P.302 |
| 3 | `10` | `A` | Thầy Vũ Mạnh Hùng (ID: 4) | P.101 |
| 4 | `12` | `A` | Thầy Đỗ Quốc Tuấn (ID: 5) | P.201 |

---

## 3. Môn học (`subjects`)

| ID | Mã môn | Tên môn học | Số tiết/tuần |
|---|---|---|---|
| 1 | `MATH` | Toán | 5 |
| 2 | `VIET` | Tiếng Việt | 5 |
| 3 | `ENG` | Tiếng Anh | 4 |
| 4 | `SCI` | Khoa học & Tự nhiên | 2 |

---

## 4. Phân công giảng dạy (`teaching_assignments`)

| ID | Giáo viên | Lớp | Môn học | Năm học |
|---|---|---|---|---|
| 1 | Cô Nguyễn Thị Lan (ID: 1) | Lớp 3A (ID: 1) | Toán (ID: 1) | 2026-2027 |
| 2 | Thầy Trần Văn Bình (ID: 2) | Lớp 3A (ID: 1) | Tiếng Việt (ID: 2) | 2026-2027 |
| 3 | Cô Lê Thị Hương (ID: 3) | Lớp 3B (ID: 2) | Toán (ID: 1) | 2026-2027 |

---

## 5. Học sinh và Phụ huynh (`students`, `parents`, `guardian_students`)

### Học sinh:
| ID | Họ và tên | Mã HS | RollNo | Lớp | Ngày sinh |
|---|---|---|---|---|---|
| 1 | Hoàng Khánh Đăng | `ADM20260001` | `01` | Lớp 3A (ID: 1) | 2016-03-15 |
| 2 | Hoàng Minh Khôi | `ADM20260002` | `02` | Lớp 3A (ID: 1) | 2016-08-20 |
| 3 | Vũ Tuấn Kiệt | `ADM20260003` | `01` | Lớp 3B (ID: 2) | 2016-05-10 |

### Phụ huynh:
| ID | Họ và tên | Điện thoại | Email |
|---|---|---|---|
| 1 | Hoàng Văn Hùng | `0901111111` | `hung.hoang@test.com` |
| 2 | Phạm Thị Dung | `0902222222` | `dung.pham@test.com` |
| 3 | Vũ Đình Tuấn | `0903333333` | `tuan.vu@test.com` |

### Liên kết Giám hộ (`guardian_students`):
| Phụ huynh | Học sinh | Quan hệ |
|---|---|---|
| Phụ huynh 1 (Hoàng Văn Hùng) | Học sinh 1 (Hoàng Khánh Đăng) | Bố |
| Phụ huynh 2 (Phạm Thị Dung) | Học sinh 1 (Hoàng Khánh Đăng) | Mẹ (Nhiều phụ huynh 1 con) |
| Phụ huynh 2 (Phạm Thị Dung) | Học sinh 2 (Hoàng Minh Khôi) | Mẹ (1 phụ huynh nhiều con) |
| Phụ huynh 3 (Vũ Đình Tuấn) | Học sinh 3 (Vũ Tuấn Kiệt) | Bố |

---

## 6. Dữ liệu Học liệu (`materials` & `material_files`)

| ID | Tiêu đề | Môn | GV tạo | Trạng thái | Lớp nhận | File đính kèm |
|---|---|---|---|---|---|---|
| 1 | Bài giảng Toán Tuần 6 | Toán | Cô Lan (ID: 1) | `PUBLISHED` | Lớp 3A (ID: 1) | `fileId = 1` (`de_cuong.pdf` tồn tại trên đĩa) |
| 2 | Đề cương Tiếng Việt Nháp | Tiếng Việt | Thầy Bình (ID: 2) | `DRAFT` | Lớp 3A (ID: 1) | `fileId = 2` |

---

## 7. Dữ liệu Bài tập (`homework` & `homework_assignments`)

- **Bài tập ID 1:** "Bài kiểm tra Toán Đại số 15 phút", gồm 5 câu hỏi (Single, Multiple, True/False, Short Answer, Essay), tổng điểm 10.0.
- **Assignment ID 1:** Bài tập 1 giao cho Lớp 3A; `dueDate = 2026-10-25T23:59:59`; `allowLateSubmission = false`.
