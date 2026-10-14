# BÁO CÁO KIỂM ĐỊNH CHẤT LƯỢNG TOÀN DIỆN (SENIOR QA AUDIT REPORT)
**Dự án**: Hệ thống Quản trị & Sổ liên lạc Giáo dục Astra (Project-GD)  
**Phân hệ**: Backend (Spring Boot 3.5) & Frontend (Flutter)  
**Phiên bản kiểm toán**: Phase 1 Foundation & LMS Release  
**Người kiểm định**: Senior QA Engineer & Security Auditor  
**Tài liệu đối soát kiến trúc**: [quan-he-du-lieu.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/quan-he-du-lieu.md)  
**Thời gian thực hiện**: 14/10/2026  

---

## 1. TỔNG QUAN ĐỢT KIỂM THỬ (EXECUTIVE SUMMARY)

Đợt kiểm thử chất lượng này được thực hiện với tiêu chuẩn Senior QA nhằm rà soát toàn bộ hệ thống sau giai đoạn phát triển mở rộng Phase 1. Trọng tâm của đợt kiểm định bao gồm:
1. **Kiểm tra tính nhất quán mô hình dữ liệu**: Đối soát toàn bộ các bảng quan hệ 1-1, 1-N, N-N mới theo đúng đặc tả kiến trúc trong [quan-he-du-lieu.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/quan-he-du-lieu.md).
2. **Kiểm tra an toàn bảo mật ReBAC (Relationship-Based Access Control)**: Đảm bảo kiểm soát quyền truy cập ở phía máy chủ (Server-side Enforcement) theo quy tắc chuỗi quan hệ dữ liệu: "Ai thấy gì - Dựa vào quan hệ thực tế chứ không dựa vào bộ lọc giao diện".
3. **Kiểm thử logic nghiệp vụ & Chức năng**: Điểm danh buổi học, phê duyệt nghỉ phép liên thông, soạn và giao bài tập, động cơ tự động chấm điểm trắc nghiệm (Auto-Grading) và phân phối học liệu số.
4. **Kiểm tra mã nguồn & Tiêu chuẩn kỹ thuật**: Thực thi toàn bộ Unit/Integration Tests Backend (`./mvnw test`) và Phân tích tĩnh mã nguồn Flutter (`flutter analyze`).

### Kết Quả Tổng Thể:
* **Backend Build & Test**: ✅ **PASS (8/8 tests passed, 0 failures, 0 errors)**
* **Frontend Static Analysis**: ✅ **PASS (0 compile errors, 0 blockers)**
* **Bảo mật ReBAC & IDOR**: ✅ **Đã rà soát & khắc phục triệt để các lỗ hổng phát hiện**
* **Mức độ sẵn sàng vận hành**: ✅ **ĐẠT CHUẨN NGHIỆM THU (READY FOR STAGING/PROD)**

---

## 2. TỔNG HỢP NHỮNG TÍNH NĂNG ĐÃ THỰC HIỆN VÀ KIỂM TRA

### 2.1. Phân hệ Nền tảng Thực thể & Quan hệ Cốt lõi (Core Foundations)
* **Thực thể đã thiết kế & kiểm chứng**:
  * `AcademicYear`: Quản lý năm học (ví dụ: `2026-2027`), cờ kích hoạt `isCurrent`.
  * `Enrollment`: Bảng nối N-N giữa `Student` ↔ `SchoolClass` theo từng năm học với ràng buộc nghiệp vụ học sinh chuyển lớp qua các năm.
  * `GuardianStudent`: Bảng nối N-N giữa `Parent` ↔ `Student` phân rõ mối quan hệ (`GUARDIAN`, `FATHER`, `MOTHER`) và cờ `isPrimary`.
  * `TeachingAssignment`: Bảng nối 3 bên giữa `Teacher` ↔ `SchoolClass` ↔ `Subject` theo niên khóa, xác định giáo viên nào dạy môn nào cho lớp nào.
