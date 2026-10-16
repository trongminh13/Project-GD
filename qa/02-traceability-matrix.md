# 02 — Ma trận Truy vết Yêu cầu & Test Cases (Traceability Matrix)

**Phiên bản:** 1.0  
**Ngày cập nhật:** 2026-10-15  
**Tài liệu tham chiếu:** Spec UI/UX Phase 1, `quan-he-du-lieu.md`, `qa/01-endpoint-inventory.md`

---

## 1. Bảng Ma trận Yêu cầu → Test Cases

| STT | Mã Yêu cầu | Nội dung Yêu cầu nghiệp vụ / Kỹ thuật | Test Cases tương ứng | Mức độ bao phủ |
|---|---|---|---|---|
| 1 | **REQ-AUTH-01** | Đăng nhập hệ thống theo 4 vai trò (ADMIN, TEACHER, PARENT, STUDENT) | TC-AUTH-001, TC-AUTH-004, TC-AUTH-005, TC-AUTH-006, TC-UI-001 | 100% |
| 2 | **REQ-AUTH-02** | Khóa tài khoản sau 5 lần đăng nhập sai (15 phút, ADMIN miễn khóa) | TC-AUTH-002, TC-AUTH-003, TC-AUTH-005 | 100% |
| 3 | **REQ-AUTH-03** | Đổi mật khẩu bắt buộc lần đầu và đổi mật khẩu chủ động | TC-AUTH-008, TC-AUTH-009, TC-AUTH-010 | 100% |
| 4 | **REQ-AUTH-04** | Gửi và xác thực OTP qua SMS/Mock (Rate limit 60s) | TC-AUTH-011, TC-AUTH-012, TC-AUTH-013, TC-NOTI-008 | 100% |
| 5 | **REQ-AUTH-05** | Hết hạn phiên JWT (TTL 24h) và thu hồi token khi đăng xuất | TC-AUTH-006, TC-SEC-002, TC-SEC-003 | 100% |
| 6 | **REQ-SEC-01** | Kiểm tra quyền ReBAC Enrollment: PH chỉ xem con mình, HS chỉ xem mình | TC-SEC-006, TC-SEC-007, TC-SEC-008, TC-SEC-009, TC-SEC-010, TC-SEC-011 | 100% |
| 7 | **REQ-SEC-02** | Kiểm tra quyền ReBAC Điểm danh: PH chỉ xem con mình, GV chỉ xem lớp mình | TC-SEC-012, TC-SEC-013, TC-SEC-014, TC-SEC-015, TC-SEC-016 | 100% |
| 8 | **REQ-SEC-03** | Phân quyền điểm danh hàng loạt: GV chỉ được điểm danh cho lớp mình dạy | TC-SEC-017, TC-SEC-018, TC-ATT-001 | 100% |
| 9 | **REQ-SEC-04** | Phân quyền duyệt đơn nghỉ phép: CHỈ GVCN mới được duyệt đơn | TC-SEC-019, TC-SEC-020, TC-SEC-021, TC-ATT-013, TC-ATT-014 | 100% |
| 10 | **REQ-SEC-05** | Chặn nộp đơn nghỉ phép cho con người khác hoặc học sinh tự nộp | TC-SEC-022, TC-SEC-023, TC-SEC-024 | 100% |
| 11 | **REQ-SEC-06** | Phân quyền nhập điểm và xem điểm: ReBAC môn học & lớp phụ trách | TC-SEC-026, TC-SEC-027, TC-SEC-028, TC-SEC-029, TC-ATT-016 | 100% |
| 12 | **REQ-SEC-07** | Phân quyền tải file học liệu: Chỉ học sinh/phụ huynh thuộc lớp nhận mới được tải | TC-SEC-030, TC-SEC-031, TC-SEC-032, TC-SEC-033, TC-SEC-034, TC-SEC-035, TC-SEC-036 | 100% |
| 13 | **REQ-SEC-08** | Chặn Path Traversal và tải file không tồn tại trên ổ cứng | TC-SEC-037 | 100% |
| 14 | **REQ-SEC-09** | Phân quyền soạn bài, giao bài và xem bài làm học sinh (Homework ReBAC) | TC-SEC-038, TC-SEC-039, TC-SEC-040, TC-SEC-041, TC-SEC-042, TC-SEC-043 | 100% |
| 15 | **REQ-SEC-10** | Chặn học sinh mở đề của lớp khác hoặc xem bài làm của bạn học | TC-SEC-044, TC-SEC-047, TC-SEC-048 | 100% |
| 16 | **REQ-SEC-11** | Chống gian lận: Không để lộ đáp án đúng khi học sinh đang làm bài | TC-SEC-045, TC-HW-017 | 100% |
| 17 | **REQ-SEC-12** | Chống tiêm nhiễm đáp án: Chặn gửi optionId không thuộc câu hỏi | TC-SEC-046 | 100% |
| 18 | **REQ-SEC-13** | Phân quyền học phí: PH chỉ xem sao kê của con mình | TC-SEC-051, TC-SEC-052, TC-PAY-001 | 100% |
| 19 | **REQ-SEC-14** | Phân quyền phân công giảng dạy | TC-SEC-053, TC-SEC-054, TC-CORE-016 | 100% |
| 20 | **REQ-CORE-01**| Duy nhất một năm học hiện tại tại một thời điểm | TC-CORE-002, TC-CORE-004 | 100% |
| 21 | **REQ-CORE-02**| Quản lý danh mục năm học, khối, lớp, môn học, giáo viên | TC-CORE-001, TC-CORE-003, TC-CORE-008..TC-CORE-013 | 100% |
| 22 | **REQ-CORE-03**| Quan hệ nhiều-nhiều Phụ huynh - Học sinh (nhiều con, nhiều người giám hộ) | TC-CORE-006, TC-CORE-017 | 100% |
| 23 | **REQ-CORE-04**| Student Portal: Xem thông tin cá nhân và bảng điểm | TC-CORE-014, TC-CORE-015 | 100% |
| 24 | **REQ-ATT-01** | Điểm danh hàng loạt đủ học sinh, thiếu học sinh và gửi lại (Idempotency) | TC-ATT-001, TC-ATT-002, TC-ATT-003, TC-ATT-004, TC-ATT-005 | 100% |
| 25 | **REQ-ATT-02** | Vòng đời đơn nghỉ phép: Tạo đơn, kiểm tra biên ngày, lý do bắt buộc, chặn trùng | TC-ATT-006, TC-ATT-007, TC-ATT-008, TC-ATT-009, TC-ATT-010 | 100% |
| 26 | **REQ-ATT-03** | Tự động đồng bộ điểm danh có phép (EXCUSED) khi đơn nghỉ được duyệt | TC-ATT-013, TC-ATT-014, TC-ATT-015 | 100% |
| 27 | **REQ-HW-01**  | Soạn bài tập gồm đủ 5 dạng câu hỏi (Single, Multiple, True/False, Short, Essay)| TC-HW-001, TC-HW-002, TC-HW-003 | 100% |
| 28 | **REQ-HW-02**  | Giao bài tập cho lớp kèm hạn nộp và cấu hình nộp muộn | TC-HW-006, TC-HW-007, TC-HW-008, TC-HW-009 | 100% |
| 29 | **REQ-HW-03**  | Học sinh làm bài: Lưu nháp, thoát app vào lại còn nguyên | TC-HW-020, TC-HW-021, TC-HW-022 | 100% |
| 30 | **REQ-HW-04**  | Nộp bài chính thức, chặn nộp 2 lần, kiểm tra hạn nộp theo giờ server | TC-HW-023, TC-HW-024, TC-HW-025, TC-HW-026 | 100% |
| 31 | **REQ-HW-05**  | Chấm điểm tự động trắc nghiệm & điền ngắn (Unicode NFC, dấu \| phân cách) | TC-HW-014, TC-HW-015, TC-HW-018, TC-HW-019 | 100% |
| 32 | **REQ-HW-06**  | Giáo viên chấm điểm và nhận xét câu tự luận (Manual grading) | TC-HW-010, TC-HW-011, TC-HW-012, TC-HW-013, TC-HW-027 | 100% |
| 33 | **REQ-MAT-01** | Vòng đời học liệu: Nháp, Xuất bản, Phân phối theo lớp | TC-MAT-001, TC-MAT-002, TC-MAT-003, TC-MAT-004 | 100% |
| 34 | **REQ-MAT-02** | Học sinh xem và tải file học liệu thuộc lớp mình; xử lý tên file tiếng Việt | TC-MAT-005..TC-MAT-011 | 100% |
| 35 | **REQ-IMP-01** | Import Excel học sinh: Hợp lệ, lỗi ở giữa, nhiều lỗi, trùng lặp | TC-IMP-001..TC-IMP-007 | 100% |
| 36 | **REQ-IMP-02** | Tính nguyên tử (Atomic Rollback 100%): Không sinh bản ghi mồ côi khi lỗi | TC-IMP-002, TC-IMP-012 | 100% |
| 37 | **REQ-IMP-03** | Hỗ trợ tên tiếng Việt có dấu, xử lý file rỗng, file sai định dạng, file lớn | TC-IMP-008..TC-IMP-011, TC-IMP-013 | 100% |
| 38 | **REQ-IMP-04** | Dọn dẹp trùng lặp và đối soát dữ liệu sau migration | TC-IMP-014, TC-IMP-015, TC-IMP-016, TC-IMP-017 | 100% |
| 39 | **REQ-PAY-01** | Xem sao kê học phí, tạo đơn hàng thanh toán Razorpay | TC-PAY-001..TC-PAY-006 | 100% |
| 40 | **REQ-PAY-02** | Xác thực chữ ký thanh toán, Idempotency (chặn thanh toán 2 lần), tiền mặt | TC-PAY-007..TC-PAY-011 | 100% |
| 41 | **REQ-NOTI-01**| Gửi thông báo theo phạm vi (Toàn trường, Khối, Lớp, Vai trò) | TC-NOTI-001..TC-NOTI-004 | 100% |
| 42 | **REQ-NOTI-02**| Đánh dấu đã đọc, huy hiệu số chưa đọc, bật/tắt push notification | TC-NOTI-005, TC-NOTI-006, TC-NOTI-007 | 100% |
| 43 | **REQ-UI-01**  | Điều hướng Dashboard theo vai trò sau đăng nhập | TC-UI-001 | 100% |
| 44 | **REQ-UI-02**  | Trạng thái màn hình: Loading, Empty, Offline / No Internet | TC-UI-002, TC-UI-003, TC-UI-004 | 100% |
| 45 | **REQ-UI-03**  | Hộp thoại xác nhận các hành động nguy hiểm | TC-UI-005 | 100% |
| 46 | **REQ-UI-04**  | Tuân thủ design phẳng, chuẩn kích thước chạm WCAG (>=48dp), font lớn | TC-UI-006, TC-UI-007, TC-UI-008, TC-UI-009, TC-UI-010 | 100% |
| 47 | **REQ-NFR-01** | Chuẩn hóa tiếng Việt UTF-8 NFC/NFD, tên học sinh dài | TC-NFR-001, TC-NFR-002 | 100% |
| 48 | **REQ-NFR-02** | An toàn dữ liệu trẻ: Không log CCCD/Aadhaar thô, chống XSS, che lỗi | TC-NFR-003, TC-NFR-004, TC-NFR-005 | 100% |
| 49 | **REQ-NFR-03** | Hiệu năng phản hồi P95 <= 500ms và chịu tải đồng thời cơ bản | TC-NFR-006, TC-NFR-007 | 100% |
| 50 | **REQ-NFR-04** | Tương thích thiết bị Android 11+ và màn hình nhỏ | TC-NFR-008, TC-NFR-009 | 100% |

