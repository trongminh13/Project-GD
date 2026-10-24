import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/page_flip/page_flip_view.dart';

import 'test_helpers.dart';

Future<Rect> _pumpView(
  WidgetTester tester, {
  required FakeSource source,
  required void Function(int) onChanged,
  bool reduced = false,
  PageFlipController? controller,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PageFlipView(
          pageCount: 3,
          source: source,
          controller: controller,
          reducedMotion: reduced,
          enableHaptics: false,
          onPageChanged: onChanged,
        ),
      ),
    ),
  );
  // Cho ảnh của trang 0 và trang 1 tải xong (thời gian thật), rồi dựng lại.
  await tester.runAsync(() => waitUntil(() => source.calls.length >= 4));
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await tester.pump();
  return tester.getRect(find.descendant(of: find.byType(PageFlipView), matching: find.byType(CustomPaint)).first);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('chạm vào mép phải thì sang trang sau', (tester) async {
    final changed = <int>[];
    final page = await _pumpView(tester, source: FakeSource(), onChanged: changed.add);

    await tester.tapAt(Offset(page.right - 10, page.center.dy));
    await _settle(tester);

    expect(changed, <int>[1]);
  });

  testWidgets('vuốt từ phải sang trái quá nửa trang thì sang trang sau', (tester) async {
    final changed = <int>[];
    final page = await _pumpView(tester, source: FakeSource(), onChanged: changed.add);

    await tester.dragFrom(Offset(page.right - 30, page.bottom - 30), Offset(-page.width * 0.8, -20));
    await _settle(tester);

    expect(changed, <int>[1]);
  });

  testWidgets('vuốt ngắn rồi thả thì gập về, vẫn ở trang cũ', (tester) async {
    final changed = <int>[];
    final page = await _pumpView(tester, source: FakeSource(), onChanged: changed.add);

    await tester.dragFrom(Offset(page.right - 30, page.bottom - 30), const Offset(-40, -5));
    await _settle(tester);

    expect(changed, isEmpty);
  });

  testWidgets('ở trang đầu, chạm mép trái không làm gì', (tester) async {
    final changed = <int>[];
    final page = await _pumpView(tester, source: FakeSource(), onChanged: changed.add);

    await tester.tapAt(Offset(page.left + 10, page.center.dy));
    await _settle(tester);

    expect(changed, isEmpty);
  });

  testWidgets('giảm chuyển động: vẫn sang được trang sau (mờ dần, không gập)', (tester) async {
    final changed = <int>[];
    final page = await _pumpView(tester, source: FakeSource(), onChanged: changed.add, reduced: true);

    await tester.tapAt(Offset(page.right - 10, page.center.dy));
    await _settle(tester);

    expect(changed, <int>[1]);
  });

  testWidgets('điều khiển bằng PageFlipController: next rồi previous', (tester) async {
    final changed = <int>[];
    final controller = PageFlipController();
    await _pumpView(tester, source: FakeSource(), onChanged: changed.add, controller: controller);

    controller.next();
    await _settle(tester);
    expect(controller.currentPage, 1);

    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    controller.previous();
    await _settle(tester);
    expect(controller.currentPage, 0);
    expect(changed, <int>[1, 0]);
  });

  testWidgets('gỡ widget giữa lúc đang lật không gây lỗi', (tester) async {
    final page = await _pumpView(tester, source: FakeSource(), onChanged: (_) {});

    await tester.tapAt(Offset(page.right - 10, page.center.dy));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });
}
