import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:ashadeep/features/admin/screens/teacher_attendance_screen.dart';
import 'package:ashadeep/features/admin/screens/student_list_screen.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Audit Data
    final List<Map<String, String>> logs = [];

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: const Text('Admin Audit Logs'),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final date = DateTime.parse(log['timestamp']!);
          final isSystem = log['admin'] == 'SYSTEM';

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: () {
                // Determine navigation based on log type
                if (log['type'] == 'Attendance') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TeacherAttendanceScreen(),
                    ),
                  );
                } else if (log['action']!.contains('Fee')) {
                  // In a real app, nav to specific transaction. Here, open Student List.
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StudentListScreen(),
                    ),
                  );
                }
              },
              leading: CircleAvatar(
                backgroundColor: isSystem
                    ? AppColors.warning.withValues(alpha: 0.1)
                    : AppColors.primaryOf(context).withValues(alpha: 0.1),
                child: Icon(
                  isSystem ? Icons.settings : Icons.security,
                  color: isSystem ? AppColors.warning : AppColors.primaryOf(context),
                ),
              ),
              title: Text(
                log['action']!,
                style: AppTextStyles.heading2(context).copyWith(fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(log['details']!, style: AppTextStyles.body(context)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 12, color: AppColors.textTertiaryOf(context)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${log['admin']} • ${DateFormat('hh:mm a, dd MMM').format(date)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiaryOf(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Chip(
                label: Text(
                  log['type']!,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
                backgroundColor: isSystem ? AppColors.warning : AppColors.primaryOf(context),
                padding: EdgeInsets.zero,
              ),
            ),
          );
        },
      ),
    );
  }
}
