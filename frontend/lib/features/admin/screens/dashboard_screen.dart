import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/config/feature_flags.dart';
import 'package:ashadeep/core/widgets/fade_in_list_item.dart';
import 'package:ashadeep/features/admin/screens/student_list_screen.dart';
import 'package:ashadeep/features/admin/screens/teacher_attendance_screen.dart';
import 'package:ashadeep/features/admin/screens/teacher_list_screen.dart';
import 'package:ashadeep/features/admin/screens/class_management_screen.dart';
import 'package:ashadeep/features/admin/screens/edit_timetable_screen.dart';
import 'package:ashadeep/features/admin/screens/send_notices_screen.dart';
import 'package:ashadeep/features/admin/screens/reports_dashboard_screen.dart';
import 'package:ashadeep/screens/login_screen.dart';
import 'package:ashadeep/screens/profile_screen.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';
import 'package:ashadeep/core/widgets/demo_mode_banner.dart';
import 'package:ashadeep/features/admin/screens/bulk_import_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? _lastPressedAt;
  int _studentCount = 0;
  int _teacherCount = 0;
  bool _isLoadingStats = true;
  String _adminName = 'Admin User';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoadingStats = true);

    if (ApiConstants.isDemoMode || FeatureFlags.useDemoFallback) {
      if (mounted) {
        setState(() {
          _studentCount = 1250;
          _teacherCount = 68;
          _adminName = 'Ban Quản Trị Hệ Thống';
          _isLoadingStats = false;
        });
      }
      return;
    }

    try {
      await Future.wait([
        _fetchDashboardStats(),
        _fetchAdminProfile(),
      ]).timeout(ApiTimeoutPolicy.fastRead.duration);
    } catch (_) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _fetchAdminProfile() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return;
      final url = Uri.parse('${ApiConstants.baseUrl}/profile');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) setState(() => _adminName = data['name'] ?? 'Admin User');
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _fetchDashboardStats() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        setState(() => _isLoadingStats = false);
        return;
      }

      // Fetch students count (paginated response)
      final studentsUrl = Uri.parse('${ApiConstants.baseUrl}/students?size=1');
      final studentsResponse = await http.get(
        studentsUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (studentsResponse.statusCode == 200) {
        final data = json.decode(studentsResponse.body);
        if (mounted) {
          setState(() {
            _studentCount = data['totalElements'] ?? 0;
          });
        }
      }

      // Fetch teachers count (paginated response)
      final teachersUrl = Uri.parse('${ApiConstants.baseUrl}/teachers?size=1');
      final teachersResponse = await http.get(
        teachersUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (teachersResponse.statusCode == 200) {
        final data = json.decode(teachersResponse.body);
        if (mounted) {
          setState(() {
            _teacherCount = data['totalElements'] ?? 0;
            _isLoadingStats = false;
          });
        }
      } else {
        setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: AppColors.backgroundOf(context),
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Data',
              onPressed: () {
                _loadAllData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refreshing data...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.lightPrimary, AppColors.darkPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: Text(
                  _adminName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: const Text('admin@school.edu'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: AppColors.primaryOf(context)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Students'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StudentListScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Teachers'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TeacherListScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await AuthService().logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            const DemoModeBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAllData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overview', style: AppTextStyles.heading2(context)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FadeInListItem(
                        index: 0,
                        child: _buildClickableStatCard(
                          context,
                          'Total Students',
                          _isLoadingStats ? '...' : '$_studentCount',
                          Icons.people,
                          AppColors.primaryOf(context),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StudentListScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FadeInListItem(
                        index: 1,
                        child: _buildClickableStatCard(
                          context,
                          'Total Teachers',
                          _isLoadingStats ? '...' : '$_teacherCount',
                          Icons.school,
                          AppColors.success,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TeacherListScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Academic Management
                FadeInListItem(
                  index: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Academic Management', style: AppTextStyles.heading2(context)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              context,
                              'Manage Classes',
                              Icons.meeting_room,
                              AppColors.primaryOf(context),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ClassManagementScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionCard(
                              context,
                              'Manage Timetable',
                              Icons.calendar_today,
                              AppColors.primaryOf(context),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditTimetableScreen(),
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
                const SizedBox(height: 24),
                FadeInListItem(
                  index: 4,
                  child: Text('Quick Actions', style: AppTextStyles.heading2(context)),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    FadeInListItem(
                      index: 5,
                      child: _buildActionCard(
                        context,
                        'Manage Fees',
                        Icons.payment,
                        AppColors.primaryOf(context),
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const StudentListScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    FadeInListItem(
                      index: 6,
                      child: _buildActionCard(
                        context,
                        'Mark Attendance',
                        Icons.edit_calendar,
                        AppColors.primaryOf(context),
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TeacherAttendanceScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    FadeInListItem(
                      index: 7,
                      child: _buildActionCard(
                        context,
                        'Send Notices',
                        Icons.message,
                        AppColors.primaryOf(context),
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SendNoticesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    FadeInListItem(
                      index: 8,
                      child: _buildActionCard(
                        context,
                        'View Reports',
                        Icons.bar_chart,
                        AppColors.primaryOf(context),
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ReportsDashboardScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    FadeInListItem(
                      index: 9,
                      child: _buildActionCard(
                        context,
                        'Bulk Import',
                        Icons.upload_file,
                        AppColors.primaryOf(context),
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BulkImportScreen(),
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
      ),
    ],
  ),
),
);
  }

  Widget _buildClickableStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 30),
                  Icon(Icons.arrow_forward_ios, color: AppColors.textTertiaryOf(context), size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Text(value, style: AppTextStyles.heading2(context).copyWith(fontSize: 28)),
              const SizedBox(height: 4),
              Text(title, style: AppTextStyles.body(context).copyWith(fontSize: 14)),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(title, style: AppTextStyles.heading2(context).copyWith(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
