import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';
import 'package:ashadeep/core/theme/primary_palette.dart';
import 'package:ashadeep/utils/format_utils.dart';

enum HomeworkCardMode {
  studentTake,
  teacherGrade,
  parentView,
  viewOnly,
}

class HomeworkCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final HomeworkCardMode mode;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onCardTap;
  final bool isPrimary;
  final int paletteIndex;

  const HomeworkCard({
    super.key,
    required this.data,
    this.mode = HomeworkCardMode.viewOnly,
    this.onPrimaryAction,
    this.onCardTap,
    this.isPrimary = false,
    this.paletteIndex = 0,
  });

  bool get _isSubmitted {
    final status = (data['submissionStatus'] ?? data['status'] ?? '').toString().toLowerCase();
    return status == 'submitted' || status == 'graded';
  }

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? data['homeworkTitle'] ?? 'Bài tập';
    final subject = data['subjectName'] ?? data['subject'] ?? 'Môn học';
    final dueDate = data['dueDate'] != null ? 'Hạn: ${data['dueDate']}' : 'Hạn hôm nay';
    final score = data['finalScore'] ?? data['autoScore'] ?? data['score'];
    final style = PrimaryPalette.getStyle(paletteIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: isPrimary ? style.borderColor : AppColors.cardBorder,
          width: isPrimary ? 1.5 : AppColors.cardBorderWidth,
        ),
        borderRadius: BorderRadius.circular(isPrimary ? 14 : AppColors.cardRadius),
        color: isPrimary ? style.bgColor : AppColors.cardBg,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: style.borderColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onCardTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isPrimary ? style.textColor : AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$subject · $dueDate',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isPrimary ? FontWeight.w500 : FontWeight.normal,
                      color: isPrimary ? style.textColor.withValues(alpha: 0.8) : AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildActionWidget(context, score, style),
        ],
      ),
    );
  }

  Widget _buildActionWidget(BuildContext context, dynamic score, PrimaryBoxStyle style) {
    switch (mode) {
      case HomeworkCardMode.studentTake:
        if (_isSubmitted) {
          return InkWell(
            onTap: onCardTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: isPrimary ? const Color(0xFF10B981) : AppColors.success),
                borderRadius: BorderRadius.circular(isPrimary ? 10 : AppColors.cardRadius),
                color: isPrimary ? const Color(0xFFECFDF5) : Colors.white,
              ),
              child: Text(
                score != null ? 'Đã nộp · ${FormatUtils.formatScore(score)}' : 'Đã nộp',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? const Color(0xFF065F46) : AppColors.success,
                ),
              ),
            ),
          );
        } else {
          return ElevatedButton(
            onPressed: onPrimaryAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrimary ? style.accentColor : AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isPrimary ? 10 : AppColors.cardRadius),
              ),
            ),
            child: const Text('Làm bài', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          );
        }

      case HomeworkCardMode.teacherGrade:
        return ElevatedButton(
          onPressed: onPrimaryAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: const RoundedRectangleBorder(borderRadius: AppColors.cardBorderRadius),
          ),
          child: const Text('Chấm bài', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        );

      case HomeworkCardMode.parentView:
        return InkWell(
          onTap: onCardTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: _isSubmitted ? AppColors.success : AppColors.warning),
              borderRadius: AppColors.cardBorderRadius,
              color: Colors.white,
            ),
            child: Text(
              _isSubmitted
                  ? (score != null ? 'Điểm: ${FormatUtils.formatScore(score)}' : 'Đã nộp')
                  : 'Chưa nộp',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _isSubmitted ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        );

      case HomeworkCardMode.viewOnly:
        return const SizedBox.shrink();
    }
  }
}
