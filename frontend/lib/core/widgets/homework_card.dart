import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';
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

  const HomeworkCard({
    super.key,
    required this.data,
    this.mode = HomeworkCardMode.viewOnly,
    this.onPrimaryAction,
    this.onCardTap,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        color: AppColors.cardBg,
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$subject · $dueDate',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildActionWidget(context, score),
        ],
      ),
    );
  }

  Widget _buildActionWidget(BuildContext context, dynamic score) {
    switch (mode) {
      case HomeworkCardMode.studentTake:
        if (_isSubmitted) {
          return InkWell(
            onTap: onCardTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.success),
                color: Colors.white,
              ),
              child: Text(
                score != null ? 'Đã nộp · ${FormatUtils.formatScore(score)}' : 'Đã nộp',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
          );
        } else {
          return ElevatedButton(
            onPressed: onPrimaryAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
