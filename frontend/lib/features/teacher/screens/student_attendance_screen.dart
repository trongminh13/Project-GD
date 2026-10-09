import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/models/student.dart';
import 'package:intl/intl.dart';
import 'package:ashadeep/core/services/student_service.dart';
import 'package:ashadeep/core/services/attendance_service.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  // Use StudentService to fetch students dynamically
  List<Student> _students = [];

  // Map to track attendance status: true = Present, false = Absent
  final Map<String, bool> _attendance = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    // Mock: Teacher is Class Teacher of 10
    final fetchedStudents = await StudentService().getStudentsByClass('10');
    if (mounted) {
      setState(() {
        _students = fetchedStudents; // Use fetchedStudents
        for (var student in _students) {
          // Default all to Present
          _attendance[student.id] = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Class 10-A Attendance',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              today,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _students.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final student = _students[index];
                final isPresent = _attendance[student.id] ?? true;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPresent
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    child: Text(
                      student.admissionNumber,
                      style: TextStyle(
                        color: isPresent ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    student.admissionNumber,
                    style: AppTextStyles.body(context).copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isPresent
                              ? AppColors.success
                              : AppColors.surfaceAltOf(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _attendance[student.id] = true;
                            });
                          },
                          child: Text(
                            'P',
                            style: TextStyle(
                              color: isPresent ? Colors.white : AppColors.textPrimaryOf(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: !isPresent ? AppColors.error : AppColors.surfaceAltOf(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _attendance[student.id] = false;
                            });
                          },
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: !isPresent ? Colors.white : AppColors.textPrimaryOf(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOf(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  // Save attendance and send SMS notifications via backend
                  bool success = await AttendanceService()
                      .submitClassAttendance(
                        '10',
                        DateTime.now().toIso8601String(),
                        _attendance,
                      );

                  if (!mounted) return;

                  if (success) {
                    int absentCount = _attendance.values
                        .where((v) => v == false)
                        .length;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Attendance Submitted. $absentCount Absent SMS sent.',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to submit attendance to server.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Submit & Notify Parents',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
