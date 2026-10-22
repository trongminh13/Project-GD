import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ashadeep/core/enums/education_level.dart';

/// Các chế độ màu chữ giao diện ứng dụng
enum AppTextColorMode {
  defaultBlack, // Mặc định: Đen than lịch lãm (#202124)
  green, // Xanh lá: Tươi mát, tràn đầy năng lượng (#1B5E20)
  emerald, // Xanh lục: Ngọc bích sang trọng, tập trung (#004D40)
  pink, // Hồng: Trẻ trung, ấm áp, cá tính (#AD1457)
}

/// Mô tả thông tin các hình nền học đường trong thư mục images/
class AppBackgroundItem {
  final String key;
  final String assetPath;
  final String nameVi;
  final String descriptionVi;

  const AppBackgroundItem({
    required this.key,
    required this.assetPath,
    required this.nameVi,
    required this.descriptionVi,
  });
}

class ThemeManager extends ChangeNotifier {
  static const _keyThemeMode = 'theme_mode';
  static const _keyTextColorMode = 'app_text_color_mode';
  static const _keyBgImagePath = 'app_bg_image_path';
  static const _keyEducationLevel = 'app_education_level';

  /// Danh sách 8 hình nền học đường có sẵn trong thư mục images/
  static const List<AppBackgroundItem> availableBackgrounds = [
    AppBackgroundItem(
      key: 'school',
      assetPath: 'images/school.jpg',
      nameVi: 'Mặc Định',
      descriptionVi: 'Bút và Vàng',
    ),
    AppBackgroundItem(
      key: 'bg_classroom',
      assetPath: 'images/bg_classroom.jpg',
      nameVi: 'Lớp học',
      descriptionVi: 'Không gian lớp học hiện đại & bài giảng',
    ),
    AppBackgroundItem(
      key: 'bg_students',
      assetPath: 'images/bg_students.jpg',
      nameVi: 'Quốc tế Phụ Nữ',
      descriptionVi: 'Ngày Quốc tế Phụ nữ',
    ),
    AppBackgroundItem(
      key: 'bg_school_yard',
      assetPath: 'images/bg_school_yard.jpg',
      nameVi: 'Giõ tổ Hùng Vương',
      descriptionVi: 'Giõ tổ Hùng Vương',
    ),
    AppBackgroundItem(
      key: 'bg_campus',
      assetPath: 'images/bg_campus.jpg',
      nameVi: 'Trung thu',
      descriptionVi: 'Trung thu',
    ),
    AppBackgroundItem(
      key: 'bg_library',
      assetPath: 'images/bg_library.jpg',
      nameVi: 'Ngày sinh Chủ tịch Hồ Chí Minh',
      descriptionVi: 'Ngày sinh Chủ tịch Hồ Chí Minh',
    ),
    AppBackgroundItem(
      key: 'Giải Phóng miền Nam',
      assetPath: 'images/bg_hallway.jpg',
      nameVi: 'Giải Phóng miền Nam',
      descriptionVi: 'Ngày giải phóng miền Nam',
    ),
    AppBackgroundItem(
      key: 'bg_study_desk',
      assetPath: 'images/bg_study_desk.jpg',
      nameVi: 'Halloween',
      descriptionVi: 'Halloween',
    ),
  ];

  ThemeMode _mode = ThemeMode.light;
  AppTextColorMode _textColorMode = AppTextColorMode.defaultBlack;
  String _bgImagePath = 'images/school.jpg';
  EducationLevel _educationLevel = EducationLevel.highSchool;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;
  AppTextColorMode get textColorMode => _textColorMode;
  String get bgImagePath => _bgImagePath;
  EducationLevel get educationLevel => _educationLevel;

  /// Màu chữ chính thích ứng theo tùy chọn của người dùng (tối ưu tương phản WCAG AAA trên nền trắng)
  Color get textMain {
    switch (_textColorMode) {
      case AppTextColorMode.green:
        return const Color(0xFF1B5E20); // Xanh lá cây tự nhiên đậm
      case AppTextColorMode.emerald:
        return const Color(0xFF004D40); // Xanh lục ngọc bích đậm
      case AppTextColorMode.pink:
        return const Color(0xFFAD1457); // Hồng đậm cá tính
      case AppTextColorMode.defaultBlack:
        return const Color(0xFF202124); // Đen than mặc định
    }
  }

