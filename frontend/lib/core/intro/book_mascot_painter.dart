import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Bảng màu của intro. Mặc định theo spec thiết kế chuẩn của hệ thống.
class IntroPalette {
  const IntroPalette({
    this.background = const Color(0xFFFFFFFF),
    this.primary = const Color(0xFF2457C5),
    this.primaryDark = const Color(0xFF1D479F),
    this.ink = const Color(0xFF202124),
    Color? limb,
    Color? pupil,
    this.muted = const Color(0xFF5F6368),
    this.line = const Color(0xFFDADCE0),
    this.paper = const Color(0xFFF5F6F7),
    this.white = const Color(0xFFFFFFFF),
  }) : limb = limb ?? ink,
       pupil = pupil ?? ink;

  final Color background;
  final Color primary;
  final Color primaryDark;
  final Color ink;
  final Color limb;
  final Color pupil;
  final Color muted;
  final Color line;
  final Color paper;
  final Color white;

  static const IntroPalette standard = IntroPalette();

  static const IntroPalette dark = IntroPalette(
    background: Color(0xFF202124),
    primary: Color(0xFF8AB4F8),
    primaryDark: Color(0xFF669DF6),
    ink: Color(0xFFF1F3F4),
    limb: Color(0xFFE8EAED),
    pupil: Color(0xFF202124),
    muted: Color(0xFF9AA0A6),
    line: Color(0xFF3C4043),
    paper: Color(0xFF303134),
    white: Color(0xFFFFFFFF),
  );
}

