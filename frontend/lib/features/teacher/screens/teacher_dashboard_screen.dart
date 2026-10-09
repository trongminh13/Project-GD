import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/widgets/fade_in_list_item.dart';
import 'package:ashadeep/features/teacher/screens/student_attendance_screen.dart';
import 'package:ashadeep/features/teacher/screens/upload_marks_screen.dart';
import 'package:ashadeep/features/teacher/screens/timetable_screen.dart';
import 'package:ashadeep/screens/profile_screen.dart'; // Import ProfileScreen
import 'package:ashadeep/screens/login_screen.dart';
import 'package:ashadeep/core/services/school_class_service.dart';
import 'package:ashadeep/models/school_class.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;

  const TeacherDashboardScreen({
    super.key,
    this.teacherId = 'T001', // Default for dev
    this.teacherName = 'Amit Verma', // Default for dev
  });

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  SchoolClass? _assignedClass;
  List<String> _assignedSubjects = [];
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  void _loadTeacherData() {
    // 1. Find Class Teacher Assignment
    _assignedClass = ClassService().getClassByClassTeacherId(widget.teacherId);

    // 2. Find Subject Assignments (Aggregated)
    final schedule = ClassService().getTeacherSchedule(widget.teacherName);
    final subjectSet = <String>{};
    for (var slot in schedule) {
      subjectSet.add('${slot['subject']} (${slot['class']})');
    }
    _assignedSubjects = subjectSet.toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [const Color(0xFF5C6BC0), const Color(0xFF3949AB)]
        : [const Color(0xFF1A237E), const Color(0xFF0D1454)];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        final now = DateTime.now();
        final maxDuration = const Duration(seconds: 2);
        final isWarning =
            _lastPressedAt == null ||
            now.difference(_lastPressedAt!) > maxDuration;

        if (isWarning) {
          _lastPressedAt = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          const platform = MethodChannel('com.school.backend/appRetain');
          try {
            platform.invokeMethod('sendToBackground');
          } catch (e) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teacher Dashboard'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile & Info Card
              FadeInListItem(
                index: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOf(context).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white24,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.teacherName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'ID: ${widget.teacherId}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 10),
                      // Class Teacher Badge
                      if (_assignedClass != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Class Teacher of: ',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Class ${_assignedClass!.grade}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'Not Assigned as Class Teacher',
                          style: TextStyle(color: Colors.white70),
                        ),

                      const SizedBox(height: 10),
                      // Subjects List
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.book,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Assigned Subjects:',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 4),
                                if (_assignedSubjects.isEmpty)
                                  const Text(
                                    'No active classes found',
                                    style: TextStyle(color: Colors.white),
                                  )
                                else
                                  ..._assignedSubjects.map(
                                    (s) => Text(
                                      s,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInListItem(
                index: 1,
                child: Text('Quick Actions', style: AppTextStyles.heading2(context)),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  FadeInListItem(
                    index: 2,
                    child: _buildActionCard(
                      context,
                      'Attendance',
                      Icons.how_to_reg,
                      AppColors.primaryOf(context),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const StudentAttendanceScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  FadeInListItem(
                    index: 3,
                    child: _buildActionCard(
                      context,
                      'Upload Marks',
                      Icons.grade,
                      AppColors.success,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const UploadMarksScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  FadeInListItem(
                    index: 4,
                    child: _buildActionCard(
                      context,
                      'View Timetable',
                      Icons.schedule,
                      AppColors.primaryOf(context),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TimetableScreen(
                              teacherName: widget.teacherName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  FadeInListItem(
                    index: 5,
                    child: _buildActionCard(
                      context,
                      'My Profile',
                      Icons.person,
                      AppColors.primaryOf(context),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.heading2(context).copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
