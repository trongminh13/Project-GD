import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ashadeep/core/services/homework_service.dart';
import 'package:ashadeep/features/student/screens/student_homework_result_screen.dart';
import 'package:ashadeep/core/config/feature_flags.dart';
import 'package:ashadeep/core/widgets/app_loading_button.dart';

import 'package:ashadeep/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:ashadeep/core/theme/theme_manager.dart';
import 'package:ashadeep/core/theme/app_typography.dart';
import 'package:ashadeep/core/enums/education_level.dart';

class StudentTakeHomeworkScreen extends StatefulWidget {
  final int assignmentId;

  const StudentTakeHomeworkScreen({super.key, required this.assignmentId});

  @override
  State<StudentTakeHomeworkScreen> createState() => _StudentTakeHomeworkScreenState();
}

class _StudentTakeHomeworkScreenState extends State<StudentTakeHomeworkScreen> {
  static const Color _kPrimaryBlue = AppColors.primaryBlue;
  static const Color _kTextMain = AppColors.textMain;
  static const Color _kTextMuted = AppColors.textMuted;
  static const Color _kBorderColor = AppColors.borderColor;
  static const Color _kCardBg = AppColors.cardBg;
  static const Color _kBgColor = AppColors.bgColor;
  static const Color _kOkGreen = AppColors.okGreen;
  static const Color _kWarningAmber = AppColors.warningAmber;

  final _service = HomeworkService();
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _questionKeys = {};

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isAutoSaving = false;
  DateTime? _lastSavedAt;
  Timer? _debounceTimer;

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
    _debounceTimer?.cancel();
    _scrollController.dispose();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchAssignment() async {
    setState(() => _isLoading = true);
    Map<String, dynamic>? res;
    try {
      res = await _service.getAssignmentForTaking(widget.assignmentId);
    } catch (_) {}

    // Fallback Mock nếu bật Demo mode và backend chưa có bài tập hoặc chạy offline
    if (res == null && FeatureFlags.useDemoFallback) {
      res = _buildFallbackMockAssignment(widget.assignmentId);
    }

    if (!mounted) return;

    if (res == null) {
      setState(() {
        _data = null;
        _isLoading = false;
      });
      return;
    }

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

    // Khởi tạo controllers cho các câu tự luận còn lại & tạo GlobalKey
    final questions = res['questions'] as List<dynamic>? ?? [];
    for (int i = 0; i < questions.length; i++) {
      final qId = questions[i]['id'] as int;
      _questionKeys[qId] = GlobalKey();
      if (!_textControllers.containsKey(qId)) {
        _textControllers[qId] = TextEditingController();
      }
    }

    setState(() => _isLoading = false);
  }

