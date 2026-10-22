import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ashadeep/core/theme/theme_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeManager Customization Unit Tests', () {
    test('TC-THEME-01: Default state has black text and school.jpg background', () async {
      final manager = ThemeManager();
      // Allow async _loadTheme to execute
      await pumpEventQueue();

      expect(manager.textColorMode, equals(AppTextColorMode.defaultBlack));
      expect(manager.bgImagePath, equals('images/school.jpg'));
      expect(manager.textMain, equals(const Color(0xFF202124)));
      expect(manager.textColorModeLabel, equals('Mặc định (Đen)'));
      expect(manager.currentBackgroundLabel, equals('Mặc Định'));
    });

    test('TC-THEME-02: availableBackgrounds contains exactly 8 school images', () {
      expect(ThemeManager.availableBackgrounds.length, equals(8));
      final keys = ThemeManager.availableBackgrounds.map((b) => b.key).toList();
      expect(keys, containsAll([
        'school',
        'bg_classroom',
        'bg_students',
        'bg_school_yard',
        'bg_campus',
        'bg_library',
        'Giải Phóng miền Nam',
        'bg_study_desk',
      ]));

      // Verify every image starts with images/
      for (final item in ThemeManager.availableBackgrounds) {
        expect(item.assetPath.startsWith('images/'), isTrue);
        expect(item.nameVi.isNotEmpty, isTrue);
      }
    });

    test('TC-THEME-03: Switching textColorMode updates textMain, textSub and notifies listeners', () async {
      final manager = ThemeManager();
      await pumpEventQueue();

      int notifyCount = 0;
      manager.addListener(() => notifyCount++);

      // 1. Switch to Green (Xanh lá)
      await manager.setTextColorMode(AppTextColorMode.green);
      expect(manager.textColorMode, equals(AppTextColorMode.green));
      expect(manager.textMain, equals(const Color(0xFF1B5E20)));
      expect(manager.textSub, equals(const Color(0xFF2E7D32)));
      expect(manager.textColorModeLabel, equals('Xanh lá'));
      expect(notifyCount, equals(1));

      // 2. Switch to Emerald (Xanh lục)
      await manager.setTextColorMode(AppTextColorMode.emerald);
      expect(manager.textColorMode, equals(AppTextColorMode.emerald));
      expect(manager.textMain, equals(const Color(0xFF004D40)));
      expect(manager.textSub, equals(const Color(0xFF00695C)));
      expect(manager.textColorModeLabel, equals('Xanh lục'));
      expect(notifyCount, equals(2));

      // 3. Switch to Pink (Hồng)
      await manager.setTextColorMode(AppTextColorMode.pink);
      expect(manager.textColorMode, equals(AppTextColorMode.pink));
      expect(manager.textMain, equals(const Color(0xFFAD1457)));
      expect(manager.textSub, equals(const Color(0xFFC2185B)));
      expect(manager.textColorModeLabel, equals('Hồng'));
      expect(notifyCount, equals(3));

      // 4. Switch back to Default Black
      await manager.setTextColorMode(AppTextColorMode.defaultBlack);
      expect(manager.textColorMode, equals(AppTextColorMode.defaultBlack));
      expect(manager.textMain, equals(const Color(0xFF202124)));
      expect(manager.textColorModeLabel, equals('Mặc định (Đen)'));
      expect(notifyCount, equals(4));

      // Verify persistence in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_text_color_mode'), equals('default'));
    });

    test('TC-THEME-04: Changing background updates bgImagePath and saves to preferences', () async {
      final manager = ThemeManager();
      await pumpEventQueue();

      int notifyCount = 0;
      manager.addListener(() => notifyCount++);

      await manager.setBackgroundImage('images/bg_library.jpg');
      expect(manager.bgImagePath, equals('images/bg_library.jpg'));
      expect(manager.currentBackgroundLabel, equals('Ngày sinh Chủ tịch Hồ Chí Minh'));
      expect(notifyCount, equals(1));

      await manager.setBackgroundImage('images/bg_classroom.jpg');
      expect(manager.bgImagePath, equals('images/bg_classroom.jpg'));
      expect(manager.currentBackgroundLabel, equals('Lớp học'));
      expect(notifyCount, equals(2));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_bg_image_path'), equals('images/bg_classroom.jpg'));
    });

    test('TC-THEME-05: Restores theme preferences on initialization', () async {
      SharedPreferences.setMockInitialValues({
        'app_text_color_mode': 'pink',
        'app_bg_image_path': 'images/bg_campus.jpg',
      });

      final manager = ThemeManager();
      await pumpEventQueue();

      expect(manager.textColorMode, equals(AppTextColorMode.pink));
      expect(manager.textMain, equals(const Color(0xFFAD1457)));
      expect(manager.textColorModeLabel, equals('Hồng'));
      expect(manager.bgImagePath, equals('images/bg_campus.jpg'));
      expect(manager.currentBackgroundLabel, equals('Trung thu'));
    });
  });
}
