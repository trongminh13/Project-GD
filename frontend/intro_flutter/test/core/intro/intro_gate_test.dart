import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Đổi 'your_app' thành tên package trong pubspec.yaml của dự án.
import 'package:your_app/core/intro/intro_gate.dart';
import 'package:your_app/core/intro/intro_policy.dart';

class _FakePolicy implements IntroPolicy {
  _FakePolicy(this.show);
  final bool show;
  int marked = 0;

  @override
  Future<bool> shouldShow() async => show;

  @override
  Future<void> markShown() async => marked++;
}

Widget _app({
  required IntroPolicy policy,
  required Future<void> ready,
  bool reduceMotion = false,
}) {
  Widget gate = IntroGate(
    policy: policy,
    ready: ready,
    appName: 'Astra',
    tagline: 'Ứng dụng nhà trường',
    semanticsLabel: 'Ứng dụng nhà trường. Chạm để bỏ qua',
    builder: (_) => const Text('HOME'),
  );
  if (reduceMotion) {
    gate = MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: gate,
    );
  }
  return MaterialApp(home: gate);
}

/// Bơm khung hình cho đến khi màn kế tiếp xuất hiện (tối đa [max]).
Future<void> _pumpUntilHome(WidgetTester tester, {Duration max = const Duration(seconds: 8)}) async {
  const step = Duration(milliseconds: 250);
  var elapsed = Duration.zero;
  while (find.text('HOME').evaluate().isEmpty && elapsed < max) {
    await tester.pump(step);
    elapsed += step;
  }
}

void main() {
  testWidgets('chạy hết thì vào màn kế tiếp', (tester) async {
    final policy = _FakePolicy(true);
    await tester.pumpWidget(_app(policy: policy, ready: Future<void>.value()));
    await tester.pump();

    expect(find.text('Astra'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
    expect(policy.marked, 1);

    await _pumpUntilHome(tester);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('Astra'), findsNothing);
  });

  testWidgets('không hiện intro khi policy từ chối', (tester) async {
    final policy = _FakePolicy(false);
    await tester.pumpWidget(_app(policy: policy, ready: Future<void>.value()));
    await tester.pump();

    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('Astra'), findsNothing);
    expect(policy.marked, 0);
  });

  testWidgets('chạm bỏ qua vào ngay và không lặp lại khi hết giờ', (tester) async {
    await tester.pumpWidget(_app(policy: _FakePolicy(true), ready: Future<void>.value()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byType(IntroGate));
    await tester.pump();
    expect(find.text('HOME'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('HOME'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('giảm chuyển động: hiện hình tĩnh rồi vào màn kế tiếp', (tester) async {
    await tester.pumpWidget(_app(
      policy: _FakePolicy(true),
      ready: Future<void>.value(),
      reduceMotion: true,
    ));
    await tester.pump();

    expect(find.text('Astra'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);

    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('khởi động chậm: giữ tư thế rồi vẫn chuyển sau giới hạn chờ', (tester) async {
    final never = Completer<void>(); // khởi động không bao giờ xong
    await tester.pumpWidget(_app(policy: _FakePolicy(true), ready: never.future));
    await tester.pump();

    // Vẫy xong sớm nhất ở 1,4 giây, giữ thêm tối đa 1 giây, nên chưa thể vào ở 1,9 giây.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('HOME'), findsNothing);

    await _pumpUntilHome(tester);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('khởi động lỗi vẫn không chặn màn kế tiếp', (tester) async {
    final failing = Future<void>.error(StateError('boom'));
    // Gắn sẵn trình xử lý để test không báo lỗi chưa xử lý từ chính Future này.
    unawaited(failing.catchError((Object _) {}));
    await tester.pumpWidget(_app(policy: _FakePolicy(true), ready: failing));
    await tester.pump();

    await _pumpUntilHome(tester);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('gỡ widget giữa chừng không gây lỗi', (tester) async {
    await tester.pumpWidget(_app(policy: _FakePolicy(true), ready: Future<void>.value()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });
}
