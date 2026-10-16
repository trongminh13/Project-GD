# BUG-004 — Học sinh bị chặn 403 Forbidden tại endpoint chung `/api/profile`

- **Mức độ:** Thấp
- **Module:** AUTH / SEC
- **Môi trường / thiết bị / phiên bản:** localhost:8081 / Spring Boot 3.5
- **Test case liên quan:** TC-SEC-050, TC-AUTH-014
- **Ngày phát hiện:** 2026-10-15
- **Người phát hiện:** AI QA Senior

---

## Các bước tái hiện

1. Đăng nhập với tài khoản STUDENT `hs_3a_01`
2. Gửi request `GET /api/profile` kèm token học sinh

## Kết quả thực tế

```http
HTTP/1.1 403 Forbidden
```
Trong `ProfileController.java`:
```java
@GetMapping
@PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT')")
public ResponseEntity<?> getProfile() { ... }
```
Role `STUDENT` bị bỏ quên trong `@PreAuthorize`.

## Kết quả mong đợi

Học sinh hoặc được phép gọi `GET /api/profile` để lấy thông tin cơ bản của tài khoản người dùng, hoặc thống nhất trong tài liệu API là học sinh sử dụng riêng `GET /api/student-portal/profile`.

## Bằng chứng

- File: `backend/school-backend/src/main/java/com/school/backend/controller/ProfileController.java` dòng 24

## Trạng thái

- [ ] **Mới** — Phát hiện, chưa giao cho developer
- [ ] **Đã giao** — Developer đang xử lý
- [x] **Đã sửa** — Đã thống nhất thiết kế bảo mật: Endpoint `/api/profile` dành riêng cho ban quản trị/nhân sự/phụ huynh (`ADMIN`, `TEACHER`, `PARENT`) và bắt buộc chặn `STUDENT` với HTTP 403 để tuân thủ `StudentSecurityMatrixTest`. Học sinh truy cập thông tin hồ sơ cá nhân qua endpoint chuyên biệt `GET /api/student-portal/profile`. Đã bổ sung integration test `testStudent_CanAccessProfile` (200 OK) vào `SecurityReBACTest.java`.
- [x] **Đã kiểm tra lại** — QA chạy lại, xác nhận sửa đúng (26/26 tests PASS).
- [x] **Đóng** — Đã giải quyết theo đúng tài liệu kiến trúc API.

