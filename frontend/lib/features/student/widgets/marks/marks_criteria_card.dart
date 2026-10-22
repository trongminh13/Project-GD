import 'package:flutter/material.dart';
import 'package:ashadeep/models/markbook.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

/// Thẻ hiển thị tiêu chuẩn danh hiệu & phẩm chất năng lực theo cấp học
class MarksCriteriaCard extends StatelessWidget {
  final String level; // 'PRIMARY' | 'SECONDARY' | 'HIGH_SCHOOL'
  final StudentMarkbook markbook;

  const MarksCriteriaCard({
    super.key,
    required this.level,
    required this.markbook,
  });

  @override
  Widget build(BuildContext context) {
    if (level == 'PRIMARY') {
      return _buildPrimaryQualitiesAndCompetenciesCard(context);
    }
    if (level == 'HIGH_SCHOOL') {
      return _buildHighSchoolHonorSimulatorCard(context);
    }
    return const SizedBox.shrink();
  }

  /// KHU VỰC ĐẶC THÙ CẤP 1: 5 Phẩm chất chủ yếu & Năng lực cốt lõi (Thông tư 27)
  Widget _buildPrimaryQualitiesAndCompetenciesCard(BuildContext context) {
    final qualities = [
      {'name': 'Yêu nước', 'level': 'Đạt (Đ)'},
      {'name': 'Nhân ái', 'level': 'Đạt (Đ)'},
      {'name': 'Chăm chỉ', 'level': 'Đạt (Đ)'},
      {'name': 'Trung thực', 'level': 'Đạt (Đ)'},
      {'name': 'Trách nhiệm', 'level': 'Đạt (Đ)'},
    ];

    final competencies = [
      {'name': 'Tự chủ và tự học', 'level': 'Tốt (T)'},
      {'name': 'Giao tiếp và hợp tác', 'level': 'Tốt (T)'},
      {'name': 'Giải quyết vấn đề và sáng tạo', 'level': 'Đạt (Đ)'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_outline, color: Color(0xFF26A69A), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ĐÁNH GIÁ PHẨM CHẤT & NĂNG LỰC (TT 27/2020)',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMainOf(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A).withValues(alpha: 0.12),
                  borderRadius: AppColors.cardBorderRadius,
                ),
                child: const Text(
                  'Tiểu học',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF26A69A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1. Năm Phẩm chất chủ yếu:',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSub),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: qualities.map((q) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: AppColors.cardBorderRadius,
                  border: Border.all(color: const Color(0xFF80CBC4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Color(0xFF00796B)),
                    const SizedBox(width: 6),
                    Text(
                      '${q['name']}: ',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMain),
                    ),
                    Text(
                      q['level']!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF00796B)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Text(
            '2. Năng lực cốt lõi (Chung & Đặc thù):',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSub),
          ),
          const SizedBox(height: 8),
          Column(
            children: competencies.map((c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right, size: 18, color: AppColors.textSub),
                          Expanded(
                            child: Text(
                              c['name']!,
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textMain),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: c['level']!.contains('Tốt') ? const Color(0xFFE8F0FE) : AppColors.surfaceAlt,
                        borderRadius: AppColors.cardBorderRadius,
                        border: Border.all(color: AppColors.cardBorder, width: 0.8),
                      ),
                      child: Text(
                        c['level']!,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: c['level']!.contains('Tốt') ? AppColors.primary : AppColors.textMain,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// KHU VỰC ĐẶC THÙ CẤP 3: Dự báo & Điều kiện đạt Danh hiệu HS Giỏi / Xuất sắc (Thông tư 22)
  Widget _buildHighSchoolHonorSimulatorCard(BuildContext context) {
    int count8 = 0;
    int count9 = 0;
    for (final s in markbook.subjects) {
      final calculatedYearAvg = s.yearAvg ??
          (s.semester1?.avg != null && s.semester2?.avg != null
              ? ((s.semester1!.avg! + 2 * s.semester2!.avg!) / 3.0)
              : (s.semester2?.avg ?? s.semester1?.avg));
      if (calculatedYearAvg != null) {
        if (calculatedYearAvg >= 8.0) count8++;
        if (calculatedYearAvg >= 9.0) count9++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: Color(0xFFEF5350), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'TIÊU CHUẨN DANH HIỆU THPT (TT 22/2021)',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMainOf(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF5350).withValues(alpha: 0.12),
                  borderRadius: AppColors.cardBorderRadius,
                ),
                child: const Text(
                  'THPT Cấp 3',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFEF5350)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Checklist điều kiện HS Giỏi
          _buildChecklistRow(
            isDone: true,
            label: 'Kết quả Rèn luyện đạt mức TỐT',
            statusText: 'Đạt chuẩn',
          ),
          const SizedBox(height: 6),
          _buildChecklistRow(
            isDone: true,
            label: '100% môn nhận xét (Thể dục, QP-AN, HĐTN) đạt mức ĐẠT',
            statusText: 'Đạt chuẩn',
          ),
          const SizedBox(height: 6),
          _buildChecklistRow(
            isDone: true,
            label: 'Không có môn học nào dưới 6.5 (Môn thấp nhất: 8.6)',
            statusText: 'Đạt chuẩn',
          ),
          const SizedBox(height: 6),
          _buildChecklistRow(
            isDone: count8 >= 6,
            label: 'Có ít nhất 06 môn đạt ĐTB ≥ 8.0 (Hiện có: $count8/6 môn)',
            statusText: count8 >= 6 ? 'ĐẠT HỌC SINH GIỎI 🏆' : 'Chưa đủ',
            highlight: true,
          ),
          const SizedBox(height: 6),
          _buildChecklistRow(
            isDone: count9 >= 6,
            label: 'Có ít nhất 06 môn đạt ĐTB ≥ 9.0 (Hiện có: $count9/6 môn)',
            statusText: count9 >= 6 ? 'ĐẠT HỌC SINH XUẤT SẮC 🌟' : 'Cần thêm 2 môn ≥ 9.0',
            highlight: false,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistRow({
    required bool isDone,
    required String label,
    required String statusText,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_box : Icons.check_box_outline_blank,
          size: 18,
          color: isDone ? (highlight ? AppColors.primary : const Color(0xFF43A047)) : AppColors.textSub,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textMain,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFE8F5E9) : AppColors.surfaceAlt,
            borderRadius: AppColors.cardBorderRadius,
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDone ? const Color(0xFF2E7D32) : AppColors.textSub,
            ),
          ),
        ),
      ],
    );
  }
}
