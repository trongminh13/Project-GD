# Intro "sách đi bộ" (Flutter)

Màn chào ngắn khi mở app: cuốn sách vuông đi từ trái vào, vẫy tay, hiện tên app, rồi đi ra phải. Vẽ hoàn toàn bằng `CustomPainter`, không thêm tệp tài nguyên. Chạy được trên Android, iOS và web.

Đặc tả đầy đủ: `intro-sach-di-bo-flutter.md`.

> **Chưa kiểm chứng:** code này chưa được biên dịch hay chạy test trong môi trường tạo ra nó (không có Flutter SDK). Hãy chạy `flutter analyze` và `flutter test` trước khi dùng, và đo hiệu năng trên máy thật như mục 10 của đặc tả.

## Cấu trúc

```
lib/core/intro/
  book_mascot_painter.dart   Painter vẽ sách + IntroPalette (bảng màu)
  intro_gate.dart            Widget bọc màn đầu tiên, điều khiển thời gian
  intro_policy.dart          Quy tắc hiện/ẩn (6 giờ, công tắc tắt) bằng shared_preferences
  intro_setting_tile.dart    Công tắc "Hiệu ứng mở app" cho màn Cài đặt
test/core/intro/
  book_mascot_painter_test.dart
  intro_gate_test.dart
  intro_policy_test.dart
```

Có thể đổi thư mục `core/intro` theo cấu trúc dự án. Sau khi chép vào, sửa `your_app` trong các file test thành tên package thật.

## Thư viện

Chỉ cần `shared_preferences`. Nếu dự án chưa có, thêm vào `pubspec.yaml` (hỏi lại nhóm trước, theo quy tắc dự án):

```yaml
dependencies:
  shared_preferences: ^2.2.0   # chọn phiên bản tương thích với dự án
```

## Cách gắn vào app

Bọc màn đầu tiên bằng `IntroGate`. `ready` là Future của việc khởi động thật (đọc phiên đăng nhập, cấu hình). Nó phải bắt đầu chạy **trước** khi `IntroGate` dựng, để chạy song song với intro.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.bootstrap});

  final Future<void> bootstrap; // ví dụ: đọc token, nạp cấu hình. KHÔNG gọi mạng chỉ để phục vụ intro.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IntroGate(
        ready: bootstrap,
        appName: 'Đại Việt',                       // lấy từ chuỗi bản địa hóa
        tagline: 'Ứng dụng nhà trường',          // có thể bỏ
        semanticsLabel: 'Ứng dụng nhà trường. Chạm để bỏ qua phần giới thiệu',
        skipHint: 'Chạm để bỏ qua',              // có thể bỏ
        builder: (context) => const AuthGate(),  // màn kế tiếp của bạn
      ),
    );
  }
}
```

Nếu dự án dùng `go_router` hoặc `Navigator 2`, đặt `IntroGate` làm màn gốc bọc router, hoặc làm route đầu tiên rồi chuyển hướng trong `builder`. Điều quan trọng là `IntroGate` chỉ được dựng khi app khởi động nguội, để quy tắc "không hiện khi quay lại từ nền" đúng.

Công tắc trong Cài đặt:

```dart
IntroSettingTile(
  title: 'Hiệu ứng mở app',
  subtitle: 'Hiện hoạt ảnh ngắn khi mở ứng dụng',
)
```

## Hành vi cần biết

| Tình huống | Kết quả |
|---|---|
| Lần đầu cài | Hiện đủ (2 giây trên app, 1 giây trên web) |
| Mở lại trong vòng 6 giờ | Không hiện |
| Mở lại sau 6 giờ | Hiện |
| Công tắc "Hiệu ứng mở app" tắt | Không bao giờ hiện |
| Chạm màn hình | Vào màn kế tiếp ngay, chỉ một lần |
| Hệ điều hành bật giảm chuyển động | Hình sách đứng yên khoảng 0,7 giây rồi vào |
| Khởi động chưa xong khi vẫy xong | Giữ tư thế tối đa 1 giây, rồi vào màn kế tiếp ở trạng thái đang tải |
| Khởi động lỗi | Không chặn. Màn kế tiếp tự xử lý lỗi |

Các hằng số có thể chỉnh: `duration`, `holdLimit`, `reducedMotionDuration` (tham số của `IntroGate`), `minGap` (tham số của `SharedPrefsIntroPolicy`).

## Lưu ý cho từng nền tảng

* **Web:** Flutter chỉ hiện sau khi engine nạp xong, nên intro bắt đầu muộn hơn lúc mở trang. Mặc định web chạy 1 giây. Nếu đo thấy nặng trên iOS Safari, truyền `policy` luôn trả `false` khi `kIsWeb`. `disableAnimations` trên web lấy từ `prefers-reduced-motion`; hãy thử trên iOS Safari thật.
* **Android và iOS:** đặt màu nền màn hình khởi động gốc (native splash) trùng `#FFFFFF` để không bị nháy giữa màn gốc và intro.
* **Backend Java:** không cần thay đổi gì. Intro chạy hoàn toàn ở client và không gọi API.

## Việc cần làm sau khi chép vào

1. Đổi `your_app` trong các file test, chạy `flutter analyze` và `flutter test`.
2. Map `IntroPalette` sang hằng số màu của dự án.
3. Chuyển chuỗi (`appName`, `tagline`, nhãn trợ năng) sang hệ thống bản địa hóa.
4. Đo hiệu năng trên iPhone thật ở chế độ `--profile` (mục 10 của đặc tả).
