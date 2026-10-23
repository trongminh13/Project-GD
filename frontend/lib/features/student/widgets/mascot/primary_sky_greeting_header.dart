import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Buổi trong ngày cho học sinh Cấp 1
enum SkyTimePeriod {
  morning, // 05:00 - 11:59
  afternoon, // 12:00 - 17:59
  evening, // 18:00 - 04:59
}

/// Helper phân loại thời gian trong ngày
class SkyTimeHelper {
  static SkyTimePeriod fromDateTime([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) {
      return SkyTimePeriod.morning;
    } else if (hour >= 12 && hour < 18) {
      return SkyTimePeriod.afternoon;
    } else {
      return SkyTimePeriod.evening;
    }
  }

  static String getGreetingTitle(SkyTimePeriod period) {
    switch (period) {
      case SkyTimePeriod.morning:
        return 'Chào buổi sáng ✨';
      case SkyTimePeriod.afternoon:
        return 'Chào buổi chiều 🌤️';
      case SkyTimePeriod.evening:
        return 'Chào buổi tối 🌙';
    }
  }
}

/// Painter vẽ hình ảnh thiên nhiên "chỉ 1 nửa phần trên hiện" (Peeking Celestial Element)
/// Đồ họa 100% Vector sắc nét, ngộ nghĩnh, màu sắc rực rỡ chuẩn phong cách thiếu nhi Tiểu học
class SkyCelestialPainter extends CustomPainter {
  final SkyTimePeriod period;
  final Color primaryColor;

  SkyCelestialPainter({
    required this.period,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h; // Đường chân trời nằm ở đáy canvas, đối tượng chỉ nhô 1 nửa phần trên lên

    switch (period) {
      case SkyTimePeriod.morning:
        _drawMorningSun(canvas, cx, cy, w, h);
        break;
      case SkyTimePeriod.afternoon:
        _drawAfternoonSunAndClouds(canvas, cx, cy, w, h);
        break;
      case SkyTimePeriod.evening:
        _drawEveningMoonAndStars(canvas, cx, cy, w, h);
        break;
    }
  }

  /// Buổi sáng: Mặt trời nửa vòm cười rạng rỡ với các tia nắng nan quạt và mây trắng e ấp
  void _drawMorningSun(Canvas canvas, double cx, double cy, double w, double h) {
    final sunRadius = h * 0.72;

    // 1. Các tia nắng vàng cam xòe ra trên nửa vòm
    final rayPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    const rayCount = 7;
    for (int i = 0; i < rayCount; i++) {
      // Góc xòe từ 195 độ đến 345 độ (nửa vòng tròn phía trên)
      final angle = (195 + (150 / (rayCount - 1)) * i) * math.pi / 180;
      final startR = sunRadius + 3.0;
      final endR = sunRadius + (i % 2 == 0 ? 8.5 : 6.0);
      final p1 = Offset(cx + startR * math.cos(angle), cy + startR * math.sin(angle));
      final p2 = Offset(cx + endR * math.cos(angle), cy + endR * math.sin(angle));
      canvas.drawLine(p1, p2, rayPaint);
    }

    // 2. Vầng hào quang sáng ấm áp quanh mặt trời
    final auraPaint = Paint()
      ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), sunRadius + 2.5, auraPaint);

