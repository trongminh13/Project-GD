# Hồ sơ Kiểm thử — Project-GD Phase 1

**Dự án:** Hệ thống Quản trị & Sổ liên lạc Giáo dục Đại Việt  
**Phiên bản:** Phase 1  
**Môi trường:** Backend Spring Boot 3.5 / Java 21, Port 8081 · DB PostgreSQL `ashadeep_school_db`  
**Ngày khởi tạo:** 2026-10-15  
**QA Lead:** AI QA Senior (độc lập)

---

## Cách đọc hồ sơ

| Thư mục / File | Nội dung |
|---|---|
| `00-test-plan.md` | Kế hoạch kiểm thử tổng thể (phạm vi, môi trường, tiêu chí) |
| `01-endpoint-inventory.md` | Danh sách toàn bộ 72 endpoint và ma trận phân quyền |
| `02-traceability-matrix.md` | Ma trận yêu cầu → test case |
| `03-test-cases/` | File test case theo module (AUTH, SEC, CORE, ATT, HW, MAT, IMP, PAY, NOTI, UI, NFR) |
| `04-test-data/` | Tài khoản test, dữ liệu mẫu, file Excel mẫu |
| `05-automation/` | Bộ gọi API (HTTP REST client) |
| `06-execution-reports/` | Báo cáo từng lần chạy với số liệu thật |
| `07-bugs/` | Mỗi lỗi một file, theo mẫu `_TEMPLATE.md` |
| `08-signoff/` | Checklist nghiệm thu và phát hành |

---

## Bảng tiến độ

| Giai đoạn | Nội dung | Trạng thái | Ngày hoàn thành |
|---|---|---|---|
| 0 — Khung | Cấu trúc thư mục, test plan, endpoint inventory, bug template | ✅ Xong | 2026-10-15 |
| 1 — P0 | Test case bảo mật ReBAC, dữ liệu lõi, thanh toán (54 SEC, ATT, HW, IMP, PAY) | ✅ Xong | 2026-10-15 |
| 2 — P1/P2/P3 | Toàn bộ 11 module (196 test case), dữ liệu seed, tài khoản, 9 file Excel mẫu | ✅ Xong | 2026-10-15 |
| 3 — Chạy | Chạy 35 ca P0 thực tế qua JUnit/Postgres, 27 Pass, 5 Fail -> mở 5 BUG | ✅ Xong | 2026-10-15 |
| 4 — Nghiệm thu | UAT checklist theo 4 vai trò, Release checklist sẵn sàng phát hành | ✅ Xong | 2026-10-15 |

---

## Quy ước trạng thái test case

| Ký hiệu | Ý nghĩa |
|---|---|
| `Chưa chạy` | Test case đã viết nhưng chưa thực thi |
| `Pass` | Kết quả thực tế khớp với kết quả mong đợi (có bằng chứng) |
| `Fail` | Kết quả thực tế khác kết quả mong đợi → có file BUG tương ứng |
| `Chặn - chờ quyết định` | Hành vi chưa được phê duyệt bởi AI Lead / Product Owner |
| `Không chạy được` | Môi trường lỗi, server không hoạt động, thiếu dữ liệu seed |

---

## Lưu ý bảo mật

- Hồ sơ này **không chứa** mật khẩu thật, API key, nội dung `.env`.
- Tài khoản trong `04-test-data/accounts.md` chỉ mô tả cấu trúc, không chứa credential thật.
- File Excel mẫu trong `04-test-data/excel-samples/` không chứa dữ liệu cá nhân thật.
