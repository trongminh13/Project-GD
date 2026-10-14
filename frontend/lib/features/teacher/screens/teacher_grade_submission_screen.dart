import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/homework_service.dart';

class TeacherGradeSubmissionScreen extends StatefulWidget {
  final int submissionId;

  const TeacherGradeSubmissionScreen({super.key, required this.submissionId});

  @override
  State<TeacherGradeSubmissionScreen> createState() => _TeacherGradeSubmissionScreenState();
}

class _TeacherGradeSubmissionScreenState extends State<TeacherGradeSubmissionScreen> {
  final _service = HomeworkService();
  bool _isLoading = true;
  bool _isSaving = false;

  Map<String, dynamic>? _submission;
  final TextEditingController _feedbackController = TextEditingController();
  final Map<int, TextEditingController> _scoreControllers = {}; // answerId -> score
  final Map<int, TextEditingController> _noteControllers = {}; // answerId -> note

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    for (final c in _scoreControllers.values) {
      c.dispose();
    }
    for (final c in _noteControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    final data = await _service.getSubmissionDetails(widget.submissionId);
    if (!mounted) return;

    if (data != null) {
      _submission = data;
      _feedbackController.text = data['teacherFeedback'] ?? '';

      final answers = data['answers'] as List<dynamic>? ?? [];
      for (final a in answers) {
        final aId = a['id'] as int;
        final score = a['score'];
        final note = a['teacherNote'] ?? '';

        _scoreControllers[aId] = TextEditingController(text: score != null ? score.toString() : '');
        _noteControllers[aId] = TextEditingController(text: note);
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _submitGrade() async {
    if (_submission == null) return;

    final answers = _submission!['answers'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> answerGrades = [];

    for (final a in answers) {
      final aId = a['id'] as int;
      final scoreText = _scoreControllers[aId]?.text.trim() ?? '';
      final note = _noteControllers[aId]?.text.trim() ?? '';
      final scoreVal = double.tryParse(scoreText);

      answerGrades.add({
        'answerId': aId,
        'score': scoreVal,
        'teacherNote': note,
      });
    }

    setState(() => _isSaving = true);
    final res = await _service.gradeSubmission(
      submissionId: widget.submissionId,
      teacherFeedback: _feedbackController.text.trim(),
      answerGrades: answerGrades,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu kết quả chấm điểm!'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Lỗi khi lưu điểm.'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chấm bài học sinh')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_submission == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chấm bài học sinh')),
        body: const Center(child: Text('Không thể tải bài làm.')),
      );
    }

    final student = _submission!['student'] as Map<String, dynamic>? ?? {};
    final studentName = student['name'] ?? 'Học sinh';
    final assignment = _submission!['assignment'] as Map<String, dynamic>? ?? {};
    final homework = assignment['homework'] as Map<String, dynamic>? ?? {};
    final hwTitle = homework['title'] ?? 'Bài tập';
    final answers = _submission!['answers'] as List<dynamic>? ?? [];
    final autoScore = _submission!['autoScore'] ?? 0.0;
    final finalScore = _submission!['finalScore'];
    final status = _submission!['status'] ?? 'SUBMITTED';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chấm bài: $studentName'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner thông tin
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withValues(alpha: 0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hwTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Điểm trắc nghiệm tự chấm: $autoScore đ',
                        style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'GRADED' ? Colors.green.withValues(alpha: 0.15) : Colors.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status == 'GRADED' ? 'Điểm: $finalScore đ' : 'Chờ chấm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: status == 'GRADED' ? Colors.green : Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách các câu hỏi & câu trả lời
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (int i = 0; i < answers.length; i++) _buildAnswerItem(answers[i], i + 1),
                const SizedBox(height: 16),
                const Text('Lời phê chung của giáo viên:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Nhập nhận xét tổng quan cho bài làm của học sinh...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.surfaceAltOf(context),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _submitGrade,
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_rounded),
                label: const Text('Hoàn tất chấm điểm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerItem(Map<String, dynamic> ans, int order) {
    final aId = ans['id'] as int;
    final q = ans['question'] as Map<String, dynamic>? ?? {};
    final qType = q['questionType'] as String? ?? 'ESSAY';
    final content = q['content'] ?? '';
    final maxPoints = q['points'] ?? 1.0;
    final isAuto = ans['isAutoGraded'] == true;
    final ansText = ans['answerText'] as String?;
    final selectedOpts = ans['selectedOptions'] as List<dynamic>? ?? [];

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
                Text('Câu $order ($qType)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Tối đa: $maxPoints đ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 10),

            if (isAuto) ...[
              // Trắc nghiệm
              Text(
                'Lựa chọn của học sinh: ${selectedOpts.map((o) => o['option']?['content']).join(', ')}',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Điểm tự chấm: ${_scoreControllers[aId]?.text ?? 0.0} đ',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ] else ...[
              // Tự luận
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAltOf(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (ansText != null && ansText.isNotEmpty) ? ansText : '(Học sinh không nhập nội dung)',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _scoreControllers[aId],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Điểm câu này',
                        hintText: 'VD: 7.5',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _noteControllers[aId],
                      decoration: InputDecoration(
                        labelText: 'Ghi chú cho học sinh',
                        hintText: 'Nhận xét câu này...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