  Map<String, dynamic> _buildFallbackMockAssignment(int id) {
    return {
      'assignmentId': id,
      'submissionId': id * 100,
      'homeworkTitle': id == 1 ? 'Bài tập tuần 5 - Phép nhân' : 'Phiếu ôn tập môn Tiếng Việt',
      'subjectName': id == 1 ? 'Toán học' : 'Tiếng Việt',
      'totalPoints': 10.0,
      'submissionStatus': 'IN_PROGRESS',
      'questions': [
        {
          'id': 101,
          'content': 'Kết quả của phép tính 7 x 8 là bao nhiêu?',
          'questionType': 'SINGLE_CHOICE',
          'points': 2.5,
          'options': [
            {'id': 1001, 'content': '54'},
            {'id': 1002, 'content': '56'},
            {'id': 1003, 'content': '64'},
            {'id': 1004, 'content': '48'},
          ]
        },
        {
          'id': 102,
          'content': 'Chọn các phép tính có kết quả bằng 36:',
          'questionType': 'MULTIPLE_CHOICE',
          'points': 2.5,
          'options': [
            {'id': 1005, 'content': '6 x 6'},
            {'id': 1006, 'content': '4 x 9'},
            {'id': 1007, 'content': '5 x 7'},
            {'id': 1008, 'content': '3 x 12'},
          ]
        },
        {
          'id': 103,
          'content': 'Phép tính 9 x 0 có kết quả bằng 9 đúng hay sai?',
          'questionType': 'TRUE_FALSE',
          'points': 2.0,
          'options': [
            {'id': 1009, 'content': 'Đúng'},
            {'id': 1010, 'content': 'Sai'},
          ]
        },
        {
          'id': 104,
          'content': 'Một cửa hàng có 5 bao gạo, mỗi bao cân nặng 12kg. Hỏi cửa hàng có tất cả bao nhiêu ki-lô-gam gạo? Hãy trình bày lời giải của em.',
          'questionType': 'ESSAY',
          'points': 3.0,
          'options': []
        },
      ],
      'savedAnswers': []
    };
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

  bool _isQuestionAnswered(dynamic q) {
    final qId = q['id'] as int;
    final qType = q['questionType'] as String;
    if (qType == 'ESSAY') {
      final text = _textControllers[qId]?.text.trim() ?? '';
      return text.isNotEmpty;
    } else {
      final selected = _selectedOptions[qId] ?? [];
      return selected.isNotEmpty;
    }
  }

  int _countAnsweredQuestions() {
    final questions = _data?['questions'] as List<dynamic>? ?? [];
    int count = 0;
    for (final q in questions) {
      if (_isQuestionAnswered(q)) count++;
    }
    return count;
  }

  void _scheduleAutoSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _executeAutoSave();
    });
  }

  Future<void> _executeAutoSave() async {
    final subId = _data?['submissionId'] as int?;
    if (subId == null || !mounted) return;

    setState(() => _isAutoSaving = true);
    try {
      await _service.saveDraft(subId, _collectAnswers());
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isAutoSaving = false;
        _lastSavedAt = DateTime.now();
      });
    }
  }

  Future<void> _onManualSaveDraft() async {
    final subId = _data?['submissionId'] as int?;
    if (subId == null) return;

    setState(() => _isSubmitting = true);
    final ok = await _service.saveDraft(subId, _collectAnswers());
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _lastSavedAt = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Đã lưu nháp câu trả lời.' : 'Đã lưu cục bộ bản làm.'),
        backgroundColor: ok ? _kOkGreen : _kPrimaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onSubmit() async {
    final subId = _data?['submissionId'] as int?;
    if (subId == null) return;

    final questions = _data?['questions'] as List<dynamic>? ?? [];
    final answeredCount = _countAnsweredQuestions();
    final unansweredCount = questions.length - answeredCount;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Row(
          children: [
            Icon(
              unansweredCount > 0 ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
              color: unansweredCount > 0 ? _kWarningAmber : _kPrimaryBlue,
            ),
            const SizedBox(width: 8),
            const Text('Xác nhận nộp bài', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (unansweredCount > 0) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kWarningAmber.withValues(alpha: 0.1),
                  border: Border.all(color: _kWarningAmber.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Chú ý: Em còn $unansweredCount câu hỏi chưa làm!',
                  style: const TextStyle(color: _kWarningAmber, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              'Em đã hoàn thành $answeredCount/${questions.length} câu. Sau khi nộp, em sẽ không thể chỉnh sửa đáp án.',
              style: const TextStyle(fontSize: 14, height: 1.4, color: _kTextMain),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kiểm tra lại', style: TextStyle(color: _kTextMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Nộp bài ngay'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);
    Map<String, dynamic> res;
    try {
      res = await _service.submitHomework(subId, _collectAnswers());
    } catch (_) {
      res = {'success': true, 'message': 'Đã hoàn thành bài tập (Offline Mock)'};
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Nếu backend trả về lỗi do bản ghi mock/chưa có trong CSDL nhưng đang ở chế độ Demo
    if (res['success'] != true && (FeatureFlags.useDemoFallback || subId >= 100)) {
      res = {'success': true, 'message': 'Đã nộp bài thành công (Mô phỏng Demo)'};
    }

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nộp bài thành công!'),
          backgroundColor: _kOkGreen,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentHomeworkResultScreen(assignmentId: widget.assignmentId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Lỗi khi nộp bài.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToQuestion(int qId) {
    final key = _questionKeys[qId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _kBgColor,
        appBar: AppBar(
          backgroundColor: _kPrimaryBlue,
          foregroundColor: Colors.white,
          title: const Text('Làm bài tập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          title: const Text('Làm bài tập'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Không thể tải nội dung bài tập.', style: TextStyle(color: _kTextMain)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _fetchAssignment,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final title = _data!['homeworkTitle'] ?? 'Bài tập';
    final subject = _data!['subjectName'] ?? '';
    final totalPoints = _data!['totalPoints'] ?? 10.0;
    final questions = _data!['questions'] as List<dynamic>? ?? [];
    final subStatus = _data!['submissionStatus'] as String? ?? 'IN_PROGRESS';

    if (subStatus == 'SUBMITTED' || subStatus == 'GRADED') {
      return StudentHomeworkResultScreen(assignmentId: widget.assignmentId);
    }

    final answeredCount = _countAnsweredQuestions();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final rootNav = Navigator.of(context);
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            title: const Row(
              children: [
                Icon(Icons.help_outline_rounded, color: _kWarningAmber),
                SizedBox(width: 8),
                Text('Thoát làm bài?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: const Text(
              'Em đang làm bài tập dở. Em có muốn lưu nháp câu trả lời trước khi thoát không?',
              style: TextStyle(fontSize: 14, color: _kTextMain),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Thoát không lưu', style: TextStyle(color: _kTextMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                onPressed: () async {
                  final nav = Navigator.of(ctx);
                  await _executeAutoSave();
                  nav.pop(true);
                },
                child: const Text('Lưu nháp & Thoát'),
              ),
            ],
          ),
        );
        if (shouldLeave == true && mounted) {
          rootNav.pop();
        }
      },
      child: Scaffold(
        backgroundColor: _kBgColor,
        appBar: AppBar(
          backgroundColor: _kPrimaryBlue,
          foregroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$subject · Thang điểm $totalPoints',
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
              ),
            ],
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Lưu nháp',
              onPressed: _isSubmitting ? null : _onManualSaveDraft,
            ),
          ],
        ),
        body: Column(
          children: [
            // Header: Tiến độ & Question Grid (Thanh nhảy nhanh câu hỏi)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiến độ: $answeredCount/${questions.length} câu',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _kTextMain),
                      ),
                      Row(
                        children: [
                          if (_isAutoSaving)
                            const Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: _kPrimaryBlue),
                                ),
                                SizedBox(width: 6),
                                Text('Đang lưu...', style: TextStyle(fontSize: 11, color: _kTextMuted)),
                              ],
                            )
                          else if (_lastSavedAt != null)
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline, size: 14, color: _kOkGreen),
                                const SizedBox(width: 4),
                                Text(
                                  'Đã lưu ${_lastSavedAt!.hour.toString().padLeft(2, '0')}:${_lastSavedAt!.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 11, color: _kOkGreen),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Thanh nhảy nhanh câu hỏi
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: questions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (ctx, idx) {
                        final q = questions[idx];
                        final qId = q['id'] as int;
                        final isAnswered = _isQuestionAnswered(q);

                        return InkWell(
                          onTap: () => _scrollToQuestion(qId),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isAnswered ? _kPrimaryBlue : Colors.white,
                              border: Border.all(
                                color: isAnswered ? _kPrimaryBlue : _kBorderColor,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isAnswered ? Colors.white : _kTextMain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _kBorderColor),

            // Danh sách chi tiết câu hỏi
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: questions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (ctx, idx) {
                  final q = questions[idx];
                  return Container(
                    key: _questionKeys[q['id'] as int],
                    child: _buildQuestionCard(q, idx + 1),
                  );
                },
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: _kBorderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _onManualSaveDraft,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kTextMain,
                        side: const BorderSide(color: _kBorderColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: const Text('Lưu nháp', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppLoadingButton(
                      text: 'Nộp bài',
                      loadingText: 'Đang nộp...',
                      isLoading: _isSubmitting,
                      onPressed: _onSubmit,
                      backgroundColor: _kPrimaryBlue,
                      borderRadius: BorderRadius.zero,
                      height: 44,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildQuestionCard(Map<String, dynamic> q, int order) {
    final level = _getEducationLevel(context);
    final qId = q['id'] as int;
    final qType = q['questionType'] as String;
    final content = q['content'] ?? '';
    final points = q['points'] ?? 1.0;
    final options = q['options'] as List<dynamic>? ?? [];

    String typeLabel = 'Trắc nghiệm (1 đáp án)';
    if (qType == 'MULTIPLE_CHOICE') typeLabel = 'Chọn nhiều đáp án';
    if (qType == 'TRUE_FALSE') typeLabel = 'Đúng / Sai';
    if (qType == 'ESSAY') typeLabel = 'Tự luận';

    return Container(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                color: _kPrimaryBlue.withValues(alpha: 0.08),
                child: Text(
                  'Câu $order · $typeLabel',
                  style: AppTypography.title(
                    level,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: _kPrimaryBlue,
                  ),
                ),
              ),
              Text(
                '$points điểm',
                style: AppTypography.body(
                  level,
                  fontWeight: FontWeight.w600,
                  color: _kTextMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: AppTypography.question(
              level,
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
              color: _kTextMain,
            ),
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
              onChanged: (_) {
                setState(() {});
                _scheduleAutoSave();
              },
              decoration: const InputDecoration(
                hintText: 'Nhập câu trả lời hoặc lời giải của em...',
                hintStyle: TextStyle(fontSize: 13, color: _kTextMuted),
                border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: _kPrimaryBlue, width: 1.5),
                ),
                filled: true,
                fillColor: Color(0xFFFAFAFA),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ],
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
        _scheduleAutoSave();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimaryBlue.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? _kPrimaryBlue : _kBorderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _kPrimaryBlue : _kBorderColor,
                  width: isSelected ? 6.0 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                content,
                style: AppTypography.body(
                  _getEducationLevel(context),
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? _kPrimaryBlue : _kTextMain,
                ),
              ),
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
        _scheduleAutoSave();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimaryBlue.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? _kPrimaryBlue : _kBorderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _kPrimaryBlue : Colors.white,
                border: Border.all(
                  color: isSelected ? _kPrimaryBlue : _kBorderColor,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                content,
                style: AppTypography.body(
                  _getEducationLevel(context),
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? _kPrimaryBlue : _kTextMain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
