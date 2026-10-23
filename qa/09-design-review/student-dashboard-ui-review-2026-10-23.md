# Đánh giá Product Design & QA: Dashboard học sinh Tiểu học

**Ngày:** 23/10/2026  
**Đối tượng:** Dashboard học sinh, tập trung vào thẻ nhận diện linh vật dành cho Cấp 1  
**Mục đích:** Tổng hợp đánh giá nghiêm khắc, rủi ro sản phẩm và hướng cải thiện để QA/Product/Design cùng rà soát.

## Tóm tắt cho QA team

- **Cảm giác “AI/template”: khoảng 70% (ước lượng chủ quan).** Đây là cảm nhận về phong cách giao diện, không phải tỷ lệ code/thiết kế do AI tạo. Không thể xác định tác giả chỉ từ UI hoặc code.
- **Mức hoàn thiện sản phẩm hiện tại: khoảng 5/10.** Có ý tưởng phù hợp học sinh nhỏ tuổi, nhưng còn giống prototype/demo hơn giao diện phát hành.
- **Rủi ro cần ưu tiên:** dữ liệu mẫu có thể xuất hiện trước dữ liệu thật; thời khóa biểu ở chế độ thật có thể bị báo trống; lịch tuần dùng ngày neo cứng.
- **Phạm vi đánh giá:** đọc mã nguồn hiện tại. Chưa chạy app, chưa xác minh trên thiết bị thật và chưa kiểm thử các luồng bằng tài khoản.
- **Không có thay đổi code trong lần rà soát này.**

## Điểm tốt đang có

- Thẻ riêng cho học sinh Tiểu học thể hiện ý định thiết kế theo lứa tuổi, thay vì dùng cùng một header cho mọi cấp học.
- Mascot được vẽ bằng vector trong Flutter, không phụ thuộc ảnh raster; ý tưởng tạo cảm giác thân thiện.
- Thông tin lớp, học sinh và giáo viên được đưa lên đầu trang, phù hợp nhu cầu nhận diện nhanh.
- Có trạng thái rỗng và thông báo Demo ở một số khu vực; đây là nền tảng tốt nếu nội dung được phân biệt chính xác giữa dữ liệu thật, dữ liệu mẫu và lỗi tải.

## Phát hiện cần xử lý

Mức độ dưới đây là mức ưu tiên product/QA đề xuất, không phải phân loại severity theo quy trình chính thức của dự án.

