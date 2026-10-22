import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/intro/intro_gate.dart';
import 'package:ashadeep/core/intro/intro_policy.dart';

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
    appName: 'Giáo Dục Đại Việt',
    tagline: 'Cổng thông tin nhà trường',
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

    expect(find.text('Giáo Dục Đại Việt'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
    expect(policy.marked, 1);

    await _pumpUntilHome(tester);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('Giáo Dục Đại Việt'), findsNothing);
  });

  testWidgets('không hiện intro khi policy từ chối', (tester) async {
    final policy = _FakePolicy(false);
    await tester.pumpWidget(_app(policy: policy, ready: Future<void>.value()));
    await tester.pump();

    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('Giáo Dục Đại Việt'), findsNothing);
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

    expect(find.text('Giáo Dục Đại Việt'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);

    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('khởi động chậm: giữ tư thế rồi vẫn chuyển sau giới hạn chờ', (tester) async {
    final never = Completer<void>(); // khởi động không bao giờ xong
    await tester.pumpWidget(_app(policy: _FakePolicy(true), ready: never.future));
    await tester.pump();

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

  testWidgets('tự động nhận diện theme tối khi hệ thống là Dark Mode', (tester) async {
    final policy = _FakePolicy(true);
    await tester.pumpWidget(
      MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        home: IntroGate(
          policy: policy,
          ready: Future<void>.value(),
          appName: 'Giáo Dục Đại Việt',
          semanticsLabel: 'Ứng dụng nhà trường',
          builder: (_) => const Text('HOME'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Giáo Dục Đại Việt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
