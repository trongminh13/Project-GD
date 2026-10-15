# Test Cases — HW: Bài tập và Chấm điểm

**Module:** HW  
**Tổng số test case:** 27  
**Tham chiếu:** `quan-he-du-lieu.md` Mục 2.4; Kế hoạch vai trò Học sinh; `TeacherHomeworkController.java`, `StudentHomeworkController.java`, `ParentHomeworkController.java`

---

### TC-HW-001 — Giáo viên tạo bài tập mới hợp lệ gồm đủ 5 dạng câu hỏi
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `TeacherHomeworkController.java` `POST /api/teacher/homework`
- **Endpoint / Màn hình:** `POST /api/teacher/homework`
- **Tiền điều kiện:** GV `gv_chunhiem_3a` đăng nhập; Môn Toán (ID 1)
- **Dữ liệu vào:**
  ```json
  {
    "title": "Bài kiểm tra Đại số Chương 1",
    "description": "Ôn tập phép cộng trừ và biểu thức",
    "subjectId": 1,
    "questions": [
      {
        "questionType": "SINGLE_CHOICE",
        "questionText": "Kết quả của 15 + 27 là bao nhiêu?",
        "points": 2.0,
        "options": [
          {"optionText": "42", "isCorrect": true},
          {"optionText": "32", "isCorrect": false},
          {"optionText": "52", "isCorrect": false}
        ]
      },
      {
        "questionType": "MULTIPLE_CHOICE",
        "questionText": "Các số nào sau đây là số chẵn?",
        "points": 2.0,
        "options": [
          {"optionText": "2", "isCorrect": true},
          {"optionText": "4", "isCorrect": true},
          {"optionText": "7", "isCorrect": false}
        ]
      },
      {
        "questionType": "TRUE_FALSE",
        "questionText": "Mặt trời mọc ở hướng Đông.",
        "points": 2.0,
        "options": [
          {"optionText": "Đúng", "isCorrect": true},
          {"optionText": "Sai", "isCorrect": false}
        ]
      },
      {
        "questionType": "SHORT_ANSWER",
        "questionText": "Thủ đô của Việt Nam là gì?",
        "points": 2.0,
        "correctAnswer": "Hà Nội|Ha Noi|thủ đô Hà Nội"
      },
      {
        "questionType": "ESSAY",
        "questionText": "Em hãy nêu cảm nghĩ về ngày khai trường (khoảng 50 từ).",
        "points": 2.0
      }
    ]
  }
  ```
- **Các bước:**
  1. Gửi request tạo bài tập
- **Kết quả mong đợi:** HTTP 201 Created; trả về `id` bài tập mới; tổng điểm = 10.0; đủ 5 câu hỏi được lưu
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-002 — Tạo bài tập không có tiêu đề hoặc không có câu hỏi
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Lỗi
- **Tham chiếu:** Validation `HomeworkCreateRequest`
- **Endpoint / Màn hình:** `POST /api/teacher/homework`
- **Tiền điều kiện:** GV đăng nhập
- **Dữ liệu vào:** `{"title":"","subjectId":1,"questions":[]}`
- **Các bước:**
  1. Gửi request tạo bài tập với title rỗng và danh sách câu hỏi rỗng
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo tiêu đề bắt buộc và bài tập phải có ít nhất 1 câu hỏi
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-003 — Tạo câu hỏi SINGLE_CHOICE có 0 hoặc nhiều hơn 1 đáp án đúng
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Biên / Lỗi
- **Tham chiếu:** LMS Validation Rule
- **Endpoint / Màn hình:** `POST /api/teacher/homework`
- **Tiền điều kiện:** GV đăng nhập
- **Dữ liệu vào:** Câu hỏi loại `SINGLE_CHOICE` nhưng gắn `isCorrect: true` cho cả 2 options
- **Các bước:**
  1. Gửi request tạo bài tập
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo câu hỏi đơn lựa chọn chỉ được có duy nhất 1 đáp án đúng
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-004 — Giáo viên xem danh sách bài tập do mình tạo
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #45 (`GET /api/teacher/homework`)
- **Endpoint / Màn hình:** `GET /api/teacher/homework`
- **Tiền điều kiện:** GV `gv_chunhiem_3a` đã tạo 2 bài tập
- **Dữ liệu vào:** Token của `gv_chunhiem_3a`
- **Các bước:**
  1. Gọi `GET /api/teacher/homework`
