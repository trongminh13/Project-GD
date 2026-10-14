# Mối quan hệ dữ liệu của ứng dụng giáo dục (Phase 1)

Tài liệu này mô tả các thực thể và mọi mối quan hệ giữa chúng: một-một (1–1), một-nhiều (1–N) và nhiều-nhiều (N–N). Nó dựa trên spec UI/UX Phase 1, demo hiện có (Phụ huynh, Giáo viên, Học sinh, School Admin) và kế hoạch vai trò Học sinh.

Đây là mô hình khái niệm để thống nhất cách hiểu trước khi thiết kế cơ sở dữ liệu. Tên bảng, kiểu dữ liệu và công nghệ lưu trữ chưa được chốt vì nhóm chưa cho biết stack. Mục 7 liệt kê những điểm cần xác nhận.

## 1. Cách đọc ký hiệu

| Ký hiệu | Ý nghĩa |
| --- | --- |
| 1–1 | Mỗi bản ghi bên này khớp đúng một bản ghi bên kia |
| 1–N | Một bản ghi bên trái có nhiều bản ghi bên phải, mỗi bản ghi bên phải chỉ thuộc một bên trái |
| N–N | Hai bên đều có thể có nhiều bản ghi bên kia; cần một **bảng nối** ở giữa |
| FK | Khóa ngoại (trỏ sang bảng khác) |
| UQ | Ràng buộc duy nhất (không được trùng) |

## 2. Sơ đồ tổng thể (ER)

```mermaid
erDiagram
    SCHOOL ||--o{ ACADEMIC_YEAR : "có"
    SCHOOL ||--o{ USER : "quản lý"
    SCHOOL ||--o{ ROOM : "có"
    SCHOOL ||--o{ SUBJECT : "dạy"

    USER ||--o| STUDENT : "hồ sơ học sinh"
    USER ||--o| TEACHER : "hồ sơ giáo viên"
    USER ||--o| GUARDIAN : "hồ sơ phụ huynh"
    USER ||--o{ USER_ROLE : "được gán"
    ROLE ||--o{ USER_ROLE : "gồm"

    GUARDIAN ||--o{ GUARDIAN_STUDENT : "liên kết"
    STUDENT ||--o{ GUARDIAN_STUDENT : "liên kết"

    ACADEMIC_YEAR ||--o{ CLASS : "gồm"
    TEACHER ||--o{ CLASS : "chủ nhiệm"
    CLASS ||--o{ ENROLLMENT : "có"
    STUDENT ||--o{ ENROLLMENT : "học trong"

    TEACHER ||--o{ TEACHING_ASSIGNMENT : "được phân công"
    CLASS ||--o{ TEACHING_ASSIGNMENT : "có"
    SUBJECT ||--o{ TEACHING_ASSIGNMENT : "thuộc"

    CLASS ||--o{ LESSON_SLOT : "có tiết"
    SUBJECT ||--o{ LESSON_SLOT : "môn"
    TEACHER ||--o{ LESSON_SLOT : "dạy"
    ROOM ||--o{ LESSON_SLOT : "tại"

    CLASS ||--o{ ATTENDANCE_SESSION : "có buổi điểm danh"
    ATTENDANCE_SESSION ||--o{ ATTENDANCE_RECORD : "gồm"
    STUDENT ||--o{ ATTENDANCE_RECORD : "được ghi"
    LEAVE_REQUEST |o--o{ ATTENDANCE_RECORD : "giải thích"

    STUDENT ||--o{ LEAVE_REQUEST : "nghỉ"
    GUARDIAN ||--o{ LEAVE_REQUEST : "gửi"
    TEACHER |o--o{ LEAVE_REQUEST : "duyệt"

    ANNOUNCEMENT ||--o{ ANNOUNCEMENT_TARGET : "gửi tới"
    ANNOUNCEMENT ||--o{ ANNOUNCEMENT_READ : "được đọc"
    USER ||--o{ ANNOUNCEMENT_READ : "đọc"
    EVENT ||--o{ EVENT_TARGET : "gửi tới"

    SUBJECT ||--o{ MATERIAL : "có"
    TEACHER ||--o{ MATERIAL : "soạn"
    MATERIAL ||--o{ MATERIAL_FILE : "có phiên bản"
    MATERIAL ||--o{ MATERIAL_CLASS : "xuất bản cho"
    CLASS ||--o{ MATERIAL_CLASS : "nhận"
    MATERIAL ||--o{ MATERIAL_REVIEW : "được duyệt"

    HOMEWORK ||--o{ QUESTION : "gồm"
    QUESTION ||--o{ QUESTION_OPTION : "có lựa chọn"
    HOMEWORK ||--o{ HOMEWORK_ASSIGNMENT : "giao"
    CLASS ||--o{ HOMEWORK_ASSIGNMENT : "nhận"
    HOMEWORK_ASSIGNMENT ||--o{ SUBMISSION : "có bài làm"
    STUDENT ||--o{ SUBMISSION : "làm"
    SUBMISSION ||--o{ ANSWER : "gồm"
    QUESTION ||--o{ ANSWER : "được trả lời"
    ANSWER ||--o{ ANSWER_OPTION : "chọn"
    QUESTION_OPTION ||--o{ ANSWER_OPTION : "được chọn"

    USER ||--o{ NOTIFICATION : "nhận"
    USER ||--o{ DEVICE_TOKEN : "có thiết bị"
    USER ||--o{ AUDIT_LOG : "thực hiện"
```

