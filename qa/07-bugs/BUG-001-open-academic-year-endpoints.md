# BUG-001 — Endpoint cấu hình năm học thiếu @PreAuthorize cho phép truy cập không cần token

- **Mức độ:** Cao
- **Module:** SEC / CORE
- **Môi trường / thiết bị / phiên bản:** localhost:8081 / Spring Boot 3.5 / Java 21
- **Test case liên quan:** TC-CORE-001, TC-CORE-002, TC-SEC-001
- **Ngày phát hiện:** 2026-10-15
- **Người phát hiện:** AI QA Senior

---

## Các bước tái hiện

1. Không đăng nhập, không gửi kèm header `Authorization`
2. Gửi request `GET http://localhost:8081/api/academic-years`
3. Gửi tiếp request `GET http://localhost:8081/api/academic-years/current`

## Kết quả thực tế

```http
HTTP/1.1 200 OK
Content-Type: application/json

[
  {"id":1,"yearName":"2025-2026","startDate":"2025-09-01","endDate":"2026-05-31","isCurrent":false},
  {"id":2,"yearName":"2026-2027","startDate":"2026-09-01","endDate":"2027-05-31","isCurrent":true}
]
```
Mã nguồn tại `AcademicYearController.java`:
- Method `getAllAcademicYears()` không có `@PreAuthorize`
- Method `getCurrentAcademicYear()` không có `@PreAuthorize`

## Kết quả mong đợi

```http
HTTP/1.1 401 Unauthorized
{"error": "Unauthorized", "message": "Full authentication is required to access this resource"}
```
Tất cả endpoint nội bộ cần yêu cầu token xác thực hợp lệ (tối thiểu `hasAuthority('ADMIN')` hoặc các vai trò trong trường).

## Bằng chứng

- File mã nguồn: `backend/school-backend/src/main/java/com/school/backend/controller/AcademicYearController.java` dòng 24 & 30
- Báo cáo kiểm thử: `06-execution-reports/2026-10-15-lan-01.md`

## Trạng thái

- [x] **Mới** — Phát hiện, chưa giao cho developer
- [ ] **Đã giao** — Developer đang xử lý
- [ ] **Đã sửa** — Developer báo sửa xong
- [ ] **Đã kiểm tra lại** — QA chạy lại, xác nhận sửa đúng
- [ ] **Đóng** — Đã xác nhận, không còn tái hiện được
