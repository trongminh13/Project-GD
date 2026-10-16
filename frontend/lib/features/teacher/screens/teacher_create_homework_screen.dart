import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/homework_service.dart';

class TeacherCreateHomeworkScreen extends StatefulWidget {
  const TeacherCreateHomeworkScreen({super.key});

  @override
  State<TeacherCreateHomeworkScreen> createState() => _TeacherCreateHomeworkScreenState();
}

class _TeacherCreateHomeworkScreenState extends State<TeacherCreateHomeworkScreen> {
  final _service = HomeworkService();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _selectedSubjectId = 3; // Mặc định Toán (id=3)
  bool _isSaving = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'questionType': 'SINGLE_CHOICE',
      'content': TextEditingController(text: 'Phép tính 5 + 5 bằng bao nhiêu?'),
      'points': TextEditingController(text: '1.0'),
      'explanation': TextEditingController(text: '5 + 5 = 10'),
      'options': [
        {'content': TextEditingController(text: '8'), 'isCorrect': false},
        {'content': TextEditingController(text: '10'), 'isCorrect': true},
        {'content': TextEditingController(text: '12'), 'isCorrect': false},
      ],
    },
    {
      'questionType': 'ESSAY',
      'content': TextEditingController(text: 'Nêu ý nghĩa của việc chăm chỉ học tập hàng ngày.'),
      'points': TextEditingController(text: '9.0'),
      'explanation': TextEditingController(text: ''),
      'options': <Map<String, dynamic>>[],
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final q in _questions) {
      (q['content'] as TextEditingController).dispose();
      (q['points'] as TextEditingController).dispose();
      (q['explanation'] as TextEditingController).dispose();
      for (final opt in (q['options'] as List<dynamic>)) {
        (opt['content'] as TextEditingController).dispose();
      }
    }
    super.dispose();
  }

  void _addQuestion(String type) {
    setState(() {
      if (type == 'SINGLE_CHOICE') {
        _questions.add({
          'questionType': 'SINGLE_CHOICE',
          'content': TextEditingController(),
          'points': TextEditingController(text: '1.0'),
          'explanation': TextEditingController(),
          'options': [
            {'content': TextEditingController(text: 'Lựa chọn A'), 'isCorrect': true},
            {'content': TextEditingController(text: 'Lựa chọn B'), 'isCorrect': false},
          ],
        });
      } else if (type == 'TRUE_FALSE') {
        _questions.add({
          'questionType': 'TRUE_FALSE',
          'content': TextEditingController(),
          'points': TextEditingController(text: '1.0'),
          'explanation': TextEditingController(),
          'options': [
            {'content': TextEditingController(text: 'Đúng'), 'isCorrect': true},
            {'content': TextEditingController(text: 'Sai'), 'isCorrect': false},
          ],
        });
      } else {
        _questions.add({
          'questionType': 'ESSAY',
          'content': TextEditingController(),
          'points': TextEditingController(text: '5.0'),
          'explanation': TextEditingController(),
          'options': <Map<String, dynamic>>[],
        });
      }
    });
  }

  Future<void> _saveHomework() async {
    if (!_formKey.currentState!.validate()) return;

    final List<Map<String, dynamic>> questionsPayload = [];
    int order = 1;
    for (final q in _questions) {
      final qType = q['questionType'] as String;
      final content = (q['content'] as TextEditingController).text.trim();
      final points = double.tryParse((q['points'] as TextEditingController).text.trim()) ?? 1.0;
      final explanation = (q['explanation'] as TextEditingController).text.trim();

      final List<Map<String, dynamic>> optionsPayload = [];
      int optOrder = 1;
      for (final opt in (q['options'] as List<dynamic>)) {
        optionsPayload.add({
          'optionOrder': optOrder++,
          'content': (opt['content'] as TextEditingController).text.trim(),
          'isCorrect': opt['isCorrect'] == true,
        });
      }

      questionsPayload.add({
        'questionOrder': order++,
        'questionType': qType,
        'content': content,
        'points': points,
        'explanation': explanation.isNotEmpty ? explanation : null,
        'options': optionsPayload,
      });
    }

    setState(() => _isSaving = true);
    final res = await _service.createHomework({
      'subjectId': _selectedSubjectId,
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'totalPoints': 10.0,
      'questions': questionsPayload,
    });
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo bài tập thành công!'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Lỗi khi tạo bài tập.'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soạn bài tập mới'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Thông tin cơ bản
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thông tin bài tập', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề bài tập *',
                        hintText: 'VD: Bài tập cuối tuần 9',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedSubjectId,
                      decoration: const InputDecoration(labelText: 'Môn học', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 3, child: Text('Môn Toán')),
                        DropdownMenuItem(value: 5, child: Text('Môn Tiếng Việt')),
                        DropdownMenuItem(value: 6, child: Text('Môn Tiếng Anh')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSubjectId = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả / Hướng dẫn làm bài',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Danh sách câu hỏi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách câu hỏi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                PopupMenuButton<String>(
                  onSelected: _addQuestion,
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(value: 'SINGLE_CHOICE', child: Text('+ Thêm Trắc nghiệm (1 đáp án)')),
                    PopupMenuItem(value: 'TRUE_FALSE', child: Text('+ Thêm Đúng / Sai')),
                    PopupMenuItem(value: 'ESSAY', child: Text('+ Thêm Tự luận')),
                  ],
                  child: ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Thêm câu hỏi'),
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: AppColors.primary,
                      disabledForegroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            for (int i = 0; i < _questions.length; i++) _buildQuestionEditor(i),
            const SizedBox(height: 24),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveHomework,
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_rounded),
                label: const Text('Lưu & Hoàn tất soạn bài', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionEditor(int index) {
    final q = _questions[index];
    final qType = q['questionType'] as String;
    final options = q['options'] as List<dynamic>;

    String typeName = 'Trắc nghiệm';
    if (qType == 'TRUE_FALSE') typeName = 'Đúng / Sai';
    if (qType == 'ESSAY') typeName = 'Tự luận';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Câu ${index + 1} ($typeName)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      _questions.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: q['content'] as TextEditingController,
              decoration: const InputDecoration(labelText: 'Nội dung câu hỏi *', border: OutlineInputBorder(), isDense: true),
              validator: (v) => v == null || v.trim().isEmpty ? 'Nhập nội dung câu hỏi' : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    controller: q['points'] as TextEditingController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Điểm số', border: OutlineInputBorder(), isDense: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: q['explanation'] as TextEditingController,
                    decoration: const InputDecoration(labelText: 'Lời giải thích (tùy chọn)', border: OutlineInputBorder(), isDense: true),
                  ),
                ),
              ],
            ),
            if (qType != 'ESSAY') ...[
              const SizedBox(height: 12),
              const Text('Các lựa chọn đáp án (Chọn hình tròn để đánh dấu đáp án đúng):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              for (int oIdx = 0; oIdx < options.length; oIdx++) ...[
                Row(
                  children: [
                    Radio<int>(
                      value: oIdx,
                      groupValue: options.indexWhere((e) => e['isCorrect'] == true),
                      onChanged: (val) {
                        setState(() {
                          for (int k = 0; k < options.length; k++) {
                            options[k]['isCorrect'] = (k == val);
                          }
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: options[oIdx]['content'] as TextEditingController,
                        decoration: InputDecoration(
                          hintText: 'Nội dung lựa chọn ${String.fromCharCode(65 + oIdx)}',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    if (options.length > 2)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
                        onPressed: () {
                          setState(() {
                            options.removeAt(oIdx);
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
