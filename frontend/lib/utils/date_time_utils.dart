class DateTimeUtils {
  DateTimeUtils._();

  static const List<String> schoolDays = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
  ];

  static const List<String> dayNames = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ Nhật',
  ];

  /// Trả về chuỗi ngày tiếng Việt đầy đủ. Ví dụ: "Thứ Hai, 12/10/2026"
  static String formatVietnameseFullDate(DateTime date) {
    final dayOfWeek = dayNames[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$dayOfWeek, $day/$month/$year';
  }

  /// Tính toán nhãn tuần học. Ví dụ: "Tuần 12–16/10 (tuần này)"
  static String getWeekLabel(int weekOffset, {DateTime? anchorDate}) {
    final base = anchorDate ?? DateTime(2026, 10, 12);
    final monday = base.add(Duration(days: 7 * weekOffset));
    final friday = monday.add(const Duration(days: 4));

    final mondayDay = monday.day;
    final fridayDay = friday.day;
    final month = friday.month.toString().padLeft(2, '0');

    final suffix = weekOffset == 0 ? ' (tuần này)' : '';
    return 'Tuần $mondayDay–$fridayDay/$month$suffix';
  }

  /// Tách khoảng thời gian tiết học: "07:30–08:15" -> ["07:30", "08:15"]
  static List<String> parseLessonTimeRange(String timeRange) {
    if (timeRange.contains('–')) {
      return timeRange.split('–').map((e) => e.trim()).toList();
    }
    if (timeRange.contains('-')) {
      return timeRange.split('-').map((e) => e.trim()).toList();
    }
    return [timeRange, ''];
  }

  /// Kiểm tra xem một hạn nộp có bị quá hạn so với hiện tại không
  static bool isOverdue(String? dueDateStr, {DateTime? now}) {
    if (dueDateStr == null || dueDateStr.isEmpty) return false;
    final current = now ?? DateTime.now();

    try {
      DateTime? due;
      if (dueDateStr.contains('/')) {
        final parts = dueDateStr.split('/');
        if (parts.length >= 3) {
          due = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
            23, 59, 59,
          );
        }
      } else {
        due = DateTime.tryParse(dueDateStr);
      }

      if (due != null) {
        return current.isAfter(due);
      }
    } catch (_) {}
    return false;
  }
}
