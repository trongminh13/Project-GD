import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ashadeep/utils/constants.dart' show ApiConstants;
import 'page_image_window.dart';

import 'book_mock_content_provider.dart';

/// Nguồn ảnh Hybrid cho sách điện tử:
/// - Khi có `fileId` và kết nối mạng: Tải ảnh trang PDF thật từ backend qua API Streaming (`?dpi=...`)
/// - Khi offline hoặc chạy Demo: Tự động dùng `ui.PictureRecorder` vẽ trang bài học số hóa chuẩn đẹp.
class MaterialPdfPageImageSource implements PageImageSource {
  final int? fileId;
  final String? jwtToken;
  final String baseUrl;
  final Map<String, dynamic> bookData;
  final bool isDarkMode;

  MaterialPdfPageImageSource({
    this.fileId,
    this.jwtToken,
    String? baseUrl,
    required this.bookData,
    this.isDarkMode = false,
  }) : baseUrl = baseUrl ?? ApiConstants.baseUrl;

  @override
  Future<ui.Image> load(int index, {required int targetWidth, bool thumbnail = false}) async {
    // 1. Thử tải trang PDF thật từ backend nếu có fileId
    if (fileId != null) {
      final pageNum = index + 1;
      final dpi = thumbnail
          ? 72
          : ((targetWidth * 72 / 595).clamp(72.0, 150.0)).round();
      final url = '$baseUrl/materials/files/$fileId/pages/$pageNum?dpi=$dpi';

      try {
        final headers = <String, String>{};
        if (jwtToken != null && jwtToken!.isNotEmpty) {
          headers['Authorization'] = 'Bearer $jwtToken';
        }
        final res = await http.get(Uri.parse(url), headers: headers)
            .timeout(const Duration(seconds: 4));

        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          final codec = await ui.instantiateImageCodec(
            res.bodyBytes,
            targetWidth: targetWidth,
          );
          try {
            final frame = await codec.getNextFrame();
            return frame.image;
          } finally {
            codec.dispose();
          }
        }
      } catch (_) {
        // Lỗi mạng hoặc server không có file -> chuyển sang fallback vẽ canvas
      }
    }

    // 2. Fallback: Vẽ trang số hóa bằng PictureRecorder (hoàn toàn offline)
    return _renderProceduralPage(index, targetWidth, thumbnail);
  }

  Future<ui.Image> _renderProceduralPage(int index, int targetWidth, bool thumbnail) async {
    final pageNum = index + 1;
    final w = targetWidth.toDouble();
    final h = w * 1.4142; // Tỷ lệ chuẩn A4
    final u = w / 360.0; // Tỷ lệ phóng to đơn vị

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final bg = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFCFBF7);
    final border = isDarkMode ? const Color(0xFF333333) : const Color(0xFFE8E5DD);
    final textColor = isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF2C2C2C);
    final textSub = isDarkMode ? const Color(0xFF9E9E9E) : const Color(0xFF757575);
    final primary = const Color(0xFF2457C5);

    // Vẽ nền giấy sách
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = bg);
    canvas.drawRect(
      Rect.fromLTWH(1, 1, w - 2, h - 2),
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    if (thumbnail) {
      // Bản vẽ thu nhỏ cực nhanh cho thumbnail
      final tp = TextPainter(
        text: TextSpan(
          text: 'Trang $pageNum',
          style: TextStyle(fontSize: 14 * u, fontWeight: FontWeight.bold, color: textSub),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((w - tp.width) / 2, (h - tp.height) / 2));
      return recorder.endRecording().toImage(targetWidth, h.round());
    }

    // Phân giải nội dung bài học số hóa chuẩn theo môn học và cấp học
    final lesson = BookMockContentProvider.resolve(bookData, pageNum);

    var y = 20 * u;

    // Header: Tiêu đề chương & Số trang
    void drawText(String text, double size, FontWeight weight, Color color, {double maxWidth = 0}) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: size * u,
            fontWeight: weight,
            color: color,
            height: 1.4,
            fontFamily: 'Roboto',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth > 0 ? maxWidth : w - 40 * u);
      tp.paint(canvas, Offset(20 * u, y));
      y += tp.height;
    }

    // Top Bar
    drawText(lesson.chapterTitle, 10, FontWeight.bold, primary, maxWidth: w - 90 * u);
    final pageNumPainter = TextPainter(
      text: TextSpan(
        text: 'TRANG $pageNum',
        style: TextStyle(
          fontSize: 11 * u,
          fontWeight: FontWeight.bold,
          color: primary,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pageNumPainter.paint(canvas, Offset(w - 20 * u - pageNumPainter.width, 20 * u));
    y += 10 * u;

    // Đường kẻ phân cách trên
    canvas.drawLine(
      Offset(20 * u, y),
      Offset(w - 20 * u, y),
      Paint()..color = border..strokeWidth = 1 * u,
    );
    y += 16 * u;

    // Tiêu đề bài học
    drawText(lesson.lessonTitle, 15, FontWeight.bold, textColor);
    y += 12 * u;

    // Box Kiến thức trọng tâm
    final boxTop = y;
    final boxPadding = 12 * u;
    final tipPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '📖 ${lesson.tipTitle}:\n',
            style: TextStyle(
              fontSize: 12 * u,
              fontWeight: FontWeight.bold,
              color: primary,
              height: 1.4,
              fontFamily: 'Roboto',
            ),
          ),
          TextSpan(
            text: lesson.tipText,
            style: TextStyle(
              fontSize: 11 * u,
              color: textColor,
              height: 1.45,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - 40 * u - 2 * boxPadding);

    final boxHeight = tipPainter.height + 2 * boxPadding;
    final boxRect = Rect.fromLTWH(20 * u, boxTop, w - 40 * u, boxHeight);
    canvas.drawRect(
      boxRect,
      Paint()..color = primary.withValues(alpha: isDarkMode ? 0.15 : 0.06),
    );
    canvas.drawRect(
      boxRect,
      Paint()
        ..color = primary.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * u,
    );
    tipPainter.paint(canvas, Offset(20 * u + boxPadding, boxTop + boxPadding));
    y += boxHeight + 16 * u;

    // Phần Bài tập 1
    drawText(lesson.exTitle, 13, FontWeight.bold, textColor);
    y += 4 * u;
    drawText(lesson.exContent, 11.5, FontWeight.normal, textColor);
    y += 12 * u;

    // Phần Bài tập 2 (nếu có)
    if (lesson.exTitle2.isNotEmpty) {
      drawText(lesson.exTitle2, 13, FontWeight.bold, textColor);
      y += 4 * u;
      drawText(lesson.exContent2, 11.5, FontWeight.normal, textColor);
      y += 16 * u;
    }

    // Footer: Logo nhà xuất bản & Số trang ở chân
    final footerY = h - 35 * u;
    canvas.drawLine(
      Offset(20 * u, footerY - 10 * u),
      Offset(w - 20 * u, footerY - 10 * u),
      Paint()..color = border..strokeWidth = 1 * u,
    );

    final footerLeft = TextPainter(
      text: TextSpan(
        text: '${lesson.footerBookName} · Đại Việt EdTech',
        style: TextStyle(
          fontSize: 9 * u,
          color: textSub,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - 90 * u);
    footerLeft.paint(canvas, Offset(20 * u, footerY));

    final footerRight = TextPainter(
      text: TextSpan(
        text: '- $pageNum -',
        style: TextStyle(
          fontSize: 10 * u,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    footerRight.paint(canvas, Offset(w - 20 * u - footerRight.width, footerY));

    return recorder.endRecording().toImage(targetWidth, h.round());
  }
}
