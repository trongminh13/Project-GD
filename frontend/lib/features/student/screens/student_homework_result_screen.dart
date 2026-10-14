import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/homework_service.dart';

class StudentHomeworkResultScreen extends StatefulWidget {
  final int assignmentId;

  const StudentHomeworkResultScreen({super.key, required this.assignmentId});

  @override
  State<StudentHomeworkResultScreen> createState() => _StudentHomeworkResultScreenState();
}

class _StudentHomeworkResultScreenState extends State<StudentHomeworkResultScreen> {
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
    final res = await _service.getAssignmentForTaking(widget.assignmentId);
    if (!mounted) return;
    setState(() {
      _data = res;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kết quả bài tập')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kết quả bài tập')),
        body: const Center(child: Text('Không thể tải kết quả bài làm.')),
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

    // Map saved answers by questionId
    final Map<int, Map<String, dynamic>> ansMap = {};
    for (final a in savedAnswers) {
      ansMap[a['questionId'] as int] = a as Map<String, dynamic>;
    }

    final isGraded = status == 'GRADED';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả bài làm'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Điểm số & Trạng thái
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGraded
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFF4A148C), const Color(0xFF6A1B9A)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isGraded ? Colors.green : Colors.purple).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subject,
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                if (isGraded && finalScore != null) ...[
                  Text(
                    '$finalScore / $totalPoints',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Điểm tổng kết',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ] else ...[
                  Text(
                    '${autoScore ?? 0.0} đ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Điểm trắc nghiệm (Tự luận chờ GV chấm)',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
                if (isLate) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Nộp muộn sau hạn',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Lời nhận xét của Giáo viên
          if (feedback != null && feedback.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              color: Colors.amber.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.rate_review_rounded, color: Colors.amber, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nhận xét của Giáo viên',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            feedback,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          const Text(
            'Chi tiết câu trả lời & Lời giải',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Danh sách chi tiết từng câu
          for (int i = 0; i < questions.length; i++)
            _buildQuestionResultCard(questions[i], i + 1, ansMap[questions[i]['id'] as int]),
        ],
      ),
    );
  }

  Widget _buildQuestionResultCard(
    Map<String, dynamic> q,
    int order,
    Map<String, dynamic>? studentAns,
  ) {
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

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Câu $order',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (scoreAchieved != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isCorrect ? Colors.green : Colors.red).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$scoreAchieved / $points đ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  )
                else
                  Text(
                    '$points đ (Chờ chấm)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.4),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAltOf(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bài làm của học sinh:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (answerText != null && answerText.isNotEmpty) ? answerText : '(Chưa trả lời)',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (correctAnswerText != null && correctAnswerText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gợi ý đáp án chuẩn:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                      ),
                      const SizedBox(height: 4),
                      Text(correctAnswerText, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ],

            // Lời giải thích / Ghi chú của giáo viên
            if (teacherNote != null && teacherNote.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Lời phê: $teacherNote',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.purple),
              ),
            ],
            if (explanation != null && explanation.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Giải thích: $explanation',
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionResultRow(Map<String, dynamic> opt, bool isStudentSelected, bool isCorrect) {
    Color? bgColor;
    Color iconColor = Colors.grey;
    IconData icon = Icons.radio_button_unchecked;

    if (isCorrect) {
      bgColor = Colors.green.withValues(alpha: 0.12);
      iconColor = Colors.green;
      icon = Icons.check_circle_rounded;
    } else if (isStudentSelected && !isCorrect) {
      bgColor = Colors.red.withValues(alpha: 0.12);
      iconColor = Colors.red;
      icon = Icons.cancel_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: isStudentSelected ? Border.all(color: iconColor, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              opt['content'] ?? '',
              style: TextStyle(
                fontWeight: isStudentSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                color: isCorrect ? Colors.green.shade900 : null,
              ),
            ),
          ),
          if (isStudentSelected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Em đã chọn', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
