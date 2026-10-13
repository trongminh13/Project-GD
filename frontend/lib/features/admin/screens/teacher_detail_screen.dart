import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/features/admin/screens/teacher_full_report_screen.dart';

class TeacherDetailScreen extends StatelessWidget {
  final String teacherId;
  final String name;

  const TeacherDetailScreen({super.key, required this.teacherId, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: Text(name),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Message Dialog...')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.secondaryOf(context).withValues(alpha: 0.1),
                    child: Icon(Icons.person, size: 40, color: AppColors.secondaryOf(context)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.heading2(context)),
                      Text('ID: $teacherId • Senior Teacher', style: AppTextStyles.body(context)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning, padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.notifications_active, color: Colors.white),
                    label: const Text('Send Reminder', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      _showReminderDialog(context);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    icon: const Icon(Icons.history),
                    label: const Text('Full Report'),
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherFullReportScreen(teacherId: teacherId, name: name)));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text('Attendance History (Last 30 Days)', style: AppTextStyles.heading2(context).copyWith(fontSize: 18)),
            const SizedBox(height: 16),

            // Attendance List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                // Mock History
                final date = DateTime.now().subtract(Duration(days: index * 2)); // Every alternate day
                final status = index == 2 ? 'Absent' : (index == 4 ? 'Leave' : 'Present');
                final color = status == 'Present' ? AppColors.success : (status == 'Absent' ? AppColors.error : AppColors.warning);

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.circle, size: 12, color: color),
                    title: Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Reminder/Notice'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g. Please submit marks by 5PM',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notice sent to $name!')));
              Navigator.pop(context);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
