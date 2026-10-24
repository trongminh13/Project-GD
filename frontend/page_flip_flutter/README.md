# Lật trang sách một mặt (Flutter + Java)

Một trang trên màn hình. Vuốt từ phải sang trái, góc dưới bên phải nhấc lên rồi gập sang trái để sang trang sau. Vuốt từ trái sang phải để quay lại. Chạy trên Android, iOS và web.

Bản mẫu để xem cảm giác: trang "Lật Trang Sách" đã đăng trong phiên làm việc (bản canvas trên trình duyệt, dùng cùng công thức hình học).

> **Chưa kiểm chứng:** mã Flutter và Java chưa được biên dịch hay chạy test trong môi trường tạo ra nó (không có Flutter SDK và JDK với PDFBox). Đã kiểm tra: cú pháp của các file Dart, và các tính chất hình học chính bằng bản Python tương đương (phản chiếu góc về đúng điểm kéo, hai phần cộng lại bằng diện tích trang). Hãy chạy `flutter analyze` và `flutter test`, rồi đo trên máy thật như mục "Đo hiệu năng".

## Cấu trúc

```
lib/core/page_flip/
  fold_geometry.dart       Hình học nếp gập (hàm thuần, test được)
  page_fold_painter.dart   CustomPainter + PageFrame (mỗi khung tối đa 3 lần vẽ ảnh)
  page_image_window.dart   Cửa sổ ảnh 3 trang, giải mã đúng kích thước, giải phóng trang ngoài cửa sổ
  page_flip_view.dart      Widget: cử chỉ, hoạt ảnh, chạm, bàn phím, trợ năng, giảm chuyển động
test/core/page_flip/       Test đơn vị và test widget
example/page_flip_demo.dart  Chạy thử không cần backend (ảnh trang vẽ bằng code)
backend/PageRenderService.java  Vẽ trang PDF thành JPEG theo cỡ định sẵn (điểm xuất phát)
```

Sau khi chép vào dự án, đổi `your_app` trong các file test và `example` thành tên package thật. Không cần thư viện mới, chỉ dùng Flutter SDK (cần Flutter 3.18 trở lên vì dùng `onKeyEvent`).

## Chạy thử

```
flutter run -t example/page_flip_demo.dart
flutter analyze
flutter test test/core/page_flip
```

## Cách dùng

```dart
final controller = PageFlipController();

PageFlipView(
  pageCount: totalPages,                 // từ API siêu dữ liệu
  aspectRatio: pageAspect,               // rộng/cao, mặc định A4 dọc
  controller: controller,                // để gắn nút "Trang sau/Trước" nếu cần
  hintOnOpen: isFirstTimeOpeningBook,    // nhấc góc một lần để gợi ý cử chỉ
  onPageChanged: (page) => saveProgress(page),
  source: BytesPageImageSource((pageIndex, widthPx) async {
    // Gọi API của bạn, trả về byte JPEG. Gắn token, xử lý lỗi, bộ nhớ đệm đĩa ở đây.
    return api.getPageBytes(fileId, pageIndex, widthPx);
  }),
);
```

`PageImageSource` là interface, nên có thể thay bằng nguồn riêng (bộ nhớ đệm đĩa, ảnh cục bộ).

## Quy tắc tương tác (đã cài)

| Hành động | Kết quả |
|---|---|
| Vuốt phải sang trái, bắt đầu ở 70% bên phải trang | Sang trang sau |
| Vuốt trái sang phải, bắt đầu ở 70% bên trái trang | Về trang trước |
| Thả tay khi góc đã qua khoảng 55% trang, hoặc vuốt nhanh trên 700 px/s | Lật hết |
| Thả sớm | Gập về chỗ cũ |
| Chạm 40% bên phải / trái | Sang trang sau / về trang trước |
| Phím mũi tên phải / trái (web, máy tính) | Sang trang sau / về trang trước |
| Trợ năng: tăng / giảm | Sang trang sau / về trang trước |
| Hệ điều hành bật giảm chuyển động | Mờ dần 140 ms, không gập |
| Ảnh trang đích chưa tải xong | Bỏ qua thao tác (không nhấp nháy). Hiện vòng tải nếu trang hiện tại chưa có ảnh |

Các hằng số có thể chỉnh: `flipDuration`, `liftFactor`, `shadow`, `backColor`, `maxDecodeWidth`, `thumbWidth` (tham số của `PageFlipView`). Ngưỡng 0,55 / 0,4 / 0,7 nằm trong `_finishDrag` của `page_flip_view.dart`.

## RAM, độ trễ (ước tính, chưa đo)

