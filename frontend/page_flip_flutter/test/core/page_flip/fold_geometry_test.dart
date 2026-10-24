import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

// Đổi 'your_app' thành tên package trong pubspec.yaml của dự án.
import 'package:your_app/core/page_flip/fold_geometry.dart';

double _area(List<Offset> p) {
  if (p.length < 3) return 0;
  var s = 0.0;
  for (var i = 0; i < p.length; i++) {
    final a = p[i];
    final b = p[(i + 1) % p.length];
    s += a.dx * b.dy - b.dx * a.dy;
  }
  return s.abs() / 2;
}

void main() {
  const size = Size(360, 509);
  const corner = Offset(360, 509);

  group('compute', () {
    test('chưa kéo thì không có nếp gập', () {
      expect(FoldGeometry.compute(size, corner), isNull);
      expect(FoldGeometry.compute(size, const Offset(359.8, 509)), isNull);
    });

    test('vector pháp tuyến có độ dài 1', () {
      final f = FoldGeometry.compute(size, const Offset(200, 440))!;
      expect(math.sqrt(f.normal.dx * f.normal.dx + f.normal.dy * f.normal.dy), closeTo(1, 1e-9));
    });

    test('phản chiếu góc C cho đúng điểm kéo P', () {
      const p = Offset(180, 430);
      final f = FoldGeometry.compute(size, p)!;
      final r = f.reflect(corner);
      expect(r.dx, closeTo(p.dx, 1e-6));
      expect(r.dy, closeTo(p.dy, 1e-6));
    });

    test('điểm nằm trên nếp gập không đổi khi phản chiếu', () {
      final f = FoldGeometry.compute(size, const Offset(150, 400))!;
      final r = f.reflect(f.mid);
      expect(r.dx, closeTo(f.mid.dx, 1e-9));
      expect(r.dy, closeTo(f.mid.dy, 1e-9));
    });

    test('hai phần cộng lại bằng diện tích trang', () {
      for (final p in <Offset>[const Offset(300, 500), const Offset(180, 430), const Offset(20, 350), const Offset(-200, 509)]) {
        final f = FoldGeometry.compute(size, p)!;
        expect(_area(f.cornerSide) + _area(f.flatSide), closeTo(size.width * size.height, 1e-6), reason: 'P=$p');
      }
    });

    test('ma trận phản chiếu cho cùng kết quả với reflect()', () {
      final f = FoldGeometry.compute(size, const Offset(170, 420))!;
      final m = f.reflectionMatrix;
      const q = Offset(300, 120);
      final x = m[0] * q.dx + m[4] * q.dy + m[12];
      final y = m[1] * q.dx + m[5] * q.dy + m[13];
      final r = f.reflect(q);
      expect(x, closeTo(r.dx, 1e-6));
      expect(y, closeTo(r.dy, 1e-6));
    });

    test('lật hết (P ở -W, H): nếp thẳng đứng ở x=0, trang bên dưới chiếm toàn bộ', () {
      final f = FoldGeometry.compute(size, Offset(-size.width, size.height))!;
      expect(f.normal.dx, closeTo(1, 1e-9));
      expect(f.mid.dx, closeTo(0, 1e-9));
      expect(_area(f.cornerSide), closeTo(size.width * size.height, 1e-6));
      expect(_area(f.flatSide), closeTo(0, 1e-6));
    });
  });

  group('cornerFor', () {
    test('chưa kéo thì ở đúng góc dưới phải', () {
      final c = FoldGeometry.cornerFor(size, size.width, 0);
      expect(c.dx, size.width);
      expect(c.dy, closeTo(size.height, 1e-9));
    });

    test('không nhấc góc cao quá 45% chiều cao trang', () {
      final c = FoldGeometry.cornerFor(size, 100, 10000);
      expect(c.dy, greaterThanOrEqualTo(0.45 * size.height - 1e-9));
    });

    test('lật hết thì nếp thẳng đứng (y về đáy trang)', () {
      final c = FoldGeometry.cornerFor(size, -size.width, 50);
      expect(c.dy, closeTo(size.height, 1e-9));
    });

    test('kéo ngang thì nếp chéo (góc được nhấc lên)', () {
      final c = FoldGeometry.cornerFor(size, 200, 0);
      expect(c.dy, lessThan(size.height));
    });
  });

  group('clipPolygon', () {
    test('cắt hình vuông bằng đường thẳng đứng ở giữa cho hai nửa bằng nhau', () {
      const sq = <Offset>[Offset(0, 0), Offset(10, 0), Offset(10, 10), Offset(0, 10)];
      final right = FoldGeometry.clipPolygon(sq, const Offset(5, 5), const Offset(1, 0), positive: true);
      final left = FoldGeometry.clipPolygon(sq, const Offset(5, 5), const Offset(1, 0), positive: false);
      expect(_area(right), closeTo(50, 1e-9));
      expect(_area(left), closeTo(50, 1e-9));
    });
  });
}
