import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ashadeep/core/enums/education_level.dart';
import 'package:ashadeep/core/theme/app_typography.dart';
import 'package:ashadeep/core/theme/theme_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Vô hiệu hóa HTTP runtime fetching trong môi trường test
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppTypography Dynamic Font Tests by Education Level', () {
    test('TC-TYPO-01: Cấp 1 (Tiểu học) uses Fredoka for Title and Nunito for Body', () {
      final titleFont = AppTypography.getTitleFontFamily(EducationLevel.primary);
      final bodyFont = AppTypography.getBodyFontFamily(EducationLevel.primary);

      expect(titleFont.toLowerCase(), contains('fredoka'));
      expect(bodyFont.toLowerCase(), contains('nunito'));
    });

    test('TC-TYPO-02: Cấp 2 (THCS) uses Plus Jakarta Sans for Title and Be Vietnam Pro for Body', () {
      final titleFont = AppTypography.getTitleFontFamily(EducationLevel.secondary);
      final bodyFont = AppTypography.getBodyFontFamily(EducationLevel.secondary);

      expect(titleFont.toLowerCase().replaceAll(' ', ''), contains('plusjakartasans'));
      expect(bodyFont.toLowerCase().replaceAll(' ', ''), contains('bevietnampro'));
    });

    test('TC-TYPO-03: Cấp 3 (THPT) uses Plus Jakarta Sans for Title and Be Vietnam Pro for Body', () {
      final titleFont = AppTypography.getTitleFontFamily(EducationLevel.highSchool);
      final bodyFont = AppTypography.getBodyFontFamily(EducationLevel.highSchool);

      expect(titleFont.toLowerCase().replaceAll(' ', ''), contains('plusjakartasans'));
      expect(bodyFont.toLowerCase().replaceAll(' ', ''), contains('bevietnampro'));
    });

    test('TC-TYPO-04: buildTextTheme generates non-null TextTheme with fallback fonts', () {
      final primaryTheme = AppTypography.buildTextTheme(EducationLevel.primary);
      expect(primaryTheme.displayLarge, isNotNull);
      expect(primaryTheme.titleLarge, isNotNull);
      expect(primaryTheme.bodyMedium, isNotNull);
      expect(primaryTheme.labelLarge, isNotNull);

      final secondaryTheme = AppTypography.buildTextTheme(EducationLevel.secondary);
      expect(secondaryTheme.displayLarge, isNotNull);
      expect(secondaryTheme.titleLarge, isNotNull);
      expect(secondaryTheme.bodyMedium, isNotNull);
      expect(secondaryTheme.labelLarge, isNotNull);

      final highSchoolDarkTheme = AppTypography.buildTextTheme(EducationLevel.highSchool, isDark: true);
      expect(highSchoolDarkTheme.displayLarge, isNotNull);
      expect(highSchoolDarkTheme.bodyMedium?.color, isNotNull);
    });

    test('TC-TYPO-05: Semantic getters produce valid TextStyles with anti-glyph-error fallback', () {
      final qStylePrimary = AppTypography.question(EducationLevel.primary, fontSize: 16);
      expect(qStylePrimary.fontSize, equals(16));
      expect(qStylePrimary.fontFamily?.toLowerCase().replaceAll(' ', ''), contains('nunito'));

      final qStyleSecondary = AppTypography.question(EducationLevel.secondary, fontSize: 15);
      expect(qStyleSecondary.fontSize, equals(15));
      expect(qStyleSecondary.fontFamily?.toLowerCase().replaceAll(' ', ''), contains('bevietnampro'));

      final scoreStyle = AppTypography.score(EducationLevel.highSchool, fontSize: 26);
      expect(scoreStyle.fontSize, equals(26));
      expect(scoreStyle.fontWeight, equals(FontWeight.bold));
      expect(scoreStyle.fontFamily?.toLowerCase().replaceAll(' ', ''), contains('plusjakartasans'));

      final quoteStyle = AppTypography.quote(EducationLevel.secondary);
      expect(quoteStyle.fontFamily?.toLowerCase().replaceAll(' ', ''), contains('quicksand'));
    });
  });

  group('ThemeManager EducationLevel State Management Tests', () {
    test('TC-TYPO-06: ThemeManager defaults to highSchool and updates educationLevel with notification', () async {
      final themeManager = ThemeManager();
      expect(themeManager.educationLevel, equals(EducationLevel.highSchool));

      bool notified = false;
      themeManager.addListener(() {
        notified = true;
      });

      await themeManager.setEducationLevel(EducationLevel.primary);
      expect(themeManager.educationLevel, equals(EducationLevel.primary));
      expect(notified, isTrue);

      notified = false;
      await themeManager.setEducationLevel(EducationLevel.secondary);
      expect(themeManager.educationLevel, equals(EducationLevel.secondary));
      expect(notified, isTrue);
    });

    test('TC-TYPO-07: AppTypography.initialize() enforces Local Asset-First with runtime HTTP fetching disabled', () {
      AppTypography.initialize();
      expect(GoogleFonts.config.allowRuntimeFetching, isFalse);
      expect(AppTypography.fontFallback, contains('Be Vietnam Pro'));
      expect(AppTypography.fontFallback, contains('Nunito'));
      expect(AppTypography.fontFamilyFallback, equals(AppTypography.fontFallback));
    });
  });
}
