import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';
import 'package:ashadeep/core/theme/primary_palette.dart';

class LessonRow extends StatelessWidget {
  final int lessonIndex;
  final String subject;
  final String time;
  final String teacher;
  final String room;
  final bool isCompact;
  final bool hasDivider;
  final VoidCallback? onTap;
  final bool isPrimary;
  final int paletteIndex;

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
    this.isPrimary = false,
    this.paletteIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final style = PrimaryPalette.getStyle(paletteIndex != 0 ? paletteIndex : (lessonIndex - 1));

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: isCompact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: isPrimary ? (isCompact ? Colors.white : style.bgColor.withValues(alpha: 0.35)) : Colors.white,
        border: hasDivider
            ? Border(
                bottom: BorderSide(
                  color: isPrimary ? style.borderColor.withValues(alpha: 0.35) : AppColors.border,
                ),
              )
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
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? style.textColor.withValues(alpha: 0.85) : AppColors.textSub,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: isPrimary ? style.borderColor : AppColors.border),
                color: isPrimary ? style.bgColor : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(isPrimary ? 6 : 0),
              ),
              child: Text(
                'Tiết $lessonIndex',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? style.textColor : AppColors.textSub,
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
                    fontWeight: isCompact ? FontWeight.w700 : FontWeight.bold,
                    color: isPrimary ? style.textColor : AppColors.textMain,
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
            if (isPrimary)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: style.bgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: style.borderColor, width: 1.0),
                ),
                child: Text(
                  'Tiết $lessonIndex',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: style.textColor,
                  ),
                ),
              )
            else
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
            Icon(
              Icons.chevron_right,
              size: 18,
              color: isPrimary ? style.accentColor : AppColors.textSub,
            ),
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
