import 'package:flutter/material.dart';
import 'package:ashadeep/core/services/homework_service.dart';
import 'package:ashadeep/core/services/homework_mock_content_provider.dart';
import 'package:ashadeep/core/theme/app_colors.dart';
import 'package:ashadeep/core/config/feature_flags.dart';
import 'package:ashadeep/utils/constants.dart' show ApiConstants;
import 'package:provider/provider.dart';
import 'package:ashadeep/core/theme/theme_manager.dart';
import 'package:ashadeep/core/theme/app_typography.dart';
import 'package:ashadeep/core/enums/education_level.dart';

class StudentHomeworkResultScreen extends StatefulWidget {
  final int assignmentId;
  final Map<String, dynamic>? initialData;

  const StudentHomeworkResultScreen({
    super.key,
    required this.assignmentId,
    this.initialData,
  });

  @override
  State<StudentHomeworkResultScreen> createState() => _StudentHomeworkResultScreenState();
}

class _StudentHomeworkResultScreenState extends State<StudentHomeworkResultScreen> {
  static const Color _kPrimaryBlue = AppColors.primaryBlue;
  static const Color _kTextMain = AppColors.textMain;
  static const Color _kTextMuted = AppColors.textMuted;
  static const Color _kBorderColor = AppColors.borderColor;
  static const Color _kCardBg = AppColors.cardBg;
  static const Color _kBgColor = AppColors.bgColor;
  static const Color _kOkGreen = AppColors.okGreen;
  static const Color _kWarningAmber = AppColors.warningAmber;
  static const Color _kDangerRed = AppColors.dangerRed;

