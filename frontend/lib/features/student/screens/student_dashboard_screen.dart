import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/core/services/student_portal_service.dart';
import 'package:ashadeep/screens/login_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _portalService = StudentPortalService();

  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _attendance = [];
  List<Map<String, dynamic>> _marks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

      final results = await Future.wait([profileFuture, attendanceFuture, marksFuture]);
      if (mounted) {
        setState(() {
          _profile = results[0] as Map<String, dynamic>?;
          _attendance = results[1] as List<Map<String, dynamic>>;
          _marks = results[2] as List<Map<String, dynamic>>;
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
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryOf(context).withValues(alpha: 0.1),
                    child: Text(
                      name.isNotEmpty ? name[0] : 'S',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryOf(context)),
                    ),
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
