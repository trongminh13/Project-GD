import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/utils/format_utils.dart';

void main() {
  group('FormatUtils Tests', () {
    test('formatScore formats numbers correctly', () {
      expect(FormatUtils.formatScore(8), '8 đ');
      expect(FormatUtils.formatScore(8.0), '8 đ');
      expect(FormatUtils.formatScore(8.5), '8.5 đ');
      expect(FormatUtils.formatScore(null), '- đ');

      expect(FormatUtils.formatScore(8.5, maxScore: 10), '8.5 / 10 đ');
      expect(FormatUtils.formatScore(8, maxScore: 10.0), '8 / 10 đ');
    });

    test('formatClassName formats correctly', () {
      expect(FormatUtils.formatClassName(grade: '3', section: 'A'), 'Lớp 3A');
      expect(FormatUtils.formatClassName(grade: '5', section: ''), 'Lớp 5');
      expect(FormatUtils.formatClassName(fallback: 'Lớp 4B'), 'Lớp 4B');
      expect(FormatUtils.formatClassName(), 'Lớp 3A');
    });

    test('formatCurrency formats Vietnamese dong correctly', () {
      expect(FormatUtils.formatCurrency(1000), '1.000 đ');
      expect(FormatUtils.formatCurrency(50000), '50.000 đ');
      expect(FormatUtils.formatCurrency(1250000), '1.250.000 đ');
      expect(FormatUtils.formatCurrency(0), '0 đ');
    });
  });
}
