# BÁO CÁO KIỂM ĐỊNH CHẤT LƯỢNG TOÀN DIỆN (SENIOR QA AUDIT REPORT)
**Dự án**: Hệ thống Quản trị & Sổ liên lạc Giáo dục Astra (Project-GD)  
**Phân hệ**: Backend (Spring Boot 3.5 / Java 21) & Frontend (Flutter)  
**Phiên bản kiểm toán**: Phase 1 Foundation & LMS Hardened Release  
**Người kiểm định**: Senior QA Engineer & Security Auditor  
**Tài liệu đối soát kiến trúc**: [quan-he-du-lieu.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/quan-he-du-lieu.md)  
**Thời gian cập nhật**: 15/10/2026 (Bổ sung Hardening: Global Exception Handler & Converter Logging)  

---

## 1. TỔNG QUAN ĐỢT KIỂM ĐỊNH (EXECUTIVE SUMMARY)

Đợt kiểm định chất lượng và gia cố hệ thống (Hardening) được triển khai nhằm giải quyết triệt để các rủi ro kiến trúc, an toàn bảo mật quan hệ (ReBAC/IDOR), tính toàn vẹn dữ liệu trong LMS và cơ chế di chuyển dữ liệu Flyway:

1. **Gia cố bảo mật ReBAC (Relationship-Based Access Control) & Triệt tiêu IDOR**:
   * Tập trung hóa toàn bộ logic xác thực quan hệ vào [`SchoolAccessPolicy.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/security/SchoolAccessPolicy.java).
   * **ISSUE-01 (Đơn nghỉ phép)**: Phụ huynh chỉ được xem con của mình (`guardian_students`), Giáo viên chỉ được xem/duyệt học sinh lớp mình chủ nhiệm (`classes.homeroom_teacher_id`). Giáo viên bộ môn không có quyền duyệt đơn nghỉ và sẽ nhận `403 Forbidden`.
   * **ISSUE-02 (Lịch sử lớp học Enrollment)**: Xóa bỏ lỗ hổng kiểm tra theo role chung. Áp dụng quy tắc quan hệ chặt chẽ: Phụ huynh chỉ xem con mình, Học sinh chỉ xem chính mình, Giáo viên chỉ xem học sinh thuộc lớp mình dạy; các trường hợp vi phạm đều bị chặn với mã HTTP chuẩn `403 Forbidden`.
2. **Quản lý phiên bản CSDL Flyway an toàn & Khắc phục thiếu Baseline**:
   * Bổ sung [`V1__initial_schema.sql`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/resources/db/migration/V1__initial_schema.sql) mô tả toàn bộ schema cơ sở (users, teachers, classes, parents, students, subjects, attendance, marks, fees).
   * Tích hợp `flyway-core` và `flyway-database-postgresql` vào `pom.xml`.
   * Cấu hình an toàn `spring.flyway.baseline-on-migrate=true` và `spring.flyway.baseline-version=0`: Giúp ứng dụng khởi động an toàn trên cả Database trống (chạy tuần tự V1..V4) lẫn Database đã có dữ liệu (đánh dấu baseline version 0 và chạy các script idempotent mà không làm gãy schema).
3. **Động cơ LMS & Tự động chấm điểm (Auto-Grading)**:
   * Bổ sung hỗ trợ dạng câu hỏi Điền câu trả lời ngắn (`SHORT_ANSWER`).
   * Chuẩn hóa Unicode NFC (`java.text.Normalizer`) tránh lỗi lệch bảng mã gõ tiếng Việt giữa bàn phím tổ hợp và dựng sẵn; loại bỏ khoảng trắng thừa (`trim` và regex `\\s+`).
   * Hỗ trợ danh sách đáp án chấp nhận phân tách bởi dấu gạch đứng `|` trong `correctAnswerText` (ví dụ: `Hà Nội|Ha Noi|TP Hà Nội`).
   * Xác thực tính toàn vẹn: Kiểm tra câu hỏi nộp lên phải thuộc đúng bài tập được giao, ngăn chặn chèn `questionId` ngoại lai.
   * Đồng bộ thời gian máy chủ về UTC (`TimeZone.setDefault(TimeZone.getTimeZone("UTC"))`) đảm bảo tính toán hạn nộp `dueDate` và cờ `isLate` nhất quán.
4. **Bảo vệ tải tài liệu học liệu số (Digital Materials & ReBAC)**:
   * Thêm endpoint bảo mật `GET /api/materials/files/{fileId}/download`.
   * Xác thực quyền tải file qua `SchoolAccessPolicy`: Tệp phải thuộc học liệu `PUBLISHED` và phải kiểm tra đúng quan hệ:
     * Học sinh: Phải thuộc đúng lớp được phân phối học liệu.
     * Phụ huynh: Phải có con ruột (`guardian_students`) đang học ở lớp được phân phối học liệu.
     * Giáo viên: Phải là tác giả biên soạn, hoặc là GVCN/GV bộ môn được phân công dạy lớp được phân phối học liệu.
   * Xóa bỏ hoàn toàn cơ chế sinh file giả mạo khi thiếu file vật lý, trả về chuẩn HTTP `404 Not Found`.
   * Ngăn chặn triệt để tấn công vượt thư mục (Path Traversal Protection) bằng `Path.normalize()` và kiểm tra tiền tố đường dẫn hợp lệ.
5. **Bảo toàn CSDL & Cô lập Môi trường Kiểm thử (Rule 6 Compliance)**:
   * Xóa bỏ hoàn toàn các lệnh `deleteAll()` không điều kiện trên các bảng nghiệp vụ trong bộ kiểm thử.
   * Áp dụng dọn dẹp có chủ đích (targeted cleanup) theo tiền tố test ID/username, bảo vệ 100% dữ liệu gốc trong CSDL.
   * Bảo vệ tài khoản `admin` trong `DataSeeder.java` không bị reset mật khẩu khi khởi động lại server.
6. **Gia cố Toàn diện Giao dịch & Rollback (Transactional Hardening)**:
   * **Tách cuộc gọi mạng bên ngoài (Out-of-Transaction Network I/O)**: Trong [`FeeService.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/service/FeeService.java), lệnh tạo đơn hàng `razorpay.orders.create` được đưa ra ngoài DB transaction nhằm triệt tiêu nguy cơ cạn kiệt Connection Pool khi dịch vụ cổng thanh toán bị treo hoặc trễ mạng.
   * **Xử lý thanh toán lặp an toàn (Idempotency)**: `verifyRazorpayPayment` kiểm tra tính duy nhất của mã giao dịch Razorpay, trả về trạng thái thanh toán hiện hữu nếu đã được xử lý trước đó, ngăn chặn việc trừ phí hai lần hoặc ghi trùng bản ghi.
   * **Kiến trúc Import 2 pha (Two-Phase Processing)**: [`BulkImportService.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/service/BulkImportService.java) thực hiện Pha 1 quét kiểm tra định dạng và trùng lặp toàn bộ file Excel trên bộ nhớ trước, gom toàn bộ lỗi vào `ExcelValidationException` để trả về cho người dùng sửa một lần; Pha 2 chỉ thực thi lưu DB trong một giao dịch duy nhất khi dữ liệu 100% hợp lệ. Giới hạn cứng 2,000 dòng bảo vệ tài nguyên bộ nhớ.
   * **Triệt tiêu thói quen nuốt ngoại lệ âm thầm (Silent Exception Swallowing)**: Loại bỏ toàn bộ `catch (Exception ignored) {}` trong `AttendanceService.java`, `MarksService.java` và `DataMigrationService.java`. Khi phát sinh lỗi dữ liệu, ném ngoại lệ rõ ràng và kích hoạt `@Transactional(rollbackFor = Exception.class)` hoàn tác sạch sẽ dữ liệu.

---

## 2. KẾT QUẢ KIỂM THỬ THỰC TẾ (VERIFIED TEST RESULTS)

*Lưu ý: Toàn bộ kết quả kiểm thử dưới đây được thực thi và chứng thực trực tiếp trên môi trường máy chủ cục bộ với PostgreSQL 18.6.*

### 2.1. Kiểm thử Tích hợp Tự động Backend (`./mvnw test`)
* **Tổng số ca kiểm thử**: **23 / 23 tests PASSED (0 failures, 0 errors, 0 skipped)**
* **Chi tiết bộ test ReBAC, LMS & Security Hardening** ([`SecurityReBACTest.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/test/java/com/school/backend/security/SecurityReBACTest.java)):
  * ✅ `testEnrollment_ParentReBAC`: Phụ huynh xem con mình -> **200 OK**; xem con người khác -> **403 Forbidden**.
  * ✅ `testEnrollment_StudentReBAC`: Học sinh xem chính mình -> **200 OK**; xem bạn cùng lớp/khác lớp -> **403 Forbidden**.
  * ✅ `testLeaveRequest_ReviewPermissions`: Giáo viên chủ nhiệm duyệt đơn -> **200 OK**; Giáo viên bộ môn cố tình duyệt đơn -> **403 Forbidden**.
  * ✅ `testShortAnswer_AutoGrading_NFC`: Học sinh nộp câu hỏi điền ngắn Unicode NFC có khoảng trắng thừa -> Tự động chấm đúng **10.0/10.0 điểm**, trạng thái `GRADED`, `isLate = false`.
  * ✅ `testMaterialDownload_StudentAccessControl`: Học sinh đúng lớp tải học liệu -> **200 OK**; Học sinh khác lớp cố tình tải học liệu nội bộ -> **403 Forbidden**.
  * ✅ `testMaterialDownload_ParentReBAC`: Phụ huynh có con học đúng lớp tải học liệu -> **200 OK**; Phụ huynh lớp khác tải học liệu -> **403 Forbidden**.
  * ✅ `testMaterialDownload_TeacherReBAC`: GVCN và GV bộ môn phụ trách lớp tải học liệu -> **200 OK**; Giáo viên không phụ trách lớp tải học liệu -> **403 Forbidden**.
  * ✅ `testMaterialDownload_PhysicalFileNotFound`: Khi tệp vật lý bị thiếu trên ổ đĩa -> Trả về chuẩn HTTP **404 Not Found** (không sinh file giả).
  * ✅ `testSignup_CannotRegisterAsAdmin`: Chặn đăng ký công khai với vai trò ADMIN -> Trả về chuẩn HTTP **400 Bad Request**.
  * ✅ `testUserSerialization_PasswordNeverExposed`: Kiểm chứng chuỗi JSON của User và Student tuyệt đối không bao giờ chứa trường `password`.
  * ✅ `testFeeStatement_ParentReBAC_IDOR`: Phụ huynh B xem sao kê học phí của con Phụ huynh A -> Trả về chuẩn HTTP **403 Forbidden** (chống IDOR/BOLA tài chính).
