# Test Cases — UI: Ứng dụng Mobile Flutter

**Module:** UI  
**Tổng số test case:** 10  
**Tham chiếu:** Spec UI/UX Phase 1, `frontend/lib/main.dart`, các màn hình theo vai trò (53 screens)

---

### TC-UI-001 — Điều hướng đúng màn hình trang chủ theo vai trò sau đăng nhập
- **Module:** UI
- **Ưu tiên:** P0
- **Loại:** Điều hướng / Phân quyền UI
- **Tham chiếu:** Spec UI/UX Mục Điều hướng; `main.dart`
- **Endpoint / Màn hình:** Màn hình Login Flutter
- **Tiền điều kiện:** 4 tài khoản với 4 vai trò khác nhau
- **Dữ liệu vào:**
  - ADMIN `admin` -> Admin Dashboard
  - TEACHER `gv_chunhiem_3a` -> Teacher Dashboard
  - PARENT `ph_con_3a` -> Parent Dashboard
  - STUDENT `hs_3a_01` -> Student Portal Dashboard
- **Các bước:**
  1. Đăng nhập lần lượt từng tài khoản
- **Kết quả mong đợi:** Mỗi vai trò được điều hướng đúng 100% vào trang chủ của mình; thanh điều hướng dưới đáy (BottomNavigationBar) hiển thị đúng các tab của vai trò đó
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-UI-002 — Trạng thái đang tải dữ liệu (Loading State / Shimmer / Progress Indicator)
- **Module:** UI
- **Ưu tiên:** P2
- **Loại:** Trải nghiệm người dùng
- **Tham chiếu:** Spec UI/UX Mục Trạng thái màn hình
- **Endpoint / Màn hình:** Màn hình Danh sách Điểm danh / Danh sách Bài tập
- **Tiền điều kiện:** Mạng có độ trễ (throttling 3G)
- **Dữ liệu vào:** Chuyển tab hoặc tải dữ liệu
- **Các bước:**
  1. Mở màn hình khi API đang phản hồi chậm
- **Kết quả mong đợi:** Hiển thị hiệu ứng shimmer hoặc vòng quay tải dữ liệu mượt mà; không bị nháy trắng màn hình hoặc đơ cảm ứng; không cho phép bấm đúp gây duplicate request
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-UI-003 — Trạng thái danh sách rỗng (Empty State)
- **Module:** UI
- **Ưu tiên:** P2
- **Loại:** Giao diện
- **Tham chiếu:** Spec UI/UX Mục Trạng thái rỗng
- **Endpoint / Màn hình:** Màn hình Đơn xin nghỉ phép / Màn hình Bài tập
- **Tiền điều kiện:** Học sinh chưa có bài tập nào hoặc phụ huynh chưa có đơn xin nghỉ
- **Dữ liệu vào:** Mở danh sách rỗng
- **Các bước:**
  1. Vào màn hình không có dữ liệu
- **Kết quả mong đợi:** Hiển thị hình minh họa và thông điệp thân thiện rõ ràng (VD: "Chưa có bài tập nào được giao" hoặc "Chưa có đơn xin nghỉ phép"), không để màn hình trống trơn
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-UI-004 — Trạng thái mất kết nối mạng (No Internet / Network Error)
- **Module:** UI
- **Ưu tiên:** P1
- **Loại:** Xử lý ngoại lệ UI
- **Tham chiếu:** Spec UI/UX Mục Lỗi mạng
- **Endpoint / Màn hình:** Toàn bộ ứng dụng
- **Tiền điều kiện:** Thiết bị bật Chế độ máy bay (Airplane mode) hoặc ngắt Wifi/4G
- **Dữ liệu vào:** Thực hiện thao tác gọi API
- **Các bước:**
  1. Tắt kết nối mạng trên thiết bị
  2. Bấm làm mới (Pull-to-refresh) hoặc chuyển màn hình
- **Kết quả mong đợi:** Hiển thị banner/hộp thông báo màu vàng/đỏ: "Không có kết nối Internet. Vui lòng kiểm tra lại mạng", kèm nút "Thử lại"; ứng dụng không bị crash văng ra ngoài
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-UI-005 — Hộp thoại xác nhận trước các hành động không thể hoàn tác (Confirmation Dialog)
- **Module:** UI
- **Ưu tiên:** P1
- **Loại:** Bảo vệ dữ liệu người dùng
- **Tham chiếu:** Spec UI/UX Mục Hộp thoại xác nhận
- **Endpoint / Màn hình:** Nộp bài tập chính thức, Hủy đơn nghỉ phép, Đăng xuất
- **Tiền điều kiện:** Học sinh chuẩn bị bấm "Nộp bài"
- **Dữ liệu vào:** Bấm nút "Nộp bài"
- **Các bước:**
  1. Bấm nút nộp bài
