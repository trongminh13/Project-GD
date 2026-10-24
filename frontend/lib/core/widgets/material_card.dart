import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';
import 'package:ashadeep/features/student/screens/student_book_detail_screen.dart';

class MaterialCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onOpenMaterial;

  const MaterialCard({super.key, required this.data, this.onOpenMaterial});

  Map<String, dynamic>? get _firstFile {
    final files = data['files'];
    if (files is! List || files.isEmpty || files.first is! Map) return null;
    return Map<String, dynamic>.from(files.first as Map);
  }

  String get _fileType {
    final rawType = (data['fileType'] ?? data['mimeType'] ?? '')
        .toString()
        .toUpperCase();
    final fileName = (_firstFile?['fileName'] ?? data['fileName'] ?? '')
        .toString()
        .toUpperCase();
    final value = rawType.isNotEmpty ? rawType : fileName;

    if (value.contains('AUDIO') ||
        value.endsWith('.MP3') ||
        value.endsWith('.M4A')) {
      return 'AUDIO';
    }
    if (value.contains('VIDEO') ||
        value.endsWith('.MP4') ||
        value.endsWith('.MOV')) {
      return 'VIDEO';
    }
    if (value.isEmpty || value.contains('PDF') || value.endsWith('.PDF')) {
      return 'PDF';
    }
    if (value.contains('WORD') ||
        value.endsWith('.DOC') ||
        value.endsWith('.DOCX')) {
      return 'DOC';
    }
    if (value.contains('EXCEL') ||
        value.endsWith('.XLS') ||
        value.endsWith('.XLSX')) {
      return 'XLS';
    }
    if (value.contains('POWERPOINT') ||
        value.endsWith('.PPT') ||
        value.endsWith('.PPTX')) {
      return 'PPT';
    }
    final extension = fileName.contains('.') ? fileName.split('.').last : '';
    return extension.isEmpty ? 'FILE' : extension;
  }

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] ?? 'Sách học').toString().trim();
    final description = (data['description'] ?? '').toString().trim();
    final subject = (data['subjectName'] ?? 'Chung').toString().trim();
    final teacher = (data['teacherName'] ?? '').toString().trim();
    final fileSize = (data['fileSize'] ?? '').toString().trim();
    final pageCount =
        (data['pageCount'] ?? _firstFile?['pageCount'])?.toString().trim() ??
        '';
    final metadata = <String>[
      if (subject.isNotEmpty) subject,
      if (teacher.isNotEmpty) teacher,
      if (pageCount.isNotEmpty) '$pageCount trang',
      if (fileSize.isNotEmpty) fileSize,
    ].join(' · ');

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
      borderRadius: AppColors.cardBorderRadius,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder, width: 1),
          borderRadius: AppColors.cardBorderRadius,
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Center(
                child: Icon(
                  _materialIcon(_fileType),
                  size: 38,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.3,
                        color: AppColors.textSub,
                      ),
                    ),
                  ],
                  if (metadata.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      metadata,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSub,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.textSub),
          ],
        ),
      ),
    );
  }
}

IconData _materialIcon(String fileType) => switch (fileType) {
  'AUDIO' => Icons.graphic_eq_rounded,
  'VIDEO' => Icons.play_circle_outline_rounded,
  'DOC' => Icons.description_outlined,
  'XLS' => Icons.table_chart_outlined,
  'PPT' => Icons.slideshow_outlined,
  _ => Icons.menu_book_rounded,
};
