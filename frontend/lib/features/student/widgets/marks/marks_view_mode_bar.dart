import 'package:flutter/material.dart';
import 'package:ashadeep/core/widgets/app_section_header.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

/// Thanh công cụ chuyển đổi chế độ xem Bảng điểm (Thẻ mở rộng / Sổ điểm điện tử)
class MarksViewModeBar extends StatelessWidget {
  final int subjectCount;
  final bool isTableView;
  final ValueChanged<bool> onToggleViewMode;

  const MarksViewModeBar({
    super.key,
    required this.subjectCount,
    required this.isTableView,
    required this.onToggleViewMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppSectionHeader(
          title: 'Kết quả chi tiết môn học ($subjectCount)',
        ),
        Row(
          children: [
            InkWell(
              onTap: () => onToggleViewMode(false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: !isTableView ? AppColors.primary : Colors.white,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Icon(
                  Icons.view_agenda_outlined,
                  size: 16,
                  color: !isTableView ? Colors.white : AppColors.textMain,
                ),
              ),
            ),
            InkWell(
              onTap: () => onToggleViewMode(true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isTableView ? AppColors.primary : Colors.white,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Icon(
                  Icons.table_chart_outlined,
                  size: 16,
                  color: isTableView ? Colors.white : AppColors.textMain,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