- **Kết quả mong đợi:** HTTP 200 OK; chỉ trả về các bài do chính GV này tạo
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-005 — Giáo viên xem chi tiết bài tập kèm bộ câu hỏi
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #46 (`GET /api/teacher/homework/{id}`)
- **Endpoint / Màn hình:** `GET /api/teacher/homework/{id}`
- **Tiền điều kiện:** Bài tập ID 1 do GV tạo
- **Dữ liệu vào:** `id = 1`
- **Các bước:**
  1. Gọi `GET /api/teacher/homework/1`
- **Kết quả mong đợi:** HTTP 200 OK; đầy đủ thông tin đề bài, danh sách câu hỏi, options và đánh dấu đáp án đúng
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-006 — Giáo viên giao bài tập cho lớp học (Assign)
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `TeacherHomeworkController.java` `POST /api/teacher/homework/{id}/assign`
- **Endpoint / Màn hình:** `POST /api/teacher/homework/{id}/assign`
- **Tiền điều kiện:** GV dạy lớp 3A (classId = 1); Bài tập ID 1
- **Dữ liệu vào:**
  ```json
  {
    "classId": 1,
    "startDate": "2026-10-15T08:00:00",
    "dueDate": "2026-10-25T23:59:59",
    "allowLateSubmission": false
  }
  ```
- **Các bước:**
  1. Gửi request giao bài tập
- **Kết quả mong đợi:** HTTP 200 OK; tạo bản ghi Assignment mới liên kết giữa bài tập và lớp 3A; học sinh lớp 3A sẽ thấy bài tập này
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-007 — Giao bài tập với hạn nộp (dueDate) trong quá khứ
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Lỗi / Biên
- **Tham chiếu:** Validation `AssignHomeworkRequest`
- **Endpoint / Màn hình:** `POST /api/teacher/homework/{id}/assign`
- **Tiền điều kiện:** GV dạy lớp 3A
- **Dữ liệu vào:** `{"classId":1,"dueDate":"2020-01-01T00:00:00"}`
- **Các bước:**
  1. Gửi request giao bài với hạn nộp trong quá khứ
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo "Hạn nộp phải sau thời điểm hiện tại"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-008 — Giao bài tập cho phép nộp muộn (allowLateSubmission = true)
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** Hành vi chưa duyệt Mục 8.1
- **Endpoint / Màn hình:** `POST /api/teacher/homework/{id}/assign`
- **Tiền điều kiện:** GV giao bài
- **Dữ liệu vào:** `{"classId":1,"dueDate":"2026-10-20T23:59:59","allowLateSubmission":true}`
- **Các bước:**
  1. Giao bài với cờ `allowLateSubmission = true`
- **Kết quả mong đợi:** HTTP 200 OK; cờ được lưu đúng trong DB; học sinh nộp sau hạn sẽ được ghi nhận trạng thái "Nộp muộn"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-009 — Giáo viên xem danh sách các đợt giao bài (Assignments)
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #48
- **Endpoint / Màn hình:** `GET /api/teacher/homework/assignments`
- **Tiền điều kiện:** GV đã giao 2 đợt bài
- **Dữ liệu vào:** Token của GV
- **Các bước:**
  1. Gọi `GET /api/teacher/homework/assignments`
- **Kết quả mong đợi:** HTTP 200 OK; trả về danh sách đợt giao bài kèm số lượng học sinh đã nộp / tổng số học sinh
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-010 — Giáo viên xem danh sách bài nộp của một đợt giao
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #49
- **Endpoint / Màn hình:** `GET /api/teacher/homework/assignments/{assignmentId}/submissions`
- **Tiền điều kiện:** Đợt giao ID 1 có 3 học sinh đã nộp
- **Dữ liệu vào:** `assignmentId = 1`
- **Các bước:**
  1. GV gọi `GET /api/teacher/homework/assignments/1/submissions`
- **Kết quả mong đợi:** HTTP 200 OK; danh sách 3 bài nộp gồm tên học sinh, thời điểm nộp, trạng thái (`SUBMITTED`/`GRADED`), điểm tự chấm
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-011 — Giáo viên xem chi tiết bài làm của học sinh (Submission Detail)
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #50
- **Endpoint / Màn hình:** `GET /api/teacher/homework/submissions/{submissionId}`
- **Tiền điều kiện:** Submission ID 1 đã nộp
- **Dữ liệu vào:** `submissionId = 1`
- **Các bước:**
  1. Gọi `GET /api/teacher/homework/submissions/1`
