import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

class LessonRow extends StatelessWidget {
  final int lessonIndex;
  final String subject;
  final String time;
  final String teacher;
  final String room;
  final bool isCompact;
  final bool hasDivider;
  final VoidCallback? onTap;

  const LessonRow({
    super.key,
    required this.lessonIndex,
    required this.subject,
    required this.time,
    required this.teacher,
    required this.room,
    this.isCompact = false,
    this.hasDivider = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: isCompact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: hasDivider
            ? const Border(bottom: BorderSide(color: AppColors.border))
            : null,
      ),
      child: Row(
        children: [
          if (isCompact) ...[
            Container(
              width: 48,
              alignment: Alignment.centerLeft,
              child: Text(
                time.split('–')[0].trim(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSub,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                color: AppColors.surfaceAlt,
              ),
              child: Text(
                'Tiết $lessonIndex',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSub,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: isCompact ? 15 : 16,
                    fontWeight: isCompact ? FontWeight.w600 : FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                if (!isCompact) const SizedBox(height: 2),
                Text(
                  '$teacher · $room',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSub,
                  ),
                ),
              ],
            ),
          ),
          if (isCompact) ...[
            Text(
              'Tiết $lessonIndex',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ] else ...[
            Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSub,
              ),
            ),
          ],
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textSub),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
