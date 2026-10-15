# BUG-002 — Giáo viên có thể điểm danh hàng loạt cho lớp mình không phụ trách (BOLA / IDOR)

- **Mức độ:** Nghiêm trọng
- **Module:** SEC / ATT
- **Môi trường / thiết bị / phiên bản:** localhost:8081 / Spring Boot 3.5 / Java 21
- **Test case liên quan:** TC-SEC-017, TC-ATT-001
- **Ngày phát hiện:** 2026-10-15
- **Người phát hiện:** AI QA Senior

---

## Các bước tái hiện

1. Đăng nhập với tài khoản giáo viên `gv_lop_khac` (chỉ dạy lớp 3B, hoàn toàn không phụ trách lớp 3A)
2. Lấy JWT Token của `gv_lop_khac`
3. Gửi request `POST /api/attendance/bulk` với `classId = 1` (Lớp 3A):
   ```json
   {
     "classId": 1,
     "date": "2026-10-15",
     "records": [
       {"studentId": 1, "status": "ABSENT", "remarks": "Điểm danh chéo bởi GV khác"}
     ]
   }
   ```

## Kết quả thực tế

```http
HTTP/1.1 200 OK
{"message": "Attendance marked successfully"}
```
Trong `AttendanceController.java`:
```java
@PostMapping("/bulk")
@PreAuthorize("hasAuthority('TEACHER') or hasAuthority('ADMIN')")
public ResponseEntity<?> markBulkAttendance(@RequestBody BulkAttendanceRequest request) {
    attendanceService.markBulkAttendance(request);
    return ResponseEntity.ok(new MessageResponse("Attendance marked successfully"));
}
```
Controller chỉ kiểm tra xem user có role `TEACHER` hay không (`hasAuthority('TEACHER')`), mà **hoàn toàn không xác minh** xem giáo viên đang gọi có phải là GVCN hoặc giáo viên được phân công giảng dạy tại `classId` đó hay không. Dẫn đến lỗ hổng BOLA (Broken Object Level Authorization).

## Kết quả mong đợi

```http
HTTP/1.1 403 Forbidden
{"message": "Access Denied: You do not have permission to mark attendance for this class"}
```
Hệ thống phải gọi policy check `SchoolAccessPolicy.verifyTeacherCanManageClassAttendance(auth, request.getClassId())`.

## Bằng chứng

- File mã nguồn: `backend/school-backend/src/main/java/com/school/backend/controller/AttendanceController.java` dòng 42-47
- Báo cáo kiểm thử: `06-execution-reports/2026-10-15-lan-01.md`

## Trạng thái

- [x] **Mới** — Phát hiện, chưa giao cho developer
- [ ] **Đã giao** — Developer đang xử lý
- [ ] **Đã sửa** — Developer báo sửa xong
- [ ] **Đã kiểm tra lại** — QA chạy lại, xác nhận sửa đúng
- [ ] **Đóng** — Đã xác nhận, không còn tái hiện được