## 3. Các thực thể

| Thực thể | Là gì | Trường chính (khái niệm) |
| --- | --- | --- |
| SCHOOL | Nhà trường (một trường hoặc một tenant) | tên, mã |
| ACADEMIC_YEAR | Năm học | trường, tên (2026–2027), ngày bắt đầu, ngày kết thúc |
| USER | Tài khoản đăng nhập | tên đăng nhập hoặc số điện thoại, mật khẩu băm, trạng thái |
| ROLE | Vai trò | Phụ huynh, Giáo viên, Học sinh, School Admin, Content Admin |
| STUDENT | Hồ sơ học sinh | họ tên, ngày sinh, mã học sinh |
| TEACHER | Hồ sơ giáo viên | họ tên, bộ môn |
| GUARDIAN | Hồ sơ phụ huynh | họ tên, số điện thoại |
| CLASS | Lớp trong một năm học | tên (3A), khối, năm học, giáo viên chủ nhiệm |
| SUBJECT | Môn học | tên (Toán, Tiếng Việt…) |
| ROOM | Phòng học | tên (P.201), loại |
| LESSON_SLOT | Một tiết trong thời khóa biểu | lớp, môn, giáo viên, phòng, thứ, tiết, giờ |
| ATTENDANCE_SESSION | Một buổi điểm danh của lớp | lớp, ngày, tiết, người gửi, thời điểm gửi |
| ATTENDANCE_RECORD | Trạng thái của một học sinh trong buổi đó | trạng thái (Có mặt, Vắng, Muộn, Có phép), ghi chú |
| LEAVE_REQUEST | Đơn nghỉ phép | học sinh, người gửi, ngày bắt đầu, ngày kết thúc, lý do, trạng thái |
| ANNOUNCEMENT | Thông báo | tiêu đề, nội dung, ngày đăng |
| EVENT | Sự kiện | tên, ngày giờ, địa điểm, mô tả |
| MATERIAL | Học liệu | môn, người soạn, tiêu đề, trạng thái (Nháp, Chờ duyệt, Đã xuất bản) |
| MATERIAL_FILE | Tệp của học liệu theo phiên bản | tệp gốc, tệp PDF đã chuyển, số trang |
| HOMEWORK | Nội dung bài tập (dùng lại được) | môn, người soạn, tiêu đề, ghi chú |
| QUESTION | Câu hỏi của bài tập | dạng (một đáp án, nhiều đáp án, đúng/sai, điền ngắn, tự luận), nội dung, điểm, đáp án đúng |
| QUESTION_OPTION | Lựa chọn của câu trắc nghiệm | nội dung, đúng hay sai |
| HOMEWORK_ASSIGNMENT | Việc giao một bài tập cho một lớp | bài, lớp, hạn nộp |
| SUBMISSION | Bài làm của một học sinh | trạng thái (Đang làm, Đã nộp), thời điểm nộp, điểm tự chấm, điểm cuối |
| ANSWER | Câu trả lời của một học sinh cho một câu | câu hỏi, nội dung trả lời, điểm, ghi chú giáo viên |
| NOTIFICATION | Thông báo đẩy hoặc trong ứng dụng gửi tới một người | loại, nội dung, đã đọc |
| DEVICE_TOKEN | Thiết bị đăng ký nhận thông báo đẩy | nền tảng, mã thiết bị |
| AUDIT_LOG | Nhật ký thao tác nhạy cảm | ai, làm gì, trên bản ghi nào, lúc nào |

