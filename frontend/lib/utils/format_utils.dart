class FormatUtils {
  FormatUtils._();

  /// Format điểm số: "9.5 / 10.0 đ" hoặc "8 đ"
  static String formatScore(dynamic score, {dynamic maxScore}) {
    if (score == null) return '- đ';
    final scoreStr = score is num
        ? (score % 1 == 0 ? score.toInt().toString() : score.toStringAsFixed(1))
        : score.toString();

    if (maxScore != null) {
      final maxStr = maxScore is num
          ? (maxScore % 1 == 0 ? maxScore.toInt().toString() : maxScore.toStringAsFixed(1))
          : maxScore.toString();
      return '$scoreStr / $maxStr đ';
    }
    return '$scoreStr đ';
  }

  /// Ghép tên lớp: "3" + "A" -> "Lớp 3A"
  static String formatClassName({String? grade, String? section, String? fallback}) {
    if (grade != null && grade.isNotEmpty) {
      final sec = section ?? '';
      return 'Lớp $grade$sec';
    }
    return fallback ?? 'Lớp 3A';
  }

  /// Format tiền Việt Nam: 1250000 -> "1.250.000 đ"
  static String formatCurrency(num amount) {
    final str = amount.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join()} đ';
  }
}
