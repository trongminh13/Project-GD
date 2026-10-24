import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ashadeep/utils/constants.dart' show ApiConstants;
import 'page_image_window.dart';

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

  bool get _isToan1 {
    final title = (bookData['title'] ?? '').toString().toLowerCase();
    return title.contains('toán 1') || title.contains('toan 1');
  }

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

    // Xác định nội dung bài học theo SGK
    String chapterTitle = 'CHỦ ĐỀ 1: LÀM QUEN VỚI MỘT SỐ HÌNH';
    String lessonTitle = 'BÀI 1: HÌNH VUÔNG - TRÒN - TAM GIÁC - CHỮ NHẬT';
    String tipText = '• Quan sát đồ vật trong lớp học và nhận biết các hình học cơ bản.\n'
        '• Hình tròn không có góc, lăn được dễ dàng.\n'
        '• Hình vuông có 4 cạnh bằng nhau, hình tam giác có 3 góc và 3 cạnh.';
    String exTitle = '1. Đố vui nhận diện hình học:';
    String exContent = 'a) Mặt trời, chiếc đĩa ăn cơm có hình: [ Hình tròn ]\n'
        'b) Khung tranh gia đình, viên gạch hoa có hình: [ Hình vuông ]\n'
        'c) Biển báo giao thông hình tam giác: [ Hình tam giác ]';

    if (_isToan1) {
      if (pageNum >= 24 && pageNum < 50) {
        chapterTitle = 'CHỦ ĐỀ 2: CHỮ SỐ VÀ PHÉP SO SÁNH';
        lessonTitle = 'BÀI 8: CÁC SỐ TỪ 1 ĐẾN 10 VÀ SO SÁNH SỐ';
        tipText = '• Đếm xuôi: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.\n'
            '• Đếm ngược: 10, 9, 8, 7, 6, 5, 4, 3, 2, 1.\n'
            '• Dấu > (lớn hơn), dấu < (bé hơn), dấu = (bằng nhau).';
        exTitle = '1. Điền dấu so sánh thích hợp (> , < , =):';
        exContent = 'a) 5 > 3       b) 8 < 9       c) 6 = 6\n'
            'd) 10 > 7      e) 4 > 2       g) 1 > 0';
      } else if (pageNum >= 50 && pageNum < 82) {
        chapterTitle = 'CHỦ ĐỀ 3: PHÉP CỘNG VÀ TRỪ TRONG PHẠM VI 10';
        lessonTitle = 'BÀI 15: PHÉP CỘNG VÀ PHÉP TRỪ CƠ BẢN';
        tipText = '• Thêm vào tức là làm phép tính cộng (+).\n'
            '• Bớt đi hoặc cho đi tức là làm phép tính trừ (-).\n'
            '• 5 + 5 = 10 ; 10 - 4 = 6 ; 7 + 3 = 10.';
        exTitle = '1. Tính nhẩm nhanh:';
        exContent = 'a) 4 + 3 = 7       b) 6 + 2 = 8       c) 5 + 5 = 10\n'
            'd) 9 - 4 = 5       e) 10 - 3 = 7      g) 7 - 0 = 7';
      } else if (pageNum >= 82) {
        chapterTitle = 'CHỦ ĐỀ 4: HÌNH KHỐI VÀ THỜI GIAN THỰC TẾ';
        lessonTitle = 'BÀI 25: KHỐI HỘP VÀ XEM ĐỒNG HỒ ĐÚNG GIỜ';
        tipText = '• Khối hộp chữ nhật có các mặt bao quanh là hình chữ nhật.\n'
            '• Khối lập phương có 6 mặt đều là các hình vuông.\n'
            '• Đồng hồ chỉ đúng giờ khi kim dài (kim phút) chỉ thẳng vào số 12.';
        exTitle = '1. Xem đồng hồ và đọc giờ:';
        exContent = 'a) Kim ngắn chỉ số 7, kim dài chỉ số 12: [ 7 giờ đúng ]\n'
            'b) Kim ngắn chỉ số 8, kim dài chỉ số 12: [ 8 giờ đúng ]';
      }
    } else {
      chapterTitle = 'CHƯƠNG ${((pageNum - 1) ~/ 25) + 1}: KIẾN THỨC BỔ TRỢ';
      lessonTitle = 'BÀI HỌC TRỌNG TÂM - TRANG $pageNum';
      tipText = '• Đọc kỹ định lý và làm bài tập thực hành theo hướng dẫn của giáo viên.\n'
          '• Vận dụng kiến thức vào thực tế đời sống hàng ngày.';
      exTitle = 'Bài tập thực hành:';
      exContent = 'Học sinh thực hiện đầy đủ các câu hỏi và ghi chép vào vở bài tập.';
    }

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
    drawText(chapterTitle, 10, FontWeight.bold, primary, maxWidth: w - 90 * u);
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
    drawText(lessonTitle, 15, FontWeight.bold, textColor);
    y += 12 * u;

    // Box Kiến thức trọng tâm
    final boxTop = y;
    final boxPadding = 12 * u;
    final tipPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '📖 Kiến thức trọng tâm:\n',
            style: TextStyle(
              fontSize: 12 * u,
              fontWeight: FontWeight.bold,
              color: primary,
              height: 1.4,
              fontFamily: 'Roboto',
            ),
          ),
          TextSpan(
            text: tipText,
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
    y += boxHeight + 20 * u;

    // Phần Bài tập
    drawText(exTitle, 13, FontWeight.bold, textColor);
    y += 6 * u;
    drawText(exContent, 12, FontWeight.normal, textColor);
    y += 24 * u;

    // Footer: Logo nhà xuất bản & Số trang ở chân
    final footerY = h - 35 * u;
    canvas.drawLine(
      Offset(20 * u, footerY - 10 * u),
      Offset(w - 20 * u, footerY - 10 * u),
      Paint()..color = border..strokeWidth = 1 * u,
    );

    final footerLeft = TextPainter(
      text: TextSpan(
        text: 'Đại Việt EdTech · Thư Viện Số Quốc Gia',
        style: TextStyle(
          fontSize: 9 * u,
          color: textSub,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
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