## 4. Mối quan hệ 1–1

| Quan hệ | Giải thích | Ràng buộc |
| --- | --- | --- |
| USER ↔ STUDENT | Tài khoản học sinh có đúng một hồ sơ học sinh | `student.user_id` UQ, có thể trống nếu học sinh chưa có tài khoản |
| USER ↔ TEACHER | Tài khoản giáo viên có đúng một hồ sơ giáo viên | `teacher.user_id` UQ |
| USER ↔ GUARDIAN | Tài khoản phụ huynh có đúng một hồ sơ phụ huynh | `guardian.user_id` UQ |
| SUBMISSION ↔ điểm cuối | Mỗi bài làm có một tổng điểm (tự chấm cộng điểm tự luận) | Lưu thành trường của SUBMISSION, không cần bảng riêng |
| ANSWER ↔ điểm chấm tay | Mỗi câu tự luận có tối đa một điểm do giáo viên chấm | Trường của ANSWER |

Một người vừa là giáo viên vừa là phụ huynh (có con học cùng trường) có **một** USER nhưng **hai** hồ sơ (TEACHER và GUARDIAN) và hai dòng trong USER_ROLE. Vì vậy USER ↔ hồ sơ là 1–1 theo từng loại, không phải 1–1 tuyệt đối.

## 5. Mối quan hệ 1–N

| Bên 1 | Bên N | Khóa ngoại | Ghi chú |
| --- | --- | --- | --- |
| SCHOOL | ACADEMIC_YEAR | `academic_year.school_id` | |
| SCHOOL | USER, ROOM, SUBJECT | `school_id` | Mọi truy vấn lọc theo trường |
| ACADEMIC_YEAR | CLASS | `class.academic_year_id` | Lớp 3A năm nay và lớp 3A năm sau là hai bản ghi khác nhau |
| TEACHER | CLASS (chủ nhiệm) | `class.homeroom_teacher_id` | Mỗi lớp có một giáo viên chủ nhiệm; một giáo viên chủ nhiệm tối đa một lớp mỗi năm học (UQ theo năm) |
| CLASS | LESSON_SLOT | `lesson_slot.class_id` | UQ (lớp, thứ, tiết) |
| SUBJECT, TEACHER, ROOM | LESSON_SLOT | `subject_id`, `teacher_id`, `room_id` | UQ (giáo viên, thứ, tiết) và UQ (phòng, thứ, tiết) để không trùng lịch |
| CLASS | ATTENDANCE_SESSION | `class_id` | UQ (lớp, ngày, tiết) |
| ATTENDANCE_SESSION | ATTENDANCE_RECORD | `session_id` | UQ (buổi, học sinh) |
| STUDENT | ATTENDANCE_RECORD | `student_id` | Phụ huynh xem lịch sử điểm danh qua quan hệ này |
| STUDENT | LEAVE_REQUEST | `student_id` | Một học sinh có nhiều đơn nghỉ |
| GUARDIAN | LEAVE_REQUEST (người gửi) | `submitted_by_guardian_id` | |
| TEACHER | LEAVE_REQUEST (người duyệt) | `reviewed_by_teacher_id` | Trống khi đơn đang chờ |
| LEAVE_REQUEST | ATTENDANCE_RECORD | `attendance_record.leave_request_id` | Trống nếu không có đơn. Khi đơn được duyệt, bản ghi điểm danh của ngày đó hiện trạng thái Có phép |
| ANNOUNCEMENT | ANNOUNCEMENT_TARGET, ANNOUNCEMENT_READ | `announcement_id` | |
| EVENT | EVENT_TARGET | `event_id` | |
| SUBJECT | MATERIAL, HOMEWORK | `subject_id` | |
| TEACHER | MATERIAL, HOMEWORK (người soạn) | `created_by_teacher_id` | |
| MATERIAL | MATERIAL_FILE | `material_id` | Mỗi lần tải lên là một phiên bản mới |
| MATERIAL | MATERIAL_REVIEW | `material_id` | Lịch sử duyệt: ai duyệt, kết quả, lý do từ chối |
| HOMEWORK | QUESTION | `homework_id` | Có thứ tự câu |
| QUESTION | QUESTION_OPTION | `question_id` | Chỉ với câu trắc nghiệm và đúng/sai |
| HOMEWORK | HOMEWORK_ASSIGNMENT | `homework_id` | Một bài có thể giao cho nhiều lớp |
| CLASS | HOMEWORK_ASSIGNMENT | `class_id` | |
| HOMEWORK_ASSIGNMENT | SUBMISSION | `assignment_id` | UQ (việc giao, học sinh): mỗi học sinh một bài làm cho mỗi lần giao |
| STUDENT | SUBMISSION | `student_id` | |
| SUBMISSION | ANSWER | `submission_id` | UQ (bài làm, câu hỏi) |
| QUESTION | ANSWER | `question_id` | |
| USER | NOTIFICATION, DEVICE_TOKEN, AUDIT_LOG | `user_id` | |