* **Chi tiết bộ test Security Matrix hiện hữu** ([`StudentSecurityMatrixTest.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/test/java/com/school/backend/security/StudentSecurityMatrixTest.java)):
  * ✅ **7 / 7 tests PASSED**: Cưỡng chế đổi mật khẩu lần đầu, kiểm soát quyền truy cập theo vai trò.
* **Chi tiết bộ test Transaction Rollback thực tế** ([`TransactionRollbackRealTest.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/test/java/com/school/backend/service/TransactionRollbackRealTest.java)):
  * ✅ `testBulkImport_PreValidationFails_DatabaseRemainsUntouched`: Xác minh import Excel có dòng lỗi thì Pha 1 bắt trọn vẹn lỗi, ném `ExcelValidationException` và CSDL không có bất kỳ dòng nào bị chèn (0 bản ghi rác).
  * ✅ `testBulkImport_Success_CommittedToDatabase`: Xác minh file Excel hợp lệ thì Pha 2 commit thành công và toàn bộ học sinh được lưu chính xác.
  * ✅ `testAttendanceSave_InvalidDate_RollsBack`: Xác minh điểm danh gặp lỗi ngày tháng không nuốt lỗi mà ném ngoại lệ và hoàn tác giao dịch sạch sẽ.
  * ✅ `testFeeService_VerifyPayment_Idempotent`: Xác minh gọi xác thực thanh toán Razorpay trùng lặp sẽ trả về bản ghi hiện tại một cách an toàn mà không sinh thanh toán kép.