- **Kết quả mong đợi:** HTTP 200 OK; hiển thị từng câu hỏi, câu trả lời của học sinh, kết quả đúng/sai tự chấm, và nội dung câu tự luận
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-012 — Giáo viên chấm điểm và nhận xét câu tự luận (Manual Grading)
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `TeacherHomeworkController.java` `PUT /api/teacher/homework/submissions/{submissionId}/grade`
- **Endpoint / Màn hình:** `PUT /api/teacher/homework/submissions/{submissionId}/grade`
- **Tiền điều kiện:** Submission ID 1 có câu tự luận (questionId = 5, tối đa 2.0 điểm); GV phụ trách lớp
- **Dữ liệu vào:**
  ```json
  {
    "teacherComment": "Bài viết giàu cảm xúc, diễn đạt lưu loát",
    "details": [
      {"questionId": 5, "points": 1.75}
    ]
  }
  ```
- **Các bước:**
  1. GV gửi request chấm điểm
- **Kết quả mong đợi:** HTTP 200 OK; điểm câu tự luận cập nhật thành 1.75; tổng điểm bài nộp cập nhật lại; trạng thái chuyển sang `GRADED`
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-013 — Nhập điểm câu tự luận vượt quá số điểm tối đa của câu hỏi
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Biên / Lỗi
- **Tham chiếu:** `TeacherHomeworkService.java`
- **Endpoint / Màn hình:** `PUT /api/teacher/homework/submissions/{submissionId}/grade`
- **Tiền điều kiện:** Câu hỏi ID 5 tối đa 2.0 điểm
- **Dữ liệu vào:** `{"details":[{"questionId":5,"points":5.0}]}`
- **Các bước:**
  1. GV gửi điểm 5.0 (> 2.0)
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo "Điểm chấm không được vượt quá điểm tối đa của câu hỏi"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-014 — Chấm tự động câu hỏi Đúng/Sai (TRUE_FALSE Auto-grading)
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Chức năng tự động
- **Tham chiếu:** `StudentHomeworkService.java`
- **Endpoint / Màn hình:** `POST /api/student-portal/homework/submissions/{submissionId}/submit`
- **Tiền điều kiện:** Câu hỏi TRUE_FALSE đáp án đúng là "Đúng" (2.0 điểm)
- **Dữ liệu vào:** Học sinh chọn option "Đúng"
- **Các bước:**
  1. Học sinh nộp bài
- **Kết quả mong đợi:** Hệ thống tự động chấm `isCorrect = true`, cộng 2.0 điểm cho câu hỏi
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-015 — Chấm tự động câu hỏi Điền ngắn chuẩn hóa Unicode NFC và phân cách `|`
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Chức năng tự động / Unicode
- **Tham chiếu:** `SecurityReBACTest.java` L554; Mục 6.5
- **Endpoint / Màn hình:** `POST /api/student-portal/homework/submissions/{submissionId}/submit`
- **Tiền điều kiện:** Đề bài: "Thủ đô của Việt Nam là gì?", `correctAnswer = "Hà Nội|Ha Noi|thủ đô Hà Nội"`
- **Dữ liệu vào:** Học sinh nhập `"  hà nội  "` (chữ thường, khoảng trắng thừa, Unicode dựng sẵn/tổ hợp)
- **Các bước:**
  1. Học sinh gửi câu trả lời điền ngắn
  2. Hệ thống chấm điểm tự động
- **Kết quả mong đợi:** Hệ thống trim khoảng trắng, chuẩn hóa NFC, so khớp không phân biệt hoa thường -> Kết quả `isCorrect = true`, đạt 2.0 điểm
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-016 — Học sinh xem danh sách bài tập được giao cho lớp mình
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #52 (`GET /api/student-portal/homework`)
- **Endpoint / Màn hình:** `GET /api/student-portal/homework`
- **Tiền điều kiện:** Đăng nhập với STUDENT `hs_3a_01` (lớp 3A)
- **Dữ liệu vào:** Token của STUDENT
- **Các bước:**
  1. Gọi `GET /api/student-portal/homework`
