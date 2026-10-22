import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class AppColors {
  // Light Mode Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF5F5F5);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF5F5F5F);
  static const Color lightTextTertiary = Color(0xFF9E9E9E);
  static const Color lightPrimary = Color(0xFF1A237E);
  static const Color lightSecondary = Color(0xFF800020);
  static const Color lightSilver = Color(0xFF9E9E9E);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightDivider = Color(0xFFF0F0F0);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF151515);
  static const Color darkSurfaceAlt = Color(0xFF1E1E1E);
  static const Color darkSurfaceElevated = Color(0xFF282828);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFA8A8A8);
  static const Color darkTextTertiary = Color(0xFF6B6B6B);
  static const Color darkPrimary = Color(0xFF5C6BC0);
  static const Color darkSecondary = Color(0xFFE04868);
  static const Color darkSilver = Color(0xFFC0C0C0);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkDivider = Color(0xFF1F1F1F);

  // Shared Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);

  // Splash Screen
  static const Color splashBackground = Color(0xFF0D1454);
  static const Color splashText = Color(0xFFC0C0C0);

  // Backward Compatibility (light mode defaults)
  static const Color primary = lightPrimary;
  static const Color secondary = lightSecondary;
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;

  // Theme-Aware Getters (use these when you have BuildContext)
  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color surfaceAltOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceAlt : lightSurfaceAlt;
  static Color surfaceElevatedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceElevated : lightSurface;
  static Color textPrimaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  static Color textTertiaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextTertiary : lightTextTertiary;
  static Color primaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  static Color secondaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;
  static Color silverOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSilver : lightSilver;
  static Color borderOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;
  static Color dividerOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkDivider : lightDivider;
}

class ApiConstants {
  /// Cờ xác định phiên bản biên dịch chạy chế độ Demo trình chiếu (tách biệt hoàn toàn bản thường)
  /// Ví dụ: flutter build web --dart-define=DEMO_MODE=true
  static const bool isDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);

  /// URL được truyền động qua biến môi trường khi build:
  /// ví dụ: flutter build web --dart-define=API_BASE_URL=https://api.truongdaiviet.edu.vn/api
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    // 1. Ưu tiên biến môi trường --dart-define=API_BASE_URL
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    // 2. Nếu có trong .env cục bộ (khi dev chạy local)
    try {
      final envVal = dotenv.env['API_BASE_URL'];
      if (envVal != null && envVal.isNotEmpty) {
        return envVal;
      }
    } catch (_) {}

    // 3. Nếu đang chạy với cờ DEMO_MODE thì không bắt buộc URL thật
    if (isDemoMode) {
      return '';
    }

    // 4. Môi trường Debug / Development nội bộ máy dev
    if (!kReleaseMode) {
      return 'http://localhost:8081/api';
    }

    // 5. FAIL-FAST TRÊN RELEASE PRODUCTION:
    // Tuyệt đối không trỏ về domain rác hay tên miền ảo. Ném ngoại lệ cấu hình rõ ràng!
    throw StateError(
      'LỖI CẤU HÌNH PRODUCTION: Bản Release bắt buộc phải được biên dịch với --dart-define=API_BASE_URL=https://... '
      'hoặc cờ --dart-define=DEMO_MODE=true đối với bản trình chiếu.',
    );
  }
}

class AppTextStyles {
  static const List<String> _fontFallback = [
    'Be Vietnam Pro',
    'Nunito',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  // Theme-aware (use these when you have context)
  static TextStyle heading1(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium?.copyWith(
          color: AppColors.textPrimaryOf(context),
        ) ??
        GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryOf(context),
          textStyle: const TextStyle(fontFamilyFallback: _fontFallback),
        );
  }

  static TextStyle heading2(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimaryOf(context),
        ) ??
        GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryOf(context),
          textStyle: const TextStyle(fontFamilyFallback: _fontFallback),
        );
  }

  static TextStyle body(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondaryOf(context),
        ) ??
        GoogleFonts.beVietnamPro(
          fontSize: 16,
          color: AppColors.textSecondaryOf(context),
          textStyle: const TextStyle(fontFamilyFallback: _fontFallback),
        );
  }

  static TextStyle button(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ) ??
        GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          textStyle: const TextStyle(fontFamilyFallback: _fontFallback),
        );
  }

  // Backward-compatible statics (light mode defaults)
  static TextStyle get heading1Static => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.lightTextPrimary,
    textStyle: const TextStyle(fontFamilyFallback: _fontFallback),
  );
  static TextStyle get heading2Static => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
    textStyle: const TextStyle(fontFamilyFallback: _fontFallback),
  );
  static TextStyle get bodyStatic => GoogleFonts.beVietnamPro(
    fontSize: 16,
    color: AppColors.lightTextSecondary,
    textStyle: const TextStyle(fontFamilyFallback: _fontFallback),
  );
  static TextStyle get buttonStatic => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    textStyle: const TextStyle(fontFamilyFallback: _fontFallback),
  );
}