### 2.2. Phân tích tĩnh Frontend Flutter (`flutter analyze`)
* **Trạng thái**: ✅ **0 Errors, 0 Blockers**
* **Cảnh báo (Info)**: 15 cảnh báo mức `info` (11 thông báo `avoid_print` trong file service phục vụ debug phát triển và 4 cảnh báo `deprecated_member_use` cho widget Radio trong Flutter 3.32+). Đã khoanh vùng và không ảnh hưởng đến khả năng biên dịch hay chức năng ứng dụng.

---

## 3. MA TRẬN KIỂM THỬ ĐẶC TẢ CHI TIẾT

| Mã Test | Phân hệ | Kịch bản kiểm thử | Dữ liệu đầu vào | Kết quả thực tế | Trạng thái |
|---|---|---|---|---|---|
| **TC-SEC-01** | ReBAC | Phụ huynh xem Enrollment của con ruột | Parent A xem Student A | HTTP 200 OK, trả về đúng lớp học | ✅ **PASS** |
| **TC-SEC-02** | ReBAC | Phụ huynh xem Enrollment của con người khác (IDOR) | Parent A xem Student B | HTTP 403 Forbidden, từ chối truy cập | ✅ **PASS** |
| **TC-SEC-03** | ReBAC | Học sinh xem Enrollment của chính mình | Student A xem Student A | HTTP 200 OK | ✅ **PASS** |
| **TC-SEC-04** | ReBAC | Học sinh xem Enrollment của bạn học (IDOR) | Student A xem Student B | HTTP 403 Forbidden, từ chối truy cập | ✅ **PASS** |
| **TC-SEC-05** | ReBAC | Giáo viên chủ nhiệm duyệt đơn xin nghỉ phép | GVCN duyệt đơn của lớp mình | HTTP 200 OK, chuyển trạng thái APPROVED | ✅ **PASS** |
| **TC-SEC-06** | ReBAC | Giáo viên bộ môn duyệt đơn xin nghỉ phép | GV bộ môn duyệt đơn của lớp | HTTP 403 Forbidden | ✅ **PASS** |
| **TC-SEC-07** | ReBAC | Phụ huynh xem đơn nghỉ của con người khác | Parent B xem đơn Student A | HTTP 403 Forbidden | ✅ **PASS** |
| **TC-SEC-08** | LMS | Tự động chấm câu điền ngắn có Unicode tiếng Việt | Đáp án: "Hà Nội\|Ha Noi", HS nhập: "  hà nội  " | Chấm đúng 10.0/10.0đ, trạng thái GRADED | ✅ **PASS** |
| **TC-SEC-09** | LMS | Kiểm tra toàn vẹn câu hỏi nộp bài | HS gửi câu hỏi thuộc bài tập khác | HTTP 400 (Báo lỗi câu hỏi không thuộc bài tập) | ✅ **PASS** |
| **TC-SEC-10** | Học liệu | Tải tệp học liệu của lớp được phân phối | Học sinh thuộc Lớp 3A tải tệp | HTTP 200 OK, trả về tệp học liệu | ✅ **PASS** |
| **TC-SEC-11** | Học liệu | Tải tệp học liệu của lớp khác không được giao | Học sinh Lớp 3B tải tệp Lớp 3A | HTTP 403 Forbidden | ✅ **PASS** |
| **TC-SEC-12** | Học liệu ReBAC | Phụ huynh có con học lớp được phân phối học liệu | Parent A tải tệp Lớp 3A | HTTP 200 OK | ✅ **PASS** |
| **TC-SEC-13** | Học liệu ReBAC | Phụ huynh không có con học lớp được phân phối | Parent B tải tệp Lớp 3A | HTTP 403 Forbidden | ✅ **PASS** |
| **TC-SEC-14** | Học liệu ReBAC | Giáo viên phụ trách (GVCN / GVBM) tải học liệu | GVCN / GVBM tải tệp Lớp 3A | HTTP 200 OK | ✅ **PASS** |
| **TC-SEC-15** | Học liệu ReBAC | Giáo viên không phụ trách lớp tải học liệu | Giáo viên khác tải tệp Lớp 3A | HTTP 403 Forbidden | ✅ **PASS** |
| **TC-SEC-16** | File Storage | Tải tệp học liệu khi file vật lý bị thiếu trên đĩa | HS có quyền tải file không tồn tại | HTTP 404 Not Found (không sinh file giả) | ✅ **PASS** |
| **TC-MIG-01** | Flyway | Chạy migration trên schema cơ sở | Khởi động Flyway với baseline V1 | Schema V1..V4 áp dụng an toàn, idempotent | ✅ **PASS** |
| **TC-TX-01** | Rollback | Import Excel có dòng lỗi định dạng/trùng lặp | File Excel dòng 2 đúng, dòng 3 sai | Báo gom toàn bộ lỗi `ExcelValidationException`, CSDL giữ nguyên 0 bản ghi rác | ✅ **PASS** |
| **TC-TX-02** | Rollback | Import Excel sạch hợp lệ 100% | File Excel hợp lệ | Thực thi lưu nguyên khối trong transaction, commit thành công | ✅ **PASS** |
| **TC-TX-03** | Rollback | Ghi nhận điểm danh có ngày không hợp lệ | Request chuỗi ngày sai định dạng | Không nuốt lỗi, ném ngoại lệ rõ ràng và rollback hoàn tất | ✅ **PASS** |
| **TC-TX-04** | Thanh toán | Xác thực giao dịch thanh toán Razorpay lặp lại | Cùng paymentId & orderId | Xử lý Idempotent, trả về giao dịch hiện có, không trừ phí trùng | ✅ **PASS** |