| ID | Ưu tiên | Phát hiện | Tác động / cách xác minh | Hướng xử lý |
|---|---|---|---|---|
| DATA-01 | **P0 – trước phát hành** | Dashboard gán hồ sơ, điểm danh, điểm, bài tập, học liệu và thông báo mẫu ngay khi bắt đầu tải; sau đó mới gọi API. | Có thể hiện nhầm dữ liệu mẫu hoặc dữ liệu không thuộc học sinh trong thời gian chờ API/lúc API lỗi. Kiểm tra tài khoản thật trên mạng chậm, API timeout và API trả lỗi từng phần. | Chỉ dùng dữ liệu tổng hợp trong chế độ Demo rõ ràng. Ở chế độ thật, dùng skeleton/trạng thái tải hoặc cache gắn đúng tài khoản; tuyệt đối không giữ fallback mẫu như dữ liệu thật. |
| SCH-01 | **P1 – chức năng chính** | Trang chủ chỉ lấy lịch mẫu khi `FeatureFlags.useDemoFallback` bật; nhánh còn lại gán danh sách rỗng. Service `getMyTimetable()` có tồn tại nhưng không được dashboard gọi. | Chế độ thật có thể luôn hiện “Hôm nay không có tiết”, kể cả khi học sinh có lịch. Kiểm tra cùng một học sinh có lịch ở tab Lịch và ở trang chủ trong Demo/Live. | Nạp lịch thật, lọc đúng ngày và dùng trạng thái riêng cho “không có lịch”, “đang tải”, “không tải được”. |
| SCH-02 | **P1 – dữ liệu sai** | Lịch tuần dùng ngày cơ sở cố định `DateTime(2026, 10, 12)` trong khi nhãn “hôm nay” tính từ ngày hiện tại và week offset. | Ngày trên lịch có thể không khớp ngày được đánh dấu hôm nay. Kiểm tra ở tuần hiện tại và khi chuyển tuần. | Tính đầu tuần từ ngày hiện tại và offset; không neo lịch sản phẩm vào một ngày literal. |
| DATA-02 | **P1 – độ tin cậy** | Dữ liệu fallback có thông tin không nhất quán với tài liệu tài khoản demo. README mô tả `student01` là Nguyễn Minh Anh; nhánh fallback Cấp 1 mặc định Hoàng Văn Thư nếu `userData['name']` không có. Nhánh THPT có Lê Hoàng Long nhưng giới tính Nữ. | QA có thể thấy tài khoản, lớp hoặc hồ sơ khác nhau tùy trường dữ liệu có được trả về hay không. Giảm niềm tin vào sản phẩm/dữ liệu. | Tạo fixture demo duy nhất, có schema rõ ràng; xác nhận tên/lớp/cấp học/giới tính/mã học sinh trên mọi đường vào Demo và Live. |
| UI-01 | **P1 – responsive** | Thẻ chia cứng 62% nội dung / 38% mascot; thông tin tên học sinh và giáo viên chỉ hiển thị một dòng, ellipsis. | Màn hình nhỏ hoặc tên dài có thể mất thông tin quan trọng; hàng lớp/ngày bị chật. Kiểm tra độ rộng 320, 360, 390, 480 px và tăng cỡ chữ hệ thống. | Có breakpoint đổi sang bố cục dọc hoặc giảm mascot; ưu tiên hiển thị trọn tên; không thu nhỏ chữ để ép vừa. |
| NAV-01 | **P2 – discoverability** | Drawer có cấu hình vuốt từ cạnh trái nhưng không thấy nút menu mở drawer trong dashboard. | Người dùng khó biết drawer tồn tại; các mục trong đó có thể không được tìm thấy. | Thêm nút menu có nhãn truy cập được hoặc bỏ drawer nếu không có chức năng cần thiết. |
| NAV-02 | **P2 – mật độ điều hướng** | Thanh dưới có sáu mục cố định: Trang chủ, Lịch học, Sách học, Bài tập, Bảng điểm, Thông báo. | Chật trên điện thoại, đặc biệt với người dùng nhỏ tuổi; khó chọn nhanh. | Thử nhóm còn 4–5 mục theo tần suất; gom chức năng phụ vào “Tiện ích”. Kiểm tra trên thiết bị hẹp trước khi chốt. |
| UI-02 | **P2 – trạng thái Demo** | Có banner toàn cục dựa trên `ApiConstants.isDemoMode` và banner trong trang chủ dựa trên `FeatureFlags.useDemoFallback`. | Nếu cả hai flag cùng bật, nội dung Demo bị lặp hai lần và chiếm chiều cao. | Chọn một vị trí thông báo Demo; thống nhất định nghĩa giữa hai flag. QA xác minh từng tổ hợp flag. |
| UI-03 | **P2 – hành động lặp** | Đăng xuất có trong thẻ Cấp 1 và ở cuối trang chủ; ở header các cấp khác còn có thêm nút đăng xuất. | Tạo hành động thừa; nút ở cuối trang cần cuộn xa mới thấy. | Đặt đăng xuất trong khu vực tài khoản/tiện ích; không lặp trong nội dung học tập. |
| UI-04 | **P2 – affordance** | Vùng nội dung chính của thẻ mascot mở Tiện ích khi chạm; bên dưới lại có nút Tiện ích riêng. | Người dùng không biết toàn bộ thẻ có thể bấm hay chỉ nút. Có thể mở nhầm bottom sheet. | Chỉ để nút có affordance mở Tiện ích; giữ phần thông tin là nội dung không tương tác. |
| UI-05 | **P2 – thông tin mơ hồ** | Thẻ hiển thị nhãn “NGÀY” nhưng giá trị được truyền là ngày hiện tại. | Người dùng có thể hiểu nhầm là ngày sinh hoặc ngày liên quan đến hồ sơ. | Bỏ ngày khỏi thẻ nhận diện; nếu cần, đặt ngày trong tiêu đề lịch với định dạng rõ, ví dụ “Thứ Sáu, 23/10”. |
| IA-01 | **P2 – ưu tiên nội dung** | Trang chủ hiển thị “Sách đọc mới” trước “Bài tập cần làm”. | Việc cần hoàn thành có thể bị đẩy xuống dưới nội dung ít cấp bách hơn. | Ưu tiên bài sắp đến hạn, sau đó lịch hôm nay; học liệu mới ở dưới. Xác nhận thứ tự qua nhu cầu học sinh/giáo viên. |
| VIS-01 | **P3 – bản sắc thị giác** | 10 mascot dùng cùng cấu trúc/pose, màu gán theo hash tên + ngày sinh; nhãn và khẩu hiệu cũng theo mẫu. | Tạo cảm giác bộ minh họa template, màu sắc không gắn ý nghĩa rõ và chưa thành nhận diện Astra. | Dùng một bộ mascot Astra có quy tắc/biểu cảm riêng; màu thương hiệu ổn định; mascot hỗ trợ nội dung thay vì trang trí mọi chỗ. |
| VIS-02 | **P3 – trang trí chồng lớp** | Nền ảnh trường làm mờ, phủ trắng, thẻ trắng có bóng/viền và các ô con tiếp tục có viền màu. | Nhiều lớp hiệu ứng nhưng không tăng thứ bậc thông tin; dễ tạo cảm giác giao diện ghép mẫu. | Thử nền trung tính, giảm bóng và bỏ các khung lồng nhau; chỉ dùng card khi nhóm nội dung hoặc hành động cần được tách. |