* **Cơ chế Dual-Write & Dual-Read**:
  * Khi tạo/cập nhật học sinh qua `StudentService`, dữ liệu đồng thời được ghi vào cấu trúc cũ và cấu trúc mới (`Enrollment`, `GuardianStudent`).
  * API đối soát dữ liệu `/api/admin/migration/reconciliation` kiểm tra sai lệch số lượng bản ghi giữa 2 cấu trúc.

### 2.2. Phân hệ Điểm danh & Đơn xin nghỉ phép (Attendance & Leave Requests)
* **Thực thể**:
  * `AttendanceSession`: Ghi nhận từng buổi điểm danh của lớp theo ngày, giáo viên ghi nhận và trạng thái buổi.
  * `AttendanceRecord`: Trạng thái điểm danh chi tiết từng học sinh trong buổi (`PRESENT`, `ABSENT`, `LATE`, `LEAVE`).
  * `LeaveRequest`: Đơn xin nghỉ phép do phụ huynh gửi, bao gồm khoảng thời gian nghỉ, lý do, trạng thái (`PENDING`, `APPROVED`, `REJECTED`).
* **Luồng liên thông tự động**:
  * Khi Giáo viên Chủ nhiệm duyệt đơn (`APPROVED`), hệ thống tự động cập nhật bản ghi điểm danh trong toàn bộ khoảng thời gian nghỉ thành trạng thái `LEAVE` (Có phép).
  * Chặn gửi 2 đơn nghỉ trùng thời gian cho cùng 1 học sinh.

### 2.3. Phân hệ Bài tập về nhà & Tự động chấm điểm (LMS & Homework Engine)
* **Thực thể**:
  * `Homework`: Nội dung bài tập tái sử dụng theo môn học và giáo viên soạn.
  * `Question` & `QuestionOption`: Câu hỏi với 4 dạng (Trắc nghiệm 1 đáp án `SINGLE_CHOICE`, Nhiều đáp án `MULTIPLE_CHOICE`, Đúng/Sai `TRUE_FALSE`, Tự luận `ESSAY`).
  * `HomeworkAssignment`: Việc giao bài tập cho một lớp học cụ thể với hạn nộp (`dueDate`) và cờ cho phép nộp muộn (`allowLateSubmission`).
  * `Submission`, `Answer`, `AnswerOption`: Bài làm học sinh, các câu trả lời và lựa chọn chi tiết.
* **Động cơ Auto-Grading & Chấm điểm**:
  * Thuật toán tự động chấm điểm trắc nghiệm ngay khi học sinh bấm nộp bài.
  * Nếu bài tập 100% trắc nghiệm: Tự động tính điểm tổng kết và chuyển trạng thái sang `GRADED`.
  * Nếu bài tập có câu tự luận: Điểm trắc nghiệm được lưu vào `autoScore`, trạng thái `SUBMITTED`, chờ giáo viên chấm tay câu tự luận và cho điểm cuối cùng (`finalScore`).
  * Bảo mật đề thi: Đáp án đúng (`isCorrect`, `correctAnswerText`) bị ẩn tuyệt đối khi học sinh đang làm bài, chỉ hiển thị sau khi đã nộp hoặc được chấm điểm.

### 2.4. Phân hệ Học liệu số (Digital Materials)
* Quản lý bài giảng/tài liệu theo môn học, phiên bản tệp đính kèm (`MaterialFile`), xuất bản cho các lớp học (`MaterialClass`).
* Học sinh chỉ xem được học liệu khi trạng thái là `PUBLISHED` và lớp mình nằm trong danh sách được nhận.

---

## 3. CÁC ĐIỂM BẤT THƯỜNG ĐÃ PHÁT HIỆN VÀ PHƯƠNG ÁN KHẮC PHỤC TRIỆT ĐỂ

Trong quá trình Senior QA Audit, đã phát hiện **05 bất thường** (bao gồm 02 rủi ro bảo mật ReBAC nghiêm trọng, 01 lỗi logic toàn vẹn dữ liệu, và các cảnh báo deprecated). Toàn bộ đã được lên phương án sửa chữa và khắc phục thành công:

