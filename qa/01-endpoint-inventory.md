# 01 — Danh sách Endpoint & Ma trận Phân quyền

**Nguồn:** Đọc trực tiếp từ 21 Controller Java trong `backend/school-backend/src/main/java/com/school/backend/controller/`  
**Ngày cập nhật:** 2026-10-15  
**Tổng số endpoint:** 72

---

## Chú giải

| Ký hiệu | Ý nghĩa |
|---|---|
| ✅ | Vai trò được phép gọi |
| ❌ | Vai trò bị từ chối (403) |
| 🔓 | Không cần token (public) |
| ⚠️ | Có role check nhưng **thiếu kiểm tra quan hệ** — ứng viên IDOR |
| 🔴 | Không có `@PreAuthorize` — bất kỳ token hợp lệ hoặc không token nào cũng gọi được |
| ReBAC | Có kiểm tra quan hệ trong service layer |

---

## AUTH — `/api/auth`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Ghi chú | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 1 | POST | `/api/auth/signin` | AuthController | 🔓 | 🔓 | 🔓 | 🔓 | Public | TC-AUTH-001..006 |
| 2 | POST | `/api/auth/signup` | AuthController | 🔓 | 🔓 | 🔓 | 🔓 | Public — ⚠️ Cần xác nhận quyền tạo role | TC-AUTH-007 |
| 3 | POST | `/api/auth/change-password` | AuthController | ✅ | ✅ | ✅ | ✅ | Cần token; đổi pw của chính mình | TC-AUTH-008..010 |
| 4 | POST | `/api/auth/send-otp` | AuthController | 🔓 | 🔓 | 🔓 | 🔓 | Rate limit: 60s/lần, 5/giờ | TC-AUTH-011..012 |
| 5 | POST | `/api/auth/verify-otp` | AuthController | 🔓 | 🔓 | 🔓 | 🔓 | | TC-AUTH-013 |

---

## ACADEMIC_YEAR — `/api/academic-years`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Ghi chú | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 6 | GET | `/api/academic-years` | AcademicYearController | 🔴 | 🔴 | 🔴 | 🔴 | **Không có @PreAuthorize** | TC-CORE-001, TC-SEC-001 |
| 7 | GET | `/api/academic-years/current` | AcademicYearController | 🔴 | 🔴 | 🔴 | 🔴 | **Không có @PreAuthorize** | TC-CORE-002, TC-SEC-002 |
| 8 | POST | `/api/academic-years` | AcademicYearController | ✅ | ❌ | ❌ | ❌ | | TC-CORE-003 |
| 9 | PUT | `/api/academic-years/{id}/set-current` | AcademicYearController | ✅ | ❌ | ❌ | ❌ | | TC-CORE-004 |

---

## STUDENT — `/api/students`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Điều kiện quan hệ | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 10 | GET | `/api/students` | StudentController | ✅ | ✅ | ❌ | ❌ | | TC-CORE-005 |
| 11 | GET | `/api/students/my-wards` | StudentController | ❌ | ❌ | ✅ | ❌ | ReBAC: guardian_students | TC-CORE-006 |
| 12 | GET | `/api/students/{id}` | StudentController | ✅ | ⚠️ | ❌ | ❌ | Controller đã chặn PARENT (phụ huynh bắt buộc dùng /my-wards); TEACHER cần kiểm tra ReBAC theo lớp phụ trách | TC-SEC-003 |
| 13 | POST | `/api/students` | StudentController | ✅ | ❌ | ❌ | ❌ | | TC-CORE-007 |
| 14 | DELETE | `/api/students/cleanup-duplicates` | StudentController | ✅ | ❌ | ❌ | ❌ | Nguy hiểm — xóa hàng loạt | TC-IMP-014 |
| 15 | DELETE | `/api/students/{id}` | StudentController | ✅ | ❌ | ❌ | ❌ | | — |

---

## TEACHER — `/api/teachers`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Ghi chú | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 16 | GET | `/api/teachers` | TeacherController | ✅ | ✅ | ❌ | ❌ | | TC-CORE-008 |
| 17 | GET | `/api/teachers/{id}` | TeacherController | ✅ | ✅ | ❌ | ❌ | ⚠️ Thiếu ReBAC — bất kỳ GV nào xem được | TC-SEC-004 |
| 18 | POST | `/api/teachers` | TeacherController | ✅ | ❌ | ❌ | ❌ | | TC-CORE-009 |

---

