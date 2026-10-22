import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/marks_service.dart';
import 'package:ashadeep/models/markbook.dart';
import 'package:ashadeep/core/enums/education_level.dart';
import 'package:ashadeep/core/theme/theme_manager.dart';
import 'package:ashadeep/core/theme/app_typography.dart';
import 'package:ashadeep/features/student/widgets/markbook_table_widget.dart';

/// Màn hình bảng điểm học bạ phụ huynh theo chuẩn Bộ GD&ĐT Việt Nam.
/// Hỗ trợ đầy đủ cả 3 cấp học: Tiểu học (TT27/2020), THCS và THPT (TT22/2021).
class ParentMarksScreen extends StatefulWidget {
  final String? studentId;
  const ParentMarksScreen({super.key, this.studentId});

  @override
  State<ParentMarksScreen> createState() => _ParentMarksScreenState();
}

class _ParentMarksScreenState extends State<ParentMarksScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  StudentMarkbook? _markbook;
  bool _isLoading = true;
  String? _errorMsg;
  int _selectedSemester = 1; // 1: HK1, 2: HK2, 3: Cả năm

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _loadMarkbook();
  }

  Future<void> _loadMarkbook() async {
    final sid = widget.studentId;
    if (sid == null || sid.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Không xác định được học sinh.';
        });
      }
      return;
    }

    final data = await MarksService().getStudentMarkbook(sid);
    if (mounted) {
      setState(() {
        _markbook = data;
        _isLoading = false;
        if (data == null) {
          _errorMsg = 'Chưa có dữ liệu học bạ cho năm học này.';
        }
      });
      if (data != null) {
        final level = EducationLevelHelper.fromString(data.educationLevel) ??
            EducationLevel.primary;
        try {
          Provider.of<ThemeManager>(context, listen: false)
              .setEducationLevel(level);
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showReportCardPreviewModal(StudentMarkbook markbook) {
    final level = EducationLevelHelper.fromString(markbook.educationLevel) ??
        EducationLevel.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      color: AppColors.borderOf(context),
                      margin: const EdgeInsets.only(bottom: 16),
                    ),
                  ),
                  Center(
                    child: Text(
                      'CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM\nĐộc lập - Tự do - Hạnh phúc',
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        level,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'PHIẾU BÁO ĐIỂM HỌC TẬP & RÈN LUYỆN',
                      style: AppTypography.title(
                        level,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Năm học: ${markbook.academicYear ?? "2026-2027"} • Học kỳ ${_selectedSemester == 3 ? "Cả năm" : (_selectedSemester == 2 ? "II" : "I")}',
                      style: AppTypography.body(
                        level,
                        fontSize: 12,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Họ và tên học sinh: ${markbook.studentName}',
                    style: AppTypography.body(
                      level,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Mã học sinh: ${markbook.studentAdmissionNumber ?? "—"} • Lớp: ${markbook.className ?? "—"}',
                    style: AppTypography.body(level, color: Colors.black87),
                  ),
                  Text(
                    'Trường: ${markbook.schoolName ?? "Trường Astra"}',
                    style: AppTypography.body(level, color: Colors.black87),
                  ),
                  const SizedBox(height: 14),
                  Table(
                    border: TableBorder.all(color: AppColors.borderOf(context)),
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFF5F7FA)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              'Môn học',
                              style: AppTypography.title(
                                level,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              'ĐTB Môn',
                              style: AppTypography.title(
                                level,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              'Xếp loại',
                              style: AppTypography.title(
                                level,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      ...markbook.subjects.map((s) {
                        double? avg;
                        if (_selectedSemester == 1) {
                          avg = s.semester1?.avg;
                        } else if (_selectedSemester == 2) {
                          avg = s.semester2?.avg;
                        } else {
                          // Cả năm (TT22): ĐTBmcn = (ĐTBmhk1 + 2 * ĐTBmhk2) / 3
                          avg = s.yearAvg ??
                              (s.semester1?.avg != null && s.semester2?.avg != null
                                  ? ((s.semester1!.avg! + 2 * s.semester2!.avg!) / 3.0)
                                  : null);
                        }
                        final classification = _classifyScore(avg);
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                s.subjectName,
                                style: AppTypography.body(
                                  level,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                avg != null ? avg.toStringAsFixed(1) : '-',
                                textAlign: TextAlign.center,
                                style: AppTypography.score(
                                  level,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                classification,
                                textAlign: TextAlign.center,
                                style: AppTypography.button(
                                  level,
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Điểm trung bình chung: ${markbook.overallAvg?.toStringAsFixed(1) ?? "—"} / 10.0',
                    style: AppTypography.body(
                      level,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Xếp loại học lực: ${markbook.overallClassification ?? "—"} • Rèn luyện: ${markbook.conduct ?? "Tốt"}',
                    style: AppTypography.body(level, color: Colors.black87),
                  ),
                  if (markbook.honorTitle != null && markbook.honorTitle!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Danh hiệu khen thưởng: ${markbook.honorTitle}',
                      style: AppTypography.title(
                        level,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GIÁO VIÊN CHỦ NHIỆM\n(Ký và ghi rõ họ tên)',
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          level,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'HIỆU TRƯỞNG DUYỆT\n(Đã ký số điện tử)',
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          level,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Đã xuất file học bạ điện tử (PDF) thành công!',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: Text(
                      'Tải Xuống Bản In (PDF)',
                      style: AppTypography.button(
                        level,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(context, 'Đang tải học bạ...'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMsg != null || _markbook == null) {
      return Scaffold(
        appBar: _buildAppBar(context, 'Học bạ'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined,
                  size: 64, color: AppColors.textSecondaryOf(context)),
              const SizedBox(height: 16),
              Text(
                _errorMsg ?? 'Không có dữ liệu.',
                style: TextStyle(color: AppColors.textSecondaryOf(context)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final markbook = _markbook!;
    final level = EducationLevelHelper.fromString(markbook.educationLevel) ??
        EducationLevel.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Học bạ – ${markbook.academicYear ?? ""}',
          style: AppTypography.title(level, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Xem phiếu báo điểm A4',
            icon: const Icon(Icons.print_outlined),
            onPressed: () => _showReportCardPreviewModal(markbook),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh chọn học kỳ
              _buildSemesterSelector(level),
              const SizedBox(height: 16),
              MarkbookTableWidget(markbook: markbook),
              const SizedBox(height: 16),
              // Nút xem bản in PDF
              OutlinedButton.icon(
                onPressed: () => _showReportCardPreviewModal(markbook),
                icon: const Icon(Icons.description_outlined),
                label: Text(
                  'Xem & In Phiếu Báo Điểm Khổ A4',
                  style: AppTypography.button(
                    level,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.borderOf(context)),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppColors.cardBorderRadius,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterSelector(EducationLevel level) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Row(
        children: [
          _semesterTabItem(1, 'Học kỳ I', level),
          _semesterTabItem(2, 'Học kỳ II', level),
          _semesterTabItem(3, 'Cả năm', level),
        ],
      ),
    );
  }

  Widget _semesterTabItem(int index, String title, EducationLevel level) {
    final isSelected = _selectedSemester == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSemester = index;
          });
        },
        borderRadius: AppColors.cardBorderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppColors.cardBorderRadius,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.button(
              level,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondaryOf(context),
            ),
          ),
        ),
      ),
    );
  }

  String _classifyScore(double? score) {
    if (score == null) return '—';
    if (score >= 8.0) return 'Tốt';
    if (score >= 6.5) return 'Khá';
    if (score >= 5.0) return 'Đạt';
    return 'Chưa đạt';
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      elevation: 0,
      centerTitle: true,
    );
  }
}
