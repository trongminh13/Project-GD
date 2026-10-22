import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Bảng màu của intro. Mặc định theo spec dự án; nên map sang
/// hằng số màu sẵn có của app (ví dụ AppColors) thay vì giữ giá trị cứng.
class IntroPalette {
  const IntroPalette({
    this.background = const Color(0xFFFFFFFF),
    this.primary = const Color(0xFF2457C5),
    this.primaryDark = const Color(0xFF1D479F),
    this.ink = const Color(0xFF202124),
    this.muted = const Color(0xFF5F6368),
    this.line = const Color(0xFFDADCE0),
    this.paper = const Color(0xFFF5F6F7),
    this.white = const Color(0xFFFFFFFF),
  });

  final Color background;
  final Color primary;
  final Color primaryDark;
  final Color ink;
  final Color muted;
  final Color line;
  final Color paper;
  final Color white;

  static const IntroPalette standard = IntroPalette();
}

/// Vẽ cuốn sách vuông đi bộ, vẫy tay. Toàn bộ là hình chữ nhật, không gradient,
/// không bóng, không bo góc.
///
/// `progress` chạy 0 → 1 (tuyến tính). Mốc:
///  - 0.0 – 0.4: đi vào từ cạnh trái
///  - 0.4 – 0.7: đứng yên, vẫy tay
///  - 0.7 – 1.0: đi ra cạnh phải
///
/// Painter lắng nghe `progress` qua `repaint`, nên chỉ vẽ lại, không dựng lại widget.
class BookMascotPainter extends CustomPainter {
  BookMascotPainter({
    required this.progress,
    this.palette = IntroPalette.standard,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final IntroPalette palette;

  static const double tEnter = 0.4;
  static const double tWave = 0.7;
  static const double cyclesIn = 2;
  static const double cyclesOut = 1.5;
  static const double unitW = 96;
  static const double unitH = 114;

  // Paint tạo một lần cho mỗi painter, không tạo mới trong paint().
  late final Paint _ink = _flat(palette.ink);
  late final Paint _inkSmooth = _smooth(palette.ink);
  late final Paint _primary = _flat(palette.primary);
  late final Paint _primaryDark = _flat(palette.primaryDark);
  late final Paint _paper = _flat(palette.paper);
  late final Paint _white = _flat(palette.white);
  late final Paint _line = _flat(palette.line);

  static Paint _flat(Color c) => Paint()
    ..color = c
    ..isAntiAlias = false;

  static Paint _smooth(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true;

  /// Hệ số co theo chiều rộng màn hình (khung gốc 96 đơn vị).
  static double scaleFor(double width) =>
      (width * 0.25).clamp(80.0, 120.0).toDouble() / unitW;

  /// Góc tay phải (độ) theo tiến độ p (0..1) của giai đoạn vẫy.
  /// Mốc: 0, -125, -155, -125, -155, 0. Góc âm là giơ lên phía ngoài bên phải.
  static double waveAngle(double p) {
    const stops = <double>[0, -125, -155, -125, -155, 0];
    final x = p.clamp(0.0, 1.0).toDouble() * 5;
    final i = x.floor().clamp(0, 4).toInt();
    return stops[i] + (stops[i + 1] - stops[i]) * (x - i);
  }

  static void _r(Canvas canvas, Paint paint, double x, double y, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
  }

  void _arm(Canvas canvas, double armX, double handX, double pivotX, double degrees) {
    canvas.save();
    canvas.translate(pivotX, 30);
    canvas.rotate(degrees * math.pi / 180);
    canvas.translate(-pivotX, -30);
    _r(canvas, _inkSmooth, armX, 30, 10, 30);
    _r(canvas, _inkSmooth, handX, 58, 14, 10);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value.clamp(0.0, 1.0).toDouble();
    final s = scaleFor(size.width);
    final half = size.width / 2 + unitW / 2 * s;

    var dx = 0.0;
    var cycles = 0.0;
    var wave = 0.0;
    var walking = false;

    if (t < tEnter) {
      final p = t / tEnter;
      dx = -half * (1 - Curves.easeOut.transform(p));
      cycles = cyclesIn * p;
      walking = true;
    } else if (t < tWave) {
      wave = waveAngle((t - tEnter) / (tWave - tEnter));
    } else {
      final p = (t - tWave) / (1 - tWave);
      dx = half * Curves.easeIn.transform(p);
      cycles = cyclesOut * p;
      walking = true;
    }

    // Mỗi chu kỳ: chân trái nhấc rồi chân phải nhấc. Mọi giá trị bằng 0 ở đầu
    // và cuối mỗi nửa chu kỳ nên không bị giật khi đổi giai đoạn.
    final step = walking ? math.sin(2 * math.pi * cycles) : 0.0;
    final bob = -4 * step.abs();
    final liftA = 6 * math.max(0.0, step);
    final liftB = 6 * math.max(0.0, -step);
    final swing = 12 * step;

    final top = (size.height / 2 - 100 * s).roundToDouble();
    final ox = (size.width / 2 - unitW / 2 * s + dx).roundToDouble();
    final oy = (top + bob * s).roundToDouble();

    // Đường nền, sát đáy bàn chân.
    canvas.drawRect(
      Rect.fromLTWH(0, (top + unitH * s).roundToDouble(), size.width, 2),
      _line,
    );

    canvas.save();
    canvas.translate(ox, oy);
    canvas.scale(s);

    // Chân (vẽ trước thân).
    _r(canvas, _ink, 30, 86 - liftA, 10, 16);
    _r(canvas, _ink, 26, 102 - liftA, 18, 8);
    _r(canvas, _ink, 56, 86 - liftB, 10, 16);
    _r(canvas, _ink, 52, 102 - liftB, 18, 8);

    // Tay trái đung đưa khi đi.
    _arm(canvas, 2, 0, 7, swing);

    // Thân sách.
    _r(canvas, _primary, 12, 8, 72, 78);
    _r(canvas, _primaryDark, 12, 8, 10, 78);
    _r(canvas, _paper, 22, 80, 62, 6);
    _r(canvas, _white, 34, 18, 38, 6);
    _r(canvas, _white, 34, 28, 26, 6);

    // Mắt và miệng.
    _r(canvas, _white, 36, 46, 12, 14);
    _r(canvas, _ink, 40, 50, 6, 8);
    _r(canvas, _white, 58, 46, 12, 14);
    _r(canvas, _ink, 62, 50, 6, 8);
    _r(canvas, _white, 44, 68, 16, 4);

    // Tay phải (vẫy).
    _arm(canvas, 84, 82, 89, wave);

    canvas.restore();
  }

  @override
  bool shouldRepaint(BookMascotPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}
