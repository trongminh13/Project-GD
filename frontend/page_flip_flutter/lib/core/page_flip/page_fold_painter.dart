import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'fold_geometry.dart';
import 'page_image_window.dart';

/// Trạng thái một khung hình của vùng đọc.
class PageFrame {
  const PageFrame({
    required this.front,
    this.corner,
    this.fadeTo,
    this.fadeAlpha = 0,
  });

  /// Trang đang là mặt trước.
  final int front;

  /// Điểm góc đang bị kéo. `null` nghĩa là không gập, chỉ hiện trang phẳng.
  final Offset? corner;

  /// Khi không `null`: đang mờ dần sang trang này (dùng cho giảm chuyển động).
  final int? fadeTo;
  final double fadeAlpha;
}

/// Vẽ trang đang gập: mỗi khung hình tối đa 3 lần vẽ ảnh (trang bên dưới, phần
/// trang còn phẳng, mặt sau mờ của phần gập). Không dùng shader, `saveLayer` hay
/// `Opacity`. Không tạo `Paint` mới trong mỗi khung hình, trừ khi bật bóng.
class PageFoldPainter extends CustomPainter {
  PageFoldPainter({
    required this.frame,
    required this.window,
    required this.pageCount,
    this.shadow = false,
    this.paperColor = const Color(0xFFFFFFFF),
    this.backColor = const Color(0xFFF1F3F4),
    this.creaseColor = const Color(0x38000000),
  }) : super(repaint: Listenable.merge(<Listenable>[frame, window]));

  final ValueListenable<PageFrame> frame;
  final PageImageWindow window;
  final int pageCount;

  /// Bóng ở nếp gập (tùy chọn). Mặc định tắt để giữ giao diện phẳng.
  final bool shadow;
  final Color paperColor;
  final Color backColor;
  final Color creaseColor;

  late final Paint _paper = Paint()..color = paperColor;
  late final Paint _back = Paint()..color = backColor;
  late final Paint _image = Paint()
    ..filterQuality = FilterQuality.low
    ..isAntiAlias = false;
  // Mặt sau của trang gập: ảnh trang phản chiếu, mờ khoảng 14%.
  late final Paint _ghost = Paint()
    ..color = const Color(0x24FFFFFF)
    ..filterQuality = FilterQuality.low;
  late final Paint _fade = Paint()..filterQuality = FilterQuality.low;
  late final Paint _crease = Paint()
    ..color = creaseColor
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame.value;
    final page = Offset.zero & size;
    canvas.drawRect(page, _paper);

    final front = window.imageOf(f.front);

    // Giảm chuyển động: mờ dần sang trang khác, không gập.
    if (f.fadeTo != null) {
      _drawImage(canvas, size, front, _image);
      final to = window.imageOf(f.fadeTo!);
      if (to != null) {
        _fade.color = Color.fromRGBO(255, 255, 255, f.fadeAlpha.clamp(0.0, 1.0).toDouble());
        _drawImage(canvas, size, to, _fade);
      }
      return;
    }

    final corner = f.corner;
    final under = f.front + 1 < pageCount ? window.imageOf(f.front + 1) : null;
    final fold = corner == null ? null : FoldGeometry.compute(size, corner);
    if (fold == null || f.front + 1 >= pageCount) {
      _drawImage(canvas, size, front, _image);
      return;
    }

    // 1. Trang bên dưới, ở phía góc bị gập.
    if (fold.cornerSide.length >= 3) {
      canvas.save();
      canvas.clipPath(_polygon(fold.cornerSide));
      _drawImage(canvas, size, under, _image);
      if (shadow) {
        canvas.drawRect(
          page,
          Paint()
            ..shader = ui.Gradient.linear(
              fold.mid,
              fold.mid + fold.normal * 30,
              const <Color>[Color(0x33000000), Color(0x00000000)],
            ),
        );
      }
      canvas.restore();
    }

    // 2. Phần trang còn phẳng.
    if (fold.flatSide.length >= 3) {
      canvas.save();
      canvas.clipPath(_polygon(fold.flatSide));
      _drawImage(canvas, size, front, _image);
      canvas.restore();
    }

    // 3. Phần đã gập: mặt sau phẳng, thấy mờ nội dung xuyên qua giấy.
    final flap = fold.flap;
    if (flap.length >= 3) {
      canvas.save();
      canvas.clipRect(page);
      canvas.clipPath(_polygon(flap));
      canvas.drawRect(page.inflate(size.longestSide), _back);
      canvas.transform(fold.reflectionMatrix);
      _drawImage(canvas, size, front, _ghost);
      canvas.restore();
    }

    // 4. Nếp gập.
    canvas.save();
    canvas.clipRect(page);
    final along = Offset(fold.normal.dy, -fold.normal.dx) * 3000;
    canvas.drawLine(fold.mid + along, fold.mid - along, _crease);
    canvas.restore();
  }

  void _drawImage(Canvas canvas, Size size, ui.Image? image, Paint paint) {
    if (image == null) return;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & size,
      paint,
    );
  }

  Path _polygon(List<Offset> points) => Path()..addPolygon(points, true);

  @override
  bool shouldRepaint(PageFoldPainter old) =>
      old.window != window ||
      old.pageCount != pageCount ||
      old.shadow != shadow ||
      old.paperColor != paperColor ||
      old.backColor != backColor ||
      old.creaseColor != creaseColor;
}