    // 3. Nửa hình tròn thân Mặt Trời màu vàng cam rực rỡ
    final sunPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFDE047), Color(0xFFF59E0B)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: sunRadius))
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), sunRadius, sunPaint);

    // Viền nhẹ ngoài mặt trời
    final sunBorder = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), sunRadius, sunBorder);

    // 4. Khuôn mặt cười đáng yêu (Chỉ vẽ ở nửa trên)
    final faceY = cy - sunRadius * 0.42;

    // Đôi mắt cười hình cung tí hon
    final eyePaint = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final leftEye = Path()
      ..moveTo(cx - 7.5, faceY)
      ..quadraticBezierTo(cx - 5.5, faceY - 2.5, cx - 3.5, faceY);
    final rightEye = Path()
      ..moveTo(cx + 3.5, faceY)
      ..quadraticBezierTo(cx + 5.5, faceY - 2.5, cx + 7.5, faceY);
    canvas.drawPath(leftEye, eyePaint);
    canvas.drawPath(rightEye, eyePaint);

    // Đôi má hồng phấn e ấp
    final blushPaint = Paint()..color = const Color(0xFFF43F5E).withValues(alpha: 0.45);
    canvas.drawCircle(Offset(cx - 8.5, faceY + 4), 2.2, blushPaint);
    canvas.drawCircle(Offset(cx + 8.5, faceY + 4), 2.2, blushPaint);

    // Nụ cười chúm chím
    final mouthPaint = Paint()
      ..color = const Color(0xFF9A3412)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final mouth = Path()
      ..moveTo(cx - 3.2, faceY + 4)
      ..quadraticBezierTo(cx, faceY + 6.8, cx + 3.2, faceY + 4);
    canvas.drawPath(mouth, mouthPaint);

    // 5. Cụm mây trắng ngà bồng bềnh e ấp ở mép dưới chân mặt trời
    _drawFluffyCloud(canvas, cx + sunRadius * 0.35, cy, 14, const Color(0xFFFFFFFF), const Color(0xFFE2E8F0));
  }

  /// Buổi chiều: Mặt trời vàng dịu kết hợp cụm mây xanh bồng bềnh
  void _drawAfternoonSunAndClouds(Canvas canvas, double cx, double cy, double w, double h) {
    final sunRadius = h * 0.68;

    // 1. Nửa mặt trời màu cam mật ngọt ngả sang tây
    final sunPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFCD34D), Color(0xFFFB923C)],
      ).createShader(Rect.fromCircle(center: Offset(cx - 4, cy), radius: sunRadius))
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx - 4, cy), sunRadius, sunPaint);

    // Vệt hào quang chiều
    final rayPaint = Paint()
      ..color = const Color(0xFFF97316).withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 5; i++) {
      final angle = (205 + (130 / 4) * i) * math.pi / 180;
      final startR = sunRadius + 2.0;
      final endR = sunRadius + 6.0;
      canvas.drawLine(
        Offset(cx - 4 + startR * math.cos(angle), cy + startR * math.sin(angle)),
        Offset(cx - 4 + endR * math.cos(angle), cy + endR * math.sin(angle)),
        rayPaint,
      );
    }

    // 2. Cụm mây xanh biếc bồng bềnh che một phần chân trời
    _drawFluffyCloud(canvas, cx + 6, cy, 18, const Color(0xFFE0F2FE), const Color(0xFF38BDF8));
    _drawFluffyCloud(canvas, cx - 10, cy, 12, const Color(0xFFFFFFFF), const Color(0xFFBAE6FD));
  }

  /// Buổi tối: Nửa vòm trời đêm tím mộng mơ, Mặt trăng khuyết và các ngôi sao lấp lánh
  void _drawEveningMoonAndStars(Canvas canvas, double cx, double cy, double w, double h) {
    final domeRadius = h * 0.78;

    // 1. Nửa vòm bầu trời đêm màu tím chàm huyền ảo
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3730A3), Color(0xFF4F46E5)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: domeRadius))
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), domeRadius, skyPaint);

    // 2. Mặt trăng lưỡi liềm vàng mơ nhô lên nửa vòm
    final moonCenter = Offset(cx - 3, cy - domeRadius * 0.38);
    final moonR = domeRadius * 0.52;

    final moonPath = Path()
      ..addArc(Rect.fromCircle(center: moonCenter, radius: moonR), -math.pi / 2, math.pi)
      ..arcToPoint(
        Offset(moonCenter.dx, moonCenter.dy - moonR),
        radius: Radius.circular(moonR * 0.72),
        clockwise: false,
      );

    final moonPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonR))
      ..isAntiAlias = true;
    canvas.drawPath(moonPath, moonPaint);

    // 3. Hai ngôi sao 4 cánh lấp lánh trên vòm trời đêm
    _drawSparkleStar(canvas, cx + 11, cy - domeRadius * 0.52, 4.0, const Color(0xFFFDE047));
    _drawSparkleStar(canvas, cx - 13, cy - domeRadius * 0.28, 2.8, const Color(0xFFFFFFFF));
    _drawSparkleStar(canvas, cx + 14, cy - domeRadius * 0.16, 2.2, const Color(0xFFFDE047));
  }

  /// Vẽ cụm mây tròn nhiều tầng mềm mại
  void _drawFluffyCloud(Canvas canvas, double ox, double oy, double r, Color fillCol, Color borderCol) {
    final fill = Paint()
      ..color = fillCol
      ..isAntiAlias = true;
    final stroke = Paint()
      ..color = borderCol
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    canvas.drawCircle(Offset(ox - r * 0.45, oy), r * 0.55, fill);
    canvas.drawCircle(Offset(ox + r * 0.45, oy), r * 0.50, fill);
    canvas.drawCircle(Offset(ox, oy - r * 0.35), r * 0.70, fill);

    canvas.drawCircle(Offset(ox - r * 0.45, oy), r * 0.55, stroke);
    canvas.drawCircle(Offset(ox + r * 0.45, oy), r * 0.50, stroke);
    canvas.drawCircle(Offset(ox, oy - r * 0.35), r * 0.70, stroke);
  }

  /// Vẽ ngôi sao lấp lánh 4 cánh
  void _drawSparkleStar(Canvas canvas, double x, double y, double r, Color color) {
    final starPath = Path()
      ..moveTo(x, y - r)
      ..quadraticBezierTo(x, y, x + r, y)
      ..quadraticBezierTo(x, y, x, y + r)
      ..quadraticBezierTo(x, y, x - r, y)
      ..quadraticBezierTo(x, y, x, y - r);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(starPath, paint);
  }

  @override
  bool shouldRepaint(covariant SkyCelestialPainter oldDelegate) {
    return oldDelegate.period != period || oldDelegate.primaryColor != primaryColor;
  }
}