---

## 2. Danh sách Yêu cầu Chưa có Test Case / Chờ Quyết định

| STT | Yêu cầu nghiệp vụ | Lý do chưa phủ kín / Trạng thái | Hướng xử lý |
|---|---|---|---|
| 1 | **REQ-PENDING-01**: Quy định nộp bài tập muộn | Chưa chốt có tự động trừ % điểm khi nộp muộn không | Test case TC-HW-008 & TC-HW-026 ghi nhận `Chặn - chờ quyết định` |
| 2 | **REQ-PENDING-02**: Thời điểm công bố đáp án bài tập | Chưa quyết định: Hiện ngay, sau dueDate hay sau khi chấm xong | Ghi nhận câu hỏi chờ PO phản hồi |
| 3 | **REQ-PENDING-03**: Tính điểm câu nhiều đáp án khi chọn thiếu/thừa | Chưa quyết định: 0 điểm tuyệt đối hay điểm tỉ lệ từng phần | Ghi nhận trong TC-HW-019 |
| 4 | **REQ-PENDING-04**: Quản lý bán trú cấp 2 | Chưa có trong thiết kế Phase 1 | Loại khỏi phạm vi Phase 1 |
| 5 | **REQ-PENDING-05**: Kiến trúc Multi-tenant nhiều trường | Hiện đang thiết kế single-school (Ashadeep School) | Chưa áp dụng lọc theo school_id |