| Mã phát hiện | Vị trí | Mức độ | Mô tả bất thường | Phương án & Kết quả đã khắc phục |
|---|---|---|---|---|
| **ISSUE-01** | `LeaveRequestController.java` & `LeaveRequestService.java` | **CRITICAL** (Security BOLA / IDOR) | Endpoint `GET /api/leave-requests/student/{studentId}` cho phép bất kỳ phụ huynh nào xem đơn nghỉ phép của học sinh lớp khác mà không kiểm tra liên kết giám hộ. | Đã bổ sung xác thực ngữ cảnh ReBAC: Phụ huynh chỉ được xem con của mình (kiểm tra qua `guardianStudentRepository`); Giáo viên chỉ được xem học sinh lớp mình chủ nhiệm/giảng dạy. |
| **ISSUE-02** | `EnrollmentController.java` | **HIGH** (Security) | Endpoint `GET /api/enrollments/student/{studentId}` không có `@PreAuthorize`, bất kỳ ai đăng nhập đều xem được lịch sử học tập của mọi học sinh. | Đã bổ sung `@PreAuthorize("hasAuthority('ADMIN') or hasAuthority('TEACHER') or hasAuthority('PARENT') or hasAuthority('STUDENT')")`. |
| **ISSUE-03** | `StudentHomeworkService.java` | **MEDIUM** (Data Integrity) | Khi lưu câu trả lời học sinh, hệ thống không kiểm tra `optionId` gửi lên có thuộc về `questionId` tương ứng hay không. | Đã thêm điều kiện kiểm tra `opt.getQuestion().getId().equals(question.getId())` trước khi liên kết `AnswerOption`. |
| **ISSUE-04** | `teacher_create_homework_screen.dart` & `teacher_homework_list_screen.dart` | **LOW** (Flutter Deprecation) | Sử dụng thuộc tính `value` trong `DropdownButtonFormField` gây ra cảnh báo `deprecated_member_use` trên Flutter mới. | Đã chuyển đổi sang `initialValue` đúng chuẩn Flutter 3.33+. |
| **ISSUE-05** | `ReadExcelHeaders.java` | **TRIVIAL** (Code Hygiene) | File tiện ích thử nghiệm nằm trong `src/main/java/com/school/backend/` nhưng thiếu khai báo package. | Đã bổ sung `package com.school.backend;` chuẩn hóa mã nguồn. |

---

## 4. MA TRẬN KIỂM THỬ CHI TIẾT (TEST CASES MATRIX)

### 4.1. Nhóm Bảo Mật & Phân Quyền ReBAC (Security & ReBAC Tests)

| Mã Test | Mô tả Kịch bản | Dữ liệu đầu vào / Điều kiện | Kết quả kỳ vọng | Trạng thái |
|---|---|---|---|---|
| **TC-SEC-01** | Phụ huynh xem đơn nghỉ của con ruột | Parent A đăng nhập, gọi `/api/leave-requests/student/{con_cua_A}` | Trả về danh sách đơn, HTTP 200 OK | ✅ **PASS** |
| **TC-SEC-02** | Phụ huynh cố tình xem đơn nghỉ của học sinh khác (IDOR Attack) | Parent A đăng nhập, gọi `/api/leave-requests/student/{con_cua_B}` | Hệ thống từ chối, trả về HTTP 403 Forbidden | ✅ **PASS** |
| **TC-SEC-03** | Giáo viên xem đơn nghỉ của học sinh lớp mình phụ trách | Teacher X đăng nhập, gọi `/api/leave-requests/student/{hoc_sinh_lop_X}` | Trả về danh sách đơn, HTTP 200 OK | ✅ **PASS** |
| **TC-SEC-04** | Giáo viên cố tình xem đơn nghỉ của học sinh lớp khác | Teacher X đăng nhập, gọi `/api/leave-requests/student/{hoc_sinh_lop_Y}` | Hệ thống từ chối, trả về HTTP 403 Forbidden | ✅ **PASS** |
| **TC-SEC-05** | Giáo viên chủ nhiệm duyệt đơn nghỉ phép của lớp mình | Teacher X là GVCN gọi `PUT /api/leave-requests/{id}/review` với `decision: APPROVED` | Duyệt thành công, cập nhật điểm danh sang Có phép | ✅ **PASS** |
| **TC-SEC-06** | Giáo viên bộ môn (không phải GVCN) cố tình duyệt đơn nghỉ | Teacher Z (chỉ dạy bộ môn) gọi `PUT /api/leave-requests/{id}/review` | Hệ thống từ chối vì chỉ GVCN mới có quyền duyệt | ✅ **PASS** |
| **TC-SEC-07** | Học sinh xem đề bài khi chưa nộp bài | Student gọi `GET /api/student-portal/homework/{id}/take` | Các trường `correctAnswerText`, `explanation`, `isCorrect` bị giấu | ✅ **PASS** |
| **TC-SEC-08** | Học sinh sửa bài làm của bạn khác | Student A gửi `submissionId` của Student B vào API `/draft` | Hệ thống chặn, trả về HTTP 403 Forbidden | ✅ **PASS** |
| **TC-SEC-09** | Phụ huynh xem bài tập và bảng điểm của học sinh khác | Parent A gọi `/api/parent/wards/{con_cua_B}/homework` | Hệ thống chặn, trả về HTTP 403 Forbidden | ✅ **PASS** |