## Đề xuất hướng thiết kế

### Hướng: “Sổ tay học tập Astra”

Đây là cổng học tập của trường, không phải game. Giữ nét vui vẻ cho học sinh nhỏ nhưng để bài tập/lịch học là nội dung chính.

1. **Header:** “Chào Minh Anh!”; dòng phụ “Lớp 1A · Cô Lan”. Mascot Astra nhỏ bên cạnh lời chào. Không dùng bốn ô viền để trình bày thông tin hồ sơ.
2. **Khối đầu tiên:** “Bài tập cần làm” với số lượng, môn, hạn nộp và một nút chính như “Làm tiếp”.
3. **Khối kế tiếp:** “Lịch học hôm nay”, lấy từ lịch thật và có trạng thái tải/lỗi/không có tiết riêng.
4. **Khối sau:** “Sách của lớp” hoặc học liệu mới; ngắn gọn hơn việc cần làm.
5. **Điều hướng:** thử 4 mục chính (Trang chủ, Lịch, Học tập, Tiện ích) hoặc tối đa 5 mục; giữ thông báo dễ tìm bằng biểu tượng chuông có nhãn/badge.

### Nguyên tắc thị giác để giảm cảm giác “AI/template”

- Dùng màu Astra làm màu chủ đạo cố định. Dùng màu phụ có ý nghĩa trạng thái (ví dụ sắp đến hạn), không đổi toàn bộ giao diện theo linh vật được hash ngẫu nhiên.
- Chọn một họ mascot riêng, giữ nét vẽ, tỷ lệ, biểu cảm và cách dùng nhất quán. Không cần minh họa mọi thẻ.
- Bỏ tổ hợp nhãn in hoa + viền dày + card lồng card. Dùng thứ bậc chữ, căn lề và khoảng trắng để phân nhóm.
- Dùng câu chữ ngắn, thân thiện, gắn với dữ liệu thật: “Em còn 2 bài cần hoàn thành” thay vì khẩu hiệu chung như “Bạn Gấu Dũng Cảm”.
- Dùng nền ít cạnh tranh; giảm blur, overlay và bóng nếu chúng không làm nội dung dễ hiểu hơn.
- Giữ nút chạm đủ lớn và kiểm tra tương phản, cỡ chữ, tên dài, cỡ chữ hệ thống.
- Không dùng ngày sinh làm đầu vào chọn mascot nếu không có lý do sản phẩm dễ hiểu. Nếu vẫn dùng, không hiển thị hoặc tiết lộ ngày sinh qua key/log/chia sẻ; cân nhắc cho học sinh tự chọn nhân vật hoặc dùng mascot chung.

## Tham khảo thiết kế bên ngoài

