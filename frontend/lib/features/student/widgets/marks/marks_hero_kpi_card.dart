import 'package:flutter/material.dart';
import 'package:ashadeep/models/markbook.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

/// Thẻ Hero KPI hiển thị ĐTB, xếp loại danh hiệu và các chỉ số phụ của kỳ học
class MarksHeroKpiCard extends StatelessWidget {
  final double? avgScore;
  final String academicRank;
  final IconData rankIcon;
  final Color rankColor;
  final Color rankBg;
  final StudentMarkbook markbook;
  final String level;
  final int selectedSemester;
  final int perfectCount;

  const MarksHeroKpiCard({
    super.key,
    required this.avgScore,
    required this.academicRank,
    required this.rankIcon,
    required this.rankColor,
    required this.rankBg,
    required this.markbook,
    required this.level,
    required this.selectedSemester,
    this.perfectCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final semTitle = selectedSemester == 1
        ? 'HỌC KỲ I'
        : (selectedSemester == 2 ? 'HỌC KỲ II' : 'CẢ NĂM');

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.black, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ĐIỂM TRUNG BÌNH $semTitle',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.textSub,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              avgScore != null
                                  ? avgScore!.toStringAsFixed(1)
                                  : '—',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMainOf(context),
                                height: 1.0,
                              ),
                            ),
                            const Text(
                              ' / 10.0',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSub,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Rank Box với Icon emoji_events_rounded và viền đen
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    constraints: const BoxConstraints(minWidth: 84),
                    decoration: BoxDecoration(
                      color: rankBg,
                      borderRadius: AppColors.cardBorderRadius,
                      border: Border.all(color: Colors.black, width: 1.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(rankIcon, size: 28, color: rankColor),
                        const SizedBox(height: 4),
                        Text(
                          academicRank,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: rankColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Đường kẻ ngang màu đen ngăn cách
          Container(height: 1, color: Colors.black),
          // 3 Chỉ số phụ với đường nối phẳng liền mạch và viền dọc đen
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 6,
                    ),
                    child: _buildKpiMiniItem(
                      context,
                      label: 'Số môn đánh giá',
                      value: '${markbook.subjects.length}',
                    ),
                  ),
                ),
                Container(width: 1, color: Colors.black),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 6,
                    ),
                    child: _buildKpiMiniItem(
                      context,
                      label: level == 'PRIMARY'
                          ? 'Hoàn thành môn'
                          : 'Môn đạt Giỏi',
                      value: level == 'PRIMARY'
                          ? '100%'
                          : (perfectCount > 0
                                ? '$perfectCount môn 10'
                                : '8 môn ≥ 8.0'),
                    ),
                  ),
                ),
                Container(width: 1, color: Colors.black),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 6,
                    ),
                    child: _buildKpiMiniItem(
                      context,
                      label: 'Tiến độ học tập',
                      value: '100%',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiMiniItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: AppColors.textSub,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textMainOf(context),
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
