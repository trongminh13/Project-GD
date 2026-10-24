# ĐẶC TẢ: MÀN INTRO "SÁCH ĐI BỘ" (Flutter)

Tài liệu giao cho dev. Bản tham chiếu hình ảnh và nhịp thời gian là màn intro trong demo mobile (`App-Mobile.dc.html`, màn `intro`). Đây là mô phỏng bằng web, không phải bằng chứng về hiệu năng. Hiệu năng phải đo trên Flutter thật.

---

## 1. Mục tiêu và phạm vi

* Màn chào ngắn khi mở app: cuốn sách vuông đi từ cạnh trái vào giữa, vẫy tay, hiện tên app, rồi đi ra cạnh phải. Sau đó vào màn tiếp theo (đăng nhập, hoặc trang chủ nếu đã có phiên).
* Chạy song song với việc khởi động thật, không làm app vào chậm hơn mức cần thiết.
* **Ngoài phạm vi:** không sửa API, xác thực, hay luồng đăng nhập. Không thêm thư viện. Không đổi cấu hình CI hay build.

## 2. Ràng buộc bắt buộc

1. **Không thêm thư viện mới** (không Lottie, Rive). Chỉ dùng Flutter SDK. Nếu cần `shared_preferences` mà dự án chưa có, hỏi trước rồi mới thêm.
2. **Không tải tài nguyên:** không ảnh, không tệp animation, không font riêng. Toàn bộ vẽ bằng `CustomPainter`.
3. **Không gọi mạng** trong intro. Không dựa vào kết quả mạng để quyết định hiện hay không hiện.
4. **Phong cách:** góc vuông, màu phẳng. Cấm gradient, bóng đổ, blur, `Opacity` bao quanh cả cây widget, `ClipRRect`, `BoxShadow`.
5. **Không sửa** các file ngoài danh sách ở mục 9. Thấy lỗi ở nơi khác thì báo lại, không tự sửa.
6. Không chạy `git commit/push/merge/rebase`. Đưa sẵn câu lệnh để người dùng tự chạy.

## 3. Hình dạng nhân vật (đơn vị tương đối, khung 96 × 114)

Vẽ trong một hệ tọa độ 96 × 114, rồi co theo chiều rộng màn hình: `scale = clamp(size.width * 0.25, 80, 120) / 96`. Chiều cao nhân vật `114 * scale`. Mọi hình đều là hình chữ nhật (`Rect`), không bo góc.

Thứ tự vẽ từ sau ra trước:

| Bộ phận | Hình chữ nhật (x, y, w, h) | Màu |
|---|---|---|
| Chân trái (nhóm `legA`) | thân chân (30, 86, 10, 16) và bàn chân (26, 102, 18, 8) | `#202124` |
| Chân phải (nhóm `legB`) | thân chân (56, 86, 10, 16) và bàn chân (52, 102, 18, 8) | `#202124` |
| Tay trái (nhóm `armL`) | cánh tay (2, 30, 10, 30) và bàn tay (0, 58, 14, 10). Gốc xoay: giữa cạnh trên cánh tay, điểm (7, 30) | `#202124` |
| Thân sách | (12, 8, 72, 78) | `#2457C5` |
| Gáy sách | (12, 8, 10, 78) | `#1D479F` |
| Mép giấy | (22, 80, 62, 6) | `#F5F6F7` |
| Hai dòng tiêu đề trên bìa | (34, 18, 38, 6) và (34, 28, 26, 6) | `#FFFFFF` |
| Mắt trái: lòng trắng, rồi con ngươi | (36, 46, 12, 14), rồi (40, 50, 6, 8) | `#FFFFFF`, `#202124` |
| Mắt phải: lòng trắng, rồi con ngươi | (58, 46, 12, 14), rồi (62, 50, 6, 8) | `#FFFFFF`, `#202124` |
| Miệng | (44, 68, 16, 4) | `#FFFFFF` |
| Tay phải (nhóm `armR`) | cánh tay (84, 30, 10, 30) và bàn tay (82, 58, 14, 10). Gốc xoay: điểm (89, 30) | `#202124` |

Màu lấy từ hằng số của dự án (không viết cứng nếu đã có `AppColors` hoặc tương đương). `#1D479F` là màu primary sẫm hơn đang dùng cho trạng thái hover.

