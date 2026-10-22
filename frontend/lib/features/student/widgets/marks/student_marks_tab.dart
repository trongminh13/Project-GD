import 'package:flutter/material.dart';
import 'package:ashadeep/models/markbook.dart';
import 'package:ashadeep/core/theme/app_colors.dart';
import 'package:ashadeep/core/config/feature_flags.dart';

import 'marks_national_header.dart';
import 'marks_semester_selector.dart';
import 'marks_hero_kpi_card.dart';
import 'marks_endorsement_card.dart';
import 'marks_criteria_card.dart';
import 'marks_view_mode_bar.dart';
import 'marks_accordion_list.dart';
import 'marks_grid_table_view.dart';

/// Tab Bảng điểm & Kết quả học tập (chuẩn Bộ GD&ĐT Việt Nam)
class StudentMarksTab extends StatefulWidget {
  final StudentMarkbook markbook;
  final String level; // 'PRIMARY' | 'SECONDARY' | 'HIGH_SCHOOL'
  final String classTeacher;
  final List<dynamic> rawMarks;
  final Future<void> Function() onRefresh;

  const StudentMarksTab({
    super.key,
    required this.markbook,
    required this.level,
    required this.classTeacher,
    required this.rawMarks,
    required this.onRefresh,
  });

  @override
  State<StudentMarksTab> createState() => _StudentMarksTabState();
}

class _StudentMarksTabState extends State<StudentMarksTab> {
  int _selectedSemester = 1; // 1: Học kỳ 1, 2: Học kỳ 2, 3: Cả năm
  bool _isMarkbookTableView = false;
  final Set<int> _expandedSubjectIds = {};

