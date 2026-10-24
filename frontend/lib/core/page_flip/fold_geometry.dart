import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset, Size;

/// Hình học của nếp gập góc dưới bên phải. Thuần toán học, không vẽ gì,
/// nên test được bằng test đơn vị.
///
/// Ý tưởng: góc dưới phải C của trang bị kéo tới điểm P. Nếp gập là đường trung
/// trực của đoạn CP. Phần trang ở phía C bị gập qua nếp (phản chiếu qua đường
/// này), phần còn lại giữ phẳng.
class FoldGeometry {
  FoldGeometry._({
    required this.normal,
    required this.mid,
    required this.cornerSide,
    required this.flatSide,
    required this.reflectionMatrix,
  });

  /// Vector đơn vị vuông góc với nếp gập, hướng từ P về C.
  final Offset normal;

  /// Trung điểm của đoạn CP, nằm trên nếp gập.
  final Offset mid;

  /// Đa giác phần trang ở phía góc C (phần bị gập đi, lộ trang bên dưới).
  final List<Offset> cornerSide;

  /// Đa giác phần trang còn phẳng.
  final List<Offset> flatSide;

  /// Ma trận 4x4 (cột trước) của phép phản chiếu qua nếp gập, dùng cho `Canvas.transform`.
  final Float64List reflectionMatrix;

  /// Tính hình học cho trang cỡ [size] khi góc dưới phải bị kéo tới [corner].
  /// Trả `null` khi gần như chưa kéo (độ dài nhỏ hơn nửa pixel).
  static FoldGeometry? compute(Size size, Offset corner) {
    final w = size.width;
    final h = size.height;
    final dx = w - corner.dx;
    final dy = h - corner.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 0.5) return null;

    final nx = dx / len;
    final ny = dy / len;
    final normal = Offset(nx, ny);
    final mid = Offset((w + corner.dx) / 2, (h + corner.dy) / 2);
    final rect = <Offset>[Offset.zero, Offset(w, 0), Offset(w, h), Offset(0, h)];

    final k = 2 * (mid.dx * nx + mid.dy * ny);
    final matrix = Float64List.fromList(<double>[
      1 - 2 * nx * nx, -2 * nx * ny, 0, 0, //
      -2 * nx * ny, 1 - 2 * ny * ny, 0, 0, //
      0, 0, 1, 0, //
      k * nx, k * ny, 0, 1,
    ]);

    return FoldGeometry._(
      normal: normal,
      mid: mid,
      cornerSide: clipPolygon(rect, mid, normal, positive: true),
      flatSide: clipPolygon(rect, mid, normal, positive: false),
      reflectionMatrix: matrix,
    );
  }

  /// Phản chiếu một điểm qua nếp gập.
  Offset reflect(Offset p) {
    final d = (p.dx - mid.dx) * normal.dx + (p.dy - mid.dy) * normal.dy;
    return Offset(p.dx - 2 * d * normal.dx, p.dy - 2 * d * normal.dy);
  }

  /// Phần trang (đã phản chiếu) tạo thành mặt sau của phần bị gập.
  /// Có thể nằm ngoài khung trang, nơi vẽ phải cắt lại bằng khung trang.
  List<Offset> get flap => cornerSide.map(reflect).toList(growable: false);

  /// Cắt đa giác lồi [poly] bằng nửa mặt phẳng đi qua [mid], theo hướng [normal].
  /// `positive: true` giữ phía cùng chiều [normal]; `false` giữ phía ngược lại.
  static List<Offset> clipPolygon(
    List<Offset> poly,
    Offset mid,
    Offset normal, {
    required bool positive,
  }) {
    final sign = positive ? 1.0 : -1.0;
    double s(Offset p) =>
        sign * ((p.dx - mid.dx) * normal.dx + (p.dy - mid.dy) * normal.dy);

    final out = <Offset>[];
    for (var i = 0; i < poly.length; i++) {
      final a = poly[i];
      final b = poly[(i + 1) % poly.length];
      final sa = s(a);
      final sb = s(b);
      if (sa >= 0) out.add(a);
      if ((sa >= 0) != (sb >= 0)) {
        final t = sa / (sa - sb);
        out.add(Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t));
      }
    }
    return out;
  }

  /// Vị trí điểm kéo P theo hoành độ [px] của góc.
  ///
  /// [px] từ `size.width` (chưa kéo) đến `-size.width` (đã lật hết). [extra] là phần
  /// nhấc góc lên thêm theo ngón tay (pixel). Có một độ nhấc nền tăng theo khoảng
  /// kéo để nếp gập luôn chéo, rồi giảm dần về 0 khi gần lật xong để kết thúc
  /// bằng nếp thẳng đứng.
  static Offset cornerFor(Size size, double px, double extra) {
    final w = size.width;
    final h = size.height;
    final d = w - px;
    final base = math.min(0.2 * d, 0.3 * h);
    final fade = ((2 * w - d) / (0.6 * w)).clamp(0.0, 1.0).toDouble();
    final y = h - (base + extra) * fade;
    return Offset(px, math.max(0.45 * h, y));
  }
}
