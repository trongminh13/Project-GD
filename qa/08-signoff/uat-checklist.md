# 08 — Danh mục Nghiệm thu Người dùng (UAT Checklist — Phase 1)

**Phiên bản:** 1.0  
**Ngày:** 2026-10-15  
**Đối tượng thực hiện:** Đại diện Ban giám hiệu, Giáo viên, Phụ huynh và Học sinh thực tế

---

## 1. Dành cho Quản trị viên (ADMIN)

| STT | Kịch bản nghiệm thu | Kỳ vọng của người dùng | Kết quả | Ký duyệt |
|---|---|---|---|---|
| UAT-ADM-01 | Đăng nhập hệ thống và xem Dashboard trường | Hiển thị tổng số lớp, số học sinh, giáo viên chính xác | ⬜ Đạt / ⬜ Chưa | |
| UAT-ADM-02 | Tạo năm học mới và kích hoạt năm học hiện tại | Toàn trường chuyển sang năm học mới đồng bộ | ⬜ Đạt / ⬜ Chưa | |
| UAT-ADM-03 | Import danh sách học sinh từ file Excel mẫu | 100% học sinh vào đúng lớp, tài khoản tự động kích hoạt | ⬜ Đạt / ⬜ Chưa | |
| UAT-ADM-04 | Import file Excel có lỗi | Báo lỗi rõ ràng từng dòng, không bị tạo dữ liệu dở dang | ⬜ Đạt / ⬜ Chưa | |
| UAT-ADM-05 | Phân công giáo viên chủ nhiệm và giáo viên bộ môn | Giáo viên thấy đúng lớp được phân công | ⬜ Đạt / ⬜ Chưa | |
| UAT-ADM-06 | Gửi thông báo toàn trường | Tất cả phụ huynh và giáo viên đều nhận được | ⬜ Đạt / ⬜ Chưa | |

---

## 2. Dành cho Giáo viên Chủ nhiệm & Bộ môn (TEACHER)

| STT | Kịch bản nghiệm thu | Kỳ vọng của người dùng | Kết quả | Ký duyệt |
|---|---|---|---|---|
| UAT-TEA-01 | Điểm danh lớp chủ nhiệm hàng loạt trên điện thoại | Giao diện trực quan, thao tác nhanh trong 1 phút | ⬜ Đạt / 6 Chưa | |
| UAT-TEA-02 | Xem và duyệt đơn xin nghỉ phép của phụ huynh | Nhận thông báo có đơn mới; duyệt đơn tự động cập nhật điểm danh | ⬜ Đạt / ⬜ Chưa | |
| UAT-TEA-03 | Giáo viên bộ môn cố tình duyệt đơn nghỉ lớp khác | Hệ thống chặn lại, thông báo không có quyền | ⬜ Đạt / ⬜ Chưa | |
| UAT-TEA-04 | Soạn bài tập trắc nghiệm và tự luận trên ứng dụng | Nhập đề bài tiếng Việt dễ dàng, xem trước đề chuẩn | ⬜ Đạt / ⬜ Chưa | |
| UAT-TEA-05 | Giao bài tập cho lớp và đặt hạn nộp | Học sinh trong lớp nhận được bài ngay lập tức | ⬜ Đạt / ⬜ Chưa | |
| UAT-TEA-06 | Chấm bài tự luận và nhập điểm nhận xét | Điểm tổng tự động tính, học sinh thấy ngay nhận xét | ⬜ Đạt / ⬜ Chưa | |
| UAT-TEA-07 | Tải lên tài liệu học tập (Slide, PDF) | Tải file mượt mà, phân phối đúng các lớp được chọn | ⬜ Đạt / ⬜ Chưa | |

---

## 3. Dành cho Phụ huynh (PARENT)

| STT | Kịch bản nghiệm thu | Kỳ vọng của người dùng | Kết quả | Ký duyệt |
|---|---|---|---|---|
| UAT-PAR-01 | Đăng nhập và xem bảng theo dõi của con | Thấy đúng tên con, lớp học và giáo viên chủ nhiệm | ⬜ Đạt / ⬜ Chưa | |
| UAT-PAR-02 | Phụ huynh có 2 con chuyển đổi qua lại giữa các con | Dữ liệu tách bạch rõ ràng giữa 2 bé, không bị lẫn | ⬜ Đạt / ⬜ Chưa | |
| UAT-PAR-03 | Nộp đơn xin nghỉ ốm cho con | Chọn ngày nhanh qua lịch, gửi thành công, theo dõi được trạng thái duyệt | ⬜ Đạt / ⬜ Chưa | |
| UAT-PAR-04 | Xem tình hình điểm danh theo tháng | Lịch hiển thị màu xanh (có mặt), vàng (có phép), đỏ (vắng) | ⬜ Đạt / ⬜ Chưa | |
| UAT-PAR-05 | Xem bài tập và kết quả chấm điểm của con | Đọc được nhận xét của giáo viên và điểm chi tiết | ⬜ Đạt / ⬜ Chưa | |
| UAT-PAR-06 | Xem sao kê học phí và thanh toán trực tuyến | Số tiền nợ minh bạch, thanh toán an toàn, có biên lai | ⬜ Đạt / ⬜ Chưa | |

---

## 4. Dành cho Học sinh (STUDENT)

| STT | Kịch bản nghiệm thu | Kỳ vọng của người dùng | Kết quả | Ký duyệt |
|---|---|---|---|---|
| UAT-STU-01 | Đăng nhập lần đầu và đổi mật khẩu mới | Bắt buộc đổi mật khẩu thành công mới vào được trang chủ | ⬜ Đạt / ⬜ Chưa | |
| UAT-STU-02 | Xem danh sách bài tập cần hoàn thành | Phân loại rõ bài chưa làm, đang làm dở, đã nộp | ⬜ Đạt / ⬜ Chưa | |
| UAT-STU-03 | Làm bài tập trắc nghiệm và điền ngắn | Chọn đáp án mượt mà, gõ tiếng Việt không bị nhảy chữ | ⬜ Đạt / ⬜ Chưa | |
| UAT-STU-04 | Lưu nháp bài làm, thoát app rồi vào lại | Các câu đã làm trước đó vẫn còn nguyên vẹn | ⬜ Đạt / ⬜ Chưa | |
| UAT-STU-05 | Nộp bài thi trước hạn chót | Hiển thị hộp xác nhận, nộp xong thấy điểm tự chấm ngay | ⬜ Đạt / ⬜ Chưa | |
| UAT-STU-06 | Tải tài liệu học tập từ thầy cô | Tải file PDF về máy đọc được bình thường | ⬜ Đạt / ⬜ Chưa | |
