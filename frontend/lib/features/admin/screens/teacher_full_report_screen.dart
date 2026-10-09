import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';

class TeacherFullReportScreen extends StatelessWidget {
  final String teacherId;
  final String name;

  const TeacherFullReportScreen({
    super.key,
    required this.teacherId,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: Text('Report: $name'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Professional Profile'),
            _buildInfoCard(context, [
              {'label': 'Designation', 'value': 'Senior Mathematics Teacher'},
              {'label': 'Joining Date', 'value': '12 Aug 2020 (5 Years)'},
              {'label': 'Qualification', 'value': 'M.Sc Mathematics, B.Ed'},
              {'label': 'Contact', 'value': '+91 9876543210'},
            ]),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Attendance Summary (2025)'),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Total Working', '120', AppColors.primaryOf(context)),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Present', '110', AppColors.success)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Leaves Taken', '10', AppColors.warning),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Recent Leave History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLeaveHistoryItem(context, '10 Feb 2025', 'Sick Leave', 'Approved'),
            _buildLeaveHistoryItem(context, '05 Jan 2025', 'Casual Leave', 'Approved'),
            _buildLeaveHistoryItem(context, '20 Dec 2024', 'Emergency', 'Approved'),

            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Performance & Credentials'),
            _buildInfoCard(context, [
              {
                'label': 'Subject Average',
                'value': 'Mathematics: 88% (Class 10)',
              },
              {'label': 'Class Teacher', 'value': '10-A'},
              {'label': 'Last Review', 'value': 'Excellent (Dec 2024)'},
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: AppTextStyles.heading2(context)),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Map<String, String>> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: data.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['label']!,
                  style: TextStyle(color: AppColors.textSecondaryOf(context)),
                ),
                Text(
                  item['value']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveHistoryItem(BuildContext context, String date, String type, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                type,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Approved',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
