import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/features/admin/screens/teacher_detail_screen.dart';

class TeacherAttendanceReportScreen extends StatelessWidget {
  const TeacherAttendanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for Reporting
    final List<Map<String, dynamic>> teacherStats = [];

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: const Text('Teacher Attendance Records'),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teacherStats.length,
        itemBuilder: (context, index) {
          final stat = teacherStats[index];
          final rating = int.parse(
            stat['rating'].toString().replaceAll('%', ''),
          );
          Color statusColor = rating > 90
              ? AppColors.success
              : (rating > 75 ? AppColors.warning : AppColors.error);

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: () {
                // Navigate to Full Report
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeacherDetailScreen(
                      teacherId: stat['id'],
                      name: stat['name'],
                    ),
                  ),
                );
              },
              leading: CircleAvatar(
                backgroundColor: statusColor.withOpacity(0.1),
                child: Text(
                  stat['rating'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              title: Text(
                stat['name'],
                style: AppTextStyles.heading2(context).copyWith(fontSize: 16),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatPill('Present: ${stat['present']}', AppColors.success),
                    _buildStatPill('Absent: ${stat['absent']}', AppColors.error),
                    _buildStatPill('Leaves: ${stat['leaves']}', AppColors.primaryOf(context)),
                  ],
                ),
              ),
              trailing: Icon(Icons.bar_chart, color: AppColors.textTertiaryOf(context)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
