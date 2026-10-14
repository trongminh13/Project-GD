import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/core/services/student_portal_service.dart';
import 'package:ashadeep/core/services/homework_service.dart';
import 'package:ashadeep/features/student/screens/student_take_homework_screen.dart';
import 'package:ashadeep/features/student/screens/student_homework_result_screen.dart';
import 'package:ashadeep/screens/login_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _portalService = StudentPortalService();
  final _homeworkService = HomeworkService();

  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _attendance = [];
  List<Map<String, dynamic>> _marks = [];
  List<dynamic> _homework = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final profileFuture = _portalService.getMyProfile();
      final attendanceFuture = _portalService.getMyAttendance();
      final marksFuture = _portalService.getMyMarks();
      final homeworkFuture = _homeworkService.getStudentAssignments();

      final results = await Future.wait([profileFuture, attendanceFuture, marksFuture, homeworkFuture]);
      if (mounted) {
        setState(() {
          _profile = results[0] as Map<String, dynamic>?;
          _attendance = results[1] as List<Map<String, dynamic>>;
          _marks = results[2] as List<Map<String, dynamic>>;
          _homework = results[3] as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cổng Thông Tin Học Sinh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Hồ Sơ'),
            Tab(icon: Icon(Icons.assignment_rounded), text: 'Bài Tập'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Điểm Danh'),
            Tab(icon: Icon(Icons.grade), text: 'Kết Quả'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildHomeworkTab(),
                _buildAttendanceTab(),
                _buildMarksTab(),
              ],
            ),
    );
  }

  Widget _buildProfileTab() {
    if (_profile == null) {
      return const Center(child: Text('Không thể tải thông tin hồ sơ học sinh.'));
    }

    final name = _profile!['name'] ?? 'Học sinh';
    final admissionNumber = _profile!['admissionNumber'] ?? 'N/A';
    final rollNo = _profile!['rollNo'] ?? 'N/A';
    final grade = _profile!['grade'] ?? '';
    final section = _profile!['section'] ?? '';
    final className = '$grade $section'.trim();
    final teacher = _profile!['classTeacherName'] ?? 'Chưa phân công';
    final parent = _profile!['parentName'] ?? 'N/A';
    final parentPhone = _profile!['parentPhone'] ?? 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryOf(context).withValues(alpha: 0.2),
                    child: Icon(Icons.person, size: 40, color: AppColors.primaryOf(context)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTextStyles.heading2(context).copyWith(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('Mã HS: $admissionNumber  |  Số danh bộ: $rollNo',
                            style: AppTextStyles.body(context).copyWith(fontSize: 13, color: AppColors.textSecondaryOf(context))),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOf(context).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Lớp: $className', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryOf(context))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _infoTile(Icons.school, 'Giáo viên chủ nhiệm', teacher),
                  const Divider(),
                  _infoTile(Icons.family_restroom, 'Phụ huynh', '$parent ($parentPhone)'),
                  const Divider(),
                  _infoTile(Icons.cake, 'Ngày sinh', _profile!['dob'] ?? 'N/A'),
                  const Divider(),
                  _infoTile(Icons.wc, 'Giới tính', _profile!['gender'] ?? 'N/A'),
                  const Divider(),
                  _infoTile(Icons.home, 'Địa chỉ', _profile!['address'] ?? 'N/A'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryOf(context)),
      title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      dense: true,
    );
  }

  Widget _buildHomeworkTab() {
    if (_homework.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Chưa có bài tập nào được giao.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _homework.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _homework[index] as Map<String, dynamic>;
          final assignmentId = item['assignmentId'] as int;
          final title = item['title'] ?? 'Bài tập';
          final subject = item['subjectName'] ?? '';
          final teacher = item['teacherName'] ?? '';
          final dueDate = (item['dueDate'] ?? '').toString().split('T').first;
          final status = (item['submissionStatus'] ?? 'NOT_STARTED').toString();
          final finalScore = item['finalScore'];
          final autoScore = item['autoScore'];

          Color statusColor = Colors.orange;
          String statusText = 'Chưa làm';
          if (status == 'IN_PROGRESS') {
            statusColor = Colors.blue;
            statusText = 'Đang làm dở';
          } else if (status == 'SUBMITTED') {
            statusColor = Colors.purple;
            statusText = 'Đã nộp (Chờ chấm)';
          } else if (status == 'GRADED') {
            statusColor = Colors.green;
            statusText = 'Đã chấm: ${finalScore ?? autoScore} đ';
          }

          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (status == 'SUBMITTED' || status == 'GRADED') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentHomeworkResultScreen(assignmentId: assignmentId),
                    ),
                  ).then((_) => _loadAllData());
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentTakeHomeworkScreen(assignmentId: assignmentId),
                    ),
                  ).then((_) => _loadAllData());
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOf(context).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            subject,
                            style: TextStyle(
                              color: AppColors.primaryOf(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'GV: $teacher',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const Spacer(),
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Hạn: $dueDate',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceTab() {
    if (_attendance.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu điểm danh.'));
    }

    int presentCount = 0;
    int absentCount = 0;
    for (var a in _attendance) {
      final status = (a['status'] ?? '').toString().toUpperCase();
      if (status == 'PRESENT') {
        presentCount++;
      } else {
        absentCount++;
      }
    }
    final total = _attendance.length;
    final rate = total > 0 ? (presentCount / total * 100).toStringAsFixed(1) : '0';

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryOf(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Có mặt', '$presentCount', AppColors.success),
              _statItem('Vắng', '$absentCount', AppColors.error),
              _statItem('Tỷ lệ', '$rate%', AppColors.primaryOf(context)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _attendance.length,
            itemBuilder: (context, index) {
              final item = _attendance[index];
              final date = item['date'] ?? '';
              final status = (item['status'] ?? 'PRESENT').toString().toUpperCase();
              final isPresent = status == 'PRESENT';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(
                    isPresent ? Icons.check_circle : Icons.cancel,
                    color: isPresent ? AppColors.success : AppColors.error,
                  ),
                  title: Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Chip(
                    label: Text(isPresent ? 'Có mặt' : 'Vắng', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: isPresent ? AppColors.success : AppColors.error,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMarksTab() {
    if (_marks.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu bảng điểm.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _marks.length,
      itemBuilder: (context, index) {
        final m = _marks[index];
        final subject = m['subjectName'] ?? 'Môn học';
        final exam = m['examName'] ?? 'Kỳ thi';
        final score = m['marksObtained'] ?? 0;
        final max = m['maxMarks'] ?? 100;
        final grade = m['grade'] ?? 'N/A';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOf(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.menu_book, color: AppColors.primaryOf(context)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(exam, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$score / $max', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryOf(context))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Hạng: $grade', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
