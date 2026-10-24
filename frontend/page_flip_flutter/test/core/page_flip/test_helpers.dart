import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

// Đổi 'your_app' thành tên package trong pubspec.yaml của dự án.
import 'package:your_app/core/page_flip/page_image_window.dart';

class FakeSource implements PageImageSource {
  final List<String> calls = <String>[];
  final Set<int> failing = <int>{};

  @override
  Future<ui.Image> load(int index, {required int targetWidth, bool thumbnail = false}) async {
    calls.add('$index:${thumbnail ? 't' : 'f'}');
    if (failing.contains(index)) throw StateError('lỗi tải trang $index');
    return createTestImage(width: 4, height: 6);
  }
}

/// Chờ (thời gian thật) cho đến khi điều kiện đúng.
Future<void> waitUntil(bool Function() test, {Duration timeout = const Duration(seconds: 3)}) async {
  final end = DateTime.now().add(timeout);
  while (!test()) {
    if (DateTime.now().isAfter(end)) throw TestFailure('Hết thời gian chờ điều kiện');
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