- **Kết quả mong đợi:** HTTP 200 OK; chỉ trả về bài tập được giao cho lớp 3A; kèm hạn nộp và trạng thái làm bài (`CHƯA_LÀM`, `ĐANG_LÀM`, `ĐÃ_NỘP`)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-017 — Học sinh mở đề làm bài (Take test)
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #53 (`GET /api/student-portal/homework/{assignmentId}/take`)
- **Endpoint / Màn hình:** `GET /api/student-portal/homework/{assignmentId}/take`
- **Tiền điều kiện:** Học sinh thuộc lớp nhận bài; assignment chưa quá hạn
- **Dữ liệu vào:** `assignmentId = 1`
- **Các bước:**
  1. Gọi `GET /api/student-portal/homework/1/take`
- **Kết quả mong đợi:** HTTP 200 OK; tạo bản ghi `Submission` mới với trạng thái `IN_PROGRESS` (hoặc trả về submission nháp đang dở); nội dung câu hỏi KHÔNG có đáp án đúng
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-018 — Chấm câu hỏi nhiều đáp án khi chọn đúng đủ tất cả
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Chức năng tự động
- **Tham chiếu:** LMS Grading Engine
- **Endpoint / Màn hình:** `POST /api/student-portal/homework/submissions/{submissionId}/submit`
- **Tiền điều kiện:** Câu hỏi có 2 đáp án đúng: ID 1 và ID 2 (2.0 điểm)
- **Dữ liệu vào:** Học sinh chọn cả [1, 2]
- **Các bước:**
  1. Nộp bài
- **Kết quả mong đợi:** `isCorrect = true`; đạt trọn vẹn 2.0 điểm
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-019 — Chấm câu hỏi nhiều đáp án khi chọn thiếu hoặc chọn thừa
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Biên / Nghiệp vụ
- **Tham chiếu:** Hành vi chưa duyệt Mục 8.5 ("Cách tính điểm khi chọn thiếu hoặc thừa ở câu nhiều đáp án")
- **Endpoint / Màn hình:** `POST /api/student-portal/homework/submissions/{submissionId}/submit`
- **Tiền điều kiện:** Câu hỏi có đáp án đúng [1, 2]; phương án sai [3]
- **Dữ liệu vào:** Trường hợp A: chỉ chọn [1] (thiếu); Trường hợp B: chọn [1, 2, 3] (thừa)
- **Các bước:**
  1. Nộp bài trường hợp chọn thiếu
  2. Nộp bài trường hợp chọn thừa
- **Kết quả mong đợi:** Chặn - chờ quyết định: Hiện tại theo code là 0 điểm nếu không khớp 100%. Cần PO xác nhận có áp dụng tính điểm từng phần (partial points) không.
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chặn - chờ quyết định
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-020 — Học sinh lưu nháp bài làm (Draft)
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #54
- **Endpoint / Màn hình:** `POST /api/student-portal/homework/submissions/{submissionId}/draft`
- **Tiền điều kiện:** Học sinh đang làm bài `submissionId = 1`
- **Dữ liệu vào:**
  ```json
  {
    "answers": [
      {"questionId": 1, "selectedOptionIds": [1]},
      {"questionId": 4, "textAnswer": "Hà Nội"}
    ]
  }
  ```
- **Các bước:**
  1. Gửi request lưu draft
- **Kết quả mong đợi:** HTTP 200 OK; câu trả lời được lưu lại; trạng thái submission vẫn là `IN_PROGRESS`
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-021 — Học sinh thoát ứng dụng và vào lại: bài nháp vẫn còn nguyên
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Chức năng tích hợp UI
- **Tham chiếu:** Mục 6.5 ("lưu nháp, thoát rồi vào lại còn nguyên")
- **Endpoint / Màn hình:** Màn hình Làm bài tập Flutter
- **Tiền điều kiện:** Học sinh đã lưu nháp câu 1 và câu 4
- **Dữ liệu vào:** Mở lại bài làm `assignmentId = 1`
- **Các bước:**
  1. Đóng hẳn ứng dụng Flutter (kill process)
  2. Mở lại ứng dụng, đăng nhập vào bài tập
- **Kết quả mong đợi:** Các câu trả lời đã lưu nháp được tải lại đầy đủ, các ô tick và textfield điền đúng đáp án trước đó
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-022 — Học sinh lưu nháp ghi đè đáp án cũ
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `StudentHomeworkService.java`
- **Endpoint / Màn hình:** `POST /api/student-portal/homework/submissions/{submissionId}/draft`
- **Tiền điều kiện:** Đã nháp câu 1 chọn option 1
- **Dữ liệu vào:** Gửi draft mới câu 1 đổi sang option 2
- **Các bước:**
  1. Gửi request draft mới
