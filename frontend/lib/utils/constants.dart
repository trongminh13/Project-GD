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
  // URLs are now loaded dynamically based on the build environment:
  // - Release Mode (Play Store): Uses the secure production HTTPS domain
  // - Debug Mode (Local Dev): Uses the local IPv4 address from your `.env` file
  // ⚠️ IMPORTANT: Replace this URL with your actual backend domain before releasing to production!
  static const String _productionUrl =
      'https://api.yourdomain.com/api'; // TODO: Set this to your deployed backend URL

  static String get baseUrl {
    if (kReleaseMode) {
      return _productionUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:8081/api';
    }
    // Fallback to local .env configuration only during active development
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8081/api';
  }
}

class AppTextStyles {
  // Theme-aware (use these when you have context)
  static TextStyle heading1(BuildContext context) => GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryOf(context),
  );
  static TextStyle heading2(BuildContext context) => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryOf(context),
  );
  static TextStyle body(BuildContext context) => GoogleFonts.outfit(
    fontSize: 16,
    color: AppColors.textSecondaryOf(context),
  );
  static TextStyle button(BuildContext context) => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Backward-compatible statics (light mode defaults)
  static TextStyle get heading1Static => GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.lightTextPrimary,
  );
  static TextStyle get heading2Static => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
  );
  static TextStyle get bodyStatic => GoogleFonts.outfit(
    fontSize: 16,
    color: AppColors.lightTextSecondary,
  );
  static TextStyle get buttonStatic => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