Vẽ nhân vật với `Paint()..isAntiAlias = false` để cạnh sắc nét kiểu pixel. Làm tròn tọa độ đã nhân `scale` về số nguyên để không bị mờ cạnh.

## 4. Nhịp thời gian (tổng 2000 ms, một `AnimationController` duy nhất)

`value` chạy 0 → 1 tuyến tính trong 2000 ms. Mọi thứ khác tính từ `value`, không tạo thêm controller.

| Giai đoạn | Thời gian | Giá trị `value` | Việc xảy ra |
|---|---|---|---|
| Đi vào | 0 – 800 ms | 0 – 0,4 | Sách di chuyển ngang từ ngoài mép trái đến giữa, đường cong `Curves.easeOut`. Vị trí ngang đi từ `-(width/2 + 48*scale)` đến 0 (tính từ tâm) |
| Vẫy tay | 800 – 1400 ms | 0,4 – 0,7 | Sách đứng yên. Tay phải vẫy. Tên app hiện ra |
| Đi ra | 1400 – 2000 ms | 0,7 – 1,0 | Sách di chuyển sang phải đến ngoài mép phải, `Curves.easeIn`. Tên app mờ dần |

Chi tiết từng chuyển động:

* **Nhún thân:** khi đang đi (0 – 0,4 và 0,7 – 1,0) thân nhún lên xuống 4 đơn vị, chu kỳ 200 ms (đi vào có 4 nửa chu kỳ, đi ra có 3).
* **Chân:** mỗi chân nhấc lên 6 đơn vị rồi hạ xuống, chu kỳ 400 ms. Chân phải trễ chân trái 200 ms. Chỉ chuyển động khi đang đi.
* **Tay trái:** đung đưa ±12° quanh gốc, chu kỳ 400 ms, chỉ khi đang đi.
* **Tay phải (vẫy):** trong 600 ms của giai đoạn vẫy, quay theo các mốc 0 → −125° → −155° → −125° → −155° → 0 (tại 0%, 20%, 40%, 60%, 80%, 100% của giai đoạn). Góc âm là quay lên phía ngoài bên phải.
* **Tên app và dòng phụ:** "Đại Việt" (28 sp, đậm 600) và "Ứng dụng nhà trường" (14 sp, màu `#5F6368`) nằm dưới đường nền, **không di chuyển theo sách**. Độ mờ: 0 đến `value` 0,38; lên 1 tại 0,46; giữ 1 đến 0,72; về 0 tại 0,92. Tên và dòng phụ phải lấy từ cấu hình hoặc chuỗi bản địa hóa của app (xem mục 7), không viết cứng.
* **Đường nền:** vạch ngang cao 2 px, màu `#DADCE0`, rộng hết màn hình, nằm sát đáy bàn chân.
* **Nền:** `#FFFFFF`.

Đặt nhân vật cách tâm dọc khoảng 100 đơn vị lên phía trên, giống bản demo, để chừa chỗ cho chữ bên dưới.

## 5. Kiến trúc đề xuất

* `IntroGate` (`StatefulWidget`): bọc màn kế tiếp. Giữ `AnimationController`, đọc `MediaQuery` để biết có giảm chuyển động hay không, quyết định hiện intro hay đi thẳng.
* `BookMascotPainter extends CustomPainter`: nhận `Animation<double>` qua tham số `repaint` của `super`, nên chỉ vẽ lại, không dựng lại cây widget. `shouldRepaint` trả `false` nếu chỉ khác ở `value` (đã xử lý bằng `repaint`).
* Dùng `RepaintBoundary` quanh `CustomPaint` để các phần khác của màn không bị vẽ lại.
* Tạo sẵn các đối tượng `Paint` (một biến `static final` hoặc `final` trong lớp), không tạo `Paint` hay `Path` mới trong `paint()`.
* Không dùng `AnimatedBuilder` bọc cả màn. Chữ "Đại Việt" dùng một `AnimatedBuilder` nhỏ hoặc `FadeTransition` tính từ cùng controller.
* Hủy controller trong `dispose()`.
* Dùng `Semantics` cho cả màn: nhãn "Ứng dụng nhà trường. Chạm để bỏ qua phần giới thiệu". Phần hình vẽ bọc trong `ExcludeSemantics`.

## 6. Quy tắc hiện, ẩn và bỏ qua