/// Vẽ cuốn sách vuông đi bộ, vẫy tay. Toàn bộ là hình chữ nhật, không gradient,
/// không bóng mờ, không bo góc (chuẩn Pixel/Flat Geometric Design cao cấp).
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
  late final Paint _limb = _flat(palette.limb);
  late final Paint _limbSmooth = _smooth(palette.limb);
  late final Paint _pupil = _flat(palette.pupil);
  late final Paint _primary = _flat(palette.primary);
  late final Paint _primaryDark = _flat(palette.primaryDark);
  late final Paint _paper = _flat(palette.paper);
  late final Paint _white = _flat(palette.white);
  late final Paint _line = _flat(palette.line);
  late final Paint _muted = _flat(palette.muted);

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

  static void _r(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double w,
    double h,
  ) {
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
  }

  void _arm(
    Canvas canvas,
    double armX,
    double handX,
    double pivotX,
    double degrees,
  ) {
    canvas.save();
    canvas.translate(pivotX, 34);
    canvas.rotate(degrees * math.pi / 180);
    canvas.translate(-pivotX, -34);

    // Khớp vai áo & cánh tay
    _r(canvas, _primaryDark, armX - 1, 30, 10, 6);
    _r(canvas, _limbSmooth, armX, 34, 8, 22);

    // Cổ tay trắng & bàn tay có ngón cái tách rời
    _r(canvas, _white, handX + 1, 54, 10, 3);
    _r(canvas, _limbSmooth, handX, 57, 12, 9);
    final thumbX = armX < 48 ? handX + 10 : handX - 3;
    _r(canvas, _limbSmooth, thumbX, 58, 3, 5);

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
    var wavePhase = 0.0;

    if (t < tEnter) {
      final p = t / tEnter;
      dx = -half * (1 - Curves.easeOutCubic.transform(p));
      cycles = cyclesIn * p;
      walking = true;
    } else if (t < tWave) {
      wavePhase = (t - tEnter) / (tWave - tEnter);
      wave = waveAngle(wavePhase);
    } else {
      final p = (t - tWave) / (1 - tWave);
      dx = half * Curves.easeInCubic.transform(p);
      cycles = cyclesOut * p;
      walking = true;
    }

    // Chu kỳ bước chân và nhịp thở khi đứng yên
    final step = walking ? math.sin(2 * math.pi * cycles) : 0.0;
    final breathe = !walking ? math.sin(wavePhase * 2 * math.pi) * 1.5 : 0.0;
    final bob = walking ? (-5.0 * step.abs()) : breathe;

    final liftA = (7 * math.max(0.0, step)).toDouble();
    final liftB = (7 * math.max(0.0, -step)).toDouble();
    final swing = walking ? (18 * step).toDouble() : (-wave * 0.15);

    // Độ nghiêng thân người (hơi đổ về trước khi bước, nghiêng nhẹ khi vẫy chào)
    final tilt = walking
        ? (0.035 * math.cos(2 * math.pi * cycles) + 0.025)
        : (wave / 155.0) * 0.035;

    final top = (size.height / 2 - 100 * s).roundToDouble();
    final groundY = (top + unitH * s).roundToDouble();
    final ox = (size.width / 2 - unitW / 2 * s + dx).roundToDouble();
    final oy = (top + bob * s).roundToDouble();

    // 1. Mặt đất & gạch nền trang trí chuyển động thị sai
    canvas.drawRect(Rect.fromLTWH(0, groundY, size.width, 2), _line);
    final brickW = 28 * s;
    for (
      double bx = (size.width / 2) % (brickW * 2) - brickW * 2;
      bx < size.width;
      bx += brickW * 2
    ) {
      canvas.drawRect(Rect.fromLTWH(bx, groundY + 5 * s, brickW, 2), _line);
    }

    // 2. Bóng đổ phẳng (Flat Shadow) trên mặt đất, co giãn theo độ cao khi nhảy
    final shadowScale = 1.0 - (bob.abs() / 18.0);
    final shadowW = 64 * s * shadowScale;
    final shadowX = ox + (unitW * s - shadowW) / 2;
    canvas.drawRect(Rect.fromLTWH(shadowX, groundY - 1, shadowW, 4), _line);

    canvas.save();
    canvas.translate(ox, oy);
    canvas.scale(s);

    // 3. Chân trái & Chân phải (vẽ cổ giày trắng + đế giày phẳng, có dịch chuyển tới/lui)
    final strideA = walking ? -3.0 * step : 0.0;
    final strideB = walking ? 3.0 * step : 0.0;

    // Chân trái
    _r(canvas, _limb, 29 + strideA, 84 - liftA, 8, 18);
    _r(canvas, _white, 29 + strideA, 96 - liftA, 8, 3); // Cổ tất trắng
    _r(canvas, _limb, 25 + strideA, 102 - liftA, 18, 6);
    _r(canvas, _paper, 25 + strideA, 106 - liftA, 18, 2); // Đế giày

    // Chân phải
    _r(canvas, _limb, 57 + strideB, 84 - liftB, 8, 18);
    _r(canvas, _white, 57 + strideB, 96 - liftB, 8, 3); // Cổ tất trắng
    _r(canvas, _limb, 53 + strideB, 102 - liftB, 18, 6);
    _r(canvas, _paper, 53 + strideB, 106 - liftB, 18, 2); // Đế giày

    // Nghiêng phần thân trên theo nhịp chuyển động
    canvas.save();
    canvas.translate(48, 84);
    canvas.rotate(tilt);
    canvas.translate(-48, -84);

    // 4. Tay trái (ở lớp sau thân sách)
    _arm(canvas, 4, 2, 9, swing);

    // 5. Dây ruy-băng đánh dấu sách (Bookmark) đung đưa dưới đáy
    final ribbonSwing = (step * 3).roundToDouble();
    _r(canvas, _primaryDark, 46 + ribbonSwing, 84, 6, 9);
    _r(canvas, _primary, 46 + ribbonSwing, 91, 2, 4);
    _r(canvas, _primary, 50 + ribbonSwing, 91, 2, 4);

    // 6. Cấu trúc Thân sách 2.5D (Hoàn toàn dùng hình chữ nhật phẳng)
    // Mép bìa sau & khối trang giấy cạnh bên phải
    _r(canvas, _primaryDark, 16, 6, 70, 78);
    _r(canvas, _paper, 80, 9, 5, 73);
    _r(canvas, _line, 82, 12, 1, 68);

    // Khối trang giấy phía dưới đáy sách (tạo cảm giác sách dày)
    _r(canvas, _paper, 14, 78, 68, 8);
    _r(canvas, _line, 22, 81, 58, 2);
    _r(canvas, _line, 24, 84, 54, 1);

    // Bìa chính mặt trước & Gáy sách bên trái
    _r(canvas, _primary, 12, 8, 68, 72);
    _r(canvas, _primaryDark, 12, 8, 12, 72);
    _r(canvas, _line, 24, 8, 2, 72); // Rãnh khớp mở bìa sách

    // Đai gáy sách trang trí (Book spine bands)
    _r(canvas, _white, 14, 18, 8, 3);
    _r(canvas, _white, 14, 24, 8, 2);
    _r(canvas, _white, 14, 66, 8, 3);

    // 7. Họa tiết bìa sách & Biểu cảm Khuôn mặt
    // Nhãn tên sách phía trên
    _r(canvas, _white, 32, 16, 38, 6);
    _r(canvas, _paper, 32, 25, 24, 4);
    _r(canvas, _white, 72, 12, 4, 12); // Vệt sáng bóng trên góc bìa

    // Lông mày biểu cảm (nhướng lên vui vẻ khi vẫy tay)
    final browOffset = (!walking && wave < -90) ? -2.0 : 0.0;
    _r(canvas, _primaryDark, 33, 39 + browOffset, 14, 3);
    _r(canvas, _primaryDark, 57, 39 + browOffset, 14, 3);

    // Mắt (có hiệu ứng chớp mắt tự nhiên ở giữa chu kỳ vẫy tay)
    final isBlinking = !walking && (wavePhase > 0.46 && wavePhase < 0.54);
    if (isBlinking) {
      _r(canvas, _pupil, 33, 51, 14, 3);
      _r(canvas, _pupil, 57, 51, 14, 3);
    } else {
      // Lòng trắng mắt
      _r(canvas, _white, 33, 44, 14, 15);
      _r(canvas, _white, 57, 44, 14, 15);

      // Đồng tử liếc theo hướng đi hoặc nhìn thẳng khi vẫy chào
      final lookX = walking ? 2.0 : 0.0;
      _r(canvas, _pupil, 38 + lookX, 48, 7, 9);
      _r(canvas, _pupil, 62 + lookX, 48, 7, 9);

      // Đốm sáng mắt (Catchlight) giúp nhân vật có hồn
      _r(canvas, _white, 39 + lookX, 49, 3, 3);
      _r(canvas, _white, 63 + lookX, 49, 3, 3);
    }

    // Má hồng phẳng (Flat geometric blush)
    _r(canvas, _primaryDark, 29, 59, 6, 3);
    _r(canvas, _primaryDark, 69, 59, 6, 3);

    // Miệng: Mở rộng cười tươi khi đứng vẫy tay, mỉm cười gọn khi đi bộ
    if (!walking && wave < -80) {
      _r(canvas, _pupil, 44, 63, 16, 8);
      _r(canvas, _white, 46, 63, 12, 3); // Răng trắng
      _r(canvas, _primary, 48, 68, 8, 3); // Lưỡi
    } else {
      _r(canvas, _white, 45, 65, 14, 4);
      _r(canvas, _white, 43, 63, 2, 3);
      _r(canvas, _white, 59, 63, 2, 3);
    }

    // 8. Tay phải (Vẫy chào) & Tia hiệu ứng chuyển động (Action Lines)
    _arm(canvas, 80, 78, 84, walking ? -swing : wave);

    if (!walking && wave < -115) {
      // Các vạch sóng vẫy tay vui nhộn phía trên
      _r(canvas, _muted, 92, 6, 3, 7);
      _r(canvas, _muted, 98, 12, 7, 3);
    }

    canvas.restore(); // Kết thúc nghiêng thân sách
    canvas.restore(); // Kết thúc hệ tọa độ nhân vật
  }

  @override
  bool shouldRepaint(BookMascotPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.palette != palette;
}
