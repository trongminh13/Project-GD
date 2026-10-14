import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/homework_service.dart';
import 'package:ashadeep/features/student/screens/student_homework_result_screen.dart';

class StudentTakeHomeworkScreen extends StatefulWidget {
  final int assignmentId;

  const StudentTakeHomeworkScreen({super.key, required this.assignmentId});

  @override
  State<StudentTakeHomeworkScreen> createState() => _StudentTakeHomeworkScreenState();
}

class _StudentTakeHomeworkScreenState extends State<StudentTakeHomeworkScreen> {
  final _service = HomeworkService();
  bool _isLoading = true;
  bool _isSubmitting = false;

  Map<String, dynamic>? _data;
  final Map<int, List<int>> _selectedOptions = {}; // questionId -> list of optionId
  final Map<int, TextEditingController> _textControllers = {}; // questionId -> controller

  @override
  void initState() {
    super.initState();
    _fetchAssignment();
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchAssignment() async {
    setState(() => _isLoading = true);
    final res = await _service.getAssignmentForTaking(widget.assignmentId);
    if (!mounted) return;

    if (res != null) {
      _data = res;
      // Khôi phục các câu đã lưu
      final savedAnswers = res['savedAnswers'] as List<dynamic>? ?? [];
      for (final a in savedAnswers) {
        final qId = a['questionId'] as int;
        final selectedIds = (a['selectedOptionIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];
        _selectedOptions[qId] = selectedIds;

        final text = a['answerText'] as String?;
        if (text != null && text.isNotEmpty) {
          _textControllers[qId] = TextEditingController(text: text);
        }
      }

      // Khởi tạo controllers cho các câu tự luận còn lại
      final questions = res['questions'] as List<dynamic>? ?? [];
      for (final q in questions) {
        final qId = q['id'] as int;
        if (!_textControllers.containsKey(qId)) {
          _textControllers[qId] = TextEditingController();
        }
      }
    }
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _collectAnswers() {
    final questions = _data?['questions'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> answers = [];

    for (final q in questions) {
      final qId = q['id'] as int;
      final qType = q['questionType'] as String;

      if (qType == 'ESSAY') {
        answers.add({
          'questionId': qId,
          'answerText': _textControllers[qId]?.text.trim() ?? '',
          'selectedOptionIds': [],
        });
      } else {
        answers.add({
          'questionId': qId,
          'answerText': null,
          'selectedOptionIds': _selectedOptions[qId] ?? [],
        });
      }
    }
    return answers;
  }

  Future<void> _onSaveDraft() async {
    final subId = _data?['submissionId'] as int?;
    if (subId == null) return;

    setState(() => _isSubmitting = true);
    final ok = await _service.saveDraft(subId, _collectAnswers());
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Đã lưu nháp câu trả lời.' : 'Không thể lưu nháp.'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<void> _onSubmit() async {
    final subId = _data?['submissionId'] as int?;
    if (subId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận nộp bài'),
        content: const Text('Bạn có chắc chắn muốn nộp bài? Sau khi nộp, bạn không thể thay đổi đáp án.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Kiểm tra lại')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Nộp ngay', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);
    final res = await _service.submitHomework(subId, _collectAnswers());
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nộp bài thành công!'), backgroundColor: AppColors.success),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentHomeworkResultScreen(assignmentId: widget.assignmentId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Lỗi khi nộp bài.'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Làm bài tập')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Làm bài tập')),
        body: const Center(child: Text('Không thể tải nội dung bài tập.')),
      );
    }

    final title = _data!['homeworkTitle'] ?? 'Bài tập';
    final subject = _data!['subjectName'] ?? '';
    final totalPoints = _data!['totalPoints'] ?? 10.0;
    final questions = _data!['questions'] as List<dynamic>? ?? [];
    final subStatus = _data!['submissionStatus'] as String? ?? 'IN_PROGRESS';

    // Nếu bài đã nộp hoặc đã chấm, chuyển hướng xem kết quả
    if (subStatus == 'SUBMITTED' || subStatus == 'GRADED') {
      return StudentHomeworkResultScreen(assignmentId: widget.assignmentId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Lưu nháp',
            onPressed: _isSubmitting ? null : _onSaveDraft,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header tóm tắt
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primary.withValues(alpha: 0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      subject,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                Text(
                  'Thang điểm: $totalPoints đ',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),

          // Danh sách câu hỏi
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (ctx, idx) {
                final q = questions[idx];
                return _buildQuestionCard(q, idx + 1);
              },
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _onSaveDraft,
                    icon: const Icon(Icons.bookmark_border_rounded),
                    label: const Text('Lưu nháp'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _onSubmit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Nộp bài'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildQuestionCard(Map<String, dynamic> q, int order) {
    final qId = q['id'] as int;
    final qType = q['questionType'] as String;
    final content = q['content'] ?? '';
    final points = q['points'] ?? 1.0;
    final options = q['options'] as List<dynamic>? ?? [];

    String typeLabel = 'Trắc nghiệm';
    if (qType == 'TRUE_FALSE') typeLabel = 'Đúng / Sai';
    if (qType == 'ESSAY') typeLabel = 'Tự luận';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Câu $order • $typeLabel',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  '$points điểm',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 12),

            // Lựa chọn đáp án
            if (qType == 'SINGLE_CHOICE' || qType == 'TRUE_FALSE') ...[
              for (final opt in options) _buildRadioOption(qId, opt),
            ] else if (qType == 'MULTIPLE_CHOICE') ...[
              for (final opt in options) _buildCheckboxOption(qId, opt),
            ] else if (qType == 'ESSAY') ...[
              TextFormField(
                controller: _textControllers[qId],
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Nhập câu trả lời của em tại đây...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: AppColors.surfaceAltOf(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(int qId, Map<String, dynamic> opt) {
    final optId = opt['id'] as int;
    final content = opt['content'] ?? '';
    final currentSelected = _selectedOptions[qId] ?? [];
    final isSelected = currentSelected.contains(optId);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedOptions[qId] = [optId];
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Radio<int>(
              value: optId,
              groupValue: currentSelected.isNotEmpty ? currentSelected.first : null,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedOptions[qId] = [val];
                  });
                }
              },
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Text(content, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(int qId, Map<String, dynamic> opt) {
    final optId = opt['id'] as int;
    final content = opt['content'] ?? '';
    final currentSelected = _selectedOptions[qId] ?? [];
    final isSelected = currentSelected.contains(optId);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            currentSelected.remove(optId);
          } else {
            currentSelected.add(optId);
          }
          _selectedOptions[qId] = currentSelected;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    currentSelected.add(optId);
                  } else {
                    currentSelected.remove(optId);
                  }
                  _selectedOptions[qId] = currentSelected;
                });
              },
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Text(content, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
          ],
        ),
      ),
    );
  }
}