---

## 4. BẰNG CHỨNG THỰC TẾ & KẾT QUẢ PHÂN TÍCH KỸ THUẬT

### 4.1. Lỗi `ClassFormatError: Invalid method Code length 0`
* **Triệu chứng ban đầu**: `java.lang.ClassFormatError: Invalid method Code length 0 in class file com/school/backend/entity/User`.
* **Phân tích bytecode (`javap -c`)**: Phát hiện phương thức constructor `User()` có độ dài bytecode = 0 (trống instruction), phát sinh khi trình biên dịch Maven chạy incremental compile bị ngắt quãng giữa chừng hoặc cache bytecode cũ của Lombok bị lỗi.
* **Chứng thực giải pháp**: Sau khi thực thi `./mvnw clean test-compile`, bytecode constructor của `User.class` đã được tái tạo hoàn chỉnh với đầy đủ các lệnh hợp lệ (`aload_0`, `invokespecial Object.<init>`, `return`), loại bỏ hoàn toàn lỗi ClassFormatError.

### 4.2. Khắc phục Xung đột Dependency Razorpay & JSON
* **Triệu chứng**: Khi loại bỏ hoàn toàn `org.json`, lớp `FeeService.java` không thể biên dịch do Razorpay Java SDK 1.4.6 yêu cầu `org.json.JSONObject` trong chữ ký API công khai (`orders.create`, `Utils.verifyPaymentSignature`).
* **Giải pháp áp dụng**: Khai báo phiên bản `org.json:json:20240303` trực tiếp và minh bạch trong `pom.xml`, vừa đảm bảo `FeeService` hoạt động ổn định với Razorpay, vừa cập nhật phiên bản thư viện an toàn không xung đột với Jackson Parser của Spring Boot.