  final _service = HomeworkService();
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchResult();
  }

  Future<void> _fetchResult() async {
    setState(() => _isLoading = true);
    Map<String, dynamic>? res = widget.initialData;

    if (res == null && ApiConstants.isDemoMode) {
      res = _buildFallbackMockResult(widget.assignmentId);
    } else if (res == null) {
      try {
        res = await _service.getAssignmentForTaking(widget.assignmentId);
      } catch (_) {}

      // Fallback mock result nếu bật Demo mode và offline hoặc chưa có submission từ server
      if (res == null && FeatureFlags.useDemoFallback) {
        res = _buildFallbackMockResult(widget.assignmentId);
      }
    }

    if (!mounted) return;
    setState(() {
      _data = res;
      _isLoading = false;
    });
  }

  Map<String, dynamic> _buildFallbackMockResult(int id) {
    return HomeworkMockContentProvider.getAssignmentResult(id);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _kBgColor,
        appBar: AppBar(
          backgroundColor: _kPrimaryBlue,
          foregroundColor: Colors.white,
          title: const Text('Kết quả bài tập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator(color: _kPrimaryBlue)),
      );
    }

    if (_data == null) {
      return Scaffold(
        backgroundColor: _kBgColor,
        appBar: AppBar(
          backgroundColor: _kPrimaryBlue,
          foregroundColor: Colors.white,
          title: const Text('Kết quả bài tập'),
        ),
        body: const Center(child: Text('Không thể tải kết quả bài làm.', style: TextStyle(color: _kTextMain))),
      );
    }

    final title = _data!['homeworkTitle'] ?? 'Bài tập';
    final subject = _data!['subjectName'] ?? '';
    final totalPoints = _data!['totalPoints'] ?? 10.0;
    final status = _data!['submissionStatus'] ?? 'SUBMITTED';
    final autoScore = _data!['autoScore'] as num?;
    final finalScore = _data!['finalScore'] as num?;
    final feedback = _data!['teacherFeedback'] as String?;
    final isLate = _data!['isLate'] == true;
    final questions = _data!['questions'] as List<dynamic>? ?? [];
    final savedAnswers = _data!['savedAnswers'] as List<dynamic>? ?? [];

    final Map<int, Map<String, dynamic>> ansMap = {};
    for (final a in savedAnswers) {
      ansMap[a['questionId'] as int] = a as Map<String, dynamic>;
    }

    final isGraded = status == 'GRADED';

    return Scaffold(
      backgroundColor: _kBgColor,
      appBar: AppBar(
        backgroundColor: _kPrimaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Kết quả bài làm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Điểm số & Trạng thái theo phong cách phẳng (Flat design)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _kBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      color: _kPrimaryBlue.withValues(alpha: 0.1),
                      child: Text(
                        subject,
                        style: const TextStyle(
                          color: _kPrimaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      color: isGraded ? _kOkGreen : _kWarningAmber,
                      child: Text(
                        isGraded ? 'ĐÃ CHẤM ĐIỂM' : 'ĐANG CHỜ CHẤM',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: _kTextMain,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: _kBorderColor),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGraded && finalScore != null
                              ? '$finalScore / $totalPoints đ'
                              : '${autoScore ?? 0.0} đ',
                          style: TextStyle(
                            color: isGraded ? _kOkGreen : _kPrimaryBlue,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          isGraded ? 'Điểm tổng kết' : 'Điểm trắc nghiệm (Tự luận chờ GV)',
                          style: const TextStyle(color: _kTextMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (isLate)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: _kDangerRed.withValues(alpha: 0.1),
                        child: const Text(
                          'Nộp muộn',
                          style: TextStyle(color: _kDangerRed, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Lời nhận xét của Giáo viên
          if (feedback != null && feedback.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  left: BorderSide(color: _kWarningAmber, width: 4),
                  top: BorderSide(color: _kBorderColor),
                  right: BorderSide(color: _kBorderColor),
                  bottom: BorderSide(color: _kBorderColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.comment_outlined, color: _kWarningAmber, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Lời nhận xét của Giáo viên',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _kTextMain),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback,
                    style: const TextStyle(fontSize: 13.5, height: 1.4, color: _kTextMain),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),
          const Text(
            'Chi tiết câu trả lời & Lời giải',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _kTextMain),
          ),
          const SizedBox(height: 10),

          // Danh sách chi tiết từng câu
          for (int i = 0; i < questions.length; i++)
            _buildQuestionResultCard(questions[i], i + 1, ansMap[questions[i]['id'] as int]),
        ],
      ),
    );
  }

  EducationLevel _getEducationLevel(BuildContext context) {
    try {
      return Provider.of<ThemeManager>(context).educationLevel;
    } catch (_) {
      return EducationLevel.highSchool;
    }
  }

  Widget _buildQuestionResultCard(
    Map<String, dynamic> q,
    int order,
    Map<String, dynamic>? studentAns,
  ) {
    final level = _getEducationLevel(context);
    final qType = q['questionType'] as String;
    final content = q['content'] ?? '';
    final points = q['points'] ?? 1.0;
    final explanation = q['explanation'] as String?;
    final correctAnswerText = q['correctAnswerText'] as String?;
    final options = q['options'] as List<dynamic>? ?? [];

    final scoreAchieved = studentAns?['score'] as num?;
    final teacherNote = studentAns?['teacherNote'] as String?;
    final selectedOptIds = (studentAns?['selectedOptionIds'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];
    final answerText = studentAns?['answerText'] as String?;

    final isCorrect = scoreAchieved != null && scoreAchieved >= points;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCardBg,
        border: Border.all(color: _kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu $order',
                style: AppTypography.title(level, fontWeight: FontWeight.bold, fontSize: 13, color: _kTextMain),
              ),
              if (scoreAchieved != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  color: (isCorrect ? _kOkGreen : _kDangerRed).withValues(alpha: 0.1),
                  child: Text(
                    '$scoreAchieved / $points đ',
                    style: AppTypography.title(
                      level,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isCorrect ? _kOkGreen : _kDangerRed,
                    ),
                  ),
                )
              else
                Text(
                  '$points đ (Chờ chấm)',
                  style: AppTypography.body(level, fontSize: 12, color: _kTextMuted, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTypography.question(level, fontWeight: FontWeight.w600, fontSize: 14.5, color: _kTextMain),
          ),
          const SizedBox(height: 12),

          // Các đáp án trắc nghiệm
          if (qType != 'ESSAY') ...[
            for (final opt in options) ...[
              _buildOptionResultRow(
                opt,
                selectedOptIds.contains(opt['id'] as int),
                opt['isCorrect'] == true,
              ),
            ],
          ] else ...[
            // Tự luận
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                border: Border.all(color: _kBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bài làm của học sinh:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _kTextMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (answerText != null && answerText.isNotEmpty) ? answerText : '(Chưa trả lời)',
                    style: const TextStyle(fontSize: 13, color: _kTextMain),
                  ),
                ],
              ),
            ),
            if (correctAnswerText != null && correctAnswerText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kOkGreen.withValues(alpha: 0.05),
                  border: Border.all(color: _kOkGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gợi ý đáp án chuẩn:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _kOkGreen),
                    ),
                    const SizedBox(height: 4),
                    Text(correctAnswerText, style: const TextStyle(fontSize: 13, color: _kTextMain)),
                  ],
                ),
              ),
            ],
          ],

          // Lời nhận xét cho câu hỏi
          if (teacherNote != null && teacherNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Ghi chú GV: $teacherNote',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: _kWarningAmber),
            ),
          ],
          if (explanation != null && explanation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _kPrimaryBlue.withValues(alpha: 0.05),
                border: Border.all(color: _kPrimaryBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: _kPrimaryBlue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Giải thích: $explanation',
                      style: AppTypography.body(level, fontSize: 12.5, color: _kPrimaryBlue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionResultRow(Map<String, dynamic> opt, bool isStudentSelected, bool isCorrect) {
    Color? bgColor = Colors.white;
    Color borderColor = _kBorderColor;
    Color iconColor = _kTextMuted;
    IconData icon = Icons.radio_button_unchecked;

    if (isCorrect) {
      bgColor = _kOkGreen.withValues(alpha: 0.08);
      borderColor = _kOkGreen;
      iconColor = _kOkGreen;
      icon = Icons.check_circle;
    } else if (isStudentSelected && !isCorrect) {
      bgColor = _kDangerRed.withValues(alpha: 0.08);
      borderColor = _kDangerRed;
      iconColor = _kDangerRed;
      icon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: isStudentSelected || isCorrect ? 1.5 : 1.0),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              opt['content'] ?? '',
              style: AppTypography.body(
                _getEducationLevel(context),
                fontSize: 13,
                fontWeight: isStudentSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                color: isCorrect ? _kOkGreen : (isStudentSelected ? _kDangerRed : _kTextMain),
              ),
            ),
          ),
          if (isStudentSelected) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: isCorrect ? _kOkGreen : _kDangerRed,
              child: const Text('Em đã chọn', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ] else if (isCorrect) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: _kOkGreen,
              child: const Text('Đáp án đúng', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }
}
