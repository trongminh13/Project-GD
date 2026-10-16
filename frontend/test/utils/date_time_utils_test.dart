import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils Tests', () {
    test('formatVietnameseFullDate formats correctly', () {
      final date = DateTime(2026, 10, 12); // Thứ Hai
      final formatted = DateTimeUtils.formatVietnameseFullDate(date);
      expect(formatted, 'Thứ Hai, 12/10/2026');

      final sunday = DateTime(2026, 10, 18); // Chủ Nhật
      expect(DateTimeUtils.formatVietnameseFullDate(sunday), 'Chủ Nhật, 18/10/2026');
    });

    test('getWeekLabel returns correct week range', () {
      final anchor = DateTime(2026, 10, 12);
      final currentWeek = DateTimeUtils.getWeekLabel(0, anchorDate: anchor);
      expect(currentWeek, 'Tuần 12–16/10 (tuần này)');

      final nextWeek = DateTimeUtils.getWeekLabel(1, anchorDate: anchor);
      expect(nextWeek, 'Tuần 19–23/10');

      final prevWeek = DateTimeUtils.getWeekLabel(-1, anchorDate: anchor);
      expect(prevWeek, 'Tuần 5–9/10');
    });

    test('parseLessonTimeRange parses dash ranges properly', () {
      final range1 = DateTimeUtils.parseLessonTimeRange('07:30–08:15');
      expect(range1, ['07:30', '08:15']);

      final range2 = DateTimeUtils.parseLessonTimeRange('08:20-09:05');
      expect(range2, ['08:20', '09:05']);

      final rangeSingle = DateTimeUtils.parseLessonTimeRange('07:30');
      expect(rangeSingle, ['07:30', '']);
    });

    test('isOverdue detects past due dates correctly', () {
      final now = DateTime(2026, 10, 16, 12, 0, 0);

      // Past date dd/MM/yyyy
      expect(DateTimeUtils.isOverdue('14/10/2026', now: now), isTrue);

      // Today date
      expect(DateTimeUtils.isOverdue('16/10/2026', now: now), isFalse);

      // Future date
      expect(DateTimeUtils.isOverdue('20/10/2026', now: now), isFalse);

      // Null or empty
      expect(DateTimeUtils.isOverdue(null, now: now), isFalse);
      expect(DateTimeUtils.isOverdue('', now: now), isFalse);
    });
  });
}