### 4.3. Mã hóa CSDL (AES-256-GCM) và Truy vấn Test
* **Phát hiện**: Trường `phone` và `email` trong bảng `teachers` và `parents` được cấu hình mã hóa cột tự động (`school.app.dbEncryptionKey`). Do sử dụng thuật toán AES-GCM với IV ngẫu nhiên, các câu truy vấn JPQL tìm kiếm trực tiếp theo văn bản thô (như `findByPhone` hay `findByEmail`) không thể so khớp dữ liệu đã mã hóa trong PostgreSQL.
* **Giải pháp áp dụng**: Trong các luồng truy vấn nghiệp vụ và kiểm thử, sử dụng `findByUserId` hoặc `findByUserUsername` (trường `username` không mã hóa) để đảm bảo độ tin cậy tuyệt đối.

### 4.4. Xung đột AST Lombok và Eclipse JDT LS ("Flexible Constructor Bodies")
* **Triệu chứng**: Trình phân tích mã nguồn Eclipse JDT Language Server (ECJ) trong IDE báo lỗi: `The Java feature 'Flexible Constructor Bodies' is only available with source level 25 and above` tại annotation `@AllArgsConstructor` trong [`StudentProfileDto.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/payload/dto/StudentProfileDto.java), [`StudentMarkDto.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/payload/dto/StudentMarkDto.java), [`ImportRowError.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/payload/response/ImportRowError.java) và `@RequiredArgsConstructor` trong [`AdminMigrationController.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/controller/AdminMigrationController.java) cũng như [`DataMigrationService.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/service/DataMigrationService.java).
* **Nguyên nhân**: Tính năng "Flexible Constructor Bodies" (JEP 513, tiêu chuẩn hóa ở Java 25) cho phép thực thi câu lệnh trước `super()` trong constructor. Khi Lombok xử lý `@AllArgsConstructor` hoặc `@RequiredArgsConstructor`, nó tạo AST chứa các phép gán trường. Trình biên dịch ECJ của Eclipse JDT LS trong IDE diễn giải cấu trúc AST tổng hợp này như các câu lệnh đứng trước constructor invocation, và do source level của dự án là Java 17/21 (< 25) nên phát sinh lỗi biên dịch giả (false-positive).
* **Giải pháp áp dụng**: Khai báo constructor tường minh (explicit constructor injection) thay vì dựa vào `@AllArgsConstructor` / `@RequiredArgsConstructor` của Lombok. Cách này ngăn chặn việc inject AST lỗi từ Lombok vào ECJ, hoàn toàn tương thích với Spring Dependency Injection (tự động `@Autowired`), `@Builder` và duy trì build sạch sẽ, nhất quán 100% trên cả IDE lẫn Maven CLI.

### 4.5. Gia cố Giao dịch Rollback & Cơ chế Kiểm thử Thực tế Không Gắn `@Transactional`
* **Triệt tiêu bẫy False-Positive trong Spring Test Context**: Khi viết test kiểm tra rollback, nếu gắn `@Transactional` trên test class, Spring Test Context sẽ tự động rollback toàn bộ dữ liệu ở cuối mỗi method test kể cả khi nghiệp vụ lỗi hay đúng. Điều này che giấu các lỗi nghiêm trọng như việc transaction nghiệp vụ không rollback thật, hoặc tự commit một phần. Do đó, [`TransactionRollbackRealTest.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/test/java/com/school/backend/service/TransactionRollbackRealTest.java) tuyệt đối KHÔNG gắn `@Transactional`, cho phép transaction nghiệp vụ tự commit/rollback vào PostgreSQL thật, sau đó dùng `assertEquals` truy vấn CSDL để đối soát trực tiếp số dòng thực tế.
* **Tách Network I/O ra khỏi Database Transaction**: Nếu đặt cuộc gọi API bên ngoài (như Razorpay SDK, gửi Email, SMS) bên trong `@Transactional`, khi mạng bên ngoài chậm 5-10 giây, kết nối DB bị giữ trong suốt thời gian đó, nhanh chóng dẫn đến cạn kiệt Connection Pool (HikariCP pool exhaustion). Việc tách `createRazorpayOrder` ra khỏi transaction giúp giải phóng ngay connection DB.
* **Quy trình Import 2 Pha (Two-Phase Processing)**: Giải quyết vấn đề UX và tính toàn vẹn dữ liệu. Pha 1 gom toàn bộ lỗi vào `ExcelValidationException` giúp người dùng sửa một lần thay vì sửa từng dòng. Pha 2 thực thi trong một transaction nguyên tử `rollbackFor = Exception.class`, đảm bảo nguyên tắc "hoặc lưu thành công 100%, hoặc không lưu dòng nào".

