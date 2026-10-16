import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

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
    final title = data['title'] ?? 'Tài liệu học tập';
    final subject = data['subjectName'] ?? 'Chung';
    final teacher = data['teacherName'] ?? 'Giáo viên';
    final date = data['createdAt'] != null ? data['createdAt'].toString().split('T')[0] : '12/10/2026';
    final fileType = (data['fileType'] ?? 'PDF').toString().toUpperCase();

    return InkWell(
      onTap: () {
        if (onOpenMaterial != null) {
          onOpenMaterial!();
        } else {
          _showDefaultDetailDialog(context, title, subject, teacher, fileType, date);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          color: AppColors.cardBg,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
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
                    '$subject · $teacher · $date',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSub),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDefaultDetailDialog(
    BuildContext context,
    String title,
    String subject,
    String teacher,
    String fileType,
    String date,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Row(
          children: [
            const Icon(Icons.menu_book, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Môn học: $subject', style: const TextStyle(fontSize: 14, color: AppColors.textMain)),
            const SizedBox(height: 6),
            Text('Giáo viên: $teacher', style: const TextStyle(fontSize: 14, color: AppColors.textMain)),
            const SizedBox(height: 6),
            Text('Định dạng: $fileType', style: const TextStyle(fontSize: 14, color: AppColors.textMain)),
            const SizedBox(height: 6),
            Text('Ngày đăng: $date', style: const TextStyle(fontSize: 14, color: AppColors.textSub)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              color: AppColors.surfaceAlt,
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: AppColors.textSub),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Học liệu số an toàn, phân phối cho học sinh trong lớp.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSub),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: AppColors.textSub)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đang mở tài liệu: $title'),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Xem học liệu'),
          ),
        ],
      ),
    );
  }
}
