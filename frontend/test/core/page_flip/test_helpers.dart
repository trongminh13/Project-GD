import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/page_flip/page_image_window.dart';

class FakeSource implements PageImageSource {
  final List<String> calls = <String>[];
  final Set<int> failing = <int>{};

  @override
  Future<ui.Image> load(int index, {required int targetWidth, bool thumbnail = false}) async {
    calls.add('$index:${thumbnail ? 't' : 'f'}');
    if (failing.contains(index)) {
      throw Exception('Lỗi nạp trang $index');
    }
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 4, 6), ui.Paint()..color = const ui.Color(0xFFFFFFFF));
    return recorder.endRecording().toImage(4, 6);
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