  @override
  Widget build(BuildContext context) {
    final markbook = widget.markbook;
    final level = widget.level;

    // 1. Tính toán số liệu thống kê học lực theo kỳ đang chọn
    double? currentSemAvg;
    int evaluatedSubjectsCount = 0;
    double sumSemAvg = 0.0;
    int perfectCount = 0;

    for (final s in markbook.subjects) {
      double? a;
      if (_selectedSemester == 1) {
        a = s.semester1?.avg;
      } else if (_selectedSemester == 2) {
        a = s.semester2?.avg;
      } else {
        // Cả năm (TT22): ĐTBmcn = (ĐTBmhk1 + 2 * ĐTBmhk2) / 3
        a = s.yearAvg ??
            (s.semester1?.avg != null && s.semester2?.avg != null
                ? ((s.semester1!.avg! + 2 * s.semester2!.avg!) / 3.0)
                : null);
      }
      if (a != null) {
        sumSemAvg += a;
        evaluatedSubjectsCount++;
        if (a >= 9.0) {
          perfectCount++;
        }
      }
    }

    if (evaluatedSubjectsCount > 0) {
      currentSemAvg = sumSemAvg / evaluatedSubjectsCount;
    } else if (_selectedSemester == 3 && markbook.overallAvg != null) {
      currentSemAvg = markbook.overallAvg;
    } else if (_selectedSemester == 1 && widget.rawMarks.isNotEmpty) {
      double total = 0.0;
      int count = 0;
      for (final m in widget.rawMarks) {
        final sc = m['score'];
        if (sc != null) {
          final val = (sc is num) ? sc.toDouble() : double.tryParse(sc.toString());
          if (val != null) {
            total += val;
            count++;
          }
        }
      }
      if (count > 0) currentSemAvg = total / count;
    }

    // Xếp loại học lực
    String academicRank = 'Chưa có điểm';
    IconData rankIcon = Icons.hourglass_empty_rounded;
    Color rankColor = AppColors.textSub;
    Color rankBg = AppColors.surfaceAlt;

    if (currentSemAvg != null) {
      if (currentSemAvg >= 9.0) {
        academicRank = 'Xuất sắc';
        rankIcon = Icons.emoji_events_rounded;
        rankColor = AppColors.primary;
        rankBg = const Color(0xFFE8F0FE);
      } else if (currentSemAvg >= 8.0) {
        academicRank = 'Giỏi';
        rankIcon = Icons.workspace_premium_rounded;
        rankColor = AppColors.primary;
        rankBg = const Color(0xFFE8F0FE);
      } else if (currentSemAvg >= 6.5) {
        academicRank = 'Khá';
        rankIcon = Icons.military_tech_outlined;
        rankColor = AppColors.warning;
        rankBg = const Color(0xFFFEF7E0);
      } else if (currentSemAvg >= 5.0) {
        academicRank = 'Đạt';
        rankIcon = Icons.trending_up_rounded;
        rankColor = AppColors.primary;
        rankBg = const Color(0xFFE8F0FE);
      } else {
        academicRank = 'Chưa đạt';
        rankIcon = Icons.trending_down_rounded;
        rankColor = AppColors.error;
        rankBg = const Color(0xFFFFEBEE);
      }
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Banner chế độ Demo (nếu đang bật)
          if (FeatureFlags.useDemoFallback)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppColors.cardBorderRadius,
                border: Border.all(color: AppColors.warning, width: 1.0),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Học bạ điện tử đang hiển thị dữ liệu mô phỏng chuẩn Bộ GD&ĐT.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSub),
                    ),
                  ),
                ],
              ),
            ),

          // 1. Header Trang bìa Sổ học bạ Quốc gia
          MarksNationalHeader(
            markbook: markbook,
            level: level,
            selectedSemester: _selectedSemester,
          ),
          const SizedBox(height: 12),

          // 2. Bộ chọn Học kỳ (Semester Selector)
          MarksSemesterSelector(
            selectedSemester: _selectedSemester,
            onSelectSemester: (semId) {
              setState(() => _selectedSemester = semId);
            },
          ),
          const SizedBox(height: 14),

          // 3. Hero KPI Card - Tổng quan kết quả học tập
          MarksHeroKpiCard(
            avgScore: currentSemAvg,
            academicRank: academicRank,
            rankIcon: rankIcon,
            rankColor: rankColor,
            rankBg: rankBg,
            markbook: markbook,
            level: level,
            selectedSemester: _selectedSemester,
            perfectCount: perfectCount,
          ),
          const SizedBox(height: 14),

          // 4. Thẻ Đánh giá Rèn luyện & Nhận xét GVCN + Dấu phê duyệt Ban Giám Hiệu
          MarksEndorsementCard(
            classTeacher: widget.classTeacher,
            markbook: markbook,
          ),
          const SizedBox(height: 16),

          // 5. Khu vực tiêu chuẩn xếp loại theo cấp học (TT 27 / TT 22)
          MarksCriteriaCard(
            level: level,
            markbook: markbook,
          ),
          if (level == 'PRIMARY' || level == 'HIGH_SCHOOL') const SizedBox(height: 16),

          // 6. Thanh công cụ & Chuyển đổi chế độ xem
          MarksViewModeBar(
            subjectCount: markbook.subjects.length,
            isTableView: _isMarkbookTableView,
            onToggleViewMode: (isTable) {
              setState(() => _isMarkbookTableView = isTable);
            },
          ),
          const SizedBox(height: 12),

          // 7. Nội dung Bảng điểm: Chế độ Sổ điểm điện tử HOẶC Chế độ Thẻ mở rộng
          if (_isMarkbookTableView)
            MarksGridTableView(
              markbook: markbook,
              level: level,
              selectedSemester: _selectedSemester,
            )
          else
            MarksAccordionList(
              markbook: markbook,
              level: level,
              selectedSemester: _selectedSemester,
              expandedSubjectIds: _expandedSubjectIds,
              onToggleExpand: (subId) {
                setState(() {
                  if (_expandedSubjectIds.contains(subId)) {
                    _expandedSubjectIds.remove(subId);
                  } else {
                    _expandedSubjectIds.add(subId);
                  }
                });
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
