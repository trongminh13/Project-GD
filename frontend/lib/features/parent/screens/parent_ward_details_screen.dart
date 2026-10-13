import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/widgets/fade_in_list_item.dart';
import 'package:ashadeep/features/parent/screens/parent_attendance_screen.dart';
import 'package:ashadeep/features/parent/screens/parent_fees_screen.dart';
import 'package:ashadeep/features/parent/screens/parent_marks_screen.dart';
import 'package:ashadeep/features/parent/screens/parent_timetable_screen.dart';
import 'package:ashadeep/features/parent/screens/parent_homework_screen.dart';
import 'package:ashadeep/screens/login_screen.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class ParentWardDetailsScreen extends StatelessWidget {
  final dynamic ward;

  const ParentWardDetailsScreen({super.key, required this.ward});

  @override
  Widget build(BuildContext context) {
    final String wardName = ward['name'] ?? 'Unknown Student';
    final classStr = ward['schoolClass'] != null
        ? "${ward['schoolClass']['grade']}"
        : "N/A";
    final String admissionNumber = ward['admissionNumber'] ?? 'N/A';
    final int wardId = ward['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          wardName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryOf(context),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Title Card
            FadeInListItem(
              index: 0,
              child: _buildWardProfileCard(
                context,
                wardName,
                classStr,
                admissionNumber,
              ),
            ),
            const SizedBox(height: 32),

            // Quick Actions Label
            FadeInListItem(
              index: 1,
              child: Text(
                "Quick Actions",
                style: AppTextStyles.heading2(context),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Actions Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                FadeInListItem(
                  index: 2,
                  child: _buildActionCard(
                    context,
                    "Attendance",
                    "Check Log",
                    Icons.calendar_month_rounded,
                    const Color(0xFF4FACFE),
                    const Color(0xFF00F2FE),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentAttendanceScreen(),
                        settings: RouteSettings(arguments: wardId),
                      ),
                    ),
                  ),
                ),
                FadeInListItem(
                  index: 3,
                  child: _buildActionCard(
                    context,
                    "Performance",
                    "View Marks",
                    Icons.bar_chart_rounded,
                    const Color(0xFF43E97B),
                    const Color(0xFF38F9D7),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentMarksScreen(),
                        settings: RouteSettings(arguments: wardId),
                      ),
                    ),
                  ),
                ),
                FadeInListItem(
                  index: 4,
                  child: _buildActionCard(
                    context,
                    "Fees",
                    "Pay Now",
                    Icons.payment_rounded,
                    const Color(0xFFFA709A),
                    const Color(0xFFFEE140),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentFeesScreen(),
                        settings: RouteSettings(arguments: wardId),
                      ),
                    ),
                  ),
                ),
                FadeInListItem(
                  index: 5,
                  child: _buildActionCard(
                    context,
                    "Timetable",
                    "Weekly Plan",
                    Icons.schedule_rounded,
                    const Color(0xFFA18CD1),
                    const Color(0xFFFBC2EB),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentTimetableScreen(),
                        settings: RouteSettings(arguments: wardId),
                      ),
                    ),
                  ),
                ),
                FadeInListItem(
                  index: 6,
                  child: _buildActionCard(
                    context,
                    "Homework",
                    "Assignments",
                    Icons.assignment_rounded,
                    const Color(0xFFF6D365),
                    const Color(0xFFFDA085),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentHomeworkScreen(),
                        settings: RouteSettings(arguments: wardId),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWardProfileCard(
    BuildContext context,
    String name,
    String className,
    String admNo,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardGradientColors = isDark
        ? [const Color(0xFF5C6BC0), const Color(0xFF3949AB)]
        : [const Color(0xFF1A237E), const Color(0xFF0D1454)];
    final shadowColor = isDark
        ? const Color(0xFF5C6BC0).withValues(alpha: 0.4)
        : const Color(0xFF1A237E).withValues(alpha: 0.4);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
              ],
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primaryOf(context).withValues(alpha: 0.15),
              child: Icon(
                Icons.person_rounded,
                size: 40,
                color: AppColors.primaryOf(context),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Student Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Adm No: $admNo | $className",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color startColor,
    Color endColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: startColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textTertiaryOf(context),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
