import 'package:flutter/material.dart';
import 'package:ashadeep/models/markbook.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/enums/education_level.dart';
import 'package:ashadeep/core/theme/app_typography.dart';

/// Widget bảng điểm học bạ theo chuẩn Bộ GD&ĐT Việt Nam.
/// Hỗ trợ cả 3 cấp: Tiểu học, THCS, THPT.
/// - Cấp 1 lớp 1–3: hiển thị nhận xét thay điểm số.
/// - Cấp 1 lớp 4–5, THCS, THPT: bảng điểm số TX/GK/CK/DTB.
class MarkbookTableWidget extends StatelessWidget {
  final StudentMarkbook markbook;

  const MarkbookTableWidget({super.key, required this.markbook});

  @override
  Widget build(BuildContext context) {
    final level = EducationLevelHelper.fromString(markbook.educationLevel) ??
        EducationLevel.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF313244) : const Color(0xFFE0E0E0);
    final headerBg =
        isDark ? const Color(0xFF181825) : const Color(0xFFF5F5F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, level),
        const SizedBox(height: 16),
        if (markbook.isNarrativeOnly)
          _buildNarrativeTable(context, borderColor, bgColor, headerBg, level)
        else
          _buildScoreTable(context, borderColor, bgColor, headerBg, level),
        const SizedBox(height: 20),
        _buildSummaryRow(context, level),
      ],
    );
  }

  /// Header: tên học sinh, lớp, trường, năm học.
  Widget _buildHeader(BuildContext context, EducationLevel level) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryOf(context).withValues(alpha: 0.08),
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(
          color: AppColors.primaryOf(context).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  markbook.studentName,
                  style: AppTypography.title(
                    level,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOf(context),
                  ),
                ),
              ),
              _buildLevelBadge(context, level),
            ],
          ),
          const SizedBox(height: 6),
          _infoRow(context, level, Icons.class_outlined,
              'Lớp: ${markbook.className ?? "—"}'),
          _infoRow(context, level, Icons.school_outlined,
              markbook.schoolName ?? ''),
          _infoRow(context, level, Icons.calendar_today_outlined,
              'Năm học: ${markbook.academicYear ?? "—"}'),
        ],
      ),
    );
  }

  Widget _infoRow(
      BuildContext context, EducationLevel level, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondaryOf(context)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body(
                level,
                fontSize: 13,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(BuildContext context, EducationLevel level) {
    final label = markbook.educationLevelDisplayName;
    final color = _levelColor(markbook.educationLevel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTypography.button(
          level,
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'PRIMARY':
        return const Color(0xFF26A69A);
      case 'SECONDARY':
        return const Color(0xFF5C6BC0);
      case 'HIGH_SCHOOL':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }

  /// Bảng điểm chuẩn TX/GK/CK (Cấp 1 lớp 4-5, THCS, THPT).
  Widget _buildScoreTable(BuildContext context, Color borderColor,
      Color bgColor, Color headerBg, EducationLevel level) {
    return ClipRRect(
      borderRadius: AppColors.cardBorderRadius,
      child: Table(
        border: TableBorder.all(color: borderColor, width: 0.8),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(3),   // Môn học
          1: FlexColumnWidth(1.2), // TX HK1
          2: FlexColumnWidth(1),   // GK HK1
          3: FlexColumnWidth(1),   // CK HK1
          4: FlexColumnWidth(1.2), // DTB HK1
          5: FlexColumnWidth(1.2), // TX HK2
          6: FlexColumnWidth(1),   // GK HK2
          7: FlexColumnWidth(1),   // CK HK2
          8: FlexColumnWidth(1.2), // DTB HK2
          9: FlexColumnWidth(1.2), // DTB Năm
          10: FlexColumnWidth(1.8),// Xếp loại
        },
        children: [
          _headerRow(headerBg, context, level),
          ...markbook.subjects.map((s) => _subjectRow(s, bgColor, context, level)),
        ],
      ),
    );
  }

  TableRow _headerRow(Color headerBg, BuildContext context, EducationLevel level) {
    final style = AppTypography.title(
      level,
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: AppColors.textSecondaryOf(context),
    );
    return TableRow(
      decoration: BoxDecoration(color: headerBg),
      children: [
        _cell('Môn học', style),
        _cell('TX\nHK1', style, center: true),
        _cell('GK\nHK1', style, center: true),
        _cell('CK\nHK1', style, center: true),
        _cell('DTB\nHK1', style, center: true),
        _cell('TX\nHK2', style, center: true),
        _cell('GK\nHK2', style, center: true),
        _cell('CK\nHK2', style, center: true),
        _cell('DTB\nHK2', style, center: true),
        _cell('DTB\nNăm', style, center: true),
        _cell('Xếp\nloại', style, center: true),
      ],
    );
  }

  TableRow _subjectRow(
      SubjectMarkbook s, Color bgColor, BuildContext context, EducationLevel level) {
    final baseStyle = AppTypography.body(level, fontSize: 11, color: _textColor(context));
    final scoreStyle = AppTypography.score(
      level,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: _textColor(context),
    );
    final avgStyle = AppTypography.score(
      level,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryOf(context),
    );

    // Hiển thị danh sách TX: ví dụ "8.0, 9.0, 7.5, 8.5"
    String txHk1 = _formatTxList(s.semester1?.txScores);
    String txHk2 = _formatTxList(s.semester2?.txScores);

    return TableRow(
      decoration: BoxDecoration(color: bgColor),
      children: [
        _cell(s.subjectName, baseStyle.copyWith(fontWeight: FontWeight.w600)),
        _cell(txHk1, scoreStyle, center: true),
        _cell(_fmt(s.semester1?.gkScore), scoreStyle, center: true),
        _cell(_fmt(s.semester1?.ckScore), scoreStyle, center: true),
        _cell(_fmt(s.semester1?.avg), avgStyle, center: true),
        _cell(txHk2, scoreStyle, center: true),
        _cell(_fmt(s.semester2?.gkScore), scoreStyle, center: true),
        _cell(_fmt(s.semester2?.ckScore), scoreStyle, center: true),
        _cell(_fmt(s.semester2?.avg), avgStyle, center: true),
        _cell(_fmt(s.yearAvg), avgStyle, center: true),
        _classCell(s.academicClassification, context, level),
      ],
    );
  }

  /// Bảng nhận xét Tiểu học lớp 1–3.
  Widget _buildNarrativeTable(BuildContext context, Color borderColor,
      Color bgColor, Color headerBg, EducationLevel level) {
    final headerStyle = AppTypography.title(
      level,
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: AppColors.textSecondaryOf(context),
    );
    return ClipRRect(
      borderRadius: AppColors.cardBorderRadius,
      child: Table(
        border: TableBorder.all(color: borderColor, width: 0.8),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(3),
          3: FlexColumnWidth(2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: headerBg),
            children: [
              _cell('Môn học', headerStyle),
              _cell('Nhận xét HK1', headerStyle, center: true),
              _cell('Nhận xét HK2', headerStyle, center: true),
              _cell('Kết quả', headerStyle, center: true),
            ],
          ),
          ...markbook.subjects.map((s) {
            final hk1Comments = s.semester1?.comments?.join(', ') ?? '—';
            final hk2Comments = s.semester2?.comments?.join(', ') ?? '—';
            final bodyStyle = AppTypography.body(level, fontSize: 12, color: _textColor(context));
            return TableRow(
              decoration: BoxDecoration(color: bgColor),
              children: [
                _cell(s.subjectName, bodyStyle),
                _cell(hk1Comments, bodyStyle, center: true),
                _cell(hk2Comments, bodyStyle, center: true),
                _classCell(s.academicClassification, context, level),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Row tóm tắt cuối trang.
  Widget _buildSummaryRow(BuildContext context, EducationLevel level) {
    return Column(
      children: [
        if (markbook.honorTitle != null && markbook.honorTitle!.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
              ),
              borderRadius: AppColors.cardBorderRadius,
              border: Border.all(color: const Color(0xFFFFB300)),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium, color: Color(0xFFE65100), size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'Danh hiệu khen thưởng: ',
                      style: AppTypography.body(level, color: const Color(0xFF5D4037), fontSize: 13),
                      children: [
                        TextSpan(
                          text: markbook.honorTitle,
                          style: AppTypography.title(
                            level,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE65100),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Row(
          children: [
            _summaryChip(
              context,
              level,
              icon: Icons.bar_chart_rounded,
              label: 'ĐTB chung',
              value: _fmt(markbook.overallAvg),
              color: AppColors.primaryOf(context),
            ),
            const SizedBox(width: 12),
            _summaryChip(
              context,
              level,
              icon: Icons.emoji_events_rounded,
              label: 'Học lực',
              value: markbook.overallClassification ?? '—',
              color: _classificationColor(markbook.overallClassification),
            ),
            const SizedBox(width: 12),
            _summaryChip(
              context,
              level,
              icon: Icons.favorite_border_rounded,
              label: 'Hạnh kiểm',
              value: markbook.conduct ?? '(GV nhập)',
              color: Colors.teal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryChip(BuildContext context, EducationLevel level,
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppColors.cardBorderRadius,
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: AppTypography.body(
                  level,
                  fontSize: 10,
                  color: AppColors.textSecondaryOf(context),
                )),
            const SizedBox(height: 2),
            Text(value,
                style: AppTypography.score(
                  level,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _cell(String text, TextStyle style, {bool center = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        text,
        style: style,
        textAlign: center ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  Widget _classCell(
      String? classification, BuildContext context, EducationLevel level) {
    final color = _classificationColor(classification);
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppColors.cardBorderRadius,
          ),
          child: Text(
            classification ?? '—',
            style: AppTypography.button(
              level,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Color _classificationColor(String? c) {
    if (c == null) return Colors.grey;
    switch (c) {
      case 'Xuất sắc':
        return const Color(0xFF7C4DFF);
      case 'Tốt':
        return const Color(0xFF2E7D32);
      case 'Giỏi':
      case 'Hoàn thành tốt':
        return const Color(0xFF43A047);
      case 'Khá':
      case 'Hoàn thành':
        return const Color(0xFF1E88E5);
      case 'Đạt':
      case 'Trung bình':
        return const Color(0xFFFB8C00);
      case 'Chưa đạt':
      case 'Yếu':
      case 'Chưa hoàn thành':
        return const Color(0xFFE53935);
      case 'Kém':
        return const Color(0xFFB71C1C);
      default:
        return Colors.grey;
    }
  }

  Color _textColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
  }

  String _fmt(double? v) => v != null ? v.toStringAsFixed(1) : '—';

  String _formatTxList(List<double?>? txScores) {
    if (txScores == null || txScores.isEmpty) return '—';
    return txScores.map((e) => e != null ? e.toStringAsFixed(1) : '—').join('\n');
  }
}