- **Kết quả mong đợi:** HTTP 200 OK; đáp án câu 1 cập nhật thành option 2 (không tạo bản ghi duplicate trong DB)
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-023 — Học sinh nộp bài chính thức (Submit)
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #55
- **Endpoint / Màn hình:** `POST /api/student-portal/homework/submissions/{submissionId}/submit`
- **Tiền điều kiện:** Học sinh đang làm bài; chưa quá hạn nộp
- **Dữ liệu vào:** Body danh sách đáp án cuối cùng
- **Các bước:**
  1. Gọi `POST /api/student-portal/homework/submissions/1/submit`
- **Kết quả mong đợi:** HTTP 200 OK; trạng thái chuyển sang `SUBMITTED`; thời gian `submittedAt` được ghi nhận theo giờ server; hệ thống tự động chấm các câu trắc nghiệm/điền ngắn
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-024 — Nộp bài lần thứ 2 sau khi đã nộp thành công (Double Submission Protection)
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Biên / Bảo mật
- **Tham chiếu:** Mục 6.5 ("Nộp hai lần")
- **Endpoint / Màn hình:** `POST /api/student-portal/homework/submissions/{submissionId}/submit`
- **Tiền điều kiện:** Submission ID 1 đã ở trạng thái `SUBMITTED`
- **Dữ liệu vào:** Gửi lại request submit cho submissionId = 1
- **Các bước:**
  1. Gửi request submit lần 2
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo "Bài tập đã được nộp trước đó, không thể nộp lại"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-025 — Nộp bài khi đã quá hạn (dueDate) và không cho phép nộp muộn
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Nghiệp vụ / Biên
- **Tham chiếu:** `StudentHomeworkService.java` (`allowLateSubmission = false`)
- **Endpoint / Màn hình:** `POST /api/student-portal/homework/submissions/{submissionId}/submit`
- **Tiền điều kiện:** `dueDate = 2026-10-14T23:59:59`; hiện tại ngày 2026-10-15; `allowLateSubmission = false`
- **Dữ liệu vào:** Body submit bài
- **Các bước:**
  1. Học sinh gửi request nộp bài quá hạn
- **Kết quả mong đợi:** HTTP 400 Bad Request; thông báo "Đã quá hạn nộp bài tập"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-026 — Kiểm tra so khớp giờ hạn nộp theo giờ Server (chặn đổi giờ thiết bị)
- **Module:** HW
- **Ưu tiên:** P0
- **Loại:** Bảo mật / Biên
- **Tham chiếu:** Mục 6.5 ("Hạn nộp so theo giờ máy chủ, thử đổi giờ thiết bị")
- **Endpoint / Màn hình:** Màn hình nộp bài Flutter & API
- **Tiền điều kiện:** Server đã qua `dueDate` 5 phút; người dùng chỉnh đồng hồ điện thoại lùi lại 1 tiếng
- **Dữ liệu vào:** Nộp bài từ điện thoại đã chỉnh lùi giờ
- **Các bước:**
  1. Chỉnh giờ máy điện thoại lùi về trước hạn nộp
  2. Bấm nộp bài
- **Kết quả mong đợi:** Server kiểm tra `Instant.now()` của máy chủ -> Vẫn từ chối với HTTP 400 quá hạn; không tin tưởng timestamp từ client
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-HW-027 — Phụ huynh xem bài tập và trạng thái hoàn thành của con
- **Module:** HW
- **Ưu tiên:** P1
- **Loại:** Chức năng
- **Tham chiếu:** `01-endpoint-inventory.md` #56 (`GET /api/parent/wards/{studentId}/homework`)
- **Endpoint / Màn hình:** `GET /api/parent/wards/{studentId}/homework`
- **Tiền điều kiện:** Phụ huynh `ph_con_3a` giám hộ học sinh ID 1
- **Dữ liệu vào:** `studentId = 1`
- **Các bước:**
  1. Đăng nhập với `ph_con_3a`
  2. Gọi `GET /api/parent/wards/1/homework`
- **Kết quả mong đợi:** HTTP 200 OK; hiển thị danh sách bài tập được giao cho con mình, trạng thái nộp bài và điểm số nếu đã chấm
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —
