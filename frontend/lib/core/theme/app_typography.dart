import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashadeep/core/enums/education_level.dart';

/// Hệ thống Typography thích ứng động theo Cấp học (Cấp 1 Tiểu học, Cấp 2 THCS, Cấp 3 THPT).
/// - Cấp 1: Tiêu đề / Nút / Điểm: Fredoka (Bold / SemiBold)
///          Đoạn văn / Đề bài / Lời thoại: Nunito (Medium / Regular)
/// - Cấp 2: Tiêu đề / Nút / Thẻ bài / Điểm: Plus Jakarta Sans (Bold / SemiBold)
///          Đoạn văn / Đề bài / Trắc nghiệm / Lời giải: Be Vietnam Pro (Regular / Medium)
///          Lời thoại thân thiện / Gợi ý: Quicksand (Medium / SemiBold)
/// - Cấp 3: Tiêu đề / Nút / Điểm: Plus Jakarta Sans (Bold / SemiBold)
///          Đề thi / Đoạn văn / Lời giải: Be Vietnam Pro (Regular / Medium)
class AppTypography {
  AppTypography._();

  /// Khởi tạo cấu hình Typography cho ứng dụng (Local Asset-First, 100% Offline)
  static void initialize() {
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  /// Cho phép cưỡng chế chế độ test để không fetch font qua mạng
  static bool forceTestMode = false;

  /// Kiểm tra có đang chạy trong môi trường kiểm thử (test runner) không để tối ưu tốc độ và không kích hoạt network
  static bool get isTestMode {
    if (forceTestMode) return true;
    try {
      final name = WidgetsBinding.instance.runtimeType.toString().toLowerCase();
      return name.contains('test');
    } catch (_) {
      return false;
    }
  }

  /// Danh sách font fallback toàn diện chống lỗi dấu tiếng Việt
  static const List<String> fontFallback = [
    'Be Vietnam Pro',
    'Nunito',
    'Roboto',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'sans-serif',
  ];

  /// Alias tương thích
  static const List<String> fontFamilyFallback = fontFallback;

  /// Lấy tên Font Family tiêu đề chính theo cấp học
  static String getTitleFontFamily(EducationLevel level) {
    switch (level) {
      case EducationLevel.primary:
        return 'Fredoka';
      case EducationLevel.secondary:
      case EducationLevel.highSchool:
        return 'Plus Jakarta Sans';
    }
  }

  /// Lấy tên Font Family văn bản chính theo cấp học
  static String getBodyFontFamily(EducationLevel level) {
    switch (level) {
      case EducationLevel.primary:
        return 'Nunito';
      case EducationLevel.secondary:
      case EducationLevel.highSchool:
        return 'Be Vietnam Pro';
    }
  }

  /// Helper tạo TextStyle an toàn giữa runtime và test (Local Asset-First)
  static TextStyle _createStyle({
    required String familyName,
    required TextStyle Function() builder,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    FontStyle? fontStyle,
  }) {
    if (isTestMode) {
      return TextStyle(
        fontFamily: familyName,
        fontFamilyFallback: fontFallback,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        fontStyle: fontStyle,
      );
    }
    try {
      return builder();
    } catch (_) {
      return TextStyle(
        fontFamily: familyName,
        fontFamilyFallback: fontFallback,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        fontStyle: fontStyle,
      );
    }
  }

  /// Sinh TextTheme chuẩn cho ThemeData theo Cấp học và Chế độ Sáng/Tối
  static TextTheme buildTextTheme(
    EducationLevel level, {
    bool isDark = false,
    Color? defaultColor,
  }) {
    final textColor = defaultColor ?? (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B));
    final textSubColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (level == EducationLevel.primary) {
      // CẤP 1 (TIỂU HỌC): Fredoka cho Tiêu đề, Nunito cho Thân bài
      return TextTheme(
        displayLarge: _createStyle(
          familyName: 'Fredoka',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
          builder: () => GoogleFonts.fredoka(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        displayMedium: _createStyle(
          familyName: 'Fredoka',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
          builder: () => GoogleFonts.fredoka(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        displaySmall: _createStyle(
          familyName: 'Fredoka',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
          builder: () => GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        headlineLarge: _createStyle(
          familyName: 'Fredoka',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
          builder: () => GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        headlineMedium: _createStyle(
          familyName: 'Fredoka',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
          builder: () => GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        headlineSmall: _createStyle(
          familyName: 'Fredoka',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
          builder: () => GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        titleLarge: _createStyle(
          familyName: 'Fredoka',
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: textColor,
          builder: () => GoogleFonts.fredoka(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        titleMedium: _createStyle(
          familyName: 'Fredoka',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
          builder: () => GoogleFonts.fredoka(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        titleSmall: _createStyle(
          familyName: 'Fredoka',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
          builder: () => GoogleFonts.fredoka(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        bodyLarge: _createStyle(
          familyName: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
          builder: () => GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        bodyMedium: _createStyle(
          familyName: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textColor,
          builder: () => GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        bodySmall: _createStyle(
          familyName: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSubColor,
          builder: () => GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: textSubColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        labelLarge: _createStyle(
          familyName: 'Fredoka',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
          builder: () => GoogleFonts.fredoka(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        labelMedium: _createStyle(
          familyName: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSubColor,
          builder: () => GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textSubColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        labelSmall: _createStyle(
          familyName: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.normal,
          color: textSubColor,
          builder: () => GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.normal,
            color: textSubColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
      );
    } else {
      // CẤP 2 (THCS) & CẤP 3 (THPT): Plus Jakarta Sans cho Tiêu đề, Be Vietnam Pro cho Thân bài
      return TextTheme(
        displayLarge: _createStyle(
          familyName: 'Plus Jakarta Sans',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
          builder: () => GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        displayMedium: _createStyle(
          familyName: 'Plus Jakarta Sans',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
          builder: () => GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        displaySmall: _createStyle(
          familyName: 'Plus Jakarta Sans',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
          builder: () => GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        headlineLarge: _createStyle(
          familyName: 'Plus Jakarta Sans',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
          builder: () => GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        headlineMedium: _createStyle(
          familyName: 'Plus Jakarta Sans',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
          builder: () => GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        headlineSmall: _createStyle(
          familyName: 'Plus Jakarta Sans',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
          builder: () => GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        titleLarge: _createStyle(
          familyName: 'Plus Jakarta Sans',
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: textColor,
          builder: () => GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        titleMedium: _createStyle(
          familyName: 'Plus Jakarta Sans',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
          builder: () => GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        titleSmall: _createStyle(
          familyName: 'Plus Jakarta Sans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
          builder: () => GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        bodyLarge: _createStyle(
          familyName: 'Be Vietnam Pro',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
          builder: () => GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        bodyMedium: _createStyle(
          familyName: 'Be Vietnam Pro',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textColor,
          builder: () => GoogleFonts.beVietnamPro(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        bodySmall: _createStyle(
          familyName: 'Be Vietnam Pro',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSubColor,
          builder: () => GoogleFonts.beVietnamPro(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: textSubColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        labelLarge: _createStyle(
          familyName: 'Plus Jakarta Sans',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
          builder: () => GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        labelMedium: _createStyle(
          familyName: 'Be Vietnam Pro',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSubColor,
          builder: () => GoogleFonts.beVietnamPro(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSubColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
        labelSmall: _createStyle(
          familyName: 'Be Vietnam Pro',
          fontSize: 11,
          fontWeight: FontWeight.normal,
          color: textSubColor,
          builder: () => GoogleFonts.beVietnamPro(
            fontSize: 11,
            fontWeight: FontWeight.normal,
            color: textSubColor,
            textStyle: const TextStyle(fontFamilyFallback: fontFallback),
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // SEMANTIC TEXTSTYLE GETTERS DÀNH CHO CÁC THÀNH PHẦN GIAO DIỆN CỤ THỂ
  // ===========================================================================

  /// Tiêu đề màn hình, thẻ bài học, header
  static TextStyle title(
    EducationLevel level, {
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
  }) {
    if (level == EducationLevel.primary) {
      return _createStyle(
        familyName: 'Fredoka',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        builder: () => GoogleFonts.fredoka(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          textStyle: const TextStyle(fontFamilyFallback: fontFallback),
        ),
      );
    }
    return _createStyle(
      familyName: 'Plus Jakarta Sans',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      builder: () => GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        textStyle: const TextStyle(fontFamilyFallback: fontFallback),
      ),
    );
  }

  /// Nút bấm hành động
  static TextStyle button(
    EducationLevel level, {
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    if (level == EducationLevel.primary) {
      return _createStyle(
        familyName: 'Fredoka',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        builder: () => GoogleFonts.fredoka(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          textStyle: const TextStyle(fontFamilyFallback: fontFallback),
        ),
      );
    }
    return _createStyle(
      familyName: 'Plus Jakarta Sans',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      builder: () => GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        textStyle: const TextStyle(fontFamilyFallback: fontFallback),
      ),
    );
  }

  /// Điểm số, Rank, Huy hiệu nổi bật
  static TextStyle score(
    EducationLevel level, {
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
  }) {
    if (level == EducationLevel.primary) {
      return _createStyle(
        familyName: 'Fredoka',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        builder: () => GoogleFonts.fredoka(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          textStyle: const TextStyle(fontFamilyFallback: fontFallback),
        ),
      );
    }
    return _createStyle(
      familyName: 'Plus Jakarta Sans',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      builder: () => GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        textStyle: const TextStyle(fontFamilyFallback: fontFallback),
      ),
    );
  }

  /// Đề bài, câu hỏi bài tập / trắc nghiệm
  static TextStyle question(
    EducationLevel level, {
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    if (level == EducationLevel.primary) {
      final actualWeight = fontWeight == FontWeight.bold ? FontWeight.bold : FontWeight.w600;
      return _createStyle(
        familyName: 'Nunito',
        fontSize: fontSize,
        fontWeight: actualWeight,
        color: color,
        builder: () => GoogleFonts.nunito(
          fontSize: fontSize,
          fontWeight: actualWeight,
          color: color,
          textStyle: const TextStyle(fontFamilyFallback: fontFallback),
        ),
      );
    }
    return _createStyle(
      familyName: 'Be Vietnam Pro',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      builder: () => GoogleFonts.beVietnamPro(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        textStyle: const TextStyle(fontFamilyFallback: fontFallback),
      ),
    );
  }

  /// Đoạn văn, lời giải thích chi tiết, bài học
  static TextStyle body(
    EducationLevel level, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    FontStyle? fontStyle,
  }) {
    if (level == EducationLevel.primary) {
      return _createStyle(
        familyName: 'Nunito',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontStyle: fontStyle,
        builder: () => GoogleFonts.nunito(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          fontStyle: fontStyle,
          textStyle: const TextStyle(fontFamilyFallback: fontFallback),
        ),
      );
    }
    return _createStyle(
      familyName: 'Be Vietnam Pro',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      builder: () => GoogleFonts.beVietnamPro(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontStyle: fontStyle,
        textStyle: const TextStyle(fontFamilyFallback: fontFallback),
      ),
    );
  }

  /// Lời thoại thân thiện của trợ lý ảo / gợi ý bài học
  static TextStyle quote(
    EducationLevel level, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    if (level == EducationLevel.primary) {
      return _createStyle(
        familyName: 'Nunito',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        builder: () => GoogleFonts.nunito(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          textStyle: const TextStyle(fontFamilyFallback: fontFallback),
        ),
      );
    }
    return _createStyle(
      familyName: 'Quicksand',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      builder: () => GoogleFonts.quicksand(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        textStyle: const TextStyle(fontFamilyFallback: fontFallback),
      ),
    );
  }
}
