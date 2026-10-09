import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:ashadeep/core/services/teacher_service.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  final _teacherService = TeacherService();
  final String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Local state to track changes on this screen before "Saving" (optional, allows batch save)
  // Or current implementing instant save for simplicity.

  final List<Map<String, dynamic>> _teachers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: const Text('Mark Teacher Attendance'),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Attendance Saved Successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                  style: AppTextStyles.heading2(context).copyWith(fontSize: 16),
                ),
                Chip(
                  label: Text('Total: ${_teachers.length}'),
                  backgroundColor: AppColors.primaryOf(context),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _teachers.length,
              itemBuilder: (context, index) {
                final teacher = _teachers[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      4.0,
                    ), // Reduced padding for compact look
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryOf(context).withOpacity(0.1),
                        child: Text(
                          teacher['name'][0],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOf(context),
                          ),
                        ),
                      ),
                      title: Text(
                        teacher['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('ID: ${teacher['id']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusButton(teacher, 'Present', AppColors.success),
                          const SizedBox(width: 8),
                          _buildStatusButton(teacher, 'Absent', AppColors.error),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    Map<String, dynamic> teacher,
    String status,
    Color color,
  ) {
    bool isSelected = teacher['status'] == status;
    return InkWell(
      onTap: () {
        setState(() {
          teacher['status'] = status;
          // Update Service Immediately
          _teacherService.markAttendance(teacher['id'], _currentDate, status);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.borderOf(context)),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondaryOf(context),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