## CLASS — `/api/classes`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Ghi chú | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 19 | GET | `/api/classes` | SchoolClassController | ✅ | ✅ | ❌ | ❌ | | TC-CORE-010 |
| 20 | GET | `/api/classes/{id}` | SchoolClassController | ✅ | ✅ | ❌ | ❌ | ⚠️ Thiếu ReBAC | TC-SEC-005 |
| 21 | POST | `/api/classes` | SchoolClassController | ✅ | ❌ | ❌ | ❌ | | TC-CORE-011 |
| 22 | PUT | `/api/classes/{id}` | SchoolClassController | ✅ | ❌ | ❌ | ❌ | | TC-CORE-012 |
| 23 | DELETE | `/api/classes/{id}` | SchoolClassController | ✅ | ❌ | ❌ | ❌ | | — |

---

## SUBJECT — `/api/subjects`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Ghi chú | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 24 | GET | `/api/subjects` | SubjectController | ✅ | ✅ | ❌ | ❌ | | TC-CORE-013 |
| 25 | GET | `/api/subjects/{id}` | SubjectController | ✅ | ✅ | ❌ | ❌ | | — |

---

## ENROLLMENT — `/api/enrollments`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Điều kiện quan hệ | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 26 | GET | `/api/enrollments/student/{studentId}` | EnrollmentController | ✅ | ReBAC | ReBAC | ReBAC | `SchoolAccessPolicy.verifyCanAccessStudent` | TC-SEC-006..010 |
| 27 | GET | `/api/enrollments/class/{classId}` | EnrollmentController | ✅ | ReBAC | ❌ | ❌ | GV phải dạy lớp đó | TC-SEC-011 |

---

## ATTENDANCE — `/api/attendance`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Điều kiện quan hệ | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 28 | GET | `/api/attendance/student/{studentId}` | AttendanceController | ✅ | ReBAC | ReBAC | ❌ | AttendanceService kiểm tra guardian_students | TC-SEC-012..016 |
| 29 | GET | `/api/attendance/{studentId}` | AttendanceController | ✅ | ReBAC | ReBAC | ❌ | Alias của endpoint trên | TC-SEC-012..016 |
| 30 | POST | `/api/attendance/bulk` | AttendanceController | ✅ | ⚠️ | ❌ | ❌ | ⚠️ Thiếu kiểm tra GV chỉ điểm danh lớp mình | TC-SEC-017, TC-ATT-001..005 |
| 31 | POST | `/api/attendance/mark` | AttendanceController | ✅ | ⚠️ | ❌ | ❌ | ⚠️ Thiếu ReBAC trong controller | TC-SEC-018 |

---

## LEAVE_REQUEST — `/api/leave-requests`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Điều kiện quan hệ | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 32 | POST | `/api/leave-requests` | LeaveRequestController | ❌ | ❌ | ✅ | ❌ | PH phải có liên kết guardian_students với học sinh | TC-ATT-006..010 |
| 33 | GET | `/api/leave-requests/my-requests` | LeaveRequestController | ❌ | ❌ | ✅ | ❌ | Chỉ đơn của PH đang đăng nhập | TC-ATT-011 |
| 34 | GET | `/api/leave-requests/pending` | LeaveRequestController | ❌ | ✅ | ❌ | ❌ | GV xem đơn đang chờ của lớp mình | TC-ATT-012 |
| 35 | PUT | `/api/leave-requests/{id}/review` | LeaveRequestController | ❌ | ReBAC | ❌ | ❌ | `SchoolAccessPolicy.verifyCanReviewLeaveRequest` — CHỈ GVCN | TC-SEC-019..021, TC-ATT-013..015 |
| 36 | GET | `/api/leave-requests/student/{studentId}` | LeaveRequestController | ✅ | ReBAC | ReBAC | ❌ | Kiểm tra quan hệ trong service | TC-SEC-022..025 |

---

## MARKS — `/api/marks`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Điều kiện quan hệ | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 37 | POST | `/api/marks/bulk` | MarksController | ✅ | ⚠️ | ❌ | ❌ | ⚠️ Service kiểm tra GV có phụ trách lớp không | TC-SEC-026, TC-ATT-016 |
| 38 | GET | `/api/marks/student/{studentId}` | MarksController | ✅ | ReBAC | ReBAC | ❌ | Service kiểm tra guardian_students | TC-SEC-027..029 |
| 39 | GET | `/api/marks/{studentId}` | MarksController | ✅ | ReBAC | ReBAC | ❌ | Alias — cùng logic | TC-SEC-027..029 |

---

