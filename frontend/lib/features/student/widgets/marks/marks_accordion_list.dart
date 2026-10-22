import 'package:flutter/material.dart';
import 'package:ashadeep/core/widgets/app_empty_card.dart';
import 'package:ashadeep/models/markbook.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

/// Danh sách môn học dạng thẻ mở rộng (Accordion List View)
class MarksAccordionList extends StatelessWidget {
  final StudentMarkbook markbook;
  final String level;
  final int selectedSemester; // 1: HK1, 2: HK2, 3: Cả năm
  final Set<int> expandedSubjectIds;
  final ValueChanged<int> onToggleExpand;

  const MarksAccordionList({
    super.key,
    required this.markbook,
    required this.level,
    required this.selectedSemester,
    required this.expandedSubjectIds,
    required this.onToggleExpand,
  });

  String _classifyScore(double? avg) {
    if (avg == null) return 'Chưa có điểm';
    if (avg >= 8.0) return 'Tốt';
    if (avg >= 6.5) return 'Khá';
    if (avg >= 5.0) return 'Đạt';
    return 'Chưa đạt';
  }

  IconData _getSubjectIcon(String subjectName) {
    final lower = subjectName.toLowerCase();
    if (lower.contains('toán')) return Icons.calculate_outlined;
    if (lower.contains('văn')) return Icons.menu_book_outlined;
    if (lower.contains('anh')) return Icons.translate_outlined;
    if (lower.contains('lý') || lower.contains('vật lí')) return Icons.science_outlined;
    if (lower.contains('hóa')) return Icons.biotech_outlined;
    if (lower.contains('sinh')) return Icons.park_outlined;
    if (lower.contains('sử')) return Icons.history_edu_outlined;
    if (lower.contains('địa')) return Icons.public_outlined;
    if (lower.contains('tin')) return Icons.computer_outlined;
    if (lower.contains('dục')) return Icons.sports_basketball_outlined;
    if (lower.contains('nghệ')) return Icons.palette_outlined;
    if (lower.contains('giáo dục')) return Icons.balance_outlined;
    return Icons.book_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (markbook.subjects.isEmpty) {
      return const AppEmptyCard(
        title: 'Chưa có dữ liệu môn học',
        message: 'Chưa có thông tin điểm số môn học cho kỳ này.',
        icon: Icons.grade_outlined,
      );
    }

    return Column(
      children: markbook.subjects.map((sub) {
        final isExpanded = expandedSubjectIds.contains(sub.subjectId);
        final sem = selectedSemester == 2 ? sub.semester2 : (selectedSemester == 3 ? null : sub.semester1);
        double? avg;
        if (selectedSemester == 1) {
          avg = sub.semester1?.avg;
        } else if (selectedSemester == 2) {
          avg = sub.semester2?.avg;
        } else {
          // Cả năm (TT22): ĐTBmcn = (ĐTBmhk1 + 2 * ĐTBmhk2) / 3
          avg = sub.yearAvg ??
              (sub.semester1?.avg != null && sub.semester2?.avg != null
                  ? ((sub.semester1!.avg! + 2 * sub.semester2!.avg!) / 3.0)
                  : null);
        }
        final isNarrativeOnly = markbook.isNarrativeOnly || (sem != null && sem.avg == null && sem.ckScore == null);
        final classification = avg != null ? _classifyScore(avg) : (sub.academicClassification ?? 'Đạt');

        // Màu sắc theo thang điểm
        Color scoreColor = AppColors.primary;
        if (avg != null) {
          if (avg >= 8.0) {
            scoreColor = AppColors.primary;
          } else if (avg >= 6.5) {
            scoreColor = AppColors.warning;
          } else {
            scoreColor = AppColors.error;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppColors.cardBorderRadius,
            border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
          ),
          child: InkWell(
            onTap: () => onToggleExpand(sub.subjectId),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: scoreColor.withValues(alpha: 0.10),
                          borderRadius: AppColors.cardBorderRadius,
                        ),
                        child: Icon(_getSubjectIcon(sub.subjectName), color: scoreColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.subjectName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMainOf(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isNarrativeOnly ? 'Đánh giá bằng nhận xét' : 'Đánh giá nhận xét & điểm số',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSub),
                            ),
                          ],
                        ),
                      ),
                      if (!isNarrativeOnly && avg != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  avg.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: scoreColor,
                                  ),
                                ),
                                const Text('/10', style: TextStyle(fontSize: 11, color: AppColors.textSub)),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: scoreColor.withValues(alpha: 0.10),
                                borderRadius: AppColors.cardBorderRadius,
                              ),
                              child: Text(
                                classification,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: scoreColor),
                              ),
                            ),
                          ],
                        )
                      else if (!isNarrativeOnly && avg == null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '—',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textSub,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: AppColors.cardBorderRadius,
                                border: Border.all(color: AppColors.cardBorder, width: 0.8),
                              ),
                              child: const Text(
                                'Chưa có điểm',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSub),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: AppColors.cardBorderRadius,
                            border: Border.all(color: const Color(0xFFA5D6A7)),
                          ),
                          child: Text(
                            classification,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.textSub,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                // Chi tiết thành phần điểm khi mở rộng
                if (isExpanded) ...[
                  Container(height: 1, color: AppColors.cardBorder),
                  Container(
                    padding: const EdgeInsets.all(14),
                    color: AppColors.surfaceAlt,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isNarrativeOnly) ...[
                          if (selectedSemester == 3) ...[
                            // KHỐI ĐỐI SOÁT ĐẶC THÙ CHO CẢ NĂM (HK1, HK2, CẢ NĂM)
                            const Text(
                              'Tổng hợp điểm cả năm (chuẩn TT 22/2021):',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildScoreSubCell(
                                  'ĐTB Học kỳ I (x1)',
                                  sub.semester1?.avg != null ? sub.semester1!.avg!.toStringAsFixed(1) : '-',
                                ),
                                const SizedBox(width: 8),
                                _buildScoreSubCell(
                                  'ĐTB Học kỳ II (x2)',
                                  sub.semester2?.avg != null ? sub.semester2!.avg!.toStringAsFixed(1) : '-',
                                ),
                                const SizedBox(width: 8),
                                _buildScoreSubCell(
                                  'ĐTB Cả năm',
                                  sub.yearAvg != null ? sub.yearAvg!.toStringAsFixed(1) : (avg != null ? avg.toStringAsFixed(1) : '-'),
                                  isHighlight: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Công thức: ĐTBmcn = (ĐTBmhk1 + 2 x ĐTBmhk2) / 3',
                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSub),
                            ),
                            const SizedBox(height: 10),
                          ] else ...[
                            // KHỐI ĐIỂM THÀNH PHẦN CHO HỌC KỲ I HOẶC HỌC KỲ II
                            Text(
                              'Điểm thành phần chi tiết (${selectedSemester == 2 ? "Học kỳ II" : "Học kỳ I"}):',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub),
                            ),
                            const SizedBox(height: 8),
                            if (sem != null && (sem.txScores.isNotEmpty || sem.gkScore != null || sem.ckScore != null))
                              Row(
                                children: [
                                  _buildScoreSubCell(
                                    'ĐĐGtx (x1)',
                                    (sem.txScores.isNotEmpty)
                                        ? sem.txScores.map((e) => e != null ? e.toStringAsFixed(1) : '-').join(', ')
                                        : '-',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildScoreSubCell(
                                    'ĐĐGgk (x2)',
                                    sem.gkScore != null ? sem.gkScore!.toStringAsFixed(1) : '-',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildScoreSubCell(
                                    'ĐĐGck (x3)',
                                    sem.ckScore != null ? sem.ckScore!.toStringAsFixed(1) : '-',
                                  ),
                                ],
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.cardBorder, width: 0.8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.hourglass_empty, size: 16, color: AppColors.textSub),
                                    SizedBox(width: 8),
                                    Text(
                                      'Chưa có dữ liệu điểm kiểm tra thường xuyên & định kỳ cho kỳ này.',
                                      style: TextStyle(fontSize: 12, color: AppColors.textSub),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 10),
                          ],
                        ],
                        // Lời phê giáo viên
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.comment_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _getTeacherComment(sub, selectedSemester, sem),
                                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textMain),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getTeacherComment(SubjectMarkbook sub, int semester, SemesterMark? sem) {
    if (semester == 3) {
      final yearComments = sub.semester2?.comments ?? sub.semester1?.comments;
      if (yearComments != null && yearComments.isNotEmpty) {
        return 'Tổng kết cả năm: ${yearComments.join(' • ')}';
      }
      return 'Tổng kết năm học: Nắm vững kiến thức trọng tâm, rèn luyện kỹ năng toàn diện và đạt kết quả vững vàng.';
    }
    if (sem?.comments != null && sem!.comments!.isNotEmpty) {
      return sem.comments!.join(' • ');
    }
    return 'Học sinh nắm vững chuẩn kiến thức, tích cực phát biểu xây dựng bài.';
  }

  Widget _buildScoreSubCell(String label, String value, {bool isHighlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isHighlight ? const Color(0xFFE8F0FE) : Colors.white,
          borderRadius: AppColors.cardBorderRadius,
          border: Border.all(
            color: isHighlight ? AppColors.primary : AppColors.cardBorder,
            width: isHighlight ? 1.0 : 0.8,
          ),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSub)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isHighlight ? AppColors.primary : AppColors.textMain,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