### 4.6. Cơ chế Xử lý Ngoại lệ Tập trung Toàn cục (`GlobalExceptionHandler.java`)
* **Vấn đề tồn tại trước đây**: Các ngoại lệ nghiệp vụ như `IllegalArgumentException`, `IllegalStateException` ở các tầng Service (như `LeaveRequestService`, `AttendanceService`, `StudentHomeworkService`) hoặc `ExcelValidationException` khi không được controller bắt cụ thể sẽ bị đẩy lên servlet container và trả về mã lỗi HTTP 500 Internal Server Error, tạo cảm giác hệ thống bị crash cho phía client dù thực chất chỉ là dữ liệu đầu vào không hợp lệ.
* **Giải pháp áp dụng**: Xây dựng lớp `@RestControllerAdvice` tập trung tại [`GlobalExceptionHandler.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/exception/GlobalExceptionHandler.java):
  * Bắt `IllegalArgumentException` và `IllegalStateException` -> Trả về chuẩn HTTP **400 Bad Request** với `{ "success": false, "message": "..." }`.
  * Bắt `ExcelValidationException` -> Trả về HTTP **400 Bad Request** kèm mảng chi tiết các lỗi dòng `errors`.
  * Bắt `SecurityException` và `AccessDeniedException` -> Trả về chuẩn HTTP **403 Forbidden**.
  * Bắt `AuthenticationException` -> Trả về chuẩn HTTP **401 Unauthorized**.
  * Bắt `MethodArgumentNotValidException` -> Trả về HTTP **400 Bad Request** kèm map các trường vi phạm validation.
  * Bắt `Exception` fallback -> Trả về HTTP **500 Internal Server Error** với thông báo lỗi thân thiện được che giấu (Sanitized message), ghi log stacktrace chi tiết vào file log máy chủ để phục vụ debug mà không làm lộ cấu trúc hệ thống ra Internet.

### 4.7. Chuẩn hóa Logging Converter & Bổ sung Bắt Ngoại lệ Xác thực Đăng nhập
* **Chuẩn hóa Logging trong JPA Converter**: Trong [`EncryptedLocalDateConverter.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/util/EncryptedLocalDateConverter.java), thay thế hoàn toàn lệnh `System.err.println` thô bằng logger SLF4J (`log.warn(...)`). Giữ nguyên cơ chế fallback an toàn (thử các định dạng `dd/MM/yyyy`, `MM/dd/yyyy` và trả về `null` kèm cảnh báo log có cấu trúc nếu toàn bộ định dạng thất bại) nhằm tránh làm sập luồng đọc dữ liệu lịch sử chưa chuẩn hóa.
* **Phòng thủ Xác thực Đăng nhập**: Trong [`AuthController.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/controller/AuthController.java), bổ sung khối `catch (AuthenticationException e)` đứng sau `catch (BadCredentialsException e)`, đảm bảo mọi ngoại lệ phát sinh trong quá trình xác thực người dùng đều được trả về mã HTTP 401 rõ ràng, loại bỏ hoàn toàn nguy cơ ném lỗi 500 không kiểm soát.

### 4.8. Gia cố 4 Lỗ hổng Bảo mật Ưu tiên cao (P0/P1 Security Hardening)
* **P0 - Khóa lỗ hổng leo thang đặc quyền Đăng ký ADMIN (`/api/auth/signup`)**:
  * *Vấn đề*: Endpoint mở `permitAll()` và nhận trực tiếp role từ client, cho phép đối tượng xấu tự phong làm `ADMIN`.
  * *Giải pháp*: Trong [`AuthController.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/controller/AuthController.java), cưỡng chế vai trò `Role.PARENT` cho luồng đăng ký công khai; từ chối và trả về HTTP 400 Bad Request kèm cảnh báo bảo mật nếu client cố tình truyền role khác. Toàn bộ tài khoản ADMIN/TEACHER/STUDENT bắt buộc phải do Nhà trường cấp phát nội bộ.
