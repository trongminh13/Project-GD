import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';

class ParentHomeworkScreen extends StatefulWidget {
  const ParentHomeworkScreen({super.key});

  @override
  State<ParentHomeworkScreen> createState() => _ParentHomeworkScreenState();
}

class _ParentHomeworkScreenState extends State<ParentHomeworkScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock Data
  final List<Map<String, dynamic>> _assignments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Assignments',
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
                gradient: LinearGradient(
                  colors: tabGradientColors,
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAssignmentList(filterStatus: 'Pending'),
          _buildAssignmentList(filterStatus: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildAssignmentList({required String filterStatus}) {
    final filteredList = _assignments
        .where((a) => a['status'] == filterStatus)
        .toList();

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
              "No $filterStatus Assignments",
              style: TextStyle(
                color: AppColors.textTertiaryOf(context),
                fontSize: 18,
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
        final task = filteredList[index];
        final isPending = filterStatus == 'Pending';

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getSubjectColor(task['subject']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      task['subject'],
                      style: TextStyle(
                        color: _getSubjectColor(task['subject']),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: isPending
                            ? AppColors.error
                            : AppColors.textTertiaryOf(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${task['dueDate']}",
                        style: TextStyle(
                          color: isPending
                              ? AppColors.error
                              : AppColors.textTertiaryOf(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                task['description'],
                style: TextStyle(
                  color: AppColors.textSecondaryOf(context),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (isPending) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOf(context),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Mark as Done"),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getSubjectColor(String subject) {
    if (subject == 'Mathematics') return AppColors.primary;
    if (subject == 'Science') return AppColors.success;
    if (subject == 'English') return AppColors.warning;
    if (subject == 'History') return Colors.brown;
    if (subject == 'Computer') return Colors.purple;
    return Colors.grey;
  }
}
