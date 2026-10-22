import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/intro/book_mascot_painter.dart';

void main() {
  group('waveAngle', () {
    test('bắt đầu và kết thúc ở 0 độ', () {
      expect(BookMascotPainter.waveAngle(0), 0);
      expect(BookMascotPainter.waveAngle(1), 0);
    });

    test('đúng các mốc giơ tay', () {
      expect(BookMascotPainter.waveAngle(0.2), closeTo(-125, 1e-9));
      expect(BookMascotPainter.waveAngle(0.4), closeTo(-155, 1e-9));
      expect(BookMascotPainter.waveAngle(0.6), closeTo(-125, 1e-9));
      expect(BookMascotPainter.waveAngle(0.8), closeTo(-155, 1e-9));
    });

    test('nội suy tuyến tính giữa hai mốc', () {
      expect(BookMascotPainter.waveAngle(0.1), closeTo(-62.5, 1e-9));
    });
  });

  group('scaleFor', () {
    test('co theo chiều rộng nhưng bị chặn trong 80 – 120 đơn vị', () {
      expect(BookMascotPainter.scaleFor(200) * BookMascotPainter.unitW, closeTo(80, 1e-9));
      expect(BookMascotPainter.scaleFor(390) * BookMascotPainter.unitW, closeTo(97.5, 1e-9));
      expect(BookMascotPainter.scaleFor(1280) * BookMascotPainter.unitW, closeTo(120, 1e-9));
    });
  });

  testWidgets('vẽ được ở mọi mốc tiến độ mà không lỗi', (tester) async {
    for (final t in <double>[0, 0.1, 0.3, 0.4, 0.55, 0.7, 0.85, 1]) {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 390,
            height: 844,
            child: CustomPaint(
              painter: BookMascotPainter(progress: AlwaysStoppedAnimation<double>(t)),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('vẽ được trên IntroPalette.dark mà không lỗi', (tester) async {
    for (final t in <double>[0, 0.4, 0.55, 1]) {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 390,
            height: 844,
            child: CustomPaint(
              painter: BookMascotPainter(
                progress: AlwaysStoppedAnimation<double>(t),
                palette: IntroPalette.dark,
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