## MATERIAL — `/api`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Điều kiện quan hệ | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 40 | POST | `/api/teacher/materials` | MaterialController | ✅ | ✅ | ❌ | ❌ | | TC-MAT-001..003 |
| 41 | GET | `/api/teacher/materials` | MaterialController | ✅ | ✅ | ❌ | ❌ | Chỉ trả về bài của GV đang đăng nhập | TC-MAT-004 |
| 42 | GET | `/api/student-portal/materials` | MaterialController | ❌ | ❌ | ❌ | ✅ | Chỉ trả về học liệu PUBLISHED của lớp HS | TC-MAT-005..007 |
| 43 | GET | `/api/materials/files/{fileId}/download` | MaterialController | ✅ | ReBAC | ReBAC | ReBAC | `SchoolAccessPolicy.verifyCanDownloadMaterialFile` | TC-SEC-030..037, TC-MAT-008..011 |

---

## HOMEWORK (Teacher) — `/api/teacher/homework`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Điều kiện quan hệ | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 44 | POST | `/api/teacher/homework` | TeacherHomeworkController | ✅ | ✅ | ❌ | ❌ | | TC-HW-001..003 |
| 45 | GET | `/api/teacher/homework` | TeacherHomeworkController | ✅ | ✅ | ❌ | ❌ | Chỉ trả về bài của GV đang đăng nhập | TC-HW-004 |
| 46 | GET | `/api/teacher/homework/{id}` | TeacherHomeworkController | ✅ | ReBAC | ❌ | ❌ | GV phải là người soạn, hoặc phụ trách lớp | TC-SEC-038, TC-HW-005 |
| 47 | POST | `/api/teacher/homework/{id}/assign` | TeacherHomeworkController | ✅ | ReBAC | ❌ | ❌ | `verifyTeacherCanAssignClass` | TC-SEC-039..040, TC-HW-006..008 |
| 48 | GET | `/api/teacher/homework/assignments` | TeacherHomeworkController | ✅ | ✅ | ❌ | ❌ | Chỉ trả về assignment của GV đang đăng nhập | TC-HW-009 |
| 49 | GET | `/api/teacher/homework/assignments/{assignmentId}/submissions` | TeacherHomeworkController | ✅ | ReBAC | ❌ | ❌ | `verifyTeacherCanAccessAssignment` | TC-SEC-041, TC-HW-010 |
| 50 | GET | `/api/teacher/homework/submissions/{submissionId}` | TeacherHomeworkController | ✅ | ReBAC | ❌ | ❌ | Cần xác minh service | TC-SEC-042, TC-HW-011 |
| 51 | PUT | `/api/teacher/homework/submissions/{submissionId}/grade` | TeacherHomeworkController | ✅ | ReBAC | ❌ | ❌ | GV phải phụ trách lớp đó | TC-SEC-043, TC-HW-012..015 |

---

## HOMEWORK (Student) — `/api/student-portal/homework`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Điều kiện quan hệ | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 52 | GET | `/api/student-portal/homework` | StudentHomeworkController | ❌ | ❌ | ❌ | ✅ | Chỉ trả về bài của lớp HS | TC-HW-016 |
| 53 | GET | `/api/student-portal/homework/{assignmentId}/take` | StudentHomeworkController | ❌ | ❌ | ❌ | ✅ | HS phải thuộc lớp nhận bài; kiểm tra đáp án **không lộ** | TC-SEC-044..046, TC-HW-017..019 |
| 54 | POST | `/api/student-portal/homework/submissions/{submissionId}/draft` | StudentHomeworkController | ❌ | ❌ | ❌ | ✅ | `verifyStudentCanAccessSubmission` | TC-SEC-047, TC-HW-020..022 |
| 55 | POST | `/api/student-portal/homework/submissions/{submissionId}/submit` | StudentHomeworkController | ❌ | ❌ | ❌ | ✅ | `verifyStudentCanAccessSubmission` | TC-SEC-048, TC-HW-023..026 |

---

## HOMEWORK (Parent) — `/api/parent/wards`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Điều kiện quan hệ | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 56 | GET | `/api/parent/wards/{studentId}/homework` | ParentHomeworkController | ✅ | ❌ | ReBAC | ❌ | Service kiểm tra guardian_students | TC-SEC-049, TC-HW-027 |

---

## STUDENT PORTAL — `/api/student-portal`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Ghi chú | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 57 | GET | `/api/student-portal/profile` | StudentPortalController | ❌ | ❌ | ❌ | ✅ | Chỉ xem profile của chính mình | TC-CORE-014 |
| 58 | GET | `/api/student-portal/attendance` | StudentPortalController | ❌ | ❌ | ❌ | ✅ | Chỉ xem điểm danh của chính mình | TC-ATT-017 |
| 59 | GET | `/api/student-portal/marks` | StudentPortalController | ❌ | ❌ | ❌ | ✅ | Chỉ xem điểm của chính mình | TC-CORE-015 |

