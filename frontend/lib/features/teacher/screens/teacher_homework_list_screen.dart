import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/homework_service.dart';
import 'package:ashadeep/features/teacher/screens/teacher_create_homework_screen.dart';
import 'package:ashadeep/features/teacher/screens/teacher_grade_submission_screen.dart';

class TeacherHomeworkListScreen extends StatefulWidget {
  const TeacherHomeworkListScreen({super.key});

  @override
  State<TeacherHomeworkListScreen> createState() => _TeacherHomeworkListScreenState();
}

class _TeacherHomeworkListScreenState extends State<TeacherHomeworkListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = HomeworkService();

  bool _isLoading = true;
  List<dynamic> _homeworkList = [];
  List<dynamic> _assignmentsList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final hw = await _service.getTeacherHomework();
    final asg = await _service.getTeacherAssignments();
    if (!mounted) return;
    setState(() {
      _homeworkList = hw;
      _assignmentsList = asg;
      _isLoading = false;
    });
  }

  void _showAssignDialog(Map<String, dynamic> hw) {
    int selectedClassId = 45; // Mặc định Lớp 3A
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Giao bài: ${hw['title']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: selectedClassId,
                decoration: const InputDecoration(labelText: 'Lớp nhận bài', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 45, child: Text('Lớp 3A')),
                  DropdownMenuItem(value: 46, child: Text('Lớp 1B')),
                ],
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedClassId = v);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hạn nộp bài', style: TextStyle(fontSize: 14)),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                Navigator.pop(ctx);
                final res = await _service.assignHomework(
                  homeworkId: hw['id'] as int,
                  classId: selectedClassId,
                  dueDate: selectedDate.toIso8601String(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res['success'] == true ? 'Đã giao bài cho lớp thành công!' : res['message'] ?? 'Lỗi khi giao bài.'),
                      backgroundColor: res['success'] == true ? AppColors.success : AppColors.error,
                    ),
                  );
                  _loadData();
                }
              },
              child: const Text('Giao ngay', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmissionsSheet(Map<String, dynamic> asg) async {
    final assignmentId = asg['id'] as int;
    final hw = asg['homework'] as Map<String, dynamic>? ?? {};
    final sc = asg['schoolClass'] as Map<String, dynamic>? ?? {};
    final className = '${sc['grade'] ?? ''} ${sc['section'] ?? ''}'.trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return FutureBuilder<List<dynamic>>(
          future: _service.getAssignmentSubmissions(assignmentId),
          builder: (ctx, snapshot) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Bài làm Lớp $className: ${hw['title']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else if (!snapshot.hasData || snapshot.data!.isEmpty)
                    const Expanded(child: Center(child: Text('Chưa có học sinh nào nộp bài.')))
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (ctx, idx) {
                          final sub = snapshot.data![idx] as Map<String, dynamic>;
                          final subId = sub['id'] as int;
                          final student = sub['student'] as Map<String, dynamic>? ?? {};
                          final studentName = student['name'] ?? 'Học sinh';
                          final status = sub['status'] ?? 'IN_PROGRESS';
                          final autoScore = sub['autoScore'] ?? 0.0;
                          final finalScore = sub['finalScore'];

                          Color sColor = Colors.orange;
                          String sText = 'Đang làm';
                          if (status == 'SUBMITTED') {
                            sColor = Colors.purple;
                            sText = 'Đã nộp (Chờ chấm)';
                          } else if (status == 'GRADED') {
                            sColor = Colors.green;
                            sText = 'Đã chấm: $finalScore đ';
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: sColor.withValues(alpha: 0.15),
                              child: Icon(Icons.person, color: sColor),
                            ),
                            title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Điểm tự chấm: $autoScore đ'),
                            trailing: Chip(
                              label: Text(sText, style: TextStyle(color: sColor, fontSize: 11, fontWeight: FontWeight.bold)),
                              backgroundColor: sColor.withValues(alpha: 0.1),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TeacherGradeSubmissionScreen(submissionId: subId),
                                ),
                              ).then((_) => _loadData());
                            },
                          );
                        },
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Bài tập & LMS'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.library_books), text: 'Kho Bài Tập'),
            Tab(icon: Icon(Icons.assignment_turned_in), text: 'Lớp Đã Giao'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHomeworkTab(),
                _buildAssignmentsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeacherCreateHomeworkScreen()),
          ).then((_) => _loadData());
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Soạn bài mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHomeworkTab() {
    if (_homeworkList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Chưa có bài tập nào được soạn.', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _homeworkList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final hw = _homeworkList[index] as Map<String, dynamic>;
        final title = hw['title'] ?? 'Bài tập';
        final subject = hw['subject']?['name'] ?? '';
        final totalPoints = hw['totalPoints'] ?? 10.0;
        final questions = hw['questions'] as List<dynamic>? ?? [];

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                        subject,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Text('$totalPoints điểm', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${questions.length} câu hỏi', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Giao bài cho Lớp'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showAssignDialog(hw),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignmentsTab() {
    if (_assignmentsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Chưa có bài tập nào được giao cho lớp.', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _assignmentsList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final asg = _assignmentsList[index] as Map<String, dynamic>;
        final hw = asg['homework'] as Map<String, dynamic>? ?? {};
        final sc = asg['schoolClass'] as Map<String, dynamic>? ?? {};
        final className = '${sc['grade'] ?? ''} ${sc['section'] ?? ''}'.trim();
        final dueDate = (asg['dueDate'] ?? '').toString().split('T').first;

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(hw['title'] ?? 'Bài tập', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Lớp nhận: Lớp $className', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                Text('Hạn nộp: $dueDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.people_alt, size: 16),
              label: const Text('Xem bài nộp'),
              onPressed: () => _showSubmissionsSheet(asg),
            ),
          ),
        );
      },
    );
  }
}
