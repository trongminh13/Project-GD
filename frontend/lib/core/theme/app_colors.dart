import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ashadeep/core/theme/theme_manager.dart';

/// Bộ bảng màu chuẩn cho toàn bộ hệ thống (trích xuất từ bản mẫu Demo HTML)
class AppColors {
  AppColors._();

  /// Màu xanh chính thương hiệu (Primary Blue) #2457C5
  static const Color primary = Color(0xFF2457C5);
  static const Color primaryBlue = primary;

  /// Màu chữ chính mặc định (Main Text) #202124
  static const Color textMain = Color(0xFF202124);

  /// Màu chữ phụ mặc định (Sub / Muted Text) #5F6368
  static const Color textSub = Color(0xFF5F6368);
  static const Color textMuted = textSub;

  /// Các biến thể màu chữ cá nhân hóa
  static const Color textGreen = Color(0xFF1B5E20);
  static const Color textEmerald = Color(0xFF004D40);
  static const Color textPink = Color(0xFFAD1457);

  /// Màu viền phân cách phẳng (Border) #DADCE0
  static const Color border = Color(0xFFDADCE0);
  static const Color borderColor = border;

  /// Màu viền thẻ/hộp nội dung sắc nét (High-contrast Black Card Border)
  static const Color cardBorder = Colors.black;
  static const double cardBorderWidth = 1.0;

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

  // Helper thích ứng theo tùy chọn ThemeManager
  static Color textMainOf(BuildContext context) {
    try {
      final tm = Provider.of<ThemeManager>(context, listen: true);
      return tm.textMain;
    } catch (_) {
      return textMain;
    }
  }

  static Color textSubOf(BuildContext context) {
    try {
      final tm = Provider.of<ThemeManager>(context, listen: true);
      return tm.textSub;
    } catch (_) {
      return textSub;
    }
  }

  // Helper tương thích ngược với AppColors cũ
  static Color primaryOf(BuildContext context) => primary;
  static Color surfaceAltOf(BuildContext context) => surfaceAlt;
}
