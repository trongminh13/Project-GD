# 00 — Kế hoạch Kiểm thử (Test Plan) — Phase 1

**Phiên bản:** 1.0  
**Ngày:** 2026-10-15  
**Người soạn:** AI QA Senior  
**Tài liệu tham chiếu:** `quan-he-du-lieu.md`, `QA.md`, mã nguồn Controller & Service

---

## 1. Phạm vi kiểm thử

### Trong phạm vi
| Module | Mô tả |
|---|---|
| AUTH | Đăng nhập, đổi mật khẩu, OTP, khóa tài khoản, phiên JWT |
| SEC | Phân quyền ReBAC cho toàn bộ endpoint có tham số `id` |
| CORE | Năm học, lớp, ghi danh, liên kết phụ huynh–học sinh, phân công |
| ATT | Điểm danh hàng loạt, nghỉ phép |
| HW | Soạn bài, giao bài, làm bài (5 dạng câu hỏi), chấm điểm |
| MAT | Học liệu: trạng thái, phân phối lớp, tải file |
| IMP | Import Excel học sinh, migration data |
| PAY | Học phí, thanh toán Razorpay (sandbox) |
| NOTI | Thông báo, sự kiện |
| UI | Ứng dụng Flutter (53 màn hình) |
| NFR | Tiếng Việt, thiết bị, hiệu năng, bảo vệ dữ liệu trẻ |

### Ngoài phạm vi
- Module bán trú (chưa được thiết kế trong Phase 1)
- Multi-tenant (chưa xác nhận)
- Tích hợp SMS thật (chỉ kiểm tra mock/sandbox)
- Thanh toán với thẻ thật (chỉ Razorpay test mode)
- Môi trường staging / production

---

## 2. Môi trường và Thiết bị

### Backend
| Mục | Giá trị |
|---|---|
| Base URL | `http://localhost:8081` |
| Framework | Spring Boot 3.5 / Java 21 |
| Database | PostgreSQL `ashadeep_school_db` (localhost:5432) |
| JWT TTL | 86400000 ms = 24 giờ |
| Khóa tài khoản | 5 lần sai → khóa 15 phút (ADMIN miễn khóa) |

