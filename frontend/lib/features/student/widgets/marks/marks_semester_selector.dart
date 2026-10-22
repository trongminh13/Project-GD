import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

/// Bộ chọn Học kỳ (Học kỳ I, Học kỳ II, Cả năm)
class MarksSemesterSelector extends StatelessWidget {
  final int selectedSemester;
  final ValueChanged<int> onSelectSemester;

  const MarksSemesterSelector({
    super.key,
    required this.selectedSemester,
    required this.onSelectSemester,
  });

  @override
  Widget build(BuildContext context) {
    final semesters = [
      {'id': 1, 'label': 'Học kỳ I'},
      {'id': 2, 'label': 'Học kỳ II'},
      {'id': 3, 'label': 'Cả năm'},
    ];

    return Row(
      children: semesters.map((sem) {
        final id = sem['id'] as int;
        final isSelected = selectedSemester == id;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: id == 1 ? 0 : 4,
              right: id == 3 ? 0 : 4,
            ),
            child: InkWell(
              onTap: () => onSelectSemester(id),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: AppColors.cardBorderRadius,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.cardBorder,
                    width: AppColors.cardBorderWidth,
                  ),
                ),
                child: Center(
                  child: Text(
                    sem['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textMain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
