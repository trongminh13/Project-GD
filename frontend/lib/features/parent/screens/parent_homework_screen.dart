import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/homework_service.dart';

class ParentHomeworkScreen extends StatefulWidget {
  final int? studentId;
  const ParentHomeworkScreen({super.key, this.studentId});

  @override
  State<ParentHomeworkScreen> createState() => _ParentHomeworkScreenState();
}

class _ParentHomeworkScreenState extends State<ParentHomeworkScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = HomeworkService();

  bool _isLoading = true;
  int? _resolvedStudentId;
  List<dynamic> _assignments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolvedStudentId == null) {
      final argId = ModalRoute.of(context)?.settings.arguments;
      _resolvedStudentId = widget.studentId ?? (argId is int ? argId : int.tryParse(argId?.toString() ?? '51')) ?? 51;
      _loadHomework();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHomework() async {
    if (_resolvedStudentId == null) return;
    setState(() => _isLoading = true);
    final list = await _service.getWardHomework(_resolvedStudentId!);
    if (!mounted) return;
    setState(() {
      _assignments = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabGradientColors = isDark
        ? [const Color(0xFF5C6BC0), const Color(0xFF3949AB)]
        : [const Color(0xFF1A237E), const Color(0xFF0D1454)];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bài tập của con',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondaryOf(context),
              indicator: BoxDecoration(
                gradient: LinearGradient(colors: tabGradientColors),
                borderRadius: BorderRadius.circular(26),
              ),
              tabs: const [
                Tab(text: 'Chưa nộp / Đang làm'),
                Tab(text: 'Đã nộp / Đã có điểm'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHomework,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAssignmentList(filterCompleted: false),
                  _buildAssignmentList(filterCompleted: true),
                ],
              ),
            ),
    );
  }

  Widget _buildAssignmentList({required bool filterCompleted}) {
    final filteredList = _assignments.where((a) {
      final status = (a['submissionStatus'] ?? 'NOT_STARTED').toString();
      final isFinished = (status == 'SUBMITTED' || status == 'GRADED');
      return filterCompleted ? isFinished : !isFinished;
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceAltOf(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_turned_in_rounded,
                size: 60,
                color: AppColors.textTertiaryOf(context),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              filterCompleted ? "Chưa có bài tập nào đã nộp" : "Không có bài tập nào cần làm",
              style: TextStyle(
                color: AppColors.textTertiaryOf(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: filteredList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final task = filteredList[index] as Map<String, dynamic>;
        final title = task['title'] ?? 'Bài tập';
        final subject = task['subjectName'] ?? 'Toán';
        final desc = task['description'] ?? '';
        final teacher = task['teacherName'] ?? '';
        final dueDate = (task['dueDate'] ?? '').toString().split('T').first;
        final status = (task['submissionStatus'] ?? 'NOT_STARTED').toString();
        final finalScore = task['finalScore'];
        final autoScore = task['autoScore'];
        final feedback = task['teacherFeedback'] as String?;

        Color statusColor = Colors.orange;
        String statusLabel = 'Chưa làm';
        if (status == 'IN_PROGRESS') {
          statusColor = Colors.blue;
          statusLabel = 'Đang làm dở';
        } else if (status == 'SUBMITTED') {
          statusColor = Colors.purple;
          statusLabel = 'Đã nộp (Chờ chấm)';
        } else if (status == 'GRADED') {
          statusColor = Colors.green;
          statusLabel = 'Đạt: ${finalScore ?? autoScore} đ';
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      subject,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              if (desc.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 13, height: 1.4),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('GV: $teacher', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const Spacer(),
                  Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('Hạn nộp: $dueDate', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              if (feedback != null && feedback.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 16, color: Colors.orange),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Lời phê của thầy/cô: $feedback',
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