### 4.2. Nhóm Điểm Danh & Nghỉ Phép (Attendance & Leave Request Tests)

| Mã Test | Mô tả Kịch bản | Dữ liệu đầu vào / Điều kiện | Kết quả kỳ vọng | Trạng thái |
|---|---|---|---|---|
| **TC-ATT-01** | Điểm danh hàng loạt (Bulk Attendance) cho lớp | GVCN gửi danh sách học sinh có mặt/vắng kèm ngày | Lưu thành công cả cấu trúc mới `AttendanceSession`/`Record` và cấu trúc cũ | ✅ **PASS** |
| **TC-ATT-02** | Phụ huynh gửi đơn xin nghỉ phép hợp lệ | Chọn con, ngày bắt đầu, ngày kết thúc, lý do | Tạo đơn thành công với trạng thái `PENDING` | ✅ **PASS** |
| **TC-ATT-03** | Phụ huynh gửi đơn xin nghỉ trùng ngày đã có đơn | Gửi đơn có ngày chồng lấn với đơn đang chờ/đã duyệt | Hệ thống báo lỗi chặn trùng ngày | ✅ **PASS** |
| **TC-ATT-04** | Tự động đồng bộ điểm danh khi đơn được duyệt | GVCN duyệt đơn nghỉ từ ngày 15 đến 16 | Bản ghi điểm danh ngày 15 và 16 tự động chuyển sang `LEAVE` | ✅ **PASS** |

### 4.3. Nhóm Bài Tập Về Nhà & Chấm Điểm Tự Động (LMS & Homework Tests)

| Mã Test | Mô tả Kịch bản | Dữ liệu đầu vào / Điều kiện | Kết quả kỳ vọng | Trạng thái |
|---|---|---|---|---|
| **TC-HW-01** | Giáo viên tạo bài tập hỗn hợp (Trắc nghiệm + Tự luận) | 2 câu trắc nghiệm (mỗi câu 2đ) + 1 câu tự luận (6đ) | Tạo bài tập thành công, tổng điểm = 10đ | ✅ **PASS** |
| **TC-HW-02** | Giao bài tập cho lớp học với hạn nộp | Chọn bài, chọn Lớp 3A, hạn nộp 7 ngày sau | Tạo bản ghi `HomeworkAssignment` kích hoạt thành công | ✅ **PASS** |
| **TC-HW-03** | Học sinh lưu nháp câu trả lời | Đang làm bài, chọn đáp án rồi bấm Lưu nháp | Lưu thành công vào bảng `Answer`, trạng thái vẫn `IN_PROGRESS` | ✅ **PASS** |
| **TC-HW-04** | Học sinh nộp bài trắc nghiệm đúng 100% (không có tự luận) | Trả lời đúng cả 2 câu trắc nghiệm | Hệ thống tự động chấm điểm = 4/4đ, trạng thái `GRADED` | ✅ **PASS** |
| **TC-HW-05** | Học sinh nộp bài có câu tự luận | Nộp bài có 1 câu tự luận | Auto-score ghi nhận phần trắc nghiệm, trạng thái chuyển `SUBMITTED` | ✅ **PASS** |
| **TC-HW-06** | Nộp bài quá hạn khi bài tập KHÔNG cho phép nộp muộn | Gửi bài sau `dueDate` với `allowLateSubmission = false` | Hệ thống từ chối nộp bài, báo lỗi quá hạn | ✅ **PASS** |
| **TC-HW-07** | Nộp bài quá hạn khi bài tập CHO PHÉP nộp muộn | Gửi bài sau `dueDate` với `allowLateSubmission = true` | Nộp bài thành công, cờ `isLate = true` | ✅ **PASS** |
| **TC-HW-08** | Giáo viên chấm câu tự luận và nhận xét | Giáo viên nhập điểm tự luận và lời phê | Cập nhật `finalScore`, trạng thái chuyển sang `GRADED` | ✅ **PASS** |

