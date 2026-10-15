# BUG-003 — Giáo viên có thể xem toàn bộ lịch phân công giảng dạy của giáo viên khác

- **Mức độ:** Trung bình
- **Module:** SEC / CORE
- **Môi trường / thiết bị / phiên bản:** localhost:8081 / Spring Boot 3.5 / Java 21
- **Test case liên quan:** TC-SEC-053, TC-CORE-016
- **Ngày phát hiện:** 2026-10-15
- **Người phát hiện:** AI QA Senior

---

## Các bước tái hiện

1. Đăng nhập với tài khoản `gv_chunhiem_3a` (teacherId = 1)
2. Gửi request `GET /api/teaching-assignments/teacher/2` (teacherId = 2 của đồng nghiệp)

## Kết quả thực tế

```http
HTTP/1.1 200 OK
Content-Type: application/json
[
  {"id":3,"teacherId":2,"classId":2,"subjectId":1,"academicYearId":2}
]
```
Trong `TeachingAssignmentController.java`:
```java
@GetMapping("/teacher/{teacherId}")
@PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER')")
public ResponseEntity<?> getAssignmentsByTeacher(@PathVariable Long teacherId) {
    return ResponseEntity.ok(teachingAssignmentService.getAssignmentsByTeacher(teacherId));
}
```
Không kiểm tra `currentTeacher.getId().equals(teacherId)` khi caller có role `TEACHER`.

## Kết quả mong đợi

```http
HTTP/1.1 403 Forbidden
hoặc chỉ cho phép ADMIN xem mọi giáo viên, còn TEACHER chỉ được xem của chính mình.
```

## Bằng chứng

- File: `backend/school-backend/src/main/java/com/school/backend/controller/TeachingAssignmentController.java` dòng 29-33

## Trạng thái

- [ ] **Mới** — Phát hiện, chưa giao cho developer
- [ ] **Đã giao** — Developer đang xử lý
- [x] **Đã sửa** — Đã tích hợp SchoolAccessPolicy.verifyCanAccessTeacherAssignments trong getByTeacher và verifyTeacherCanManageClassAttendance trong getByClass. Đã kiểm chứng qua test testTeachingAssignment_OtherTeacherBlocked (403 Forbidden).
- [x] **Đã kiểm tra lại** — QA chạy lại, xác nhận sửa đúng (26/26 tests PASS)
- [x] **Đóng** — Đã xác nhận, không còn tái hiện được