* Giải mã **đúng kích thước màn hình** (`targetWidth` tối đa 1080 trên app, 900 trên web).
* Giữ **3 trang** (trước, hiện tại, sau). Một ảnh khoảng 6 đến 8 MB, tổng khoảng 20 đến 25 MB và **không tăng theo số trang**.
* Chỉ giải mã **một ảnh một lúc** để đỉnh RAM thấp. Ảnh nhỏ (360 px) của cả cửa sổ tải trước, rồi mới tải ảnh đầy đủ theo thứ tự trang hiện tại, trang sau, trang trước.
* Mặt sau của trang gập dùng lại ảnh trang, không giải mã thêm.
* Ảnh ngoài cửa sổ được `dispose()` sau khung hình hiện tại, để không dùng ảnh đã hủy.
* Không dùng `Opacity`, `saveLayer`, shader. Chỉ tạo `Paint` mới trong khung hình khi bật bóng.
* Khi đứng yên không có vòng lặp vẽ (painter chỉ vẽ lại khi trạng thái hoặc ảnh đổi).

Nếu cần nhẹ hơn nữa cho máy yếu: hạ `maxDecodeWidth` (ví dụ 720). Không đặt `radius` về 0, vì khi đó trang kế tiếp không được tải trước và mọi thao tác lật sẽ bị bỏ qua cho đến khi ảnh về.

## Hợp đồng với backend Java

Dùng lại API trang đã bàn trước, bổ sung:

| Việc | Cách làm |
|---|---|
| Hai cỡ ảnh | `GET .../files/{fileId}/pages/{page}?w=360` và `?w=1080`. Chỉ nhận các cỡ định sẵn (`PageRenderService.ALLOWED_WIDTHS`) |
| Siêu dữ liệu | `GET .../files/{fileId}/pages` trả số trang và tỷ lệ rộng/cao từng trang (`PageRenderService.pageInfos`) để app dựng bố cục trước khi ảnh về |
| Vẽ sẵn | Vẽ và lưu các cỡ lúc xuất bản học liệu, không vẽ khi người dùng đọc |
| Bộ nhớ đệm | `ETag`, `Cache-Control: private`, URL có phiên bản nội dung |
| Quyền truy cập | Kiểm tra quyền xem học liệu cho mỗi lượt, như đã thống nhất |
| Giới hạn tốc độ | Giới hạn số yêu cầu mỗi người dùng để vòng tải trước không gây bão yêu cầu |

JPEG chất lượng 80 là mặc định (có sẵn trong Java). WebP nhỏ hơn khoảng 25 đến 35% nhưng cần thư viện ngoài JDK, để pha sau.

Phía app: `BytesPageImageSource` chưa hủy được yêu cầu mạng đang chạy. Nếu dùng Dio, truyền `CancelToken` trong `PageBytesLoader` và hủy khi trang rời cửa sổ. `PageImageWindow` đã bỏ qua kết quả của trang ngoài cửa sổ.

## Đo hiệu năng (bắt buộc trên máy thật, chế độ `--profile`)

1. **Khung hình:** DevTools, tab Performance, khi kéo và khi hoàn tất lật. Mục tiêu dưới 16,6 ms ở 60 Hz, dưới 8,3 ms ở 120 Hz.
2. **RAM:** tab Memory, đọc liên tục 50 trang. `PageImageWindow.heldCount` không quá 3 và RAM đỉnh không tăng theo số trang.
3. **Độ trễ:** thời gian từ lúc mở sách đến lúc thấy ảnh nhỏ, và thời gian chờ mạng khi lật tuần tự (mục tiêu: không chờ).
4. Thiết bị tối thiểu: một iPhone thật, một Android tầm trung, và iOS Safari nếu hỗ trợ web. Ghi đủ máy, số lần đo, cách đo.

Nếu web iOS Safari quá nặng: giảm `maxDecodeWidth`, hoặc truyền `reducedMotion: true` để dùng mờ dần thay vì gập.

## Chưa có trong bản đầu

* Phóng to bằng hai ngón (sẽ xung đột với vuốt, cần thiết kế riêng).
* Mỗi trang một tỷ lệ khác nhau (hiện dùng một `aspectRatio` cho cả sách).
* Hủy yêu cầu mạng đang chạy (xem trên).
* Chặn chụp màn hình (câu hỏi mở với sản phẩm).
* Bóng ở nếp gập mặc định tắt. Bật bằng `shadow: true` nếu thiết kế đồng ý.

## Việc cần làm sau khi chép vào

1. Đổi `your_app` trong test và example, chạy `flutter analyze` và `flutter test`.
2. Nối `BytesPageImageSource` vào API thật (token, lỗi, bộ nhớ đệm đĩa).
3. Map màu `paperColor` và `backColor` sang hằng số màu dự án.
4. Chuyển nhãn trợ năng (`semanticsLabel`) sang hệ thống bản địa hóa.
5. Đo hiệu năng như trên.