---

## PROFILE — `/api/profile`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Ghi chú | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 60 | GET | `/api/profile` | ProfileController | ✅ | ✅ | ✅ | ❌ | ⚠️ STUDENT bị loại — có thể là bug nếu HS cần xem profile | TC-SEC-050, TC-AUTH-014 |
| 61 | PUT | `/api/profile` | ProfileController | ✅ | ✅ | ✅ | ❌ | Chỉ cập nhật profile của chính mình | TC-AUTH-015 |

---

## FEE — `/api/fees`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Điều kiện quan hệ | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 62 | GET | `/api/fees/statement/{studentId}` | FeeController | ✅ | ❌ | ReBAC | ❌ | PH phải là guardian của studentId | TC-SEC-051, TC-PAY-001..003 |
| 63 | POST | `/api/fees/create-order` | FeeController | ❌ | ❌ | ✅ | ❌ | | TC-PAY-004..006 |
| 64 | POST | `/api/fees/verify-payment` | FeeController | ❌ | ❌ | ✅ | ❌ | Idempotency check | TC-PAY-007..009 |
| 65 | GET | `/api/fees/student/{studentId}` | FeeController | ✅ | ❌ | ReBAC | ❌ | Cần xác minh service ReBAC | TC-SEC-052, TC-PAY-010 |
| 66 | POST | `/api/fees/pay` | FeeController | ✅ | ❌ | ❌ | ❌ | Admin manual payment | TC-PAY-011 |

---

## BULK IMPORT — `/api/upload`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Ghi chú | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 67 | POST | `/api/upload/students` | BulkImportController | ✅ | ❌ | ❌ | ❌ | File Excel, giới hạn 2000 dòng | TC-IMP-001..013 |

---

## MIGRATION — `/api/admin/migration`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Ghi chú | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 68 | GET | `/api/admin/migration/ping` | AdminMigrationController | ✅ | ❌ | ❌ | ❌ | Health check | TC-IMP-015 |
| 69 | GET | `/api/admin/migration/reconciliation` | AdminMigrationController | ✅ | ❌ | ❌ | ❌ | Báo cáo đối soát dữ liệu | TC-IMP-016 |
| 70 | POST | `/api/admin/migration/upload-excel` | AdminMigrationController | ✅ | ❌ | ❌ | ❌ | Migration data | TC-IMP-017 |

---

## TEACHING ASSIGNMENT — `/api/teaching-assignments`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Ghi chú | Test case |
|---|---|---|---|---|---|---|---|---|---|
| 71 | GET | `/api/teaching-assignments/teacher/{teacherId}` | TeachingAssignmentController | ✅ | ⚠️ | ❌ | ❌ | ⚠️ Thiếu kiểm tra GV chỉ xem phân công của mình | TC-SEC-053, TC-CORE-016 |
| 72 | GET | `/api/teaching-assignments/class/{classId}` | TeachingAssignmentController | ✅ | ⚠️ | ❌ | ❌ | ⚠️ Thiếu kiểm tra GV chỉ xem lớp mình | TC-SEC-054, TC-CORE-017 |

---

## DEBUG — `/api/test`

| # | Phương thức | Đường dẫn | Controller | ADMIN | TEACHER | PARENT | STUDENT | Ghi chú | Test case |
|---|---|---|---|---|---|---|---|---|---|
| — | GET | `/api/test/sms` | DebugController | ✅ | ❌ | ❌ | ❌ | ⚠️ Gọi Fast2SMS thật với API key từ config — cần tắt trên môi trường test | TC-NFR-008 |

---

## Tổng kết ⚠️ Ứng viên lỗi bảo mật

| # | Endpoint | Vấn đề phát hiện qua đọc code |
|---|---|---|
| 1 | `GET /api/academic-years` | Không có `@PreAuthorize` — bất kỳ request nào (kể cả không token) |
| 2 | `GET /api/academic-years/current` | Không có `@PreAuthorize` |
| 3 | `POST /api/attendance/bulk` | Giáo viên có thể điểm danh cho lớp mình không dạy (cần xác minh qua chạy) |
| 4 | `POST /api/attendance/mark` | Không có kiểm tra quan hệ trong controller |
| 5 | `GET /api/students/{id}` | Cần xác minh service có ReBAC không |
| 6 | `GET /api/teaching-assignments/teacher/{teacherId}` | GV có thể xem phân công của GV khác |
| 7 | `GET /api/teaching-assignments/class/{classId}` | GV có thể xem phân công của lớp mình không dạy |
| 8 | `GET /api/profile` | STUDENT không có quyền xem profile — có thể là thiếu sót |