## 6. Mối quan hệ N–N và bảng nối

| Hai bên | Bảng nối | Trường thêm trên bảng nối | Ràng buộc |
| --- | --- | --- | --- |
| USER ↔ ROLE | USER_ROLE | phạm vi (cả trường hoặc theo lớp), ngày cấp | UQ (người dùng, vai trò, phạm vi) |
| GUARDIAN ↔ STUDENT | GUARDIAN_STUDENT | quan hệ (cha, mẹ, người giám hộ), là liên hệ chính | UQ (phụ huynh, học sinh). Một phụ huynh có nhiều con; một học sinh có nhiều phụ huynh |
| STUDENT ↔ CLASS | ENROLLMENT | năm học, ngày vào, ngày ra, trạng thái | UQ (học sinh, năm học): mỗi năm một lớp. Qua nhiều năm, học sinh có nhiều lớp |
| TEACHER ↔ CLASS ↔ SUBJECT | TEACHING_ASSIGNMENT | năm học | UQ (giáo viên, lớp, môn). Ba bên trong một bảng vì "ai dạy môn nào cho lớp nào" là một sự kiện duy nhất. Giáo viên chủ nhiệm cũng nên có dòng ở đây cho môn họ dạy |
| ANNOUNCEMENT ↔ đối tượng | ANNOUNCEMENT_TARGET | phạm vi: cả trường, theo khối, theo lớp, theo vai trò | Một thông báo gửi cho nhiều đối tượng. Mỗi dòng là một phạm vi |
| EVENT ↔ đối tượng | EVENT_TARGET | như trên | |
| ANNOUNCEMENT ↔ USER | ANNOUNCEMENT_READ | thời điểm đọc | UQ (thông báo, người dùng). Dòng chỉ có khi đã đọc, nên chưa đọc = không có dòng |
| MATERIAL ↔ CLASS | MATERIAL_CLASS | thời điểm xuất bản | Một học liệu xuất bản cho nhiều lớp; một lớp nhận nhiều học liệu |
| ANSWER ↔ QUESTION_OPTION | ANSWER_OPTION | | Câu nhiều đáp án: một câu trả lời chọn nhiều lựa chọn, một lựa chọn được nhiều học sinh chọn |
| CLASS ↔ SUBJECT | (suy ra từ TEACHING_ASSIGNMENT) | | Không cần bảng riêng nếu mọi môn của lớp đều có người dạy |
| HOMEWORK ↔ CLASS | HOMEWORK_ASSIGNMENT | hạn nộp, thời điểm giao | Đây là N–N có thêm dữ liệu (hạn nộp theo từng lớp), nên là một thực thể thật chứ không chỉ bảng nối |

## 7. Chuỗi quan hệ quyết định "ai thấy gì"

Mọi quyền xem dữ liệu đều đi theo chuỗi quan hệ phía trên. Máy chủ kiểm tra chuỗi này ở **mọi** yêu cầu, không dựa vào bộ lọc của ứng dụng.