  /// Màu chữ phụ tương ứng với tone màu chính đã chọn
  Color get textSub {
    switch (_textColorMode) {
      case AppTextColorMode.green:
        return const Color(0xFF2E7D32);
      case AppTextColorMode.emerald:
        return const Color(0xFF00695C);
      case AppTextColorMode.pink:
        return const Color(0xFFC2185B);
      case AppTextColorMode.defaultBlack:
        return const Color(0xFF5F6368);
    }
  }

  /// Tên tiếng Việt của chế độ màu chữ hiện tại
  String get textColorModeLabel {
    switch (_textColorMode) {
      case AppTextColorMode.green:
        return 'Xanh lá';
      case AppTextColorMode.emerald:
        return 'Xanh lục';
      case AppTextColorMode.pink:
        return 'Hồng';
      case AppTextColorMode.defaultBlack:
        return 'Mặc định (Đen)';
    }
  }

  /// Tên tiếng Việt của hình nền hiện tại
  String get currentBackgroundLabel {
    final found = availableBackgrounds.where(
      (b) => b.assetPath == _bgImagePath,
    );
    if (found.isNotEmpty) {
      return found.first.nameVi;
    }
    return 'Cổng trường';
  }

  ThemeManager() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Tải ThemeMode (Dark/Light)
      final savedTheme = prefs.getString(_keyThemeMode);
      if (savedTheme == 'dark') {
        _mode = ThemeMode.dark;
      } else {
        _mode = ThemeMode.light;
      }

      // 2. Tải chế độ màu chữ
      final savedColor = prefs.getString(_keyTextColorMode);
      if (savedColor != null) {
        switch (savedColor) {
          case 'green':
            _textColorMode = AppTextColorMode.green;
            break;
          case 'emerald':
            _textColorMode = AppTextColorMode.emerald;
            break;
          case 'pink':
            _textColorMode = AppTextColorMode.pink;
            break;
          default:
            _textColorMode = AppTextColorMode.defaultBlack;
        }
      }

      // 3. Tải hình nền học đường
      final savedBg = prefs.getString(_keyBgImagePath);
      if (savedBg != null && savedBg.isNotEmpty) {
        _bgImagePath = savedBg;
      }

      // 4. Tải cấp học đã lưu (Cấp 1, Cấp 2, Cấp 3)
      final savedLevel = prefs.getString(_keyEducationLevel);
      if (savedLevel != null) {
        final parsed = EducationLevelHelper.fromString(savedLevel);
        if (parsed != null) {
          _educationLevel = parsed;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('ThemeManager _loadTheme error: $e');
    }
  }

  /// Chuyển đổi Dark / Light mode
  Future<void> toggleTheme() async {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyThemeMode,
      _mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  /// Đặt chế độ màu chữ giao diện
  Future<void> setTextColorMode(AppTextColorMode mode) async {
    if (_textColorMode == mode) return;
    _textColorMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String keyStr = 'default';
    switch (mode) {
      case AppTextColorMode.green:
        keyStr = 'green';
        break;
      case AppTextColorMode.emerald:
        keyStr = 'emerald';
        break;
      case AppTextColorMode.pink:
        keyStr = 'pink';
        break;
      case AppTextColorMode.defaultBlack:
        keyStr = 'default';
        break;
    }
    await prefs.setString(_keyTextColorMode, keyStr);
  }

  /// Đặt hình nền ứng dụng theo assetPath
  Future<void> setBackgroundImage(String assetPath) async {
    if (_bgImagePath == assetPath) return;
    _bgImagePath = assetPath;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBgImagePath, assetPath);
  }

  /// Cập nhật Cấp học để thay đổi phông chữ và giao diện tương ứng (Cấp 1: Fredoka/Nunito, Cấp 2 & 3: Plus Jakarta Sans/Be Vietnam Pro)
  Future<void> setEducationLevel(
    EducationLevel level, {
    bool notify = true,
  }) async {
    if (_educationLevel == level) return;
    _educationLevel = level;
    if (notify) {
      notifyListeners();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEducationLevel, level.name);
  }
}