1. **Chạm bất kỳ đâu** (`GestureDetector` với `behavior: HitTestBehavior.opaque`) thì dừng animation và vào màn kế tiếp ngay. Phải gọi điều hướng đúng một lần, kể cả khi vừa chạm vừa hết giờ.
2. **Giảm chuyển động:** nếu `MediaQuery.of(context).disableAnimations` là `true` thì hiện sách đứng yên ở giữa cùng chữ trong khoảng 500 – 700 ms, rồi vào màn kế tiếp. Không chạy chuyển động nào.
3. **Tần suất** (lưu bằng `shared_preferences`, hai khóa: `intro_last_shown_at`, `intro_enabled`):
   * Lần đầu cài (chưa có `intro_last_shown_at`): hiện đủ 2 giây.
   * Các lần sau: hiện nếu cách lần hiện trước từ 6 giờ trở lên **và** app khởi động nguội (cold start). Không hiện khi app quay lại từ nền.
   * Nếu `intro_enabled` là `false` (người dùng tắt trong Cài đặt) thì không bao giờ hiện.
   * Ghi `intro_last_shown_at` khi intro **bắt đầu** hiện, không phải khi kết thúc, để chạm bỏ qua vẫn tính là đã xem.
   * Nếu đọc `shared_preferences` lỗi thì mặc định coi như hiện một lần, không để app dừng.
4. **Cờ cấu hình:** có một hằng `introEnabledByDefault` (hoặc cờ tương đương trong cấu hình dự án) để tắt toàn bộ khi cần mà không phải sửa nhiều nơi.
5. **Mục trong Cài đặt:** thêm công tắc "Hiệu ứng mở app" ghi vào `intro_enabled`. Chỉ thêm đúng một dòng công tắc, không đổi bố cục màn Cài đặt.

## 7. Liên hệ với việc khởi động thật

* Việc khởi động (đọc phiên đăng nhập, cấu hình) chạy **song song** từ lúc app mở, không chờ intro bắt đầu.
* Điều hướng sang màn kế tiếp chỉ khi **cả hai** đã xong: animation chạy hết (hoặc bị chạm bỏ qua) **và** khởi động xong.
* Nếu animation hết mà khởi động chưa xong: sách đứng ở tư thế vẫy, nhún nhẹ, tối đa thêm 1 giây. Quá đó thì chuyển sang màn kế tiếp ở trạng thái đang tải (khung chờ/skeleton) của màn đó, không giữ intro thêm.
* **Không giữ người dùng ở intro để chờ mạng.** Nếu bước khởi động có gọi mạng thì phải có timeout riêng của bước đó, độc lập với intro.
* Tên app ("Đại Việt") và dòng phụ lấy từ chuỗi bản địa hóa, không viết cứng trong painter. Nếu tên app thay đổi theo trường, lấy từ cấu hình trường.

## 8. Bản web (Flutter Web, đặc biệt trên iOS Safari)

* Màn hình Flutter chỉ hiện sau khi engine nạp xong, nên intro **bắt đầu muộn hơn** lúc người dùng mở trang. Không dùng intro để che thời gian nạp engine.
* Mặc định trên web dùng **bản rút gọn khoảng 1 giây** (đi vào nhanh, vẫy một lần, vào luôn), hoặc tắt. Quyết định cuối cùng sau khi có số đo (mục 10).
* Không cần giữ trạng thái "6 giờ" trên web: web coi mỗi lần tải trang là cold start, nên trên web nên chỉ hiện ở lần đầu của mỗi phiên trình duyệt (dùng `sessionStorage` thông qua `shared_preferences` web hoặc cờ trong bộ nhớ).
* Trình duyệt di động dùng `prefers-reduced-motion` thông qua `MediaQuery.disableAnimations`. Kiểm tra đã đi đúng nhánh trên iOS Safari.

## 9. Danh sách file dự kiến thay đổi

Dev xác nhận lại tên và đường dẫn thật trong dự án trước khi làm. Báo lại nếu cần sửa thêm file nào khác.

* Tạo mới: `intro_gate.dart` (widget `IntroGate`).
* Tạo mới: `book_mascot_painter.dart` (`BookMascotPainter`).
* Tạo mới: test cho `IntroGate` (mục 11).
* Sửa: nơi khởi động app (file `main.dart` hoặc router) để bọc màn đầu tiên bằng `IntroGate`.
* Sửa: màn Cài đặt, thêm một công tắc "Hiệu ứng mở app".
* Sửa: tệp chuỗi bản địa hóa (nếu có) để thêm nhãn.
* Không sửa: API, xác thực, màn đăng nhập, các màn của vai trò.

