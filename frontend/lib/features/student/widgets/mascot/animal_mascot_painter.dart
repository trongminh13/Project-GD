import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'animal_mascot_data.dart';

/// Painter vẽ 10 linh vật bạn đồng hành (Vector Canvas thuần)
/// Chuyển đổi trung thực từ mẫu SVG trong animal-card.html
class AnimalMascotPainter extends CustomPainter {
  final AnimalMascotType type;
  final Color primaryColor;

  const AnimalMascotPainter({
    required this.type,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Kích thước chuẩn viewBox của bản thiết kế gốc là 240 x 240
    final scale = math.min(size.width / 240.0, size.height / 240.0);
    // Căn sát mép dưới và mép phải của ô hiển thị
    final dx = size.width - 240.0 * scale;
    final dy = size.height - 240.0 * scale;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    // 1. Vẽ thân và cánh tay vẫy (Dùng chung cho cả 10 con vật)
    _drawBody(canvas);

    // 2. Vẽ đầu con vật với góc nghiêng -10 độ tại tâm (150, 105)
    canvas.save();
    _rotateAround(canvas, 150.0, 105.0, -10.0 * math.pi / 180.0);
    _drawHead(canvas);
    canvas.restore();

    canvas.restore();
  }

  void _rotateAround(Canvas canvas, double cx, double cy, double radians) {
    canvas.translate(cx, cy);
    canvas.rotate(radians);
    canvas.translate(-cx, -cy);
  }

  // ===================== THÂN VÀ TAY VẪY =====================
  void _drawBody(Canvas canvas) {
    final strokeWhite3 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.round;

    final fillPrimary = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // Thân: Ellipse xoay -24 độ quanh (226, 196)
    canvas.save();
    _rotateAround(canvas, 226.0, 196.0, -24.0 * math.pi / 180.0);
    final bodyRect = Rect.fromCenter(center: const Offset(226, 196), width: 124, height: 184);
    canvas.drawOval(bodyRect, fillPrimary);
    canvas.drawOval(bodyRect, strokeWhite3);
    canvas.restore();

    // Cánh tay vươn ra vẫy
    final armPath = Path()
      ..moveTo(188, 156)
      ..quadraticBezierTo(84, 172, 78, 66);

    final armOuter = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 31.0
      ..strokeCap = StrokeCap.round;

    final armInner = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(armPath, armOuter);
    canvas.drawPath(armPath, armInner);

    // Bàn tay tròn
    canvas.drawCircle(const Offset(78, 62), 16.0, fillPrimary);
    canvas.drawCircle(const Offset(78, 62), 16.0, strokeWhite3);

    // Vòng nét trong bàn tay
    final handInner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(const Offset(78, 64), 6.0, handInner);

    // 2 vạch sóng vẫy tay
    final wavePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final wave1 = Path()
      ..moveTo(52, 40)
      ..quadraticBezierTo(38, 62, 52, 86);
    canvas.drawPath(wave1, wavePaint);

    final wave2 = Path()
      ..moveTo(36, 30)
      ..quadraticBezierTo(16, 62, 36, 96);
    canvas.drawPath(wave2, wavePaint);
  }

  // ===================== HELPER VẼ MẮT VÀ MIỆNG =====================
  void _drawEyes(Canvas canvas, double x1, double x2, double y,
      [double rx = 8.0, double ry = 9.5, double pr = 4.5]) {
    final fillWhite = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final fillPrimary = Paint()..color = primaryColor..style = PaintingStyle.fill;

    // Tròng trắng
    canvas.drawOval(Rect.fromCenter(center: Offset(x1, y), width: rx * 2, height: ry * 2), fillWhite);
    canvas.drawOval(Rect.fromCenter(center: Offset(x2, y), width: rx * 2, height: ry * 2), fillWhite);

    // Con ngươi
    canvas.drawCircle(Offset(x1 + 1.5, y + 2.0), pr, fillPrimary);
    canvas.drawCircle(Offset(x2 - 1.5, y + 2.0), pr, fillPrimary);
  }

  void _drawSmileMouth(Canvas canvas, double cx, double cy, double w, double d) {
    final mouthPath = Path()
      ..moveTo(cx - w, cy)
      ..quadraticBezierTo(cx, cy + d, cx + w, cy)
      ..quadraticBezierTo(cx, cy + d * 0.24, cx - w, cy)
      ..close();

    final fillWhite = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final strokeWhite2 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(mouthPath, fillWhite);
    canvas.drawPath(mouthPath, strokeWhite2);

    final fillPrimary = Paint()..color = primaryColor..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + d * 0.48), width: w * 0.94, height: 8.0),
      fillPrimary,
    );
  }

  // ===================== ĐẦU 10 CON VẬT =====================
  void _drawHead(Canvas canvas) {
    final strokeWhite3 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final fillPrimary = Paint()..color = primaryColor..style = PaintingStyle.fill;
    final fillWhite = Paint()..color = Colors.white..style = PaintingStyle.fill;

    switch (type) {
      case AnimalMascotType.bear: // 0. GẤU
        // 2 tai
        canvas.drawCircle(const Offset(112, 62), 19.0, fillPrimary);
        canvas.drawCircle(const Offset(112, 62), 19.0, strokeWhite3);
        canvas.drawCircle(const Offset(188, 62), 19.0, fillPrimary);
        canvas.drawCircle(const Offset(188, 62), 19.0, strokeWhite3);

        canvas.drawCircle(const Offset(112, 62), 9.0, strokeWhite3);
        canvas.drawCircle(const Offset(188, 62), 9.0, strokeWhite3);

        // Đầu tròn
        canvas.drawCircle(const Offset(150, 105), 52.0, fillPrimary);
        canvas.drawCircle(const Offset(150, 105), 52.0, strokeWhite3);

        // Mõm
        canvas.drawOval(Rect.fromCenter(center: const Offset(150, 124), width: 48, height: 40), strokeWhite3);

        // Mắt
        _drawEyes(canvas, 130, 170, 98);

        // Mũi
        canvas.drawOval(Rect.fromCenter(center: const Offset(150, 112), width: 17, height: 12), fillWhite);
        canvas.drawLine(const Offset(150, 118), const Offset(150, 124), strokeWhite3);

        // Miệng
        _drawSmileMouth(canvas, 150, 125, 16, 25);
        break;

      case AnimalMascotType.crocodile: // 1. CÁ SẤU
        // Mắt lồi
        canvas.drawCircle(const Offset(122, 64), 17.0, fillPrimary);
        canvas.drawCircle(const Offset(122, 64), 17.0, strokeWhite3);
        canvas.drawCircle(const Offset(178, 64), 17.0, fillPrimary);
        canvas.drawCircle(const Offset(178, 64), 17.0, strokeWhite3);

        // Đầu oval
        final headRect = Rect.fromCenter(center: const Offset(150, 106), width: 112, height: 96);
        canvas.drawOval(headRect, fillPrimary);
        canvas.drawOval(headRect, strokeWhite3);

        // Mắt
        _drawEyes(canvas, 122, 178, 63, 8.5, 9.5, 4.5);

        // Vòm mõm
        canvas.drawOval(Rect.fromCenter(center: const Offset(150, 124), width: 84, height: 52), strokeWhite3);

        // Lỗ mũi
        canvas.drawCircle(const Offset(137, 108), 3.0, fillWhite);
        canvas.drawCircle(const Offset(163, 108), 3.0, fillWhite);

        // Đường miệng
        final mouthPath = Path()..moveTo(118, 126)..quadraticBezierTo(150, 148, 182, 126);
        canvas.drawPath(mouthPath, strokeWhite3);

        // 5 chiếc răng tam giác
        final teeth = Path()
          ..moveTo(126.5, 132)..lineTo(133.5, 132)..lineTo(130, 139)..close()
          ..moveTo(136.5, 135.2)..lineTo(143.5, 135.2)..lineTo(140, 142)..close()
          ..moveTo(146.5, 136.3)..lineTo(153.5, 136.3)..lineTo(150, 143.5)..close()
          ..moveTo(156.5, 135.2)..lineTo(163.5, 135.2)..lineTo(160, 142)..close()
          ..moveTo(166.5, 132)..lineTo(173.5, 132)..lineTo(170, 139)..close();
        canvas.drawPath(teeth, fillWhite);
        break;

      case AnimalMascotType.cat: // 2. MÈO
        // 2 tai nhọn
        final earLeft = Path()..moveTo(102, 84)..lineTo(104, 34)..lineTo(138, 62)..close();
        final earRight = Path()..moveTo(198, 84)..lineTo(196, 34)..lineTo(162, 62)..close();
        canvas.drawPath(earLeft, fillPrimary);
        canvas.drawPath(earLeft, strokeWhite3);
        canvas.drawPath(earRight, fillPrimary);
        canvas.drawPath(earRight, strokeWhite3);

        final earInnerL = Path()..moveTo(112, 68)..lineTo(113, 50)..lineTo(127, 60);
        final earInnerR = Path()..moveTo(188, 68)..lineTo(187, 50)..lineTo(173, 60);
        canvas.drawPath(earInnerL, strokeWhite3);
        canvas.drawPath(earInnerR, strokeWhite3);

        // Đầu
        final catHead = Rect.fromCenter(center: const Offset(150, 108), width: 108, height: 96);
        canvas.drawOval(catHead, fillPrimary);
        canvas.drawOval(catHead, strokeWhite3);

        // Mắt mèo hạt dưa
        canvas.drawOval(Rect.fromCenter(center: const Offset(130, 102), width: 15, height: 20), fillWhite);
        canvas.drawOval(Rect.fromCenter(center: const Offset(170, 102), width: 15, height: 20), fillWhite);
        canvas.drawOval(Rect.fromCenter(center: const Offset(131, 103), width: 6, height: 16), fillPrimary);
        canvas.drawOval(Rect.fromCenter(center: const Offset(169, 103), width: 6, height: 16), fillPrimary);

        // Mũi tam giác
        final catNose = Path()..moveTo(144, 114)..lineTo(156, 114)..lineTo(150, 121)..close();
        canvas.drawPath(catNose, fillWhite);

        // Miệng
        final catMouth = Path()
          ..moveTo(150, 121)..lineTo(150, 126)
          ..moveTo(150, 126)..quadraticBezierTo(142, 135, 134, 127)
          ..moveTo(150, 126)..quadraticBezierTo(158, 135, 166, 127);
        canvas.drawPath(catMouth, strokeWhite3);

        // 4 râu mép
        final whiskerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(104, 114), const Offset(88, 110), whiskerPaint);
        canvas.drawLine(const Offset(104, 122), const Offset(88, 126), whiskerPaint);
        canvas.drawLine(const Offset(196, 114), const Offset(214, 110), whiskerPaint);
        canvas.drawLine(const Offset(196, 122), const Offset(214, 126), whiskerPaint);
        break;

      case AnimalMascotType.fish: // 3. CÁ
        // Vây lưng
        final topFin = Path()..moveTo(114, 70)..quadraticBezierTo(150, 14, 186, 70)..quadraticBezierTo(150, 54, 114, 70)..close();
        canvas.drawPath(topFin, fillPrimary);
        canvas.drawPath(topFin, strokeWhite3);

        final finStroke = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.2;
        canvas.drawLine(const Offset(150, 52), const Offset(150, 32), finStroke);
        canvas.drawLine(const Offset(132, 58), const Offset(126, 40), finStroke);
        canvas.drawLine(const Offset(168, 58), const Offset(174, 40), finStroke);

        // 2 vây bên
        canvas.save();
        _rotateAround(canvas, 94.0, 118.0, -25.0 * math.pi / 180.0);
        final finL = Rect.fromCenter(center: const Offset(94, 118), width: 32, height: 18);
        canvas.drawOval(finL, fillPrimary);
        canvas.drawOval(finL, strokeWhite3);
        canvas.restore();

        canvas.save();
        _rotateAround(canvas, 206.0, 118.0, 25.0 * math.pi / 180.0);
        final finR = Rect.fromCenter(center: const Offset(206, 118), width: 32, height: 18);
        canvas.drawOval(finR, fillPrimary);
        canvas.drawOval(finR, strokeWhite3);
        canvas.restore();

        // Thân cá
        final fishBody = Rect.fromCenter(center: const Offset(150, 108), width: 112, height: 100);
        canvas.drawOval(fishBody, fillPrimary);
        canvas.drawOval(fishBody, strokeWhite3);

        // Nếp mang
        final gillPath = Path()
          ..moveTo(100, 98)..quadraticBezierTo(94, 112, 100, 126)
          ..moveTo(200, 98)..quadraticBezierTo(206, 112, 200, 126);
        canvas.drawPath(gillPath, finStroke);

        // Mắt tròn to
        canvas.drawCircle(const Offset(127, 94), 13.0, fillWhite);
        canvas.drawCircle(const Offset(173, 94), 13.0, fillWhite);
        canvas.drawCircle(const Offset(129, 97), 6.5, fillPrimary);
        canvas.drawCircle(const Offset(171, 97), 6.5, fillPrimary);
        canvas.drawCircle(const Offset(131, 94.5), 2.0, fillWhite);
        canvas.drawCircle(const Offset(173, 94.5), 2.0, fillWhite);

        // Miệng chúm chím
        canvas.drawOval(Rect.fromCenter(center: const Offset(150, 125), width: 34, height: 20), fillWhite);
        final fishMouth = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
        final fMouthPath = Path()..moveTo(141, 123)..quadraticBezierTo(150, 132, 159, 123);
        canvas.drawPath(fMouthPath, fishMouth);
        break;

      case AnimalMascotType.horse: // 4. NGỰA
        // Tai
        final earL = Path()..moveTo(121, 66)..lineTo(113, 20)..lineTo(145, 52)..close();
        final earR = Path()..moveTo(179, 66)..lineTo(187, 20)..lineTo(155, 52)..close();
        canvas.drawPath(earL, fillPrimary);
        canvas.drawPath(earL, strokeWhite3);
        canvas.drawPath(earR, fillPrimary);
        canvas.drawPath(earR, strokeWhite3);

        final earInL = Path()..moveTo(122, 56)..lineTo(119, 36)..lineTo(134, 50);
        final earInR = Path()..moveTo(178, 56)..lineTo(181, 36)..lineTo(166, 50);
        canvas.drawPath(earInL, strokeWhite3);
        canvas.drawPath(earInR, strokeWhite3);

        // Đầu
        final horseHead = Rect.fromCenter(center: const Offset(150, 104), width: 90, height: 114);
        canvas.drawOval(horseHead, fillPrimary);
        canvas.drawOval(horseHead, strokeWhite3);

        // Bờm ngựa
        final mane = Path()
          ..moveTo(126, 60)
          ..quadraticBezierTo(132, 24, 152, 42)
          ..quadraticBezierTo(162, 26, 174, 60)
          ..quadraticBezierTo(150, 50, 126, 60)
          ..close();
        canvas.drawPath(mane, fillPrimary);
        canvas.drawPath(mane, strokeWhite3);

        // Mắt
        _drawEyes(canvas, 132, 168, 96, 7.0, 9.0, 4.0);

        // Mõm
        canvas.drawOval(Rect.fromCenter(center: const Offset(150, 136), width: 56, height: 40), strokeWhite3);

        // 2 lỗ mũi
        canvas.drawCircle(const Offset(139, 132), 3.5, fillWhite);
        canvas.drawCircle(const Offset(161, 132), 3.5, fillWhite);

        // Miệng
        final horseMouth = Path()..moveTo(138, 146)..quadraticBezierTo(150, 154, 162, 146);
        canvas.drawPath(horseMouth, strokeWhite3);
        break;

      case AnimalMascotType.rabbit: // 5. THỎ
        // 2 tai dài
        canvas.save();
        _rotateAround(canvas, 126.0, 42.0, -8.0 * math.pi / 180.0);
        final rEarL = Rect.fromCenter(center: const Offset(126, 42), width: 28, height: 76);
        canvas.drawOval(rEarL, fillPrimary);
        canvas.drawOval(rEarL, strokeWhite3);
        canvas.drawOval(Rect.fromCenter(center: const Offset(126, 44), width: 12, height: 52), strokeWhite3);
        canvas.restore();

        canvas.save();
        _rotateAround(canvas, 174.0, 42.0, 8.0 * math.pi / 180.0);
        final rEarR = Rect.fromCenter(center: const Offset(174, 42), width: 28, height: 76);
        canvas.drawOval(rEarR, fillPrimary);
        canvas.drawOval(rEarR, strokeWhite3);
        canvas.drawOval(Rect.fromCenter(center: const Offset(174, 44), width: 12, height: 52), strokeWhite3);
        canvas.restore();

        // Đầu tròn
        canvas.drawCircle(const Offset(150, 108), 50.0, fillPrimary);
        canvas.drawCircle(const Offset(150, 108), 50.0, strokeWhite3);

        // Mắt
        _drawEyes(canvas, 131, 169, 102, 7.0, 9.0, 4.2);

        // Mũi
        canvas.drawOval(Rect.fromCenter(center: const Offset(150, 114), width: 13, height: 9), fillWhite);

        // Miệng
        final rabMouth = Path()
          ..moveTo(150, 119)..lineTo(150, 125)
          ..moveTo(150, 125)..quadraticBezierTo(142, 133, 135, 127)
          ..moveTo(150, 125)..quadraticBezierTo(158, 133, 165, 127);
        canvas.drawPath(rabMouth, strokeWhite3);

        // 2 răng cửa thỏ
        final teethR = RRect.fromRectAndRadius(const Rect.fromLTWH(143, 128, 14, 11), const Radius.circular(2.0));
        canvas.drawRRect(teethR, fillWhite);
        final teethBorder = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 1.5;
        canvas.drawRRect(teethR, teethBorder);

        final toothDivider = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 1.6;
        canvas.drawLine(const Offset(150, 129), const Offset(150, 138), toothDivider);
        break;

      case AnimalMascotType.dog: // 6. CHÓ
        // 2 tai cụp
        canvas.save();
        _rotateAround(canvas, 102.0, 100.0, 16.0 * math.pi / 180.0);
        final dogEarL = Rect.fromCenter(center: const Offset(102, 100), width: 34, height: 68);
        canvas.drawOval(dogEarL, fillPrimary);
        canvas.drawOval(dogEarL, strokeWhite3);
        canvas.restore();

        canvas.save();
        _rotateAround(canvas, 198.0, 100.0, -16.0 * math.pi / 180.0);
        final dogEarR = Rect.fromCenter(center: const Offset(198, 100), width: 34, height: 68);
        canvas.drawOval(dogEarR, fillPrimary);
        canvas.drawOval(dogEarR, strokeWhite3);
        canvas.restore();

        // Đầu
        canvas.drawCircle(const Offset(150, 105), 50.0, fillPrimary);
        canvas.drawCircle(const Offset(150, 105), 50.0, strokeWhite3);

        // Đốm mắt
        canvas.drawOval(Rect.fromCenter(center: const Offset(170, 94), width: 34, height: 36), strokeWhite3);

        // Mắt
        _drawEyes(canvas, 131, 169, 98, 7.5, 9.0, 4.3);

        // Mõm
        canvas.drawOval(Rect.fromCenter(center: const Offset(150, 126), width: 52, height: 38), strokeWhite3);

        // Mũi
        canvas.drawOval(Rect.fromCenter(center: const Offset(150, 115), width: 20, height: 14), fillWhite);

        // Miệng
        final dogMouth = Path()
          ..moveTo(150, 122)..lineTo(150, 128)
          ..moveTo(150, 128)..quadraticBezierTo(141, 137, 132, 129)
          ..moveTo(150, 128)..quadraticBezierTo(159, 137, 168, 129);
        canvas.drawPath(dogMouth, strokeWhite3);

        // Lưỡi thè
        final tongue = Path()
          ..moveTo(143, 134)..lineTo(143, 147)..quadraticBezierTo(150, 155, 157, 147)..lineTo(157, 134)..close();
        canvas.drawPath(tongue, fillWhite);
        final tongueLine = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 1.8;
        canvas.drawLine(const Offset(150, 136), const Offset(150, 147), tongueLine);
        break;

      case AnimalMascotType.elephant: // 7. VOI
        // 2 tai to
        canvas.drawCircle(const Offset(98, 104), 30.0, fillPrimary);
        canvas.drawCircle(const Offset(98, 104), 30.0, strokeWhite3);
        canvas.drawCircle(const Offset(202, 104), 30.0, fillPrimary);
        canvas.drawCircle(const Offset(202, 104), 30.0, strokeWhite3);

        canvas.drawCircle(const Offset(98, 104), 17.0, strokeWhite3);
        canvas.drawCircle(const Offset(202, 104), 17.0, strokeWhite3);

        // Đầu
        canvas.drawCircle(const Offset(150, 102), 47.0, fillPrimary);
        canvas.drawCircle(const Offset(150, 102), 47.0, strokeWhite3);

        // Mắt
        _drawEyes(canvas, 132, 168, 92, 6.5, 8.0, 3.8);

        // Vòi voi (Trunk)
        final trunkPath = Path()
          ..moveTo(150, 108)
          ..quadraticBezierTo(150, 150, 138, 160)
          ..quadraticBezierTo(131, 166, 126, 157);

        final trunkOuter = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 27.0..strokeCap = StrokeCap.round;
        final trunkInner = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 21.0..strokeCap = StrokeCap.round;
        canvas.drawPath(trunkPath, trunkOuter);
        canvas.drawPath(trunkPath, trunkInner);

        // Ngấn vòi
        final trunkRing = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.2;
        canvas.drawLine(const Offset(141, 126), const Offset(159, 126), trunkRing);
        canvas.drawLine(const Offset(140, 138), const Offset(158, 138), trunkRing);

        // Má/ngà
        final tuskPath = Path()
          ..moveTo(118, 122)..quadraticBezierTo(124, 134, 136, 132)
          ..moveTo(182, 122)..quadraticBezierTo(176, 134, 164, 132);
        canvas.drawPath(tuskPath, strokeWhite3);
        break;

      case AnimalMascotType.duck: // 8. VỊT
        // Chỏm lông tơ trên đầu
        final tuft = Path()
          ..moveTo(136, 62)
          ..quadraticBezierTo(130, 38, 147, 47)
          ..quadraticBezierTo(151, 28, 164, 45)
          ..quadraticBezierTo(178, 38, 168, 64)
          ..close();
        canvas.drawPath(tuft, fillPrimary);
        canvas.drawPath(tuft, strokeWhite3);

        // Đầu
        canvas.drawCircle(const Offset(150, 106), 50.0, fillPrimary);
        canvas.drawCircle(const Offset(150, 106), 50.0, strokeWhite3);

        // Mắt
        _drawEyes(canvas, 130, 170, 94, 6.5, 8.5, 4.0);

        // Mỏ dẹt
        canvas.drawOval(Rect.fromCenter(center: const Offset(150, 122), width: 60, height: 30), fillWhite);

        final duckMouth = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
        final dMouthPath = Path()..moveTo(122, 122)..quadraticBezierTo(150, 138, 178, 122);
        canvas.drawPath(dMouthPath, duckMouth);

        // 2 lỗ mũi nhỏ trên mỏ
        canvas.drawCircle(const Offset(141, 115), 2.5, fillPrimary);
        canvas.drawCircle(const Offset(159, 115), 2.5, fillPrimary);
        break;

      case AnimalMascotType.frog: // 9. ẾCH
        // 2 mắt cầu lồi
        canvas.drawCircle(const Offset(116, 68), 23.0, fillPrimary);
        canvas.drawCircle(const Offset(116, 68), 23.0, strokeWhite3);
        canvas.drawCircle(const Offset(184, 68), 23.0, fillPrimary);
        canvas.drawCircle(const Offset(184, 68), 23.0, strokeWhite3);

        // Đầu dẹt ngang
        final frogHead = Rect.fromCenter(center: const Offset(150, 114), width: 116, height: 88);
        canvas.drawOval(frogHead, fillPrimary);
        canvas.drawOval(frogHead, strokeWhite3);

        // Mắt tròn to
        canvas.drawCircle(const Offset(116, 66), 13.0, fillWhite);
        canvas.drawCircle(const Offset(184, 66), 13.0, fillWhite);
        canvas.drawCircle(const Offset(118, 68), 6.5, fillPrimary);
        canvas.drawCircle(const Offset(182, 68), 6.5, fillPrimary);

        // Lỗ mũi
        canvas.drawCircle(const Offset(142, 102), 2.6, fillWhite);
        canvas.drawCircle(const Offset(158, 102), 2.6, fillWhite);

        // Miệng cười ngoác rộng
        _drawSmileMouth(canvas, 150, 118, 44, 44);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant AnimalMascotPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.primaryColor != primaryColor;
  }
}
