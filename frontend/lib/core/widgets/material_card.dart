import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';
import 'package:ashadeep/core/theme/primary_palette.dart';
import 'package:ashadeep/features/student/screens/student_book_detail_screen.dart';

class MaterialCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onOpenMaterial;
  final bool isPrimary;
  final int paletteIndex;

  const MaterialCard({
    super.key,
    required this.data,
    this.onOpenMaterial,
    this.isPrimary = false,
    this.paletteIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? 'Sách học';
    final subject = data['subjectName'] ?? 'Chung';
    final teacher = data['teacherName'] ?? 'Giáo viên';
    final fileType = (data['fileType'] ?? 'PDF').toString().toUpperCase();
    final fileSize = data['fileSize'] ?? '4.5 MB';
    final style = PrimaryPalette.getStyle(paletteIndex);

    return InkWell(
      onTap: () {
        if (onOpenMaterial != null) {
          onOpenMaterial!();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StudentBookDetailScreen(data: data),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(isPrimary ? 14 : AppColors.cardRadius),
      child: Container(
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
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isPrimary ? style.borderColor : AppColors.cardBorder,
                  width: isPrimary ? 1.0 : AppColors.cardBorderWidth,
                ),
                borderRadius: BorderRadius.circular(isPrimary ? 10 : AppColors.cardRadius),
                color: isPrimary ? Colors.white : AppColors.surfaceAlt,
              ),
              child: Icon(
                fileType.contains('AUDIO') || fileType.contains('MP3')
                    ? Icons.audiotrack
                    : (fileType.contains('VIDEO') ? Icons.play_circle_outline : Icons.picture_as_pdf),
                color: isPrimary ? style.textColor : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
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
                  const SizedBox(height: 2),
                  Text(
                    '$subject · $teacher · $fileSize',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isPrimary ? FontWeight.w500 : FontWeight.normal,
                      color: isPrimary ? style.textColor.withValues(alpha: 0.8) : AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isPrimary ? style.accentColor : AppColors.textSub,
            ),
          ],
        ),
      ),
    );
  }
}
