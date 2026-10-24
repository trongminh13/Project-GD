import 'package:flutter_test/flutter_test.dart';

// Đổi 'your_app' thành tên package trong pubspec.yaml của dự án.
import 'package:your_app/core/page_flip/page_image_window.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('tải ảnh nhỏ của cả cửa sổ trước, rồi mới tải ảnh đầy đủ', (tester) async {
    await tester.runAsync(() async {
      final src = FakeSource();
      final w = PageImageWindow(source: src, pageCount: 10, targetWidth: 1080);
      w.setCenter(0);
      await waitUntil(() => w.hasFull(0) && w.hasFull(1));

      expect(src.calls, <String>['0:t', '1:t', '0:f', '1:f']);
      expect(w.heldCount, 2);
      w.dispose();
    });
  });

  testWidgets('chuyển trung tâm thì giải phóng trang ngoài cửa sổ, RAM không tăng theo số trang', (tester) async {
    await tester.runAsync(() async {
      final src = FakeSource();
      final w = PageImageWindow(source: src, pageCount: 50, targetWidth: 1080);
      w.setCenter(0);
      await waitUntil(() => w.hasFull(0) && w.hasFull(1));

      for (var center = 5; center < 50; center += 5) {
        w.setCenter(center);
        await waitUntil(() => w.hasFull(center));
        expect(w.imageOf(0), isNull);
        expect(w.heldCount, lessThanOrEqualTo(3), reason: 'trung tâm $center');
      }
      w.dispose();
    });
  });

  testWidgets('một trang lỗi không chặn các trang khác và được thử lại ở lần đặt trung tâm kế tiếp', (tester) async {
    await tester.runAsync(() async {
      final src = FakeSource()..failing.add(1);
      final errors = <int>[];
      final w = PageImageWindow(
        source: src,
        pageCount: 10,
        targetWidth: 1080,
        onError: (i, e) => errors.add(i),
      );
      w.setCenter(0);
      await waitUntil(() => w.hasFull(0));

      expect(w.imageOf(1), isNull);
      expect(errors, contains(1));

      src.failing.clear();
      w.setCenter(0);
      await waitUntil(() => w.hasFull(1));
      expect(w.imageOf(1), isNotNull);
      w.dispose();
    });
  });

  testWidgets('trang cuối chỉ có trang trước trong cửa sổ', (tester) async {
    await tester.runAsync(() async {
      final src = FakeSource();
      final w = PageImageWindow(source: src, pageCount: 3, targetWidth: 1080);
      w.setCenter(2);
      await waitUntil(() => w.hasFull(2) && w.hasFull(1));
      expect(w.imageOf(0), isNull);
      expect(w.heldCount, 2);
      w.dispose();
    });
  });
}