- [Khan Academy Kids](https://learn.khanacademy.org/khan-academy-kids/): tham khảo cách duy trì nhóm nhân vật có nhận diện xuyên suốt và gắn chúng với hành trình học; không sao chép bố cục/game hóa của họ.
- [Duolingo ABC – How we teach](https://abc.duolingo.com/how-we-teach): tham khảo nguyên tắc vui vẻ phục vụ một hoạt động học cụ thể, bài học ngắn và có tiến trình; không biến mọi khu vực của cổng trường thành trò chơi.
- [Apple Human Interface Guidelines – Layout](https://developer.apple.com/design/human-interface-guidelines/layout): tham khảo thứ bậc nội dung, grouping, progressive disclosure và khả năng thích ứng kích thước màn hình.
- [Apple UI Design Dos and Don’ts](https://developer.apple.com/design/tips/): tham khảo vùng chạm, độ đọc, tương phản, căn chỉnh và bố cục vừa màn hình.

Đây là nguyên tắc tham khảo để áp dụng vào Astra, không phải bằng chứng rằng một phong cách cụ thể sẽ phù hợp nếu chưa thử với học sinh/giáo viên của trường.

## Checklist QA đề xuất

### Dữ liệu và trạng thái tải

- [ ] Tài khoản Live không nhìn thấy tên/điểm/bài tập/lịch mẫu trong thời gian API đang tải.
- [ ] API lỗi không biến thành trạng thái “không có bài” hoặc “không có tiết” nếu thực tế chưa xác định được dữ liệu.
- [ ] Chế độ Demo luôn được đánh dấu rõ, nhưng không xuất hiện hai banner lặp.
- [ ] Dữ liệu từng tài khoản Demo nhất quán với danh sách credential và hồ sơ hiển thị.
- [ ] Lịch trang chủ, tab lịch và nhãn ngày cùng phản ánh một nguồn dữ liệu và cùng một tuần.
- [ ] Kiểm tra lịch vào Thứ Hai, Thứ Sáu, cuối tuần, tháng/năm mới và khi đổi offset tuần.

### Responsive và khả năng dùng

- [ ] Kiểm tra thẻ ở 320/360/390/480 px; tên học sinh/giáo viên dài không bị mất hoặc che mascot.
- [ ] Kiểm tra cỡ chữ hệ thống lớn và thiết bị có safe area.
- [ ] Sáu tab hiện tại không bị cắt/khó chạm trên màn hình nhỏ; xác minh phương án rút gọn điều hướng.
- [ ] Drawer có nút mở rõ ràng hoặc được loại bỏ; thao tác vuốt không phải cách duy nhất.
- [ ] Chạm vùng thông tin thẻ không mở nhầm Tiện ích; nút Tiện ích và Đăng xuất có vùng chạm dễ dùng.
- [ ] Không lặp Đăng xuất ở nhiều vị trí trong cùng trang chủ.
- [ ] “NGÀY” được thay bằng nhãn có nghĩa hoặc được bỏ khỏi thẻ.

### Thứ bậc nội dung và thị giác

- [ ] Bài cần nộp/sắp đến hạn được ưu tiên hơn học liệu mới nếu đây là mục tiêu chính của học sinh.
- [ ] Học sinh phân biệt được nội dung, trạng thái và nút hành động mà không dựa riêng vào màu.
- [ ] Màu mascot và màu trạng thái đạt độ đọc tốt trên nền trắng.
- [ ] Card, viền, bóng và nền ảnh không tạo cảm giác nhiều lớp trang trí hơn nội dung.
- [ ] Mascot có cùng phong cách và không làm giảm không gian cho thông tin quan trọng.

## File liên quan trong repo

- `frontend/lib/features/student/widgets/mascot/primary_animal_identity_card.dart` — thẻ Cấp 1, bố cục, tương tác và nút.
- `frontend/lib/features/student/widgets/mascot/animal_mascot_data.dart` — danh sách linh vật, màu, lời chào và hash.
- `frontend/lib/features/student/widgets/mascot/animal_mascot_painter.dart` — phần vẽ vector mascot.
- `frontend/lib/features/student/screens/student_dashboard_screen.dart` — dữ liệu fallback, tải dữ liệu, dashboard, banner, navigation và lịch.
- `frontend/lib/core/services/student_portal_service.dart` — API lịch học hiện có.
- `frontend/animal-card.html` — prototype HTML tham khảo cho thẻ.

