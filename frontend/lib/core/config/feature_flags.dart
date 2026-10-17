import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Quản lý tập trung các Feature Flags và Boolean Flags của ứng dụng
class FeatureFlags {
  FeatureFlags._();

  /// Boolean flag: Cho phép nạp dữ liệu mẫu (Mock data) khi demo trình chiếu
  /// Nếu false: Tuân thủ 100% dữ liệu thực từ API, hiển thị AppEmptyCard khi rỗng
  /// Nếu true: Bổ sung dữ liệu mẫu minh họa giúp buổi demo trực quan, đầy đủ tính năng
  static bool useDemoFallback = _initDemoFallback();

  static bool _initDemoFallback() {
    // 1. Ưu tiên cờ biên dịch chính thức --dart-define=DEMO_MODE=true
    const isDemo = bool.fromEnvironment('DEMO_MODE', defaultValue: false);
    if (isDemo) return true;

    // 2. Cấu hình cục bộ trong .env
    try {
      final envVal = dotenv.env['ENABLE_DEMO_DATA'];
      if (envVal != null) {
        return envVal.toLowerCase() == 'true' || envVal == '1';
      }
    } catch (_) {}

    return kDebugMode;
  }

  /// Khôi phục trạng thái cờ về mặc định
  static void reset() {
    useDemoFallback = _initDemoFallback();
  }

  /// Boolean flag: Tự động lưu nháp câu trả lời bài tập (Auto-Save Debounce)
  static const bool enableAutoSave = true;

  /// Boolean flag: Tính năng học liệu số (Digital Materials)
  static const bool enableMaterials = true;

  /// Boolean flag: Tính năng thời khóa biểu (Timetable)
  static const bool enableTimetable = true;
}