| Vai trò | Xem được | Đường đi trong dữ liệu |
| --- | --- | --- |
| Học sinh | Lịch, học liệu, bài tập của lớp mình; chỉ ghi vào bài làm của chính mình | STUDENT → ENROLLMENT → CLASS → LESSON_SLOT, MATERIAL_CLASS, HOMEWORK_ASSIGNMENT. Chỉ SUBMISSION có `student_id` bằng mình |
| Phụ huynh | Điểm danh, lịch, đơn nghỉ, kết quả bài tập của con (chỉ xem) | GUARDIAN → GUARDIAN_STUDENT → STUDENT → ATTENDANCE_RECORD, LEAVE_REQUEST, SUBMISSION |
| Giáo viên | Lớp mình dạy hoặc chủ nhiệm; soạn bài và học liệu cho môn và lớp được phân công | TEACHER → TEACHING_ASSIGNMENT hoặc CLASS.homeroom → CLASS → ENROLLMENT → STUDENT |
| School Admin | Toàn trường: tài khoản, lớp, thời khóa biểu, liên kết phụ huynh–học sinh | `school_id` |
| Content Admin | Hàng chờ duyệt học liệu | MATERIAL có trạng thái Chờ duyệt, ghi vào MATERIAL_REVIEW |

Học liệu chỉ hiện với học sinh khi trạng thái là **Đã xuất bản** và có dòng MATERIAL_CLASS cho lớp của em.

## 8. Các luồng dữ liệu đi qua nhiều quan hệ

**Điểm danh tới phụ huynh.** Giáo viên gửi ATTENDANCE_SESSION cho lớp → mỗi học sinh có một ATTENDANCE_RECORD → phụ huynh nhìn thấy qua GUARDIAN_STUDENT. Trước khi buổi được gửi, không có bản ghi, và ứng dụng hiện "Chưa ghi nhận" chứ không hiện Vắng.

**Đơn nghỉ phép.** Phụ huynh tạo LEAVE_REQUEST cho học sinh (kiểm tra có liên kết GUARDIAN_STUDENT) → giáo viên chủ nhiệm duyệt → ATTENDANCE_RECORD của các ngày nghỉ trỏ tới đơn đó và hiện Có phép. Không cho hai đơn đang chờ hoặc đã duyệt chồng ngày với cùng một học sinh.

**Học liệu.** Giáo viên soạn MATERIAL (Nháp) → gửi duyệt (Chờ duyệt) → Content Admin ghi MATERIAL_REVIEW → Đã xuất bản và tạo MATERIAL_CLASS → học sinh của lớp đó thấy.

**Bài tập.** Giáo viên soạn HOMEWORK với QUESTION → giao qua HOMEWORK_ASSIGNMENT cho từng lớp → học sinh mở thì có SUBMISSION (Đang làm), mỗi lần lưu nháp ghi ANSWER → nộp thì máy chủ chấm các câu tự chấm được, ghi điểm vào ANSWER và SUBMISSION → câu tự luận chờ giáo viên chấm → phụ huynh xem kết quả của con.

## 9. Điểm cần xác nhận trước khi thiết kế cơ sở dữ liệu

- Hệ thống phục vụ **một trường** hay **nhiều trường** (nhiều tenant)? Nếu nhiều trường, `school_id` phải có ở mọi bảng.
- Học sinh nhỏ tuổi có tài khoản riêng hay vào qua tài khoản phụ huynh? Điều này quyết định USER ↔ STUDENT có bắt buộc hay không.
- Học sinh lên lớp: giữ nguyên STUDENT và tạo ENROLLMENT mới mỗi năm (khuyến nghị), không sao chép học sinh.
- Một lớp có nhiều giáo viên bộ môn, vậy giáo viên chủ nhiệm có tự động xem được dữ liệu mọi môn của lớp mình không?
- Nộp lại bài: nếu cho làm lại thì SUBMISSION cần thêm số lần làm, và UQ (việc giao, học sinh) phải đổi thành UQ (việc giao, học sinh, lần làm).
- Bán trú ở cấp 2: nếu bật theo khối lớp thì cần thêm quan hệ giữa CLASS hoặc khối với thực đơn và điểm danh bữa ăn. Hiện chưa có trong mô hình.
- Thời hạn lưu trữ bài làm và điểm danh của trẻ vị thành niên, và việc xóa khi học sinh nghỉ học.
