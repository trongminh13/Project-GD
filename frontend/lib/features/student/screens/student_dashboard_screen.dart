import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:ashadeep/core/theme/theme_manager.dart';
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
import 'package:ashadeep/core/widgets/app_card_error_with_retry.dart';
import 'package:ashadeep/core/widgets/demo_mode_banner.dart';
import 'package:ashadeep/utils/constants.dart' show ApiConstants;
import 'package:ashadeep/screens/login_screen.dart';
import 'package:ashadeep/core/enums/education_level.dart';

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
  bool _hasHomeworkError = false;
  bool _hasMaterialsError = false;

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

  // Bộ lọc kỳ thi trong tab Bảng điểm
  String _selectedExamFilter = 'Tất cả';

  // Thông báo
  String _selectedNoticeAudience = 'Tất cả';
  List<Map<String, dynamic>> _notices = [];

  @override
  void initState() {
    super.initState();
    _notices = _getMockNotices();
    _loadAllData();
  }

  /// Tải dữ liệu toàn diện theo mô hình Progressive Rendering:
  /// Khởi chạy song song nhưng độc lập, phần nào có dữ liệu kết xuất ngay phần đó.
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _hasHomeworkError = false;
      _hasMaterialsError = false;
    });

    // Fast-path cho môi trường Demo / Web GitHub Pages (0ms network delay)
    if (ApiConstants.isDemoMode || FeatureFlags.useDemoFallback) {
      if (mounted) {
        setState(() {
          _profile = _getMockProfile();
          _attendance = _getMockAttendance();
          _marks = _getMockMarks();
          _homework = _getMockHomework();
          _materials = _getMockMaterials();
          _notices = _getMockNotices();
          _isLoading = false;
        });
      }
      return;
    }

    // Chạy song song độc lập, không dùng Future.wait đơn khối làm tắc nghẽn cả màn hình
    await Future.wait([
      _loadProfile(),
      _loadAttendance(),
      _loadMarks(),
      _loadHomework(),
      _loadMaterials(),
      _loadNotices(),
    ]);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProfile() async {
    try {
      final p = await _portalService.getMyProfile();
      if (mounted) {
        setState(() {
          _profile = p;
          _isLoading = false; // Có profile là hiển thị khung trang chủ ngay
        });
      }
    } catch (_) {}
  }

  Future<void> _loadAttendance() async {
    try {
      final att = await _portalService.getMyAttendance();
      if (mounted) {
        setState(() {
          _attendance = att.isNotEmpty ? att : (FeatureFlags.useDemoFallback ? _getMockAttendance() : []);
        });
      }
    } catch (_) {
      if (mounted && FeatureFlags.useDemoFallback) {
        setState(() => _attendance = _getMockAttendance());
      }
    }
  }

  Future<void> _loadMarks() async {
    try {
      final m = await _portalService.getMyMarks();
      if (mounted) {
        setState(() {
          _marks = m.isNotEmpty ? m : (FeatureFlags.useDemoFallback ? _getMockMarks() : []);
        });
      }
    } catch (_) {
      if (mounted && FeatureFlags.useDemoFallback) {
        setState(() => _marks = _getMockMarks());
      }
    }
  }

  Future<void> _loadHomework() async {
    setState(() => _hasHomeworkError = false);
    try {
      final hw = await _homeworkService.getStudentAssignments();
      if (mounted) {
        setState(() {
          if (hw.isNotEmpty) {
            _homework = hw;
          } else if (FeatureFlags.useDemoFallback) {
            _homework = _getMockHomework();
          } else {
            _homework = [];
          }
          _hasHomeworkError = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (FeatureFlags.useDemoFallback) {
            _homework = _getMockHomework();
            _hasHomeworkError = false;
          } else {
            _homework = [];
            _hasHomeworkError = true;
          }
        });
      }
    }
  }

  Future<void> _loadMaterials() async {
    setState(() => _hasMaterialsError = false);
    try {
      final mat = await _portalService.getMyMaterials();
      if (mounted) {
        setState(() {
          if (mat.isNotEmpty) {
            _materials = mat;
          } else if (FeatureFlags.useDemoFallback) {
            _materials = _getMockMaterials();
          } else {
            _materials = [];
          }
          _hasMaterialsError = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (FeatureFlags.useDemoFallback) {
            _materials = _getMockMaterials();
            _hasMaterialsError = false;
          } else {
            _materials = [];
            _hasMaterialsError = true;
          }
        });
      }
    }
  }

  Future<void> _loadNotices() async {
    try {
      final list = await _portalService.getMyNotices();
      if (mounted) {
        setState(() {
          if (list.isNotEmpty) {
            _notices = list;
          } else if (FeatureFlags.useDemoFallback) {
            _notices = _getMockNotices();
          } else {
            _notices = [];
          }
        });
      }
    } catch (_) {
      if (mounted && FeatureFlags.useDemoFallback) {
        setState(() => _notices = _getMockNotices());
      }
    }
  }

  Map<String, dynamic> _getMockProfile() {
    return {
      'id': 1,
      'name': 'Nguyễn Minh Anh',
      'grade': '10',
      'section': 'A1',
      'className': 'Lớp 10A1',
      'rollNo': 'HS001',
      'admissionNumber': 'HS-2026-001',
      'classTeacher': 'Cô Lê Thu Hà',
      'dateOfBirth': '15/08/2010',
      'gender': 'Nữ',
      'parentName': 'Nguyễn Văn Hùng',
      'parentPhone': '0910157611',
    };
  }

  List<Map<String, dynamic>> _getMockMarks() {
    return [
      {
        'subjectName': 'Toán học',
        'score': 9.5,
        'maxScore': 10.0,
        'examName': 'Kiểm tra Giữa kỳ 1',
        'grade': 'Xuất sắc',
      },
      {
        'subjectName': 'Tiếng Việt',
        'score': 9.0,
        'maxScore': 10.0,
        'examName': 'Kiểm tra Giữa kỳ 1',
        'grade': 'Giỏi',
      },
      {
        'subjectName': 'Tiếng Anh',
        'score': 9.8,
        'maxScore': 10.0,
        'examName': 'Kiểm tra Giữa kỳ 1',
        'grade': 'Xuất sắc',
      },
      {
        'subjectName': 'Tự nhiên & Xã hội',
        'score': 10.0,
        'maxScore': 10.0,
        'examName': 'Kiểm tra Giữa kỳ 1',
        'grade': 'Xuất sắc',
      },
      {
        'subjectName': 'Tin học & Công nghệ',
        'score': 9.5,
        'maxScore': 10.0,
        'examName': 'Đánh giá định kỳ',
        'grade': 'Xuất sắc',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockAttendance() {
    return [
      {'date': '17/10/2026', 'status': 'PRESENT', 'remarks': 'Đi học đúng giờ'},
      {'date': '16/10/2026', 'status': 'PRESENT', 'remarks': 'Đi học đúng giờ'},
      {'date': '15/10/2026', 'status': 'PRESENT', 'remarks': 'Đi học đúng giờ'},
      {'date': '14/10/2026', 'status': 'PRESENT', 'remarks': 'Đi học đúng giờ'},
      {'date': '13/10/2026', 'status': 'PRESENT', 'remarks': 'Đi học đúng giờ'},
    ];
  }

  List<dynamic> _getMockHomework() {
    return [
      {
        'assignmentId': 28,
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
        'id': 101,
        'fileId': 1,
        'title': 'Sách giáo khoa Toán 1 - Tập 1',
        'subjectName': 'Toán',
        'teacherName': 'Bộ GD&ĐT · Kết nối tri thức',
        'fileType': 'PDF',
        'fileSize': '75.0 MB',
        'pageCount': 118,
        'filePath': 'file:///storage/emulated/0/Download/SGK_Toan_1_Tap_1.pdf',
        'createdAt': '2026-10-16',
        'isDownloaded': true,
      },
      {
        'id': 1,
        'title': 'Sách giáo khoa Toán 3 - Tập 1',
        'subjectName': 'Toán',
        'teacherName': 'Cô Lê Thu Hà',
        'fileType': 'PDF',
        'fileSize': '4.8 MB',
        'filePath': 'file:///storage/emulated/0/Download/SGK_Toan_3_Tap_1.pdf',
        'createdAt': '2026-10-12',
      },
      {
        'id': 2,
        'title': 'Vở bài tập Tiếng Việt 3',
        'subjectName': 'Tiếng Việt',
        'teacherName': 'Cô Lê Thu Hà',
        'fileType': 'PDF',
        'fileSize': '3.5 MB',
        'filePath': 'file:///storage/emulated/0/Download/VBT_Tieng_Viet_3.pdf',
        'createdAt': '2026-10-11',
      },
      {
        'id': 3,
        'title': 'Sách Tiếng Anh 3 - Global Success',
        'subjectName': 'Tiếng Anh',
        'teacherName': 'Thầy Phạm Quốc Bảo',
        'fileType': 'PDF',
        'fileSize': '6.2 MB',
        'filePath': 'file:///storage/emulated/0/Download/Tieng_Anh_3_Global_Success.pdf',
        'createdAt': '2026-10-10',
      },
      {
        'id': 4,
        'title': 'Phiếu ôn tập Toán tuần 5',
        'subjectName': 'Toán',
        'teacherName': 'Cô Lê Thu Hà',
        'fileType': 'PDF',
        'fileSize': '1.2 MB',
        'filePath': 'file:///storage/emulated/0/Download/Phieu_On_Tap_Toan_T5.pdf',
        'createdAt': '2026-10-09',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockNotices() {
    return [
      {
        'id': 1,
        'title': 'Họp phụ huynh đầu học kỳ 1 năm học 2026–2027',
        'date': '09/10/2026',
        'time': '17:00',
        'audience': 'Toàn trường',
        'sender': 'Ban Giám Hiệu',
        'isRead': false,
        'body': 'Nhà trường kính mời quý phụ huynh đến tham dự buổi họp phụ huynh đầu năm vào lúc 17:00 ngày 16/10/2026 tại Hội trường tầng 3. Nội dung: Phổ biến kế hoạch học tập, phương pháp rèn luyện và bầu Ban đại diện cha mẹ học sinh.',
      },
      {
        'id': 2,
        'title': 'Đổi giờ ra về chiều thứ Sáu ngày 16/10',
        'date': '08/10/2026',
        'time': '15:30',
        'audience': 'Lớp 3A',
        'sender': 'Cô Lê Thu Hà (GVCN)',
        'isRead': false,
        'body': 'Kính báo quý phụ huynh lớp 3A: Chiều thứ Sáu ngày 16/10 nhà trường tổ chức tập huấn chuyên môn giáo viên, học sinh lớp 3A sẽ tan học sớm 30 phút (lúc 16h00). Kính mong quý phụ huynh đón con đúng giờ.',
      },
      {
        'id': 3,
        'title': 'Kế hoạch kiểm tra sức khỏe và nha học đường định kỳ',
        'date': '05/10/2026',
        'time': '08:00',
        'audience': 'Khối 3',
        'sender': 'Phòng Y Tế Học Đường',
        'isRead': true,
        'body': 'Học sinh toàn khối 3 sẽ được khám sức khỏe định kỳ (chiều cao, cân nặng, thị lực, răng miệng) từ ngày 19/10 đến 23/10. Phụ huynh vui lòng nhắc con ăn sáng đầy đủ trước khi đến trường.',
      },
      {
        'id': 4,
        'title': 'Phát động phong trào thi đua chào mừng Ngày Nhà giáo 20/11',
        'date': '01/10/2026',
        'time': '07:30',
        'audience': 'Toàn trường',
        'sender': 'Tổng Phụ Trách Đội',
        'isRead': true,
        'body': 'Liên đội trường Tiểu học Đại Việt phát động chuỗi hoạt động ý nghĩa: Hội thi làm báo tường, tuần học tốt hoa điểm 10 và giải bóng đá mini cấp trường.',
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
    ThemeManager? themeManager;
    try {
      themeManager = Provider.of<ThemeManager>(context);
    } catch (_) {
      themeManager = null;
    }
    final textMainColor = themeManager?.textMain ?? AppColors.textMain;
    final bgImagePath = themeManager?.bgImagePath ?? 'images/school_bg.jpg';

    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMainColor),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, thickness: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textMainColor),
            onPressed: _loadAllData,
            tooltip: 'Tải lại dữ liệu',
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textMainColor),
            onPressed: _showMoreBottomSheet,
            tooltip: 'Cài đặt & Tiện ích',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Column(
        children: [
          const DemoModeBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _buildCurrentTab(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
        ),
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
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Lịch học',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Sách học',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Bài tập',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Bảng điểm',
            ),
            BottomNavigationBarItem(
              icon: _unreadNoticesCount > 0
                  ? Badge.count(
                      count: _unreadNoticesCount,
                      backgroundColor: AppColors.error,
                      child: const Icon(Icons.notifications_outlined),
                    )
                  : const Icon(Icons.notifications_outlined),
              activeIcon: _unreadNoticesCount > 0
                  ? Badge.count(
                      count: _unreadNoticesCount,
                      backgroundColor: AppColors.error,
                      child: const Icon(Icons.notifications),
                    )
                  : const Icon(Icons.notifications),
              label: 'Thông báo',
            ),
          ],
        ),
      ),
    );

    // Giao diện App Mobile chứa hình nền học đường động với hiệu ứng Bokeh Blur
    final Widget mobileApp = ClipRRect(
      borderRadius: BorderRadius.zero,
      child: Stack(
        children: [
          // 1. Hình nền học đường được chọn bởi người dùng với hiệu ứng Mờ nhẹ Soft Focus (2px) trong trẻo, sắc nét
          Positioned.fill(
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                child: Transform.scale(
                  scale: 1.02, // Giảm scale tối thiểu, tránh viền mờ màu trắng ở 4 góc cạnh
                  child: Image.asset(
                    bgImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          // 2. Lớp phủ làm dịu mỏng nhẹ 8% trắng giúp ảnh trong trẻo rực rỡ và thẻ trắng nổi khối 3D
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          // 3. Toàn bộ nội dung giao diện Scaffold của học sinh
          scaffold,
        ],
      ),
    );

    // Khi chạy trên Web / Desktop: Bọc khung mobile 480px đặt trên nền Studio tối làm nổi bật màn hình app
    if (kIsWeb) {
      return Container(
        color: const Color(0xFF0F172A), // Nền xám đen studio sang trọng bên ngoài
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.zero,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 36,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: mobileApp,
            ),
          ),
        ),
      );
    }

    return mobileApp;
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Trang chủ';
      case 1:
        return 'Lịch học';
      case 2:
        return 'Sách học';
      case 3:
        return 'Bài tập';
      case 4:
        return 'Bảng điểm & Kết quả';
      case 5:
        return 'Thông báo';
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
        return _buildMarksTab();
      case 5:
        return _buildNoticeTab();
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
    final educationLevel = EducationLevelHelper.fromGrade(_profile?['grade']);
    final levelShortTitle = EducationLevelHelper.getShortTitle(educationLevel);
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
                color: Colors.white,
                border: Border.all(color: AppColors.warning),
                borderRadius: BorderRadius.zero,
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
              color: Colors.white,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        studentName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Text(
                        levelShortTitle,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
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

          // Section 1: Sách đọc mới
          AppSectionHeader(
            title: 'Sách đọc mới',
            linkLabel: 'Xem tất cả',
            onLink: () => setState(() => _currentIndex = 2),
          ),
          const SizedBox(height: 8),
          if (_hasMaterialsError)
            AppCardErrorWithRetry(
              title: 'Không thể tải sách đọc mới',
              onRetry: _loadMaterials,
            )
          else if (_materials.isEmpty)
            const AppEmptyCard(
              title: 'Chưa có sách đọc mới',
              message: 'Thầy cô chưa chia sẻ sách đọc mới cho lớp.',
              icon: Icons.menu_book_outlined,
            )
          else
            ..._materials.take(2).map((m) => MaterialCard(data: Map<String, dynamic>.from(m as Map))),
          const SizedBox(height: 20),

          // Section 2: Bài tập cần làm
          AppSectionHeader(
            title: 'Bài tập cần làm',
            linkLabel: 'Xem tất cả',
            onLink: () => setState(() => _currentIndex = 3),
          ),
          const SizedBox(height: 8),
          if (_hasHomeworkError)
            AppCardErrorWithRetry(
              title: 'Không thể tải bài tập về nhà',
              onRetry: _loadHomework,
            )
          else if (_todoHomework.isEmpty)
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

          // Section 3: Lịch học hôm nay
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
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
              ),
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
                    onTap: () => _showLessonDetailModal(
                      lessonIndex: i + 1,
                      subject: l['subj']!,
                      time: l['time']!,
                      teacher: l['teacher']!,
                      room: l['room']!,
                    ),
                  );
                }).toList(),
              ),
            ),
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
            color: Colors.white,
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
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 3.0 : 1.0,
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                  ),
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
                        onTap: () => _showLessonDetailModal(
                          lessonIndex: i + 1,
                          subject: l['subj']!,
                          time: l['time']!,
                          teacher: l['teacher']!,
                          room: l['room']!,
                        ),
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

  // ===================== TAB 2: SÁCH HỌC =====================
  Widget _buildMatTab() {
    final educationLevel = EducationLevelHelper.fromGrade(_profile?['grade']);
    final subjects = EducationLevelHelper.getDefaultSubjects(educationLevel);
    final levelTitle = EducationLevelHelper.getTitle(educationLevel);
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
            color: Colors.white,
          ),
          child: Text(
            'Sách giáo khoa và tài liệu học tập $levelTitle được chia sẻ cho lớp ${_profile?['className'] ?? '3A'}.',
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
        if (_hasMaterialsError)
          AppCardErrorWithRetry(
            title: 'Không thể tải sách học liệu',
            onRetry: _loadMaterials,
          )
        else if (filtered.isEmpty)
          const AppEmptyCard(
            title: 'Chưa có sách học',
            message: 'Thầy cô chưa chia sẻ sách học cho môn này.',
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
            color: Colors.white,
          ),
          child: const Text(
            'Làm bài ngay trong ứng dụng. Bài làm được lưu nháp tự động, hạn nộp tính theo giờ máy chủ.',
            style: TextStyle(fontSize: 13, color: AppColors.textSub),
          ),
        ),
        const SizedBox(height: 20),

        if (_hasHomeworkError)
          AppCardErrorWithRetry(
            title: 'Không thể tải danh sách bài tập',
            onRetry: _loadHomework,
          )
        else ...[
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
      ],
    );
  }

  // ===================== TAB 4: BẢNG ĐIỂM & KẾT QUẢ HỌC TẬP =====================
  Widget _buildMarksTab() {
    // 1. Tính toán số liệu thống kê học lực
    double totalScore = 0.0;
    int validCount = 0;
    int perfectCount = 0;
    for (final m in _marks) {
      final sc = m['score'];
      if (sc != null) {
        final val = (sc is num) ? sc.toDouble() : double.tryParse(sc.toString());
        if (val != null) {
          totalScore += val;
          validCount++;
          if (val >= 10.0) {
            perfectCount++;
          }
        }
      }
    }
    final double avgScore = validCount > 0 ? (totalScore / validCount) : 0.0;

    // Xếp loại học lực theo màu xanh dương thương hiệu
    String academicRank = 'Chưa xếp loại';
    Color rankColor = AppColors.textSub;
    Color rankBg = AppColors.surfaceAlt;
    if (validCount > 0) {
      if (avgScore >= 9.0) {
        academicRank = 'Học lực Xuất sắc';
        rankColor = AppColors.primary;
        rankBg = const Color(0xFFE8F0FE);
      } else if (avgScore >= 8.0) {
        academicRank = 'Học lực Giỏi';
        rankColor = AppColors.primary;
        rankBg = const Color(0xFFE8F0FE);
      } else if (avgScore >= 6.5) {
        academicRank = 'Học lực Khá';
        rankColor = AppColors.warning;
        rankBg = const Color(0xFFFEF7E0);
      } else {
        academicRank = 'Đang rèn luyện';
        rankColor = AppColors.textSub;
        rankBg = AppColors.surfaceAlt;
      }
    }

    // 2. Bộ lọc đợt kiểm tra
    const examFilters = ['Tất cả', 'Giữa kỳ', 'Định kỳ', 'Cuối kỳ'];
    final filteredMarks = _marks.where((m) {
      if (_selectedExamFilter == 'Tất cả') return true;
      final exam = (m['examName'] ?? m['examType'] ?? '').toString().toLowerCase();
      final filter = _selectedExamFilter.toLowerCase();
      return exam.contains(filter);
    }).toList();

    final classTeacher = _profile?['classTeacher'] ?? 'Cô Lê Thu Hà';

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Banner chế độ Demo (nếu đang bật)
          if (FeatureFlags.useDemoFallback)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
                border: Border.all(color: AppColors.warning, width: 1.0),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bảng điểm đang hiển thị dữ liệu mô phỏng để minh họa tính năng.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSub),
                    ),
                  ),
                ],
              ),
            ),

          // 1. Hero KPI Card - Tổng quan kết quả học tập
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: AppColors.border, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ĐIỂM TRUNG BÌNH HỌC KỲ',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.textSub,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              avgScore.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMainOf(context),
                                height: 1.0,
                              ),
                            ),
                            const Text(
                              ' / 10.0',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSub,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: rankBg,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: rankColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium, size: 16, color: rankColor),
                          const SizedBox(width: 4),
                          Text(
                            academicRank,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: rankColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 14),
                // 3 Chỉ số phụ
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiMiniItem(
                        label: 'Số môn kiểm tra',
                        value: '$validCount môn',
                        icon: Icons.assignment_turned_in_outlined,
                      ),
                    ),
                    Container(width: 1, height: 32, color: AppColors.border),
                    Expanded(
                      child: _buildKpiMiniItem(
                        label: 'Điểm 10 tuyệt đối',
                        value: '$perfectCount môn',
                        icon: Icons.star_outline,
                      ),
                    ),
                    Container(width: 1, height: 32, color: AppColors.border),
                    Expanded(
                      child: _buildKpiMiniItem(
                        label: 'Tiến độ học tập',
                        value: '100% Hoàn thành',
                        icon: Icons.verified_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 2. Bộ lọc đợt kiểm tra (Filter Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: examFilters.map((filter) {
                final isSelected = _selectedExamFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.textMain,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedExamFilter = filter);
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Tiêu đề danh sách môn học
          AppSectionHeader(
            title: 'Kết quả chi tiết từng môn (${filteredMarks.length})',
          ),
          const SizedBox(height: 10),

          // 4. Danh sách thẻ điểm
          if (filteredMarks.isEmpty)
            const AppEmptyCard(
              title: 'Không có bài kiểm tra',
              message: 'Chưa có dữ liệu bài kiểm tra nào phù hợp với bộ lọc đã chọn.',
              icon: Icons.grade_outlined,
            )
          else
            ...filteredMarks.map((m) {
              final subject = (m['subjectName'] ?? 'Môn học').toString();
              final score = m['score'];
              final maxScore = m['maxScore'] ?? 10.0;
              final exam = (m['examName'] ?? m['examType'] ?? 'Kiểm tra định kỳ').toString();
              final grade = (m['grade'] ?? 'Đạt').toString();
              final scoreNum = (score is num) ? score.toDouble() : (double.tryParse(score?.toString() ?? '0') ?? 0.0);
              final maxScoreNum = (maxScore is num) ? maxScore.toDouble() : 10.0;
              final progress = (maxScoreNum > 0) ? (scoreNum / maxScoreNum).clamp(0.0, 1.0) : 0.0;

              // Màu sắc theo thang điểm chuẩn thương hiệu Xanh dương
              Color scoreColor = AppColors.primary;
              if (scoreNum >= 8.0) {
                scoreColor = AppColors.primary; // Xanh dương thương hiệu cho điểm giỏi và xuất sắc
              } else if (scoreNum >= 6.5) {
                scoreColor = AppColors.warning;
              } else {
                scoreColor = AppColors.error;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: AppColors.border, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Icon(_getSubjectIcon(subject), color: scoreColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMainOf(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                exam,
                                style: const TextStyle(fontSize: 12.5, color: AppColors.textSub),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  score != null ? score.toString() : '-',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: scoreColor,
                                  ),
                                ),
                                Text(
                                  '/$maxScoreNum',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSub,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: scoreColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.zero,
                              ),
                              child: Text(
                                grade,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Thanh đo điểm số trực quan phẳng vuông vức
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceAlt,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 12),

          // 5. Thẻ Đánh giá Rèn luyện & Nhận xét GVCN
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology_outlined, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Đánh giá Rèn luyện & Khen thưởng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMainOf(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Xếp loại Rèn luyện / Hạnh kiểm:',
                        style: TextStyle(fontSize: 13, color: AppColors.textSub),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: const Text(
                        'Tốt (Xuất sắc)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.format_quote, color: AppColors.primary, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Em có tinh thần học tập tự giác rất cao, tích cực tương tác trong giờ học và đạt thành tích xuất sắc ở tất cả các môn. Hãy tiếp tục phát huy nhé!\n— $classTeacher',
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildKpiMiniItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textMain),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AppColors.textSub),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getSubjectIcon(String subjectName) {
    final lower = subjectName.toLowerCase();
    if (lower.contains('toán')) return Icons.calculate_outlined;
    if (lower.contains('văn') || lower.contains('việt')) return Icons.edit_note_outlined;
    if (lower.contains('anh') || lower.contains('ngữ')) return Icons.language_outlined;
    if (lower.contains('tin') || lower.contains('công nghệ')) return Icons.computer_outlined;
    if (lower.contains('tự nhiên') || lower.contains('khtn') || lower.contains('khoa học')) return Icons.eco_outlined;
    if (lower.contains('sử') || lower.contains('địa')) return Icons.public_outlined;
    if (lower.contains('lý') || lower.contains('vật')) return Icons.bolt_outlined;
    if (lower.contains('hóa')) return Icons.science_outlined;
    if (lower.contains('sinh')) return Icons.biotech_outlined;
    if (lower.contains('nhạc') || lower.contains('âm')) return Icons.music_note_outlined;
    if (lower.contains('mỹ thuật') || lower.contains('vẽ')) return Icons.palette_outlined;
    if (lower.contains('thể dục') || lower.contains('gd thể chất')) return Icons.sports_soccer_outlined;
    return Icons.school_outlined;
  }

  int get _unreadNoticesCount => _notices.where((n) => n['isRead'] == false).length;

  // ===================== TAB 5: THÔNG BÁO =====================
  Widget _buildNoticeTab() {
    final dynamicAudiences = <String>['Tất cả'];
    for (final n in _notices) {
      final aud = (n['audience'] ?? '').toString().trim();
      if (aud.isNotEmpty && !dynamicAudiences.contains(aud)) {
        dynamicAudiences.add(aud);
      }
    }
    final audiences = dynamicAudiences.length > 1
        ? dynamicAudiences
        : ['Tất cả', 'Toàn trường', _profile?['className'] ?? 'Lớp 3A'];

    final filtered = _selectedNoticeAudience == 'Tất cả'
        ? _notices
        : _notices.where((n) => (n['audience'] ?? '').toString() == _selectedNoticeAudience).toList();
    final unreadCount = _unreadNoticesCount;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banner tóm tắt
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.campaign, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bảng tin & Thông báo nhà trường',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unreadCount > 0
                          ? 'Em có $unreadCount thông báo mới chưa đọc.'
                          : 'Đã cập nhật đầy đủ mọi thông báo.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: unreadCount > 0 ? AppColors.primary : AppColors.textSub,
                        fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bộ lọc phạm vi thông báo
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: audiences.map((aud) {
              final isSel = _selectedNoticeAudience == aud;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(aud),
                  selected: isSel,
                  onSelected: (val) {
                    if (val) setState(() => _selectedNoticeAudience = aud);
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

        // Danh sách thông báo
        if (filtered.isEmpty)
          const AppEmptyCard(
            title: 'Chưa có thông báo',
            message: 'Không có thông báo nào trong danh mục này.',
            icon: Icons.notifications_none_outlined,
          )
        else
          ...filtered.map((n) {
            final isRead = n['isRead'] == true;
            return InkWell(
              onTap: () => _showNoticeDetailModal(n),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.5),
                    width: isRead ? 1.0 : 1.5,
                  ),
                  color: Colors.white,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Icon(
                        isRead ? Icons.notifications_none : Icons.notifications_active,
                        color: isRead ? AppColors.textSub : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  n['audience'] ?? 'Chung',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSub),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${n['date']} · ${n['time']}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            n['title'] ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n['content'] ?? n['body'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSub, height: 1.35),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: AppColors.textSub),
                              const SizedBox(width: 4),
                              Text(
                                n['sender'] ?? 'Nhà trường',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSub, fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              if (!isRead)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'MỚI',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  void _showNoticeDetailModal(Map<String, dynamic> n) {
    if (n['isRead'] != true) {
      setState(() {
        n['isRead'] = true;
      });
      if (n['id'] != null) {
        _portalService.markNoticeAsRead(n['id']).ignore();
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        n['audience'] ?? 'Toàn trường',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppColors.textSub),
                      onPressed: () => Navigator.of(ctx).pop(),
                      tooltip: 'Đóng',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  n['title'] ?? '',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textMain, height: 1.3),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.textSub),
                    const SizedBox(width: 4),
                    Text(
                      '${n['date']} lúc ${n['time']}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.person_outline, size: 14, color: AppColors.textSub),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        n['sender'] ?? '',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1, color: AppColors.border),
                Text(
                  n['body'] ?? n['content'] ?? '',
                  style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textMain),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Đã hiểu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreBottomSheet() {
    final studentName = _profile?['name'] ?? 'Nguyễn Minh Anh';
    final studentId = _profile?['admissionNumber'] ?? _profile?['rollNo'] ?? _profile?['studentId'] ?? 'HS001';
    final className = FormatUtils.formatClassName(
      grade: _profile?['grade']?.toString(),
      section: _profile?['section']?.toString(),
      fallback: _profile?['className']?.toString(),
    );
    final teacher = _profile?['classTeacher'] ?? 'Cô Lê Thu Hà';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tiện ích học sinh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSub, size: 22),
                      onPressed: () => Navigator.of(ctx).pop(),
                      tooltip: 'Đóng',
                    ),
                  ],
                ),
                const Divider(height: 16, thickness: 1, color: AppColors.border),
                const SizedBox(height: 8),

                // Thẻ thông tin cá nhân tóm tắt
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    color: Colors.white,
                  ),
                  child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
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
              const SizedBox(height: 12),

              // Các chức năng
              Material(
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildMoreRow(
                      title: 'Bảng điểm & Kết quả học tập',
                      sub: 'Xem chi tiết kết quả học tập & điểm thi',
                      icon: Icons.analytics_outlined,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        setState(() => _currentIndex = 4);
                      },
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.border),
                    _buildMoreRow(
                      title: 'Lịch sử Chuyên cần / Điểm danh',
                      icon: Icons.event_available_outlined,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _showAttendanceBottomSheet();
                      },
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.border),
                    _buildMoreRow(
                      title: 'Thông tin giáo viên chủ nhiệm',
                      sub: teacher,
                      icon: Icons.school_outlined,
                      onTap: () {},
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.border),
                    _buildMoreRow(
                      title: 'Giao diện & Cá nhân hóa',
                      sub: 'Màu chữ & 8 hình nền học đường',
                      icon: Icons.palette_outlined,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _showThemeCustomizationSheet();
                      },
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.border),
                    SwitchListTile(
                      value: FeatureFlags.useDemoFallback,
                      onChanged: (val) {
                        setSheetState(() {
                          FeatureFlags.useDemoFallback = val;
                        });
                        setState(() {});
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
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _logout();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
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

  // Modal xem Chi tiết Tiết học
  void _showLessonDetailModal({
    required int lessonIndex,
    required String subject,
    required String time,
    required String teacher,
    required String room,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header với nút đóng
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                'Tiết $lessonIndex',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Thông tin tiết học',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSub, size: 22),
                          onPressed: () => Navigator.of(ctx).pop(),
                          tooltip: 'Đóng',
                        ),
                      ],
                    ),
                    const Divider(height: 16, thickness: 1, color: AppColors.border),
                    const SizedBox(height: 12),

                    // Thẻ thông tin Môn học nổi bật
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                ),
                                child: const Icon(Icons.menu_book, color: AppColors.primary, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textMain,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 14, color: AppColors.textSub),
                                        const SizedBox(width: 4),
                                        Text(
                                          time,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSub,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, thickness: 1, color: AppColors.border),
                          // Chi tiết Giáo viên & Phòng học
                          _buildDetailInfoRow(
                            icon: Icons.person_outline,
                            label: 'Giáo viên giảng dạy',
                            value: teacher,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailInfoRow(
                            icon: Icons.meeting_room_outlined,
                            label: 'Phòng học / Địa điểm',
                            value: room,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nhắc nhở học sinh
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Em vui lòng chuẩn bị sách giáo khoa, vở bài tập và tài liệu học tập của môn $subject trước khi vào lớp.',
                              style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSub),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nút Đóng
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Đã hiểu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSub),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(fontSize: 13, color: AppColors.textSub),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
        ),
      ],
    );
  }

  void _showThemeCustomizationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          ThemeManager? themeManager;
          try {
            themeManager = Provider.of<ThemeManager>(context);
          } catch (_) {
            themeManager = null;
          }

          final currentMode = themeManager?.textColorMode ?? AppTextColorMode.defaultBlack;
          final currentBg = themeManager?.bgImagePath ?? 'images/school_bg.jpg';

          return Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.palette_outlined, color: AppColors.primary, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Giao diện & Cá nhân hóa',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSub, size: 22),
                          onPressed: () => Navigator.of(ctx).pop(),
                          tooltip: 'Đóng',
                        ),
                      ],
                    ),
                    const Divider(height: 16, thickness: 1, color: AppColors.border),
                    Expanded(
                      child: ListView(
                        children: [
                          // Mục 1: Chọn màu chữ giao diện
                          const Text(
                            'MÀU CHỮ GIAO DIỆN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.textSub,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildTextColorOption(
                                label: 'Mặc định',
                                mode: AppTextColorMode.defaultBlack,
                                color: const Color(0xFF202124),
                                isSelected: currentMode == AppTextColorMode.defaultBlack,
                                onSelect: () {
                                  themeManager?.setTextColorMode(AppTextColorMode.defaultBlack);
                                  setState(() {});
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildTextColorOption(
                                label: 'Xanh lá',
                                mode: AppTextColorMode.green,
                                color: const Color(0xFF1B5E20),
                                isSelected: currentMode == AppTextColorMode.green,
                                onSelect: () {
                                  themeManager?.setTextColorMode(AppTextColorMode.green);
                                  setState(() {});
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildTextColorOption(
                                label: 'Xanh lục',
                                mode: AppTextColorMode.emerald,
                                color: const Color(0xFF004D40),
                                isSelected: currentMode == AppTextColorMode.emerald,
                                onSelect: () {
                                  themeManager?.setTextColorMode(AppTextColorMode.emerald);
                                  setState(() {});
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildTextColorOption(
                                label: 'Hồng',
                                mode: AppTextColorMode.pink,
                                color: const Color(0xFFAD1457),
                                isSelected: currentMode == AppTextColorMode.pink,
                                onSelect: () {
                                  themeManager?.setTextColorMode(AppTextColorMode.pink);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Mục 2: Chọn hình nền học đường
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'HÌNH NỀN HỌC ĐƯỜNG',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: AppColors.textSub,
                                ),
                              ),
                              Text(
                                '${ThemeManager.availableBackgrounds.length} hình ảnh',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.45,
                            ),
                            itemCount: ThemeManager.availableBackgrounds.length,
                            itemBuilder: (context, index) {
                              final b = ThemeManager.availableBackgrounds[index];
                              final isSelected = currentBg == b.assetPath;

                              return InkWell(
                                onTap: () {
                                  themeManager?.setBackgroundImage(b.assetPath);
                                  setState(() {});
                                },
                                borderRadius: BorderRadius.zero,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.zero,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.border,
                                      width: isSelected ? 2.5 : 1.0,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.zero,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.asset(
                                          b.assetPath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Container(
                                            color: AppColors.surfaceAlt,
                                            child: const Icon(Icons.image_not_supported, color: AppColors.textSub),
                                          ),
                                        ),
                                        // Gradient đen mờ ở chân ảnh để đọc tên
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          height: 38,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  Colors.black.withValues(alpha: 0.75),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                              b.nameVi,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.zero,
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.check, size: 12, color: Colors.white),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    'Đang dùng',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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

  Widget _buildTextColorOption({
    required String label,
    required AppTextColorMode mode,
    required Color color,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.zero,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : AppColors.textMain,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

