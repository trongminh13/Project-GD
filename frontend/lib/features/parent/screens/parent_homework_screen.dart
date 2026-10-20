import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/homework_service.dart';
import 'package:ashadeep/core/widgets/homework_card.dart';
import 'package:ashadeep/core/widgets/app_empty_card.dart';
import 'package:ashadeep/core/config/feature_flags.dart';

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
    if (ApiConstants.isDemoMode || FeatureFlags.useDemoFallback) {
      if (mounted) {
        setState(() {
          _assignments = [];
          _isLoading = false;
        });
      }
      return;
    }
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AppEmptyCard(
            icon: Icons.assignment_turned_in_rounded,
            title: filterCompleted
                ? 'Chưa có bài tập nào đã nộp'
                : 'Không có bài tập nào cần làm',
            message: filterCompleted
                ? 'Con chưa hoàn thành hoặc chưa nộp bài tập nào.'
                : 'Hiện tại con không có bài tập nào cần làm.',
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: filteredList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = filteredList[index] as Map<String, dynamic>;
        final feedback = task['teacherFeedback'] as String?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeworkCard(
              data: task,
              mode: HomeworkCardMode.parentView,
            ),
            if (feedback != null && feedback.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
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
        );
      },
    );
  }
}
