import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/features/admin/screens/audit_log_screen.dart';
import 'package:ashadeep/features/admin/screens/teacher_attendance_report_screen.dart';
import 'package:ashadeep/features/admin/screens/student_performance_screen.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportCard(
            context,
            'Teacher Attendance Report',
            'View detailed leave history, absence records, and monthly stats for all staff.',
            Icons.calendar_today,
            AppColors.warning,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherAttendanceReportScreen())),
          ),
          _buildReportCard(
            context,
            'System Audit Logs',
            'Track all manual fee overrides, system actions, and security events.',
            Icons.security,
            AppColors.primaryOf(context),
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditLogScreen())),
          ),
          _buildReportCard(
            context,
            'Student Performance Analytics',
            'Visual insights into class results, identifying toppers and weak areas.',
            Icons.pie_chart,
            AppColors.success,
            () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentPerformanceScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.heading2(context).copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.body(context).copyWith(fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiaryOf(context)),
            ],
          ),
        ),
      ),
    );
  }
}
