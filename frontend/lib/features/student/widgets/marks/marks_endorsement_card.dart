import 'package:flutter/material.dart';
import 'package:ashadeep/models/markbook.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

/// Thẻ Đánh giá Rèn luyện & Nhận xét GVCN + Dấu phê duyệt Ban Giám Hiệu
class MarksEndorsementCard extends StatelessWidget {
  final String classTeacher;
  final StudentMarkbook markbook;

  const MarksEndorsementCard({
    super.key,
    required this.classTeacher,
    required this.markbook,
  });

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.psychology_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Đánh giá Rèn luyện & Khen thưởng',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMainOf(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Xếp loại Rèn luyện / Hạnh kiểm:',
                  style: TextStyle(fontSize: 13, color: AppColors.textSub),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: AppColors.cardBorderRadius,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  'Tốt (Xuất sắc)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: AppColors.cardBorderRadius,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.format_quote, color: AppColors.primary, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Em có tinh thần học tập tự giác rất cao, tích cực tương tác trong giờ học và đạt thành tích xuất sắc ở tất cả các môn. Hãy tiếp tục phát huy nhé!\n— $classTeacher',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Dấu phê duyệt Ban Giám Hiệu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBE7),
              border: Border.all(color: const Color(0xFFDCE775)),
              borderRadius: AppColors.cardBorderRadius,
            ),
            child: const Row(
              children: [
                Icon(Icons.verified, size: 16, color: Color(0xFF689F38)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đã được Ban Giám Hiệu ký số và phê duyệt hồ sơ học bạ điện tử.',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF33691E)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
