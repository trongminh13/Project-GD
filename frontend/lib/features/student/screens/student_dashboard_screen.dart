import 'package:flutter/material.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/core/services/student_portal_service.dart';
import 'package:ashadeep/core/services/homework_service.dart';
import 'package:ashadeep/core/theme/app_colors.dart';
import 'package:ashadeep/core/widgets/app_section_header.dart';
import 'package:ashadeep/core/widgets/app_empty_card.dart';
import 'package:ashadeep/core/widgets/homework_card.dart';
import 'package:ashadeep/core/widgets/material_card.dart';
import 'package:ashadeep/core/widgets/lesson_row.dart';
import 'package:ashadeep/utils/date_time_utils.dart';
import 'package:ashadeep/utils/format_utils.dart';
import 'package:ashadeep/utils/status_helper.dart';
import 'package:ashadeep/features/student/screens/student_take_homework_screen.dart';
import 'package:ashadeep/features/student/screens/student_homework_result_screen.dart';
import 'package:ashadeep/core/config/feature_flags.dart';
import 'package:ashadeep/screens/login_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final _portalService = StudentPortalService();
  final _homeworkService = HomeworkService();

  int _currentIndex = 0; // 0: Trang chủ, 1: Lịch học, 2: Học liệu, 3: Bài tập, 4: Thêm
  bool _isLoading = true;

  // Dữ liệu từ Backend
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _attendance = [];
  List<Map<String, dynamic>> _marks = [];
  List<dynamic> _homework = [];
  List<dynamic> _materials = [];

  // Lịch học & thời khóa biểu
  int _selectedDay = 0; // 0: Thứ 2, 1: Thứ 3, ..., 4: Thứ 6
  int _weekOffset = 0;  // 0: tuần này, -1: tuần trước, 1: tuần sau

  // Bộ lọc môn học trong tab Học liệu
  String _selectedSubjectFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final profileFuture = _portalService.getMyProfile();
      final attendanceFuture = _portalService.getMyAttendance();
      final marksFuture = _portalService.getMyMarks();
      final homeworkFuture = _homeworkService.getStudentAssignments();
      final materialsFuture = _portalService.getMyMaterials();

      final results = await Future.wait([
        profileFuture,
        attendanceFuture,
        marksFuture,
        homeworkFuture,
        materialsFuture,
      ]);

      if (mounted) {
        setState(() {
          _profile = results[0] as Map<String, dynamic>?;
          _attendance = results[1] as List<Map<String, dynamic>>;
          _marks = results[2] as List<Map<String, dynamic>>;

          final hwList = results[3] as List<dynamic>;
          if (hwList.isNotEmpty) {
            _homework = hwList;
          } else if (FeatureFlags.useDemoFallback) {
            _homework = _getMockHomework();
          } else {
            _homework = [];
          }

          final matList = results[4] as List<dynamic>;
          if (matList.isNotEmpty) {
            _materials = matList;
          } else if (FeatureFlags.useDemoFallback) {
            _materials = _getMockMaterials();
          } else {
            _materials = [];
          }

          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (FeatureFlags.useDemoFallback) {
            _homework = _getMockHomework();
            _materials = _getMockMaterials();
          } else {
            _homework = [];
            _materials = [];
          }
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getMockHomework() {
    return [
      {
        'assignmentId': 1,
        'title': 'Bài tập tuần 5 - Phép nhân',
        'subjectName': 'Toán học',
        'dueDate': '18/10/2026',
        'submissionStatus': 'IN_PROGRESS',
      },
      {
        'assignmentId': 2,
        'title': 'Phiếu ôn tập từ chỉ đặc điểm',
        'subjectName': 'Tiếng Việt',
        'dueDate': '19/10/2026',
        'submissionStatus': 'IN_PROGRESS',
      },
      {
        'assignmentId': 3,
        'title': 'Đọc hiểu & Kể chuyện tuần 4',
        'subjectName': 'Tiếng Việt',
        'dueDate': '12/10/2026',
        'submissionStatus': 'GRADED',
        'finalScore': 9.5,
      },
      {
        'assignmentId': 4,
        'title': 'Trắc nghiệm hình học: Hình chữ nhật',
        'subjectName': 'Toán học',
        'dueDate': '10/10/2026',
        'submissionStatus': 'GRADED',
        'finalScore': 10.0,
      },
    ];
  }

  List<dynamic> _getMockMaterials() {
    return [
      {
        'id': 1,
        'title': 'Phiếu ôn tập Toán tuần 5',
        'subjectName': 'Toán',
        'teacherName': 'Cô Lê Thu Hà',
        'fileType': 'PDF',
        'createdAt': '2026-10-12',
      },
      {
        'id': 2,
        'title': 'Luyện từ và câu: Từ chỉ đặc điểm',
        'subjectName': 'Tiếng Việt',
        'teacherName': 'Cô Lê Thu Hà',
        'fileType': 'PDF',
        'createdAt': '2026-10-11',
      },
      {
        'id': 3,
        'title': 'Audio Nghe Tiếng Anh - Unit 3: My Family',
        'subjectName': 'Tiếng Anh',
        'teacherName': 'Thầy Phạm Quốc Bảo',
        'fileType': 'AUDIO',
        'createdAt': '2026-10-10',
      },
    ];
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
        content: const Text('Em có chắc chắn muốn đăng xuất khỏi hệ thống không?', style: TextStyle(color: AppColors.textMain)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSub)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Danh sách bài tập Cần làm & Đã nộp
  List<dynamic> get _todoHomework {
    return _homework.where((h) {
      final status = (h['submissionStatus'] ?? h['status'] ?? '').toString().toLowerCase();
      return status != 'submitted' && status != 'graded';
    }).toList();
  }

  List<dynamic> get _submittedHomework {
    return _homework.where((h) {
      final status = (h['submissionStatus'] ?? h['status'] ?? '').toString().toLowerCase();
      return status == 'submitted' || status == 'graded';
    }).toList();
  }

  // Danh sách tiết học mẫu (theo chuẩn bản HTML demo)
  List<Map<String, String>> _getLessonsForDay(int dayIndex) {
    final schedules = [
      // Thứ 2
      [
        {'time': '07:30–08:15', 'subj': 'Toán', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.201'},
        {'time': '08:20–09:05', 'subj': 'Tiếng Việt', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.201'},
        {'time': '09:25–10:10', 'subj': 'Tiếng Anh', 'teacher': 'Thầy Phạm Quốc Bảo', 'room': 'P.Anh 1'},
        {'time': '10:15–11:00', 'subj': 'Thể dục', 'teacher': 'Thầy Đỗ Văn Long', 'room': 'Sân trường'},
      ],
      // Thứ 3
      [
        {'time': '07:30–08:15', 'subj': 'Tiếng Việt', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.201'},
        {'time': '08:20–09:05', 'subj': 'Toán', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.201'},
        {'time': '09:25–10:10', 'subj': 'Tự nhiên và Xã hội', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.201'},
        {'time': '10:15–11:00', 'subj': 'Mỹ thuật', 'teacher': 'Cô Trần Mai', 'room': 'P.Mỹ thuật'},
      ],
      // Thứ 4
      [
        {'time': '07:30–08:15', 'subj': 'Toán', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.201'},
        {'time': '08:20–09:05', 'subj': 'Tiếng Anh', 'teacher': 'Thầy Phạm Quốc Bảo', 'room': 'P.Anh 1'},
        {'time': '09:25–10:10', 'subj': 'Tiếng Việt', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.201'},
        {'time': '10:15–11:00', 'subj': 'Âm nhạc', 'teacher': 'Cô Vũ Lan', 'room': 'P.Âm nhạc'},
      ],
      // Thứ 5
      [
        {'time': '07:30–08:15', 'subj': 'Tiếng Việt', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.201'},
        {'time': '08:20–09:05', 'subj': 'Toán', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.201'},
        {'time': '09:25–10:10', 'subj': 'Thể dục', 'teacher': 'Thầy Đỗ Văn Long', 'room': 'Sân trường'},
        {'time': '10:15–11:00', 'subj': 'Tự nhiên và Xã hội', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.201'},
      ],
      // Thứ 6
      [
        {'time': '07:30–08:15', 'subj': 'Tiếng Anh', 'teacher': 'Thầy Phạm Quốc Bảo', 'room': 'P.Anh 1'},
        {'time': '08:20–09:05', 'subj': 'Tiếng Việt', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.201'},
        {'time': '09:25–10:10', 'subj': 'Toán', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.201'},
        {'time': '10:15–11:00', 'subj': 'Mỹ thuật', 'teacher': 'Cô Trần Mai', 'room': 'P.Mỹ thuật'},
      ],
    ];

    if (dayIndex >= 0 && dayIndex < schedules.length) {
      return schedules[dayIndex];
    }
    return [];
  }

  void _onOpenTakeHomework(dynamic hw) {
    final assignmentId = hw['assignmentId'] ?? hw['id'];
    if (assignmentId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StudentTakeHomeworkScreen(
            assignmentId: int.parse(assignmentId.toString()),
          ),
        ),
      ).then((_) => _loadAllData());
    }
  }

  void _onOpenHomeworkResult(dynamic hw) {
    final aId = hw['assignmentId'] ?? hw['id'];
    if (aId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StudentHomeworkResultScreen(
            assignmentId: int.parse(aId.toString()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, thickness: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMain),
            onPressed: _loadAllData,
            tooltip: 'Tải lại dữ liệu',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _buildCurrentTab(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSub,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: 'Lịch học',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  activeIcon: Icon(Icons.menu_book),
                  label: 'Học liệu',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment),
                  label: 'Bài tập',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz),
                  activeIcon: Icon(Icons.more_horiz),
                  label: 'Thêm',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Trang chủ';
      case 1:
        return 'Lịch học';
      case 2:
        return 'Học liệu';
      case 3:
        return 'Bài tập';
      case 4:
        return 'Thêm';
      default:
        return 'Cổng học sinh';
    }
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildTimeTab();
      case 2:
        return _buildMatTab();
      case 3:
        return _buildHwTab();
      case 4:
        return _buildMoreTab();
      default:
        return _buildHomeTab();
    }
  }

  // ===================== TAB 0: TRANG CHỦ =====================
  Widget _buildHomeTab() {
    final studentName = _profile?['name'] ?? 'Nguyễn Minh Anh';
    final className = FormatUtils.formatClassName(
      grade: _profile?['grade']?.toString(),
      section: _profile?['section']?.toString(),
      fallback: _profile?['className']?.toString(),
    );
    final classTeacher = _profile?['classTeacher'] ?? 'Cô Lê Thu Hà';
    final now = DateTime.now();
    final todayWeekday = now.weekday - 1; // 0: Thứ 2 ... 4: Thứ 6
    final todayLessons = FeatureFlags.useDemoFallback
        ? _getLessonsForDay(todayWeekday >= 0 && todayWeekday < 5 ? todayWeekday : 0)
        : <Map<String, String>>[];

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Banner chỉ dẫn Chế độ Demo (nếu đang bật)
          if (FeatureFlags.useDemoFallback)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.warning),
                color: AppColors.warning.withValues(alpha: 0.08),
              ),
              child: const Row(
                children: [
                  Icon(Icons.slideshow_outlined, size: 16, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chế độ Demo: Đang hiển thị dữ liệu mẫu phục vụ trình chiếu.',
                      style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // Header cá nhân học sinh
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
                ),
                const SizedBox(height: 4),
                Text(
                  '$className · GVCN $classTeacher',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSub),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hôm nay: ${DateTimeUtils.formatVietnameseFullDate(now)}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSub),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 1: Bài tập cần làm
          AppSectionHeader(
            title: 'Bài tập cần làm',
            linkLabel: 'Xem tất cả',
            onLink: () => setState(() => _currentIndex = 3),
          ),
          const SizedBox(height: 8),
          if (_todoHomework.isEmpty)
            const AppEmptyCard(
              title: 'Không còn bài cần làm',
              message: 'Em đã nộp tất cả bài tập được giao.',
              icon: Icons.check_circle_outline,
            )
          else
            ..._todoHomework.take(3).map(
                  (hw) => HomeworkCard(
                    data: Map<String, dynamic>.from(hw as Map),
                    mode: HomeworkCardMode.studentTake,
                    onPrimaryAction: () => _onOpenTakeHomework(hw),
                    onCardTap: () => _onOpenTakeHomework(hw),
                  ),
                ),
          const SizedBox(height: 20),

          // Section 2: Lịch học hôm nay
          AppSectionHeader(
            title: 'Lịch học hôm nay',
            linkLabel: 'Xem tuần',
            onLink: () => setState(() => _currentIndex = 1),
          ),
          const SizedBox(height: 8),
          if (todayLessons.isEmpty)
            const AppEmptyCard(
              title: 'Hôm nay không có tiết',
              message: 'Không có tiết học nào được xếp lịch cho hôm nay.',
              icon: Icons.event_available_outlined,
            )
          else
            Container(
              decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
              child: Column(
                children: todayLessons.asMap().entries.map((entry) {
                  final i = entry.key;
                  final l = entry.value;
                  return LessonRow(
                    lessonIndex: i + 1,
                    subject: l['subj']!,
                    time: l['time']!,
                    teacher: l['teacher']!,
                    room: l['room']!,
                    isCompact: true,
                    hasDivider: i < todayLessons.length - 1,
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 20),

          // Section 3: Học liệu mới
          AppSectionHeader(
            title: 'Học liệu mới',
            linkLabel: 'Xem tất cả',
            onLink: () => setState(() => _currentIndex = 2),
          ),
          const SizedBox(height: 8),
          if (_materials.isEmpty)
            const AppEmptyCard(
              title: 'Chưa có học liệu mới',
              message: 'Giáo viên chưa đăng tài liệu mới cho lớp.',
              icon: Icons.menu_book_outlined,
            )
          else
            ..._materials.take(2).map((m) => MaterialCard(data: Map<String, dynamic>.from(m as Map))),
        ],
      ),
    );
  }

  // ===================== TAB 1: LỊCH HỌC =====================
  Widget _buildTimeTab() {
    final weekLabel = DateTimeUtils.getWeekLabel(_weekOffset);
    final lessons = FeatureFlags.useDemoFallback ? _getLessonsForDay(_selectedDay) : <Map<String, String>>[];

    return Column(
      children: [
        // Điều hướng tuần
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.textMain),
                onPressed: () => setState(() => _weekOffset = (_weekOffset > -1 ? _weekOffset - 1 : -1)),
                tooltip: 'Tuần trước',
              ),
              Text(
                weekLabel,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.textMain),
                onPressed: () => setState(() => _weekOffset = (_weekOffset < 1 ? _weekOffset + 1 : 1)),
                tooltip: 'Tuần sau',
              ),
            ],
          ),
        ),

        // Tabs Thứ 2 – Thứ 6
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: List.generate(DateTimeUtils.schoolDays.length, (i) {
              final isSelected = _selectedDay == i;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedDay = i),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 3.0,
                        ),
                      ),
                    ),
                    child: Text(
                      DateTimeUtils.schoolDays[i],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textMain,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Danh sách tiết học của ngày đã chọn
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (lessons.isEmpty)
                const AppEmptyCard(
                  title: 'Chưa có lịch học',
                  message: 'Thời khóa biểu cho ngày này chưa được cập nhật.',
                  icon: Icons.calendar_today_outlined,
                )
              else
                Container(
                  decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
                  child: Column(
                    children: lessons.asMap().entries.map((entry) {
                      final i = entry.key;
                      final l = entry.value;
                      return LessonRow(
                        lessonIndex: i + 1,
                        subject: l['subj']!,
                        time: l['time']!,
                        teacher: l['teacher']!,
                        room: l['room']!,
                        isCompact: false,
                        hasDivider: i < lessons.length - 1,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===================== TAB 2: HỌC LIỆU =====================
  Widget _buildMatTab() {
    final subjects = ['Tất cả', 'Toán', 'Tiếng Việt', 'Tiếng Anh'];
    final filtered = _selectedSubjectFilter == 'Tất cả'
        ? _materials
        : _materials.where((m) => (m['subjectName'] ?? '').toString() == _selectedSubjectFilter).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banner thông tin
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            color: AppColors.surfaceAlt,
          ),
          child: Text(
            'Chỉ hiện tài liệu đã được giáo viên xuất bản cho lớp ${_profile?['className'] ?? '3A'}.',
            style: const TextStyle(fontSize: 13, color: AppColors.textSub),
          ),
        ),
        const SizedBox(height: 16),

        // Bộ lọc môn học
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: subjects.map((subj) {
              final isSel = _selectedSubjectFilter == subj;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(subj),
                  selected: isSel,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSubjectFilter = subj);
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : AppColors.textMain,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  side: BorderSide(color: isSel ? AppColors.primary : AppColors.border),
                  backgroundColor: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Danh sách tài liệu
        if (filtered.isEmpty)
          const AppEmptyCard(
            title: 'Chưa có tài liệu',
            message: 'Giáo viên chưa đăng tài liệu cho môn này.',
            icon: Icons.menu_book_outlined,
          )
        else
          ...filtered.map((m) => MaterialCard(data: Map<String, dynamic>.from(m as Map))),
      ],
    );
  }

  // ===================== TAB 3: BÀI TẬP (LMS) =====================
  Widget _buildHwTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banner hướng dẫn
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            color: AppColors.surfaceAlt,
          ),
          child: const Text(
            'Làm bài ngay trong ứng dụng. Bài làm được lưu nháp tự động, hạn nộp tính theo giờ máy chủ.',
            style: TextStyle(fontSize: 13, color: AppColors.textSub),
          ),
        ),
        const SizedBox(height: 20),

        // Cần làm
        AppSectionHeader(title: 'Cần làm (${_todoHomework.length})'),
        const SizedBox(height: 8),
        if (_todoHomework.isEmpty)
          const AppEmptyCard(
            title: 'Không còn bài cần làm',
            message: 'Em đã nộp tất cả bài tập được giao.',
            icon: Icons.check_circle_outline,
          )
        else
          ..._todoHomework.map(
                (hw) => HomeworkCard(
                  data: Map<String, dynamic>.from(hw as Map),
                  mode: HomeworkCardMode.studentTake,
                  onPrimaryAction: () => _onOpenTakeHomework(hw),
                  onCardTap: () => _onOpenTakeHomework(hw),
                ),
              ),
        const SizedBox(height: 24),

        // Đã nộp
        AppSectionHeader(title: 'Đã nộp (${_submittedHomework.length})'),
        const SizedBox(height: 8),
        if (_submittedHomework.isEmpty)
          const AppEmptyCard(
            title: 'Chưa nộp bài nào',
            message: 'Bài đã nộp sẽ hiện ở đây cùng điểm số.',
            icon: Icons.history_edu_outlined,
          )
        else
          ..._submittedHomework.map(
                (hw) => HomeworkCard(
                  data: Map<String, dynamic>.from(hw as Map),
                  mode: HomeworkCardMode.studentTake,
                  onPrimaryAction: () => _onOpenHomeworkResult(hw),
                  onCardTap: () => _onOpenHomeworkResult(hw),
                ),
              ),
      ],
    );
  }

  // ===================== TAB 4: THÊM =====================
  Widget _buildMoreTab() {
    final studentName = _profile?['name'] ?? 'Nguyễn Minh Anh';
    final studentId = _profile?['admissionNumber'] ?? _profile?['rollNo'] ?? _profile?['studentId'] ?? 'HS001';
    final className = FormatUtils.formatClassName(
      grade: _profile?['grade']?.toString(),
      section: _profile?['section']?.toString(),
      fallback: _profile?['className']?.toString(),
    );
    final teacher = _profile?['classTeacher'] ?? 'Cô Lê Thu Hà';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Thẻ thông tin cá nhân tóm tắt
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.person, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mã: $studentId · $className',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSub),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Các mục chức năng
        Container(
          decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              _buildMoreRow(
                title: 'Bảng điểm & Kết quả học tập',
                icon: Icons.grade_outlined,
                onTap: () => _showMarksBottomSheet(),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              _buildMoreRow(
                title: 'Lịch sử Chuyên cần / Điểm danh',
                icon: Icons.event_available_outlined,
                onTap: () => _showAttendanceBottomSheet(),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              _buildMoreRow(
                title: 'Thông tin giáo viên chủ nhiệm',
                sub: teacher,
                icon: Icons.school_outlined,
                onTap: () {},
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              SwitchListTile(
                value: FeatureFlags.useDemoFallback,
                onChanged: (val) {
                  setState(() {
                    FeatureFlags.useDemoFallback = val;
                  });
                  _loadAllData();
                },
                title: const Text(
                  'Chế độ Dữ liệu Demo (Demo Mode)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMain),
                ),
                subtitle: Text(
                  FeatureFlags.useDemoFallback
                      ? 'Đang bật dữ liệu mẫu phục vụ trình chiếu với ban lãnh đạo'
                      : 'Đang dùng 100% dữ liệu thực từ máy chủ API',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                ),
                secondary: const Icon(Icons.slideshow_outlined, color: AppColors.primary),
                activeThumbColor: AppColors.primary,
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              _buildMoreRow(
                title: 'Đăng xuất',
                icon: Icons.logout,
                color: AppColors.error,
                onTap: _logout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoreRow({
    required String title,
    String? sub,
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.textSub, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color ?? AppColors.textMain,
                    ),
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(sub, style: const TextStyle(fontSize: 13, color: AppColors.textSub)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color ?? AppColors.textSub, size: 20),
          ],
        ),
      ),
    );
  }

  // BottomSheet xem Bảng điểm
  void _showMarksBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bảng điểm của em', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
            ),
            Expanded(
              child: _marks.isEmpty
                  ? const Center(child: Text('Chưa có dữ liệu bảng điểm', style: TextStyle(color: AppColors.textSub)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _marks.length,
                      separatorBuilder: (_, _) => const Divider(color: AppColors.border),
                      itemBuilder: (_, i) {
                        final m = _marks[i];
                        final score = m['score'] ?? '-';
                        final maxScore = m['maxScore'];
                        final exam = m['examName'] ?? m['examType'] ?? 'Định kỳ';
                        final grade = m['grade'];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(m['subjectName'] ?? 'Môn học', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
                          subtitle: Text(
                            grade != null ? 'Kỳ thi: $exam · Xếp loại: $grade' : 'Kỳ thi: $exam',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSub),
                          ),
                          trailing: Text(
                            FormatUtils.formatScore(score, maxScore: maxScore),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // BottomSheet xem Chuyên cần
  void _showAttendanceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Lịch sử chuyên cần', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
            ),
            Expanded(
              child: _attendance.isEmpty
                  ? const Center(child: Text('Chưa có dữ liệu điểm danh', style: TextStyle(color: AppColors.textSub)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _attendance.length,
                      separatorBuilder: (_, _) => const Divider(color: AppColors.border),
                      itemBuilder: (_, i) {
                        final a = _attendance[i];
                        final st = a['status']?.toString();
                        final statusInfo = StatusHelper.getAttendanceStatus(st);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(statusInfo.icon, color: statusInfo.color, size: 22),
                          title: Text('Ngày: ${a['date'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMain)),
                          subtitle: Text(
                            a['remarks'] != null && a['remarks'].toString().isNotEmpty
                                ? '${statusInfo.label} (${a['remarks']})'
                                : statusInfo.label,
                            style: TextStyle(color: statusInfo.color, fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