- **Kết quả mong đợi:** Xuất hiện hộp thoại popup xác nhận: "Bạn có chắc chắn muốn nộp bài? Sau khi nộp, bạn sẽ không thể chỉnh sửa câu trả lời.", gồm 2 nút: "Hủy" và "Xác nhận nộp"
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-UI-006 — Tuân thủ quy chuẩn thiết kế Spec Phase 1 (Màu sắc, Typography, Phẳng)
- **Module:** UI
- **Ưu tiên:** P2
- **Loại:** Thẩm mỹ / Design System
- **Tham chiếu:** Mục 6.10 ("màu, chữ, khoảng cách, góc vuông, không bóng đổ hay chuyển màu")
- **Endpoint / Màn hình:** Toàn bộ 53 màn hình Flutter
- **Tiền điều kiện:** Mở giao diện ứng dụng
- **Dữ liệu vào:** Kiểm tra mã màu, góc bo (border radius), shadows
- **Các bước:**
  1. So sánh từng màn hình với Spec UI/UX
- **Kết quả mong đợi:**
  - Đúng palette màu quy định (không dùng màu tùy tiện)
  - Typography đồng nhất theo `AppTextStyles`
  - Thiết kế phẳng rõ ràng, không lạm dụng hiệu ứng bóng đổ (box-shadow) quá đà hay gradient lòe loẹt
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-UI-007 — Kích thước vùng chạm của các nút bấm và icon (Touch Target Size)
- **Module:** UI
- **Ưu tiên:** P2
- **Loại:** Khả năng tiếp cận (Accessibility / WCAG)
- **Tham chiếu:** Mục 6.10 ("nút bấm đủ lớn"); Material Design standard >= 48x48dp
- **Endpoint / Màn hình:** Nút bấm submit, icon lịch, radio button chọn đáp án
- **Tiền điều kiện:** Mở ứng dụng trên điện thoại màn hình nhỏ (≤ 6 inch)
- **Dữ liệu vào:** Chạm ngón tay thao tác
- **Các bước:**
  1. Bấm vào các nút và tùy chọn radio
- **Kết quả mong đợi:** Vùng chạm tối thiểu đạt 48x48dp; không bị chạm nhầm vào nút bên cạnh; phản hồi chạm (ripple effect) trực quan
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-UI-008 — Khả năng hiển thị khi bật cỡ chữ lớn trong cài đặt hệ thống (Large Text Scaling)
- **Module:** UI
- **Ưu tiên:** P2
- **Loại:** Khả năng tiếp cận (Accessibility)
- **Tham chiếu:** Mục 6.10 ("chữ lớn trong cài đặt hệ thống")
- **Endpoint / Màn hình:** Màn hình Điểm thi, Xem học bạ, Chi tiết bài tập
- **Tiền điều kiện:** Cài đặt điện thoại chỉnh Font Size lên mức Max (130% - 150%)
- **Dữ liệu vào:** Mở ứng dụng với font hệ thống phóng to
- **Các bước:**
  1. Mở màn hình học bạ và làm bài
- **Kết quả mong đợi:** Chữ tự động xuống dòng phù hợp, không bị lỗi tràn viền (RenderFlex overflowed by ... pixels); các bảng dữ liệu có thể cuộn ngang/dọc
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-UI-009 — Hiển thị trên các tỉ lệ màn hình khác nhau và xoay ngang (Responsive Layout)
- **Module:** UI
- **Ưu tiên:** P2
- **Loại:** Giao diện / Thiết bị
- **Tham chiếu:** Mục 2.2 Kế hoạch kiểm thử
- **Endpoint / Màn hình:** Toàn bộ ứng dụng
- **Tiền điều kiện:** Màn hình điện thoại tỉ lệ 16:9, 20:9 và máy tính bảng
- **Dữ liệu vào:** Xoay ngang màn hình hoặc mở trên tablet
- **Các bước:**
  1. Kiểm tra bố cục màn hình
- **Kết quả mong đợi:** Giao diện tự động căn chỉnh khoảng cách, không bị vỡ bố cục; nội dung quan trọng không bị che khuất bởi tai thỏ (Notch) hoặc thanh điều hướng hệ thống
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —

---

### TC-UI-010 — Form Validation trực quan dưới từng trường nhập liệu
- **Module:** UI
- **Ưu tiên:** P2
- **Loại:** Trải nghiệm người dùng
- **Tham chiếu:** Spec UI/UX Mục Biểu mẫu
- **Endpoint / Màn hình:** Màn hình Đổi mật khẩu, Tạo bài tập, Xin nghỉ phép
- **Tiền điều kiện:** Để trống các trường bắt buộc và bấm gửi
- **Dữ liệu vào:** Form rỗng
- **Các bước:**
  1. Bấm nút Submit mà chưa nhập liệu
- **Kết quả mong đợi:** Đường viền ô nhập chuyển sang màu đỏ; dòng chữ báo lỗi hiển thị ngay dưới ô tương ứng (VD: "Vui lòng nhập lý do"); con trỏ tự động focus vào trường lỗi đầu tiên
- **Kết quả thực tế:** Chưa chạy
- **Trạng thái:** Chưa chạy
- **Bằng chứng:** —
- **Lỗi liên quan:** —
