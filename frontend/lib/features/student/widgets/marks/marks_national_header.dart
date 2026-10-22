import 'package:flutter/material.dart';
import 'package:ashadeep/models/markbook.dart';
import 'package:ashadeep/core/theme/app_colors.dart';
import 'marks_a4_print_preview.dart';

/// Header Trang bìa Sổ học bạ Quốc gia
class MarksNationalHeader extends StatelessWidget {
  final StudentMarkbook markbook;
  final String level;
  final int selectedSemester;

  const MarksNationalHeader({
    super.key,
    required this.markbook,
    required this.level,
    required this.selectedSemester,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor = const Color(0xFF26A69A); // Teal Cấp 1
    if (level == 'SECONDARY') badgeColor = const Color(0xFF5C6BC0); // Indigo Cấp 2
    if (level == 'HIGH_SCHOOL') badgeColor = const Color(0xFFEF5350); // Crimson Cấp 3

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: AppColors.cardBorderRadius,
                ),
                child: const Icon(Icons.school, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (markbook.schoolName ?? 'Trường THPT Chu Văn An').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'HỌC BẠ ĐIỆN TỬ • NĂM HỌC ${markbook.academicYear ?? "2026-2027"}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: AppColors.cardBorderRadius,
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  markbook.educationLevelDisplayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      markbook.studentName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMainOf(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mã HS: ${markbook.studentAdmissionNumber ?? "STU003"} • Lớp: ${markbook.className ?? "10A"}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => showReportCardPreviewModal(context, markbook, selectedSemester),
                icon: const Icon(Icons.print_outlined, size: 15, color: AppColors.primary),
                label: const Text(
                  'In Phiếu Điểm',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.cardBorder, width: 1.0),
                  shape: const RoundedRectangleBorder(borderRadius: AppColors.cardBorderRadius),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
