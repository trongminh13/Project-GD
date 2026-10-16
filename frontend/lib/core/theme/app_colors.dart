import 'package:flutter/material.dart';

/// Bộ bảng màu chuẩn cho toàn bộ hệ thống (trích xuất từ bản mẫu Demo HTML)
class AppColors {
  AppColors._();

  /// Màu xanh chính thương hiệu (Primary Blue) #2457C5
  static const Color primary = Color(0xFF2457C5);
  static const Color primaryBlue = primary;

  /// Màu chữ chính (Main Text) #202124
  static const Color textMain = Color(0xFF202124);

  /// Màu chữ phụ (Sub / Muted Text) #5F6368
  static const Color textSub = Color(0xFF5F6368);
  static const Color textMuted = textSub;

  /// Màu viền phân cách phẳng (Border) #DADCE0
  static const Color border = Color(0xFFDADCE0);
  static const Color borderColor = border;

  /// Màu nền Card / Box trắng #FFFFFF
  static const Color cardBg = Color(0xFFFFFFFF);

  /// Màu nền ứng dụng / nền phụ #F8F9FA
  static const Color background = Color(0xFFF8F9FA);
  static const Color bgColor = background;

  /// Màu xám nhạt cho badge, thanh tiến trình #F1F3F4
  static const Color surfaceAlt = Color(0xFFF1F3F4);

  /// Màu thành công / Đã nộp / Có mặt #237A45
  static const Color success = Color(0xFF237A45);
  static const Color okGreen = success;

  /// Màu cảnh báo / Chờ chấm / Đi muộn #E37400
  static const Color warning = Color(0xFFE37400);
  static const Color warningAmber = warning;

  /// Màu lỗi / Quá hạn / Vắng mặt #C62828
  static const Color error = Color(0xFFC62828);
  static const Color dangerRed = Color(0xFFC5221F);

  /// Màu tím / Điểm nhấn bổ trợ #5C2D91
  static const Color purple = Color(0xFF5C2D91);

  // Helper tương thích ngược với AppColors cũ nếu cần
  static Color primaryOf(BuildContext context) => primary;
  static Color surfaceAltOf(BuildContext context) => surfaceAlt;
}