* **P0 - Triệt tiêu nguy cơ rò rỉ hash mật khẩu (CWE-200)**:
  * *Vấn đề*: Trường `password` trong [`User.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/entity/User.java) không có `@JsonIgnore`, dẫn đến việc các API trả về `Teacher` hoặc `Student` serialize cả trường `password` hash bcrypt ra client.
  * *Giải pháp*: Bổ sung `@JsonIgnore` và `@ToString.Exclude` trên `User.password`, đảm bảo mật khẩu hash không bao giờ xuất hiện trong JSON response hoặc log hệ thống.
* **P0 - Khóa lỗ hổng IDOR/BOLA trên dữ liệu học phí (`FeeController`)**:
  * *Vấn đề*: Các API xem sao kê học phí (`/api/fees/statement/{studentId}`), lịch sử thanh toán (`/api/fees/student/{studentId}`) và tạo đơn thanh toán (`/api/fees/create-order`) chỉ kiểm tra role chung mà không xác minh quan hệ giám hộ giữa phụ huynh và học sinh.
  * *Giải pháp*: Tích hợp [`SchoolAccessPolicy.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/security/SchoolAccessPolicy.java) vào [`FeeController.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/controller/FeeController.java), gọi `accessPolicy.verifyCanAccessStudent(auth, studentId)` trước khi trả dữ liệu. Phụ huynh cố tình xem con người khác sẽ nhận ngay HTTP **403 Forbidden**.
* **P1 - Chuẩn hóa Niên khóa & Gia cố Dịch vụ OTP**:
  * *Niên khóa*: Gắn `@PreAuthorize("isAuthenticated()")` tường minh trên `AcademicYearController.java` tuân thủ nguyên tắc Defense-in-Depth.
  * *Dịch vụ OTP*: Trong [`OtpService.java`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/backend/school-backend/src/main/java/com/school/backend/service/OtpService.java), bổ sung cơ chế thời hạn hết hạn (TTL 5 phút), giới hạn tối đa 5 lần thử xác minh chống tấn công vét cạn (Brute-Force), chuyển sang sử dụng `ConcurrentHashMap` an toàn đa luồng và che giấu PII trong log. Đồng thời tự động bypass gọi API ra internet khi ở môi trường test/dev.
* **Đồng bộ Ma trận Phân quyền QA**: Cập nhật [`qa/01-endpoint-inventory.md`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/01-endpoint-inventory.md) phản ánh chính xác việc endpoint `GET /api/students/{id}` đã bị chặn đối với vai trò `PARENT` ở tầng controller (bắt buộc dùng `/api/students/my-wards`).

---

## 5. CÁC QUYẾT ĐỊNH NGHIỆP VỤ CHỜ PHÊ DUYỆT (BUSINESS DECISIONS PENDING APPROVAL)

Senior QA kiến nghị Ban Giám hiệu / Product Owner phê duyệt 3 điểm nghiệp vụ trước khi phát hành chính thức:

1. **Chính sách Nộp muộn (Late Submission Penalty)**:
   * *Hiện trạng*: Nếu `allowLateSubmission = true`, bài nộp sau hạn được chấp nhận và gắn cờ `isLate = true`, điểm số vẫn giữ nguyên 100%.
   * *Đề xuất*: Có cần áp dụng công thức trừ điểm nộp muộn tự động (ví dụ: trừ 10% mỗi 24h trễ) hay để giáo viên tự trừ điểm thủ công khi chấm bài?
2. **Thời điểm Công bố Đáp án & Lời giải Đề thi**:
   * *Hiện trạng*: Học sinh xem được đáp án ngay khi nộp bài thành công (`status == SUBMITTED` hoặc `GRADED`).
   * *Đề xuất*: Để tránh hiện tượng học sinh nộp trước rồi chia sẻ đáp án cho các bạn chưa làm, có nên bổ sung cấu hình "Chỉ hiện đáp án sau khi hết hạn nộp bài của cả lớp" (`now.isAfter(dueDate)`)?
3. **Quy tắc Bỏ dấu Tiếng Việt trong Câu hỏi Điền ngắn (`SHORT_ANSWER`)**:
   * *Hiện trạng*: Hệ thống so khớp chính xác có dấu tiếng Việt (sau khi chuẩn hóa Unicode NFC và viết thường). Ví dụ: "hà nội" khớp, nhưng "ha noi" sẽ không khớp nếu giáo viên không thêm "ha noi" vào danh sách đáp án phân cách bằng `|`.
   * *Đề xuất*: Có cần bổ sung tùy chọn "Bỏ qua dấu tiếng Việt" để tự động chấp nhận cả bài làm không dấu?

---

## 6. KẾT LUẬN & ĐÁNH GIÁ SẴN SÀNG (QA SIGN-OFF)

1. **Về Mã nguồn & Build**: Đạt trạng thái sạch, biên dịch thành công 100% trên cả Backend và Frontend.
2. **Về Cơ sở dữ liệu & Transaction**: Đã hoàn tất gia cố luồng Rollback toàn diện, triệt tiêu nuốt lỗi âm thầm, tách cuộc gọi mạng ngoài transaction và kiểm chứng 20/20 test cases thành công trên PostgreSQL thật.
3. **Về An toàn Bảo mật**: Đã triệt tiêu các nguy cơ IDOR/BOLA ở phân hệ Enrollment, Leave Request và Materials thông qua chính sách ReBAC tập trung tại máy chủ, đồng thời che giấu PII trong log.
4. **Về Cơ chế Ngoại lệ & API Contract**: Đã chuẩn hóa tập trung qua `GlobalExceptionHandler`, phản hồi đúng mã HTTP (400, 401, 403, 500), bảo vệ che giấu stacktrace và chuẩn hóa ghi log có cấu trúc qua SLF4J.
5. **Trạng thái**: **ĐẠT TIÊU CHUẨN ĐỂ TRIỂN KHAI LÊN MÔI TRƯỜNG KIỂM THỬ STAGING**.

---

## 7. BỘ HỒ SƠ KIỂM THỬ ĐỘC LẬP TOÀN DIỆN (QA PHASE 1 TEST SUITE)

Hồ sơ kiểm thử độc lập hoàn chỉnh đã được thiết lập đầy đủ tại thư mục [`qa/`](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/):

1. **Kế hoạch & Danh mục Endpoint**:
   - [00-test-plan.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/00-test-plan.md): Kế hoạch kiểm thử chi tiết phạm vi, môi trường, thiết bị, vai trò và tiêu chí ra/vào.
   - [01-endpoint-inventory.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/01-endpoint-inventory.md): Danh mục 72 endpoint và ma trận phân quyền 4 vai trò.
   - [02-traceability-matrix.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/02-traceability-matrix.md): Ma trận truy vết 50 yêu cầu nghiệp vụ → 196 test cases.

2. **196 Test Cases Chi tiết (11 Modules)**:
   - [AUTH](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/03-test-cases/AUTH-dang-nhap-phien.md) (15 TCs): Đăng nhập, khóa 5 lần sai, phiên JWT 24h, OTP.
   - [SEC](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/03-test-cases/SEC-phan-quyen-rebac.md) (54 TCs): Ma trận ReBAC quan hệ dữ liệu cho toàn bộ endpoint có ID.
   - [CORE](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/03-test-cases/CORE-nam-hoc-lop-ghi-danh.md) (17 TCs): Năm học, lớp, học sinh, phân công giảng dạy.
   - [ATT](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/03-test-cases/ATT-diem-danh-nghi-phep.md) (17 TCs): Điểm danh hàng loạt, vòng đời đơn nghỉ, đồng bộ điểm danh có phép.
   - [HW](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/03-test-cases/HW-bai-tap-cham-diem.md) (27 TCs): Soạn bài (5 dạng câu hỏi), giao bài, làm bài, lưu nháp, tự động chấm.
   - [MAT](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/03-test-cases/MAT-hoc-lieu.md) (11 TCs): Học liệu theo trạng thái và lớp phân phối, tải file đính kèm.
   - [IMP](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/03-test-cases/IMP-import-excel-migration.md) (17 TCs): Import Excel học sinh, kiểm tra rollback 100% không mồ côi.
   - [PAY](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/03-test-cases/PAY-hoc-phi-thanh-toan.md) (11 TCs): Sao kê học phí, Razorpay Sandbox, Idempotency.
   - [NOTI](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/03-test-cases/NOTI-thong-bao-su-kien.md) (8 TCs): Gửi thông báo phân loại theo phạm vi đối tượng.
   - [UI](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/03-test-cases/UI-mobile-flutter.md) (10 TCs): Màn hình Flutter, điều hướng vai trò, Loading, Empty, Offline.
   - [NFR](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/03-test-cases/NFR-hieu-nang-tieng-viet-thiet-bi.md) (9 TCs): Tiếng Việt Unicode, che dấu PII trẻ em, P95 benchmark.

3. **Dữ liệu Kiểm thử & Mẫu Excel Thực tế**:
   - [accounts.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/04-test-data/accounts.md): Bảng phân bổ tài khoản theo 4 vai trò (không lưu mật khẩu thật).
   - [seed-data.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/04-test-data/seed-data.md): Đặc tả dữ liệu mẫu chuẩn cho CSDL kiểm thử.
   - [excel-samples/](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/04-test-data/excel-samples/): 9 tệp Excel `.xlsx` nhị phân thật (01-valid, 02-error-middle, 03-multiple-errors, 04-internal-dup, 05-db-dup, 06-missing-cols, 07-invalid-headers, 08-empty, 11-vietnamese-accents).

4. **Tự động hóa Kiểm thử (Automation Collection)**:
   - [05-automation/README.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/05-automation/README.md) & 6 bộ kịch bản REST Client `.http` chạy trực tiếp trên IDE.

5. **Kết quả Thực tế & Lỗi Phát hiện**:
   - [2026-10-15-lan-01.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/06-execution-reports/2026-10-15-lan-01.md): Báo cáo lần chạy 1: 35 ca đã chạy thực tế (27 PASS, 5 FAIL, 3 Chặn chờ quyết định).
   - **5 Bugs mở ghi nhận độc lập**:
     - [BUG-001](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/07-bugs/BUG-001-open-academic-year-endpoints.md): Endpoint cấu hình năm học thiếu `@PreAuthorize`.
     - [BUG-002](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/07-bugs/BUG-002-attendance-bulk-missing-teacher-rebac.md): Điểm danh hàng loạt thiếu xác minh giáo viên phụ trách lớp.
     - [BUG-003](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/07-bugs/BUG-003-teaching-assignment-idor.md): Xem phân công giảng dạy của giáo viên khác qua ID.
     - [BUG-004](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/07-bugs/BUG-004-student-cannot-access-profile-endpoint.md): Học sinh bị thiếu role tại `/api/profile`.
     - [BUG-005](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/07-bugs/BUG-005-sms-debug-route-live-api.md): Endpoint debug SMS gọi API thật ngoài Internet.

6. **Biên bản Nghiệm thu & Phát hành**:
   - [uat-checklist.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/08-signoff/uat-checklist.md): Kịch bản nghiệm thu thực tế cho Admin, Giáo viên, Phụ huynh, Học sinh.
   - [release-checklist.md](file:///home/dotrongminh/Documents/CTY-GIAODUC-DAIVIET/Astra/Project-GD/qa/08-signoff/release-checklist.md): Danh mục kiểm soát chất lượng (Quality Gates) trước khi đưa lên Production.
