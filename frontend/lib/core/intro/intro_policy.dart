import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ashadeep/utils/constants.dart';

/// Quyết định có hiện màn intro hay không và ghi nhận lần đã hiện.
///
/// Tách thành interface để test `IntroGate` mà không cần `SharedPreferences`.
abstract class IntroPolicy {
  Future<bool> shouldShow();
  Future<void> markShown();
}

/// Quy tắc mặc định (lưu bằng `shared_preferences`):
///  - Người dùng tắt trong Cài đặt (`intro_enabled == false`): không hiện.
///  - Chế độ Demo/Dev (`kDebugMode` hoặc `ApiConstants.isDemoMode`): luôn hiện để nghiệm thu.
///  - Chưa từng hiện: hiện.
///  - Đã hiện nhưng cách đây >= [minGap] (mặc định 6 giờ): hiện.
///  - Đồng hồ máy bị chỉnh lùi (khoảng cách âm): coi như hiện.
///  - Đọc bộ nhớ lỗi: hiện một lần, không để app dừng.
///
/// Lưu ý: `IntroGate` chỉ được dựng khi app khởi động nguội, nên quy tắc
/// "không hiện khi quay lại từ nền" đã được bảo đảm bởi vị trí đặt widget.
class SharedPrefsIntroPolicy implements IntroPolicy {
  SharedPrefsIntroPolicy({
    this.minGap = const Duration(hours: 6),
    this.isDemoOrDev,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const String lastShownKey = 'intro_last_shown_at';
  static const String enabledKey = 'intro_enabled';

  final Duration minGap;
  final bool? isDemoOrDev;
  final DateTime Function() _now;

  bool get isDevMode => isDemoOrDev ?? (kDebugMode || ApiConstants.isDemoMode);

  @override
  Future<bool> shouldShow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(enabledKey) == false) return false;
      if (isDevMode) return true;
      final ms = prefs.getInt(lastShownKey);
      if (ms == null) return true;
      final gap = _now().difference(DateTime.fromMillisecondsSinceEpoch(ms));
      return gap.isNegative || gap >= minGap;
    } catch (_) {
      return true;
    }
  }

  /// Ghi mốc khi intro bắt đầu hiện (không phải khi kết thúc),
  /// để chạm bỏ qua vẫn được tính là đã xem.
  @override
  Future<void> markShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(lastShownKey, _now().millisecondsSinceEpoch);
    } catch (_) {
      // Không ghi được thì lần sau hiện lại, không ảnh hưởng chức năng.
    }
  }

  /// Dùng cho công tắc trong Cài đặt.
  Future<bool> isEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(enabledKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> setEnabled(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(enabledKey, value);
    } catch (_) {}
  }

  /// Dùng cho test hoặc reset trạng thái.
  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(lastShownKey);
      await prefs.remove(enabledKey);
    } catch (_) {}
  }
}