## 10. Đo hiệu năng (bắt buộc, trên máy thật)

Chạy ở chế độ **profile** (`flutter run --profile`), không dùng debug.

Thiết bị tối thiểu: một iPhone thật (ghi rõ đời máy và phiên bản iOS) và một máy Android tầm trung (ghi rõ đời máy). Với bản web, đo trên iPhone thật bằng Safari.

Ghi lại cho mỗi thiết bị, mỗi cấu hình (có và không có intro), tối thiểu 10 lần mở app nguội:

* Thời gian từ lúc mở app đến lúc người dùng thao tác được ở màn kế tiếp (ghi cách đo, ví dụ mốc đầu là gì, mốc cuối là gì).
* Số khung hình bị giật (jank) trong 2 giây intro, và thời gian build và raster của mỗi khung (xem trong DevTools, tab Performance).
* Mức RAM trước và sau intro.

**Tiêu chí đạt:**

* Không có khung nào vượt 16 ms ở phần build hoặc raster khi chạy 60 Hz. Mục tiêu dưới 8 ms mỗi phần.
* Thời gian đến lúc dùng được tăng tối đa bằng độ dài intro, và không tăng ở lần mở lại trong 6 giờ.
* Không có đợt tăng RAM rõ rệt nào do intro (dev ghi số liệu).
* Báo cáo ghi đủ máy, số lần đo, cách đo. Không nhận kết quả chỉ ghi "mượt".

Nếu không đạt: giảm độ phức tạp (bỏ dao động tay trái, bỏ nhún thân) trước, rồi mới xét tắt intro trên thiết bị đó.

## 11. Kiểm thử

Test widget (không phụ thuộc thời gian thật, dùng `tester.pump(Duration(...))`):

1. Chạy hết: sau 2000 ms điều hướng đúng một lần sang màn kế tiếp.
2. Chạm bỏ qua ở 500 ms: điều hướng ngay và đúng một lần, không điều hướng lần hai khi hết giờ.
3. Giảm chuyển động (`MediaQuery` với `disableAnimations: true`): không có animation chạy, tự vào màn kế tiếp sau khoảng 700 ms.
4. Quy tắc tần suất: lần đầu hiện, trong 6 giờ không hiện, sau 6 giờ hiện, khi `intro_enabled` là `false` không hiện (giả lập `SharedPreferences` bằng `SharedPreferences.setMockInitialValues`).
5. Khởi động chậm hơn intro: giữ tối đa 1 giây rồi chuyển màn.
6. Hủy controller: không có lỗi khi widget bị gỡ giữa chừng (không còn ticker bị rò).

Ảnh đối chiếu (golden): tối đa 2 đến 3 mốc (0,45 giây khi vừa vào giữa, 1,0 giây khi đang vẫy). Dùng đúng một nền tảng để chạy golden, vì kết quả vẽ lệch giữa các nền tảng.

Chạy `flutter analyze` và toàn bộ test hiện có. Báo kết quả thật, kể cả khi có test thất bại.

## 12. Tiêu chí nghiệm thu tổng

* [ ] Hình dạng và nhịp khớp bản demo (QA đối chiếu bằng mắt, quay video màn hình).
* [ ] Chạm bỏ qua hoạt động ở mọi thời điểm. Chỉ điều hướng một lần.
* [ ] Giảm chuyển động hoạt động trên cả iOS và Android.
* [ ] Quy tắc tần suất đúng, công tắc trong Cài đặt hoạt động.
* [ ] Không thêm thư viện, không thêm tệp tài nguyên.
* [ ] Báo cáo đo hiệu năng đủ theo mục 10, đạt tiêu chí.
* [ ] `flutter analyze` sạch và test đạt, có nhật ký kèm theo.
* [ ] Báo cáo "Modified Files Report" đúng thực tế.

## 13. Câu hỏi còn mở cho người đặt yêu cầu

1. Tên hiển thị trên intro có đúng là "Đại Việt" không, hay tên trường?
2. Có hiện intro cho cả Phụ huynh và Giáo viên, hay chỉ Học sinh (và lần đầu cài)?
3. Bản web: dùng bản rút gọn 1 giây hay tắt hoàn toàn?
4. Dòng phụ "Ứng dụng nhà trường" giữ hay bỏ?
