import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

import 'package:ashadeep/features/student/screens/student_book_detail_screen.dart';

class MaterialCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onOpenMaterial;

  const MaterialCard({
    super.key,
    required this.data,
    this.onOpenMaterial,
  });

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? 'Sách học';
    final subject = data['subjectName'] ?? 'Chung';
    final teacher = data['teacherName'] ?? 'Giáo viên';
    final fileType = (data['fileType'] ?? 'PDF').toString().toUpperCase();
    final fileSize = data['fileSize'] ?? '4.5 MB';

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
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
          borderRadius: AppColors.cardBorderRadius,
          color: AppColors.cardBg,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
                borderRadius: AppColors.cardBorderRadius,
                color: AppColors.surfaceAlt,
              ),
              child: Icon(
                fileType.contains('AUDIO') || fileType.contains('MP3')
                    ? Icons.audiotrack
                    : (fileType.contains('VIDEO') ? Icons.play_circle_outline : Icons.picture_as_pdf),
                color: AppColors.primary,
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$subject · $teacher · $fileSize',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSub),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.textSub),
          ],
        ),
      ),
    );
  }
}