### Frontend
| Mục | Giá trị |
|---|---|
| Framework | Flutter (tối thiểu Flutter 3.x) |
| Thiết bị tối thiểu | 2 Android (SDK 30+, 1 màn hình nhỏ ≤ 6"), 1 iPhone |
| Phiên bản OS cũ | Android 11 (API 30) |

### Công cụ kiểm thử
| Công cụ | Dùng cho |
|---|---|
| VS Code REST Client (`.http` file) | Gọi API tự động |
| `curl` | Gọi API nhanh từ terminal |
| Flutter DevTools | Debug UI, network |
| PostgreSQL psql / pgAdmin | Kiểm tra dữ liệu sau test |

---

## 3. Vai trò và Tài khoản Test

Xem chi tiết tại `04-test-data/accounts.md`.

| Vai trò | Username mẫu | Mô tả |
|---|---|---|
| ADMIN | `admin` | Quản trị hệ thống |
| TEACHER (chủ nhiệm 3A) | `gv_chunhiem_3a` | Giáo viên chủ nhiệm lớp 3A |
| TEACHER (bộ môn 3A) | `gv_bomon_3a` | Giáo viên bộ môn dạy lớp 3A, không chủ nhiệm |
| TEACHER (không liên quan 3A) | `gv_lop_khac` | Giáo viên không dạy và không chủ nhiệm 3A |
| PARENT (con học 3A) | `ph_con_3a` | Phụ huynh có con trong lớp 3A |
| PARENT (con không học 3A) | `ph_con_khac` | Phụ huynh có con lớp khác |
| STUDENT (lớp 3A) | `hs_3a_01` | Học sinh lớp 3A |
| STUDENT (lớp 3B) | `hs_3b_01` | Học sinh lớp 3B (dùng để test cross-class) |

---

## 4. Loại Kiểm thử và Phân bố

| Loại | Mô tả | Số lượng ước tính |
|---|---|---|
| Phân quyền (P0) | Kiểm tra RBAC + ReBAC cho endpoint có `id` | ~50 |
| Chức năng (P1) | Luồng nghiệp vụ chính | ~60 |
| Biên (P1/P2) | Giá trị biên, giới hạn, dữ liệu đặc biệt | ~25 |
| Lỗi (P1/P2) | Input sai, dữ liệu không hợp lệ | ~25 |
| Giao diện (P2/P3) | Màn hình Flutter, trạng thái rỗng/lỗi | ~20 |
| Hiệu năng (P2) | Thời gian phản hồi cơ bản | ~5 |

**Tổng ước tính:** ~185 test case

---

## 5. Tiêu chí Vào (Entry Criteria)

- [ ] Backend build thành công (`./mvnw clean package -DskipTests`)
- [ ] Server khởi động được (port 8081 phản hồi)
- [ ] Database đã có dữ liệu seed (xem `04-test-data/seed-data.md`)
- [ ] Tài khoản test theo vai trò đã được tạo
- [ ] Flutter app build thành công (`flutter build apk --debug`)

---

## 6. Tiêu chí Ra (Exit Criteria)

### Tối thiểu để báo cáo kết quả:
- Tất cả test case P0 đã chạy
- Tất cả bug P0 đã được ghi vào `07-bugs/`
- Báo cáo lần chạy `06-execution-reports/` có số liệu thật

### Để phê duyệt phát hành (Release Sign-off):
- 100% test case P0 Pass
- ≥ 90% test case P1 Pass
- 0 bug mức Nghiêm trọng còn mở
- 0 bug mức Cao còn mở
- Tất cả hành vi "Chặn - chờ quyết định" đã được phê duyệt hoặc postpone

---

## 7. Rủi ro và Giảm thiểu

| Rủi ro | Xác suất | Ảnh hưởng | Giảm thiểu |
|---|---|---|---|
| Server không khởi động (DB chưa seed) | Cao | Cao | Chuẩn bị `seed-data.md` rõ ràng; test thủ công từng service |
| Thiếu tài khoản test theo vai trò | Trung bình | Cao | Tạo script seed tài khoản trong `04-test-data/` |
| Hành vi "chặn" chưa có quyết định | Trung bình | Trung bình | Ghi `Chặn - chờ quyết định`; không block P0 test |
| Thiết bị iOS không có | Cao | Thấp | Dùng iOS Simulator hoặc ghi nhận là "Cần xác nhận" |
| Razorpay sandbox không khả dụng | Thấp | Trung bình | Mock test hoặc ghi "Không chạy được - Razorpay sandbox" |

---

## 8. Hành vi Chưa được Duyệt (Ghi "Chặn - chờ quyết định")

Các câu hỏi sau cần AI Lead / Product Owner trả lời:

1. **Nộp bài muộn**: Cho phép nộp khi đã quá `dueDate`? Mặc định bật hay tắt? Có trừ điểm tự động không?
2. **Hiện đáp án**: Học sinh thấy đáp án đúng khi nào: ngay sau nộp, sau `dueDate`, hay sau khi GV chấm xong cả lớp?
3. **Câu điền ngắn**: Chấp nhận bài làm không dấu tiếng Việt không? Mặc định `|` phân cách nhiều đáp án đúng?
4. **Làm lại bài**: Cho phép học sinh nộp lại sau khi đã `SUBMITTED` không? Số lần tối đa?
5. **Điểm câu nhiều đáp án**: Chọn thiếu hoặc chọn thừa → điểm = 0, hay tính theo tỷ lệ?
6. **Bán trú cấp 2**: Có module bán trú trong Phase 1 không? Bật theo khối lớp?
7. **Multi-tenant**: Một hệ thống cho một trường hay nhiều trường? Có `school_id` filter không?
8. **Hiệu năng**: Số người dùng đồng thời mục tiêu? Thời gian phản hồi API chấp nhận được (P95)?

---

## 9. Lịch Kiểm thử (Dự kiến)

| Mốc | Hoạt động |
|---|---|
| 2026-10-15 | Hoàn thành Giai đoạn 0 + 1 + 2 (khung + test case) |
| Sau khi server sẵn sàng | Giai đoạn 3: chạy test, ghi kết quả thật |
| Sau Giai đoạn 3 | Giai đoạn 4: UAT checklist, sign-off |