/// Widget Header Bầu Trời Lời Chào Dành Riêng Cho Học Sinh Cấp 1
/// Thiết kế chuẩn mực Senior Design:
/// - Hình Bầu trời (Mặt trời / Mây / Trăng sao) nhô nửa phần trên lên từ đỉnh
/// - Lời chào theo thời gian kết hợp tên học sinh vui tươi, rực rỡ, gần gũi với lứa tuổi Tiểu học
class PrimarySkyGreetingHeader extends StatelessWidget {
  final String studentName;
  final Color primaryColor;
  final DateTime? timeOverride;

  const PrimarySkyGreetingHeader({
    super.key,
    required this.studentName,
    required this.primaryColor,
    this.timeOverride,
  });

  @override
  Widget build(BuildContext context) {
    final period = SkyTimeHelper.fromDateTime(timeOverride);
    final greetingText = SkyTimeHelper.getGreetingTitle(period);

    // Màu sắc theo buổi trong ngày (tươi sáng, thân thiện, bảo đảm độ tương phản AA)
    Color bannerBorder;
    Color greetingTextColor;
    List<Color> gradientColors;

    switch (period) {
      case SkyTimePeriod.morning:
        bannerBorder = const Color(0xFFFDE68A);
        greetingTextColor = const Color(0xFFD97706);
        gradientColors = [
          const Color(0xFFFFFBEB),
          const Color(0xFFFEF3C7).withValues(alpha: 0.65),
        ];
        break;
      case SkyTimePeriod.afternoon:
        bannerBorder = const Color(0xFFBAE6FD);
        greetingTextColor = const Color(0xFF0284C7);
        gradientColors = [
          const Color(0xFFF0F9FF),
          const Color(0xFFE0F2FE).withValues(alpha: 0.65),
        ];
        break;
      case SkyTimePeriod.evening:
        bannerBorder = const Color(0xFFDDD6FE);
        greetingTextColor = const Color(0xFF4F46E5);
        gradientColors = [
          const Color(0xFFF5F3FF),
          const Color(0xFFEDE9FE).withValues(alpha: 0.75),
        ];
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border(
          bottom: BorderSide(color: bannerBorder, width: 1.2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 6, 14, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Biểu tượng Bầu Trời nhô nửa phần trên lên
          SizedBox(
            width: 48,
            height: 32,
            child: ClipRect(
              child: CustomPaint(
                painter: SkyCelestialPainter(
                  period: period,
                  primaryColor: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 2. Chữ Lời Chào + Tên Học Sinh
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dòng 1: Lời chào thời gian
                Text(
                  greetingText,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: greetingTextColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 1),
                // Dòng 2: Tên học sinh dễ thương
                Text(
                  studentName.isNotEmpty ? studentName : 'Bé yêu của trường',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