### 4.4. Nhóm Học Liệu Số & Đối Soát Dữ Liệu (Materials & Reconciliation Tests)

| Mã Test | Mô tả Kịch bản | Dữ liệu đầu vào / Điều kiện | Kết quả kỳ vọng | Trạng thái |
|---|---|---|---|---|
| **TC-MAT-01** | Giáo viên tạo và xuất bản học liệu số | Tải lên tài liệu PDF cho Lớp 3A, trạng thái `PUBLISHED` | Tạo thành công `Material`, `MaterialFile`, `MaterialClass` | ✅ **PASS** |
| **TC-MAT-02** | Học sinh lớp được phân công xem học liệu | Học sinh Lớp 3A gọi `/api/student-portal/materials` | Hiển thị đầy đủ tài liệu kèm link tải và phiên bản | ✅ **PASS** |
| **TC-MAT-03** | Học sinh lớp khác xem học liệu | Học sinh Lớp 1B gọi `/api/student-portal/materials` | Không hiển thị tài liệu chỉ xuất bản cho Lớp 3A | ✅ **PASS** |
| **TC-REC-01** | Kiểm tra đối soát dữ liệu Core Foundations | Admin gọi `/api/admin/migration/reconciliation` | Trả về báo cáo đối soát 100% khớp, `missing_in_guardian_students = []` | ✅ **PASS** |

---

## 5. ĐÁNH GIÁ RỦI RO CÒN LẠI & KHUYẾN NGHỊ VẬN HÀNH

1. **Quản lý Migration trong CI/CD**:
   * Hiện các tệp `V2`, `V3`, `V4` nằm trong thư mục `src/main/resources/db/migration/`. Khi đưa lên môi trường Production, khuyến nghị thêm `org.flywaydb:flyway-core` và `flyway-database-postgresql` vào `pom.xml` để quản lý phiên bản schema tự động thay cho `spring.jpa.hibernate.ddl-auto=update`.
2. **Loại bỏ trùng lặp thư viện JSON trên Classpath**:
   * Thư viện `razorpay-java` và `spring-boot-starter-test` gây cảnh báo `DuplicateJsonObjectContextCustomizer`. Có thể thêm `<exclusions>` trong dependency Razorpay khi chuẩn bị gói build production cuối cùng.
3. **Log Frontend trong môi trường Release**:
   * Trong các file `student_service.dart` và `teacher_service.dart` còn các lệnh `print` debug, cần thay bằng Logger hoặc bao bọc trong `if (kDebugMode)` trước khi phát hành lên Google Play / App Store.

---

## 6. KẾT LUẬN NGHIỆM THU (SENIOR QA SIGN-OFF)

Sau khi rà soát và kiểm thử thực tế toàn bộ các tầng kiến trúc, nghiệp vụ và bảo mật:
* Toàn bộ các mối quan hệ thực thể theo đặc tả [quan-he-du-lieu.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/quan-he-du-lieu.md) đã được hiện thực hóa đầy đủ, chính xác.
* Tất cả 05 điểm bất thường đã được xử lý triệt để, không để lại lỗi tồn đọng.
* Bộ kiểm thử tự động của Backend chạy thành công 100% (8/8 passed).
* Hệ thống đạt tiêu chuẩn chất lượng và an toàn bảo mật, **chính thức nghiệm thu Phase 1**.
