import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:ashadeep/models/markbook.dart';
import 'package:ashadeep/features/student/widgets/marks/student_marks_tab.dart';
import 'package:ashadeep/features/student/widgets/mascot/primary_animal_identity_card.dart';

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
  bool _isWeeklyView = false; // false: Lịch theo ngày, true: Lịch theo tuần toàn bộ

  // Bộ lọc môn học trong tab Học liệu
  String _selectedSubjectFilter = 'Tất cả';

  StudentMarkbook? _markbook;

  // Thông báo
  String _selectedNoticeAudience = 'Tất cả';
  List<Map<String, dynamic>> _notices = [];

  @override
  void initState() {
    super.initState();
    // 1. Nạp dữ liệu khởi tạo tức thì (0ms Fast Render đồng bộ trước frame build đầu tiên)
    _profile = _getAdaptiveMockProfileSync();
    _attendance = _getMockAttendance();
    _marks = _getMockMarks();
    _homework = _getMockHomework();
    _materials = _getMockMaterials();
    _notices = _getMockNotices();
    _isLoading = false;

    // 2. Đưa việc cập nhật Theme Provider và đồng bộ ngầm sau khi frame đầu đã hoàn tất dựng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final level = EducationLevelHelper.fromGrade(_profile?['grade'], _profile?['educationLevel']);
      try {
        Provider.of<ThemeManager>(context, listen: false).setEducationLevel(level);
      } catch (_) {}
      _loadAllData();
    });
  }

  void _safeUpdateThemeEducationLevel(EducationLevel level) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        Provider.of<ThemeManager>(context, listen: false).setEducationLevel(level);
      } catch (_) {}
    });
  }

  /// Tải dữ liệu toàn diện theo mô hình Progressive Rendering:
  /// Khởi chạy song song nhưng độc lập, phần nào có dữ liệu kết xuất ngay phần đó.
  Future<void> _loadAllData() async {
    // Nếu môi trường thuần Demo tĩnh (chạy không có máy chủ backend thật)
    if (ApiConstants.isDemoMode) {
      _syncProfileWithStoredSession();
      return;
    }

    // Đồng bộ ngầm với Backend (Progressive Live Sync)
    // Phần nào có API thật trả về sẽ cập nhật đè lên giao diện; nếu offline, giữ nguyên fallback an toàn.
    try {
      await Future.wait([
        _loadProfile(),
        _loadAttendance(),
        _loadMarks(),
        _loadHomework(),
        _loadMaterials(),
        _loadNotices(),
      ]);
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProfile() async {
    try {
      final p = await _portalService.getMyProfile();
      Map<String, dynamic>? profileData = p;
      if (profileData == null && FeatureFlags.useDemoFallback) {
        profileData = _getAdaptiveMockProfileSync();
      }
      if (!mounted) return;
      if (profileData != null) {
        setState(() {
          _profile = profileData;
          _isLoading = false; // Có profile là hiển thị khung trang chủ ngay
        });
        final level = EducationLevelHelper.fromGrade(_profile?['grade'], _profile?['educationLevel']);
        _safeUpdateThemeEducationLevel(level);
      }
    } catch (_) {
      if (FeatureFlags.useDemoFallback) {
        final mock = _getAdaptiveMockProfileSync();
        if (!mounted) return;
        setState(() {
          _profile = mock;
          _isLoading = false;
        });
        final level = EducationLevelHelper.fromGrade(_profile?['grade'], _profile?['educationLevel']);
        _safeUpdateThemeEducationLevel(level);
      }
    }
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
      final futures = await Future.wait([
        _portalService.getMyMarks(),
        _portalService.getMyMarkbook(),
      ]);
      final m = futures[0] as List<Map<String, dynamic>>;
      final mb = futures[1] as StudentMarkbook?;
      if (mounted) {
        setState(() {
          _marks = m.isNotEmpty ? m : (FeatureFlags.useDemoFallback ? _getMockMarks() : []);
          _markbook = mb ?? (FeatureFlags.useDemoFallback ? _getAdaptiveMockMarkbook() : null);
        });
      }
    } catch (_) {
      if (mounted && FeatureFlags.useDemoFallback) {
        setState(() {
          _marks = _getMockMarks();
          _markbook = _getAdaptiveMockMarkbook();
        });
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

  String _extractDobDMY(Map<String, dynamic>? profile) {
    if (profile == null) return '20102026';
    final raw = profile['dob'] ?? profile['dateOfBirth'];
    if (raw == null) return '20102026';
    final s = raw.toString().trim();
    final isoMatch = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(s);
    if (isoMatch != null) {
      final y = isoMatch.group(1)!;
      final m = isoMatch.group(2)!.padLeft(2, '0');
      final d = isoMatch.group(3)!.padLeft(2, '0');
      return '$d/$m/$y';
    }
    return s;
  }

  Map<String, dynamic> _getAdaptiveMockProfileSync() {
    final userData = AuthService.currentSessionUser;
    if (userData == null) {
      // Mặc định cho Standalone & Widget Tests khi chưa qua màn đăng nhập
      return {
        'id': 1,
        'name': 'Nguyễn Minh Anh',
        'grade': '10',
        'section': 'A1',
        'className': 'Lớp 10A1',
        'rollNo': 'HS001',
        'admissionNumber': 'HS-2026-001',
        'classTeacher': 'Cô Lê Thu Hà',
        'homeroomTeacherName': 'Cô Lê Thu Hà',
        'schoolName': 'Trường THPT Astra',
        'educationLevel': 'HIGH_SCHOOL',
        'educationLevelName': 'THPT',
        'dob': '2010-08-15',
        'dateOfBirth': '15/08/2010',
        'gender': 'Nữ',
        'parentName': 'Nguyễn Văn Hùng',
        'parentPhone': '0910157611',
      };
    }

    final rawGrade = userData['grade']?.toString() ?? '';
    final rawLevel = userData['educationLevel']?.toString() ?? '';
    final username = (userData['loginUsername'] ?? userData['username'] ?? '').toString().toLowerCase();

    // 1. Phân loại chuẩn xác theo username, educationLevel hoặc khối lớp cụ thể
    final isSec = username.contains('student02') ||
        username.contains('hocsinh2') ||
        username.contains('6a') ||
        rawLevel.toUpperCase().contains('SEC') ||
        RegExp(r'^(6|7|8|9)').hasMatch(rawGrade);

    final isHigh = username.contains('student03') ||
        username.contains('hocsinh3') ||
        username.contains('10a') ||
        rawLevel.toUpperCase().contains('HIGH') ||
        rawLevel.toUpperCase().contains('THPT') ||
        RegExp(r'^(10|11|12)').hasMatch(rawGrade);

    final isPrim = username.contains('student01') ||
        username.contains('hocsinh1') ||
        username.contains('1a') ||
        rawLevel.toUpperCase().contains('PRIM') ||
        (RegExp(r'^[1-5]').hasMatch(rawGrade) && !RegExp(r'^(10|11|12)').hasMatch(rawGrade));

    if (isSec) {
      return {
        'id': 2,
        'name': userData['name'] ?? 'Trần Bảo Nam',
        'grade': '6',
        'section': 'A',
        'className': 'Lớp 6A',
        'rollNo': 'HS002',
        'admissionNumber': 'STU002',
        'classTeacher': 'Thầy Nguyễn Văn Nam',
        'homeroomTeacherName': 'Thầy Nguyễn Văn Nam',
        'schoolName': 'Trường THCS Astra',
        'educationLevel': 'SECONDARY',
        'educationLevelName': 'THCS',
        'dob': '2015-04-18',
        'dateOfBirth': '18/04/2015',
        'gender': 'Nam',
      };
    } else if (isHigh) {
      return {
        'id': 3,
        'name': userData['name'] ?? 'Lê Hoàng Long',
        'grade': '10',
        'section': 'A1',
        'className': 'Lớp 10A1',
        'rollNo': 'HS003',
        'admissionNumber': 'STU003',
        'classTeacher': 'Cô Lê Thu Hà',
        'homeroomTeacherName': 'Cô Lê Thu Hà',
        'schoolName': 'Trường THPT Astra',
        'educationLevel': 'HIGH_SCHOOL',
        'educationLevelName': 'THPT',
        'dob': '2010-08-15',
        'dateOfBirth': '15/08/2010',
        'gender': 'Nữ',
        'parentName': 'Nguyễn Văn Hùng',
        'parentPhone': '0910157611',
      };
    } else if (isPrim) {
      return {
        'id': 1,
        'name': userData['name'] ?? 'Hoàng Văn Thư',
        'grade': '1',
        'section': 'A',
        'className': 'Lớp 1A',
        'rollNo': 'HS001',
        'admissionNumber': 'STU001',
        'classTeacher': 'Cô Nguyễn Thị Lan',
        'homeroomTeacherName': 'Cô Nguyễn Thị Lan',
        'schoolName': 'Trường Tiểu học Astra',
        'educationLevel': 'PRIMARY',
        'educationLevelName': 'Tiểu học',
        'dob': '2020-10-20',
        'dateOfBirth': '20/10/2020',
        'gender': 'Nam',
      };
    } else {
      // Mặc định cho Standalone & Widget Tests: Cấp 3 THPT
      final level = rawGrade.isNotEmpty ? EducationLevelHelper.fromGrade(rawGrade, rawLevel) : EducationLevel.highSchool;
      if (level == EducationLevel.secondary) {
        return {
          'id': 2,
          'name': userData['name'] ?? 'Trần Bảo Nam',
          'grade': '6',
          'section': 'A',
          'className': 'Lớp 6A',
          'rollNo': 'HS002',
          'admissionNumber': 'STU002',
          'classTeacher': 'Thầy Nguyễn Văn Nam',
          'homeroomTeacherName': 'Thầy Nguyễn Văn Nam',
          'schoolName': 'Trường THCS Astra',
          'educationLevel': 'SECONDARY',
          'educationLevelName': 'THCS',
          'dob': '2015-04-18',
          'dateOfBirth': '18/04/2015',
          'gender': 'Nam',
        };
      } else if (level == EducationLevel.primary) {
        return {
          'id': 1,
          'name': userData['name'] ?? 'Hoàng Văn Thư',
          'grade': '1',
          'section': 'A',
          'className': 'Lớp 1A',
          'rollNo': 'HS001',
          'admissionNumber': 'STU001',
          'classTeacher': 'Cô Nguyễn Thị Lan',
          'homeroomTeacherName': 'Cô Nguyễn Thị Lan',
          'schoolName': 'Trường Tiểu học Astra',
          'educationLevel': 'PRIMARY',
          'educationLevelName': 'Tiểu học',
          'dob': '2020-10-20',
          'dateOfBirth': '20/10/2020',
          'gender': 'Nam',
        };
      }
      return {
        'id': 1,
        'name': userData['name'] ?? 'Nguyễn Minh Anh',
        'grade': '10',
        'section': 'A1',
        'className': 'Lớp 10A1',
        'rollNo': 'HS001',
        'admissionNumber': 'HS-2026-001',
        'classTeacher': 'Cô Lê Thu Hà',
        'homeroomTeacherName': 'Cô Lê Thu Hà',
        'schoolName': 'Trường THPT Astra',
        'educationLevel': 'HIGH_SCHOOL',
        'educationLevelName': 'THPT',
        'dob': '2010-08-15',
        'dateOfBirth': '15/08/2010',
        'gender': 'Nữ',
        'parentName': 'Nguyễn Văn Hùng',
        'parentPhone': '0910157611',
      };
    }
  }

  Future<void> _syncProfileWithStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('user_data');
      if (str != null && str.isNotEmpty) {
        final userData = jsonDecode(str) as Map<String, dynamic>;
        AuthService.currentSessionUser = userData;
        final updatedMock = _getAdaptiveMockProfileSync();
        if (mounted && (_profile?['educationLevel'] != updatedMock['educationLevel'] || _profile?['name'] != updatedMock['name'])) {
          setState(() {
            _profile = updatedMock;
          });
          final level = EducationLevelHelper.fromGrade(_profile?['grade'], _profile?['educationLevel']);
          _safeUpdateThemeEducationLevel(level);
        }
      }
      // Nạp ngầm dữ liệu thật từ Backend Spring Boot nếu đang có phiên đăng nhập
      _loadProfile();
    } catch (_) {}
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
        'subjectName': 'Ngữ văn',
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
        'subjectName': 'Vật lý',
        'score': 9.5,
        'maxScore': 10.0,
        'examName': 'Kiểm tra Giữa kỳ 1',
        'grade': 'Xuất sắc',
      },
      {
        'subjectName': 'Hóa học',
        'score': 9.0,
        'maxScore': 10.0,
        'examName': 'Đánh giá định kỳ',
        'grade': 'Giỏi',
      },
    ];
  }

  StudentMarkbook _getAdaptiveMockMarkbook() {
    final level = _profile?['educationLevel']?.toString() ?? 'HIGH_SCHOOL';
    final name = _profile?['name']?.toString() ?? 'Nguyễn Minh Anh';
    final className = _profile?['className']?.toString() ?? '10A';
    final school = _profile?['schoolName']?.toString() ?? 'Trường THPT Astra';
    final admission = _profile?['admissionNumber']?.toString() ?? 'HS-2026-001';

    if (level == 'PRIMARY') {
      return StudentMarkbook(
        studentId: 101,
        studentName: name,
        studentAdmissionNumber: admission,
        academicYear: '2026-2027',
        educationLevel: 'PRIMARY',
        educationLevelDisplayName: 'Tiểu học',
        className: className,
        schoolName: school,
        overallAvg: 9.2,
        overallClassification: 'Hoàn thành xuất sắc',
        conduct: 'Chăm ngoan, lễ phép',
        subjects: const [
          SubjectMarkbook(
            subjectId: 1,
            subjectName: 'Tiếng Việt',
            academicClassification: 'Hoàn thành tốt (T)',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Đọc to, rõ ràng, diễn cảm', 'Viết chữ đều nét, đúng chính tả'],
              txScores: [9.0, 9.5],
              gkScore: 9.0,
              ckScore: 9.5,
              avg: 9.3,
            ),
          ),
          SubjectMarkbook(
            subjectId: 2,
            subjectName: 'Toán học',
            academicClassification: 'Hoàn thành tốt (T)',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Tính toán nhanh, chính xác', 'Tư duy hình học và logic tốt'],
              txScores: [9.5, 10.0],
              gkScore: 10.0,
              ckScore: 9.5,
              avg: 9.8,
            ),
          ),
          SubjectMarkbook(
            subjectId: 3,
            subjectName: 'Tiếng Anh',
            academicClassification: 'Hoàn thành tốt (T)',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Phát âm chuẩn, tự tin giao tiếp', 'Vốn từ vựng phong phú'],
              txScores: [9.5, 9.0],
              gkScore: 9.5,
              ckScore: 9.5,
              avg: 9.5,
            ),
          ),
          SubjectMarkbook(
            subjectId: 4,
            subjectName: 'Tự nhiên và Xã hội',
            academicClassification: 'Hoàn thành tốt (T)',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Tích cực khám phá môi trường xung quanh'],
            ),
          ),
          SubjectMarkbook(
            subjectId: 5,
            subjectName: 'Đạo đức',
            academicClassification: 'Hoàn thành tốt (T)',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Biết yêu thương, chia sẻ cùng bạn bè'],
            ),
          ),
          SubjectMarkbook(
            subjectId: 6,
            subjectName: 'Âm nhạc',
            academicClassification: 'Hoàn thành tốt (T)',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Hát đúng nhịp phách, hào hứng tham gia hoạt động nhóm'],
            ),
          ),
          SubjectMarkbook(
            subjectId: 7,
            subjectName: 'Mĩ thuật',
            academicClassification: 'Hoàn thành tốt (T)',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Tranh vẽ sáng tạo, phối màu tươi sáng'],
            ),
          ),
          SubjectMarkbook(
            subjectId: 8,
            subjectName: 'Giáo dục thể chất',
            academicClassification: 'Hoàn thành tốt (T)',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Nhanh nhẹn, thực hiện đúng các động tác thể dục'],
            ),
          ),
          SubjectMarkbook(
            subjectId: 9,
            subjectName: 'Hoạt động trải nghiệm',
            academicClassification: 'Hoàn thành tốt (T)',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Tự tin, chủ động trong các hoạt động tập thể'],
            ),
          ),
        ],
      );
    } else if (level == 'SECONDARY') {
      return StudentMarkbook(
        studentId: 202,
        studentName: name,
        studentAdmissionNumber: admission,
        academicYear: '2026-2027',
        educationLevel: 'SECONDARY',
        educationLevelDisplayName: 'THCS',
        className: className,
        schoolName: school,
        overallAvg: 8.6,
        overallClassification: 'Tốt',
        conduct: 'Tốt',
        subjects: const [
          SubjectMarkbook(
            subjectId: 10,
            subjectName: 'Toán học',
            academicClassification: 'Giỏi',
            semester1: SemesterMark(
              semester: 1,
              txScores: [8.5, 9.0],
              gkScore: 8.0,
              ckScore: 8.5,
              avg: 8.4,
              comments: ['Làm bài cẩn thận, nắm chắc kiến thức số học'],
            ),
          ),
          SubjectMarkbook(
            subjectId: 11,
            subjectName: 'Ngữ văn',
            academicClassification: 'Giỏi',
            semester1: SemesterMark(
              semester: 1,
              txScores: [8.0, 8.5],
              gkScore: 8.5,
              ckScore: 8.5,
              avg: 8.4,
              comments: ['Cảm thụ văn học tốt, diễn đạt mạch lạc'],
            ),
          ),
          SubjectMarkbook(
            subjectId: 12,
            subjectName: 'Tiếng Anh',
            academicClassification: 'Xuất sắc',
            semester1: SemesterMark(
              semester: 1,
              txScores: [8.5, 9.0],
              gkScore: 9.0,
              ckScore: 9.0,
              avg: 8.9,
              comments: ['Ngữ pháp vững, kĩ năng nghe đọc rất tốt'],
            ),
          ),
          SubjectMarkbook(
            subjectId: 13,
            subjectName: 'Khoa học tự nhiên',
            academicClassification: 'Giỏi',
            semester1: SemesterMark(
              semester: 1,
              txScores: [8.0, 8.5],
              gkScore: 8.0,
              ckScore: 8.5,
              avg: 8.3,
            ),
          ),
          SubjectMarkbook(
            subjectId: 14,
            subjectName: 'Lịch sử và Địa lí',
            academicClassification: 'Giỏi',
            semester1: SemesterMark(
              semester: 1,
              txScores: [8.5, 8.5],
              gkScore: 8.0,
              ckScore: 8.5,
              avg: 8.3,
            ),
          ),
          SubjectMarkbook(
            subjectId: 15,
            subjectName: 'Tin học',
            academicClassification: 'Xuất sắc',
            semester1: SemesterMark(
              semester: 1,
              txScores: [9.0, 9.5],
              gkScore: 9.0,
              ckScore: 9.5,
              avg: 9.3,
            ),
          ),
          SubjectMarkbook(
            subjectId: 16,
            subjectName: 'Giáo dục công dân',
            academicClassification: 'Giỏi',
            semester1: SemesterMark(
              semester: 1,
              txScores: [8.5, 9.0],
              gkScore: 8.5,
              ckScore: 8.5,
              avg: 8.6,
            ),
          ),
          SubjectMarkbook(
            subjectId: 17,
            subjectName: 'Công nghệ',
            academicClassification: 'Giỏi',
            semester1: SemesterMark(
              semester: 1,
              txScores: [8.0, 8.5],
              gkScore: 8.5,
              ckScore: 8.5,
              avg: 8.4,
            ),
          ),
          SubjectMarkbook(
            subjectId: 18,
            subjectName: 'Giáo dục thể chất',
            academicClassification: 'Đạt',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Thể lực tốt, tích cực rèn luyện thân thể'],
            ),
          ),
          SubjectMarkbook(
            subjectId: 19,
            subjectName: 'Nghệ thuật (Âm nhạc, Mĩ thuật)',
            academicClassification: 'Đạt',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Tham gia sôi nổi các tiết học thực hành'],
            ),
          ),
          SubjectMarkbook(
            subjectId: 20,
            subjectName: 'Hoạt động trải nghiệm, hướng nghiệp',
            academicClassification: 'Đạt',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Ý thức trách nhiệm cao với tập thể'],
            ),
          ),
        ],
      );
    } else {
      // HIGH_SCHOOL Cấp 3
      return StudentMarkbook(
        studentId: 303,
        studentName: name,
        studentAdmissionNumber: admission,
        academicYear: '2026-2027',
        educationLevel: 'HIGH_SCHOOL',
        educationLevelDisplayName: 'THPT',
        className: className,
        schoolName: school,
        overallAvg: 9.1,
        overallClassification: 'Tốt (Xuất sắc)',
        conduct: 'Tốt (Xuất sắc)',
        subjects: const [
          SubjectMarkbook(
            subjectId: 21,
            subjectName: 'Toán học',
            academicClassification: 'Xuất sắc',
            semester1: SemesterMark(
              semester: 1,
              txScores: [9.0, 9.5, 9.0],
              gkScore: 9.5,
              ckScore: 9.5,
              avg: 9.4,
              comments: ['Tư duy đại số và hình giải tích rất xuất sắc'],
            ),
            semester2: SemesterMark(
              semester: 2,
              txScores: [9.0, 9.0, 9.5],
              gkScore: 9.0,
              ckScore: 9.0,
              avg: 9.1,
              comments: ['Giải quyết tốt các bài toán phân hóa nâng cao'],
            ),
            yearAvg: 9.2,
          ),
          SubjectMarkbook(
            subjectId: 22,
            subjectName: 'Ngữ văn',
            academicClassification: 'Giỏi',
            semester1: SemesterMark(
              semester: 1,
              txScores: [8.5, 8.5, 9.0],
              gkScore: 8.5,
              ckScore: 9.0,
              avg: 8.8,
              comments: ['Hành văn lưu loát, lập luận sắc bén'],
            ),
            semester2: SemesterMark(
              semester: 2,
              txScores: [8.5, 8.5, 8.5],
              gkScore: 8.5,
              ckScore: 8.5,
              avg: 8.5,
              comments: ['Cảm thụ văn học sâu sắc, diễn đạt truyền cảm'],
            ),
            yearAvg: 8.6,
          ),
          SubjectMarkbook(
            subjectId: 23,
            subjectName: 'Tiếng Anh',
            academicClassification: 'Xuất sắc',
            semester1: SemesterMark(
              semester: 1,
              txScores: [9.5, 9.5, 10.0],
              gkScore: 9.8,
              ckScore: 9.5,
              avg: 9.7,
              comments: ['Trình độ tiếng Anh vượt trội, IELTS 7.5+ equivalent'],
            ),
            semester2: SemesterMark(
              semester: 2,
              txScores: [9.5, 9.0, 9.5],
              gkScore: 9.0,
              ckScore: 9.5,
              avg: 9.4,
              comments: ['Giao tiếp lưu loát, phát âm chuẩn quốc tế'],
            ),
            yearAvg: 9.5,
          ),
          SubjectMarkbook(
            subjectId: 24,
            subjectName: 'Vật lý',
            academicClassification: 'Xuất sắc',
            semester1: SemesterMark(
              semester: 1,
              txScores: [9.0, 9.5, 9.5],
              gkScore: 9.5,
              ckScore: 9.5,
              avg: 9.4,
              comments: ['Hiểu bản chất hiện tượng vật lý, làm bài chuẩn xác'],
            ),
            semester2: SemesterMark(
              semester: 2,
              txScores: [9.0, 9.0, 9.0],
              gkScore: 9.0,
              ckScore: 9.5,
              avg: 9.1,
              comments: ['Kỹ năng thực hành thí nghiệm và bài toán dao động tốt'],
            ),
            yearAvg: 9.2,
          ),
          SubjectMarkbook(
            subjectId: 25,
            subjectName: 'Hóa học',
            academicClassification: 'Giỏi',
            semester1: SemesterMark(
              semester: 1,
              txScores: [8.5, 9.0, 9.0],
              gkScore: 9.0,
              ckScore: 9.0,
              avg: 8.9,
              comments: ['Giải toán hóa học nhanh và khoa học'],
            ),
            semester2: SemesterMark(
              semester: 2,
              txScores: [8.5, 8.5, 9.0],
              gkScore: 8.5,
              ckScore: 8.5,
              avg: 8.6,
              comments: ['Nắm chắc lý thuyết hóa hữu cơ'],
            ),
            yearAvg: 8.7,
          ),
          SubjectMarkbook(
            subjectId: 26,
            subjectName: 'Sinh học',
            academicClassification: 'Giỏi',
            semester1: SemesterMark(
              semester: 1,
              txScores: [8.5, 8.5, 9.0],
              gkScore: 8.5,
              ckScore: 8.5,
              avg: 8.6,
            ),
            semester2: SemesterMark(
              semester: 2,
              txScores: [8.0, 8.5, 8.5],
              gkScore: 8.5,
              ckScore: 8.5,
              avg: 8.4,
            ),
            yearAvg: 8.5,
          ),
          SubjectMarkbook(
            subjectId: 27,
            subjectName: 'Lịch sử',
            academicClassification: 'Xuất sắc',
            semester1: SemesterMark(
              semester: 1,
              txScores: [8.5, 9.0, 8.5],
              gkScore: 8.5,
              ckScore: 8.5,
              avg: 8.6,
            ),
            semester2: SemesterMark(
              semester: 2,
              txScores: [9.0, 9.0, 9.5],
              gkScore: 9.0,
              ckScore: 9.5,
              avg: 9.2,
            ),
            yearAvg: 9.0,
          ),
          SubjectMarkbook(
            subjectId: 28,
            subjectName: 'Tin học',
            academicClassification: 'Xuất sắc',
            semester1: SemesterMark(
              semester: 1,
              txScores: [9.5, 10.0, 9.5],
              gkScore: 9.5,
              ckScore: 10.0,
              avg: 9.7,
            ),
            semester2: SemesterMark(
              semester: 2,
              txScores: [9.0, 9.5, 9.5],
              gkScore: 9.5,
              ckScore: 9.5,
              avg: 9.4,
            ),
            yearAvg: 9.5,
          ),
          SubjectMarkbook(
            subjectId: 29,
            subjectName: 'Giáo dục thể chất',
            academicClassification: 'Đạt',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Tích cực tham gia các hoạt động thể thao trường'],
            ),
            semester2: SemesterMark(
              semester: 2,
              comments: ['Thể lực tốt, hoàn thành đầy đủ các bài kiểm tra chạy và nhảy'],
            ),
          ),
          SubjectMarkbook(
            subjectId: 30,
            subjectName: 'Giáo dục Quốc phòng và An ninh',
            academicClassification: 'Đạt',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Chấp hành nghiêm kỷ luật và tác phong quân sự'],
            ),
            semester2: SemesterMark(
              semester: 2,
              comments: ['Nắm chắc điều lệnh đội ngũ và kỹ thuật bắn súng mô phỏng'],
            ),
          ),
          SubjectMarkbook(
            subjectId: 31,
            subjectName: 'Hoạt động trải nghiệm, hướng nghiệp',
            academicClassification: 'Đạt',
            semester1: SemesterMark(
              semester: 1,
              comments: ['Gương mẫu, định hướng nghề nghiệp rõ ràng'],
            ),
            semester2: SemesterMark(
              semester: 2,
              comments: ['Tích cực tham gia dự án cộng đồng và hướng nghiệp'],
            ),
          ),
        ],
      );
    }
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
        'title': 'Bài tập tuần 5: Khảo sát sự biến thiên hàm số bậc hai',
        'subjectName': 'Toán học',
        'dueDate': '18/10/2026',
        'submissionStatus': 'IN_PROGRESS',
      },
      {
        'assignmentId': 2,
        'title': 'Đọc hiểu & Phân tích văn bản: Chiến thắng Mtao Mxây',
        'subjectName': 'Ngữ văn',
        'dueDate': '19/10/2026',
        'submissionStatus': 'IN_PROGRESS',
      },
      {
        'assignmentId': 3,
        'title': 'Bài luận ngắn: Ý thức giữ gìn bản sắc văn hóa dân tộc',
        'subjectName': 'Ngữ văn',
        'dueDate': '12/10/2026',
        'submissionStatus': 'GRADED',
        'finalScore': 9.5,
      },
      {
        'assignmentId': 4,
        'title': 'Trắc nghiệm: Động học chất điểm và chuyển động thẳng đều',
        'subjectName': 'Vật lý',
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
        'title': 'Sách giáo khoa Toán 10 - Tập 1',
        'subjectName': 'Toán',
        'teacherName': 'Bộ GD&ĐT · Kết nối tri thức',
        'fileType': 'PDF',
        'fileSize': '68.0 MB',
        'pageCount': 124,
        'filePath': 'file:///storage/emulated/0/Download/SGK_Toan_10_Tap_1.pdf',
        'createdAt': '2026-10-16',
        'isDownloaded': true,
      },
      {
        'id': 1,
        'title': 'Sách giáo khoa Ngữ văn 10 - Tập 1',
        'subjectName': 'Ngữ văn',
        'teacherName': 'Bộ GD&ĐT · Kết nối tri thức',
        'fileType': 'PDF',
        'fileSize': '5.2 MB',
        'filePath': 'file:///storage/emulated/0/Download/SGK_Ngu_van_10_Tap_1.pdf',
        'createdAt': '2026-10-12',
      },
      {
        'id': 2,
        'title': 'Sách giáo khoa Vật lý 10',
        'subjectName': 'Vật lý',
        'teacherName': 'Bộ GD&ĐT · Kết nối tri thức',
        'fileType': 'PDF',
        'fileSize': '6.4 MB',
        'filePath': 'file:///storage/emulated/0/Download/SGK_Vat_ly_10.pdf',
        'createdAt': '2026-10-11',
      },
      {
        'id': 3,
        'title': 'Sách Tiếng Anh 10 - Global Success',
        'subjectName': 'Tiếng Anh',
        'teacherName': 'Bộ GD&ĐT · Global Success',
        'fileType': 'PDF',
        'fileSize': '8.1 MB',
        'filePath': 'file:///storage/emulated/0/Download/Tieng_Anh_10_Global_Success.pdf',
        'createdAt': '2026-10-10',
      },
      {
        'id': 4,
        'title': 'Sách giáo khoa Hóa học 10',
        'subjectName': 'Hóa học',
        'teacherName': 'Bộ GD&ĐT · Kết nối tri thức',
        'fileType': 'PDF',
        'fileSize': '5.8 MB',
        'filePath': 'file:///storage/emulated/0/Download/SGK_Hoa_hoc_10.pdf',
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        title: const Text('Đăng xuất?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
        content: const Text('Em có chắc chắn muốn đăng xuất khỏi hệ thống không?', style: TextStyle(color: AppColors.textMain)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.cardRadius)),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSub)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.cardRadius)),
            ),
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

  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_reset_outlined, size: 20, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Đổi mật khẩu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mật khẩu hiện tại:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSub)),
              const SizedBox(height: 4),
              TextField(
                controller: oldPassController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu hiện tại',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppColors.cardRadius)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Mật khẩu mới:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSub)),
              const SizedBox(height: 4),
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Tối thiểu 6 ký tự',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppColors.cardRadius)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Xác nhận mật khẩu mới:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSub)),
              const SizedBox(height: 4),
              TextField(
                controller: confirmPassController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Nhập lại mật khẩu mới',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppColors.cardRadius)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.cardRadius)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSub)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.cardRadius)),
            ),
            onPressed: () {
              if (oldPassController.text.isEmpty || newPassController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin mật khẩu')),
                );
                return;
              }
              if (newPassController.text != confirmPassController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mật khẩu mới và xác nhận mật khẩu không khớp')),
                );
                return;
              }
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đổi mật khẩu thành công!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.support_agent_outlined, size: 20, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Trợ giúp & Liên hệ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trường Phổ thông Liên cấp Astra',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain),
            ),
            SizedBox(height: 8),
            Text('📞 Tổng đài hỗ trợ: 1900 8888 (Nhánh 1: Học tập, Nhánh 2: Kỹ thuật)', style: TextStyle(fontSize: 13, color: AppColors.textSub)),
            SizedBox(height: 6),
            Text('✉️ Email: hotro@astra.edu.vn', style: TextStyle(fontSize: 13, color: AppColors.textSub)),
            SizedBox(height: 6),
            Text('🏢 Phòng Giáo vụ: Tầng 2, Tòa nhà Astra Education', style: TextStyle(fontSize: 13, color: AppColors.textSub)),
            SizedBox(height: 6),
            Text('⏰ Thời gian làm việc: 07:30 – 17:30 (Thứ 2 – Thứ 6)', style: TextStyle(fontSize: 13, color: AppColors.textSub)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.cardRadius)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
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

  // Danh sách tiết học mẫu (theo chuẩn THPT GDPT 2018)
  List<Map<String, String>> _getLessonsForDay(int dayIndex) {
    final schedules = [
      // Thứ 2
      [
        {'time': '07:30–08:15', 'subj': 'Toán', 'teacher': 'Thầy Nguyễn Văn Nam', 'room': 'P.301'},
        {'time': '08:20–09:05', 'subj': 'Ngữ văn', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.301'},
        {'time': '09:25–10:10', 'subj': 'Tiếng Anh', 'teacher': 'Thầy Phạm Quốc Bảo', 'room': 'P.Anh 1'},
        {'time': '10:15–11:00', 'subj': 'Vật lý', 'teacher': 'Thầy Đặng Hoàng Long', 'room': 'P.Lý'},
      ],
      // Thứ 3
      [
        {'time': '07:30–08:15', 'subj': 'Ngữ văn', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.301'},
        {'time': '08:20–09:05', 'subj': 'Toán', 'teacher': 'Thầy Nguyễn Văn Nam', 'room': 'P.301'},
        {'time': '09:25–10:10', 'subj': 'Hóa học', 'teacher': 'Cô Trần Mai', 'room': 'P.Hóa'},
        {'time': '10:15–11:00', 'subj': 'Lịch sử', 'teacher': 'Cô Vũ Lan', 'room': 'P.301'},
      ],
      // Thứ 4
      [
        {'time': '07:30–08:15', 'subj': 'Toán', 'teacher': 'Thầy Nguyễn Văn Nam', 'room': 'P.301'},
        {'time': '08:20–09:05', 'subj': 'Tiếng Anh', 'teacher': 'Thầy Phạm Quốc Bảo', 'room': 'P.Anh 1'},
        {'time': '09:25–10:10', 'subj': 'Sinh học', 'teacher': 'Cô Vũ Lan', 'room': 'P.Sinh'},
        {'time': '10:15–11:00', 'subj': 'Tin học', 'teacher': 'Thầy Đỗ Văn Long', 'room': 'P.Tin 2'},
      ],
      // Thứ 5
      [
        {'time': '07:30–08:15', 'subj': 'Ngữ văn', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.301'},
        {'time': '08:20–09:05', 'subj': 'Vật lý', 'teacher': 'Thầy Đặng Hoàng Long', 'room': 'P.Lý'},
        {'time': '09:25–10:10', 'subj': 'GDQP-AN', 'teacher': 'Thầy Đỗ Văn Long', 'room': 'Sân trường'},
        {'time': '10:15–11:00', 'subj': 'Địa lý', 'teacher': 'Cô Trần Mai', 'room': 'P.301'},
      ],
      // Thứ 6
      [
        {'time': '07:30–08:15', 'subj': 'Tiếng Anh', 'teacher': 'Thầy Phạm Quốc Bảo', 'room': 'P.Anh 1'},
        {'time': '08:20–09:05', 'subj': 'Hóa học', 'teacher': 'Cô Trần Mai', 'room': 'P.Hóa'},
        {'time': '09:25–10:10', 'subj': 'Toán', 'teacher': 'Thầy Nguyễn Văn Nam', 'room': 'P.301'},
        {'time': '10:15–11:00', 'subj': 'Sinh hoạt lớp', 'teacher': 'Cô Lê Thu Hà', 'room': 'P.301'},
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
    final bgImagePath = themeManager?.bgImagePath ?? 'images/school.jpg';

    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      drawer: _buildStudentDrawer(),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 60.0,
      body: SafeArea(
        child: Column(
          children: [
            const DemoModeBanner(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _buildCurrentTab(),
            ),
          ],
        ),
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
                borderRadius: BorderRadius.zero,
              ),
              child: Icon(icon, size: 18, color: AppColors.textMain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textMain),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSub),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textSub),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDrawer() {
    final studentName = _profile?['name'] ?? 'Nguyễn Minh Anh';
    final studentCode = _profile?['studentCode'] ?? _profile?['id']?.toString() ?? 'HS-2026-089';
    final className = FormatUtils.formatClassName(
      grade: _profile?['grade']?.toString(),
      section: _profile?['section']?.toString(),
      fallback: _profile?['className']?.toString(),
    );
    final educationLevel = EducationLevelHelper.fromGrade(_profile?['grade'], _profile?['educationLevel']);
    final levelShortTitle = EducationLevelHelper.getShortTitle(educationLevel);
    final schoolName = _profile?['schoolName']?.toString() ?? EducationLevelHelper.getSchoolName(educationLevel);
    final classTeacher = _profile?['classTeacher'] ?? 'Cô Lê Thu Hà';

    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      width: 320,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.zero,
          border: const Border(right: BorderSide(color: AppColors.border, width: 1.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(4, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header: Thẻ thông tin học sinh Astra (tối giản, phẳng, trang nhã)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceAlt,
                  border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        studentName.isNotEmpty
                            ? studentName.trim().split(' ').last.substring(0, 1).toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMain,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.primary),
                                  borderRadius: BorderRadius.zero,
                                ),
                                child: Text(
                                  levelShortTitle,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Mã HS: $studentCode',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSub, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$className · GVCN $classTeacher',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            schoolName,
                            style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Danh mục tính năng (Body)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.palette_outlined,
                      title: 'Cài đặt giao diện & Màu sắc',
                      subtitle: 'Hình nền, màu chữ hiển thị',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showMoreBottomSheet();
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.lock_reset_outlined,
                      title: 'Đổi mật khẩu',
                      subtitle: 'Bảo mật tài khoản học sinh',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showChangePasswordDialog();
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.support_agent_outlined,
                      title: 'Trợ giúp & Liên hệ nhà trường',
                      subtitle: 'Hotline, phòng giáo vụ, email',
                      onTap: () {
                        Navigator.of(context).pop();
                        _showSupportDialog();
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Divider(height: 1, thickness: 1, color: AppColors.border),
                    ),
                    _buildDrawerItem(
                      icon: Icons.sync_outlined,
                      title: 'Đồng bộ / Tải lại dữ liệu',
                      subtitle: 'Cập nhật điểm, bài tập & thông báo',
                      onTap: () {
                        Navigator.of(context).pop();
                        _loadAllData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đang đồng bộ dữ liệu mới nhất...', style: TextStyle(color: Colors.white)),
                            backgroundColor: AppColors.primary,
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 3. Đáy Drawer (Footer cố định): Nút Đăng xuất
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        _logout();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.05),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.4), width: 1.0),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 16, color: AppColors.error),
                            SizedBox(width: 8),
                            Text(
                              'Đăng xuất tài khoản',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Astra School Portal · v2.4 (Build 2026)',
                      style: TextStyle(fontSize: 11, color: AppColors.textSub),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  String _getTimeGreeting([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) {
      return 'Chào buổi sáng ☀️';
    } else if (hour >= 12 && hour < 18) {
      return 'Chào buổi chiều 🌤️';
    } else {
      return 'Chào buổi tối 🌙';
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
    final educationLevel = EducationLevelHelper.fromGrade(_profile?['grade'], _profile?['educationLevel']);
    final levelShortTitle = EducationLevelHelper.getShortTitle(educationLevel);
    final schoolName = _profile?['schoolName']?.toString() ?? EducationLevelHelper.getSchoolName(educationLevel);
    final classTeacher = _profile?['homeroomTeacherName'] ??
        _profile?['classTeacher'] ??
        (educationLevel == EducationLevel.primary ? 'Cô Nguyễn Thị Lan' : 'Cô Lê Thu Hà');
    final now = DateTime.now();
    final timeGreeting = _getTimeGreeting(now);
    final todayWeekday = now.weekday - 1; // 0: Thứ 2 ... 4: Thứ 6
    final todayLessons = FeatureFlags.useDemoFallback
        ? _getLessonsForDay(todayWeekday >= 0 && todayWeekday < 5 ? todayWeekday : 0)
        : <Map<String, String>>[];

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        children: [
          // Banner chỉ dẫn Chế độ Demo (nếu đang bật)
          if (FeatureFlags.useDemoFallback)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.warning),
                borderRadius: AppColors.cardBorderRadius,
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

          // Header cá nhân học sinh: Cấp 1 hiển thị Thẻ Con Vật Nhận Diện; Cấp 2 & Cấp 3 giữ Card học thuật
          if (educationLevel == EducationLevel.primary)
            PrimaryAnimalIdentityCard(
              studentName: studentName,
              className: className,
              dateStr: '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
              dobDMY: _extractDobDMY(_profile),
              teacherName: classTeacher,
              onTapMore: _showMoreBottomSheet,
              onLogout: _logout,
            )
          else
            Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppColors.cardBorderRadius,
              border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
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
                // Vùng thông tin học sinh: Có sự kiện click mở Cài đặt & Tiện ích
                InkWell(
                  onTap: _showMoreBottomSheet,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lời chào theo thời gian
                        Row(
                          children: [
                            Text(
                              timeGreeting,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                studentName,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: AppColors.primary),
                                    borderRadius: AppColors.cardBorderRadius,
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
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: AppColors.textSub,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$className · $schoolName · GVCN $classTeacher',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSub),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hôm nay: ${DateTimeUtils.formatVietnameseFullDate(now)}',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSub),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                // Thanh tác vụ cá nhân: Cài đặt & Đăng xuất (Flat Square Design)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: _showMoreBottomSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
                            borderRadius: AppColors.cardBorderRadius,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.settings_outlined, size: 15, color: AppColors.textMain),
                              SizedBox(width: 6),
                              Text(
                                'Cài đặt & Tiện ích',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMain),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _logout,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.06),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            borderRadius: AppColors.cardBorderRadius,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout, size: 15, color: AppColors.error),
                              SizedBox(width: 6),
                              Text(
                                'Đăng xuất',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppColors.cardBorderRadius,
                border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
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
          const SizedBox(height: 24),
          // Footer Trang Chủ: Đăng xuất tài khoản
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              children: [
                InkWell(
                  onTap: _logout,
                  borderRadius: AppColors.cardBorderRadius,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
                      borderRadius: AppColors.cardBorderRadius,
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 16, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(
                          'Đăng xuất tài khoản',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Astra School Portal · Hệ thống Giáo dục Liên cấp Đại Việt',
                  style: TextStyle(fontSize: 11, color: AppColors.textSub),
                  textAlign: TextAlign.center,
                ),
              ],
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

        // 2. Bộ chuyển đổi chế độ xem: Theo ngày vs Theo tuần (Flat Square Design)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
              borderRadius: AppColors.cardBorderRadius,
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isWeeklyView = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: !_isWeeklyView ? AppColors.primary : Colors.transparent,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.view_day_outlined,
                            size: 16,
                            color: !_isWeeklyView ? Colors.white : AppColors.textSub,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Theo ngày',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: !_isWeeklyView ? FontWeight.bold : FontWeight.w500,
                              color: !_isWeeklyView ? Colors.white : AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 28, color: AppColors.border),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isWeeklyView = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: _isWeeklyView ? AppColors.primary : Colors.transparent,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_view_week_outlined,
                            size: 16,
                            color: _isWeeklyView ? Colors.white : AppColors.textSub,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Theo tuần (Toàn bộ)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _isWeeklyView ? FontWeight.bold : FontWeight.w500,
                              color: _isWeeklyView ? Colors.white : AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Nội dung theo chế độ xem
        if (!_isWeeklyView) ...[
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
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _loadAllData,
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
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppColors.cardBorderRadius,
                      border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
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
        ),
      ] else ...[
        // Chế độ 2: Lịch theo tuần toàn bộ (Weekly Full View)
        Expanded(
          child: _buildWeeklyTimetable(),
        ),
      ],
    ],
  );
}

  /// Giao diện Lịch học toàn bộ tuần (Weekly Full View):
  /// Hiển thị 5 ngày từ Thứ 2 đến Thứ 6 dạng thẻ phẳng vuông vức,
  /// nhận diện ngày hôm nay và cho phép chạm vào từng tiết để xem chi tiết.
  Widget _buildWeeklyTimetable() {
    final now = DateTime.now();
    final todayWeekday = now.weekday - 1; // 0: Thứ 2 ... 6: Chủ Nhật
    final base = DateTime(2026, 10, 12);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadAllData,
      child: ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(DateTimeUtils.schoolDays.length, (dayIndex) {
        final dayDate = base.add(Duration(days: 7 * _weekOffset + dayIndex));
        final dateStr = '${dayDate.day.toString().padLeft(2, '0')}/${dayDate.month.toString().padLeft(2, '0')}/${dayDate.year}';
        final isToday = (todayWeekday == dayIndex && _weekOffset == 0);
        final dayLessons = FeatureFlags.useDemoFallback ? _getLessonsForDay(dayIndex) : <Map<String, String>>[];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppColors.cardBorderRadius,
            border: Border.all(
              color: isToday ? AppColors.primary : AppColors.cardBorder,
              width: isToday ? 1.5 : AppColors.cardBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header ngày
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surfaceAlt,
                  border: const Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 15,
                          color: isToday ? AppColors.primary : AppColors.textSub,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${DateTimeUtils.dayNames[dayIndex].toUpperCase()} · $dateStr',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isToday ? AppColors.primary : AppColors.textMainOf(context),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (isToday) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.zero,
                            ),
                            child: const Text(
                              'Hôm nay',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                        Text(
                          '${dayLessons.length} tiết',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSub),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Danh sách tiết học của ngày
              if (dayLessons.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Center(
                    child: Text(
                      'Không có tiết học nào được xếp lịch cho ngày này.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSub),
                    ),
                  ),
                )
              else
                ...dayLessons.asMap().entries.map((entry) {
                  final i = entry.key;
                  final l = entry.value;
                  return LessonRow(
                    lessonIndex: i + 1,
                    subject: l['subj']!,
                    time: l['time']!,
                    teacher: l['teacher']!,
                    room: l['room']!,
                    isCompact: true,
                    hasDivider: i < dayLessons.length - 1,
                    onTap: () => _showLessonDetailModal(
                      lessonIndex: i + 1,
                      subject: l['subj']!,
                      time: l['time']!,
                      teacher: l['teacher']!,
                      room: l['room']!,
                    ),
                  );
                }),
            ],
          ),
        );
      }),
    ),
  );
}

  // ===================== TAB 2: SÁCH HỌC =====================
  Widget _buildMatTab() {
    final educationLevel = EducationLevelHelper.fromGrade(_profile?['grade'], _profile?['educationLevel']);
    final subjects = EducationLevelHelper.getDefaultSubjects(educationLevel);
    final levelTitle = EducationLevelHelper.getTitle(educationLevel);
    final filtered = _selectedSubjectFilter == 'Tất cả'
        ? _materials
        : _materials.where((m) => (m['subjectName'] ?? '').toString() == _selectedSubjectFilter).toList();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadAllData,
      child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banner thông tin
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
            borderRadius: AppColors.cardBorderRadius,
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
                  shape: const RoundedRectangleBorder(borderRadius: AppColors.cardBorderRadius),
                  side: BorderSide(color: isSel ? AppColors.primary : AppColors.cardBorder, width: AppColors.cardBorderWidth),
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
    ),
  );
}

  // ===================== TAB 3: BÀI TẬP (LMS) =====================
  Widget _buildHwTab() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner hướng dẫn
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
              borderRadius: AppColors.cardBorderRadius,
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
      ),
    );
  }

  // ===================== TAB 4: BẢNG ĐIỂM & KẾT QUẢ HỌC TẬP (CHUẨN BỘ GD&ĐT VIỆT NAM) =====================
  Widget _buildMarksTab() {
    final markbook = _markbook ?? _getAdaptiveMockMarkbook();
    final level = markbook.educationLevel;
    final classTeacher = _profile?['classTeacher'] ?? 'Cô Lê Thu Hà';
    return StudentMarksTab(
      markbook: markbook,
      level: level,
      classTeacher: classTeacher,
      rawMarks: _marks,
      onRefresh: _loadAllData,
    );
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

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadAllData,
      child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banner tóm tắt
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
            borderRadius: BorderRadius.zero,
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
                  shape: const RoundedRectangleBorder(borderRadius: AppColors.cardBorderRadius),
                  side: BorderSide(color: isSel ? AppColors.primary : AppColors.cardBorder, width: AppColors.cardBorderWidth),
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
                    color: isRead ? AppColors.cardBorder : AppColors.primary.withValues(alpha: 0.5),
                    width: isRead ? AppColors.cardBorderWidth : 1.5,
                  ),
                  borderRadius: AppColors.cardBorderRadius,
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
                        borderRadius: AppColors.cardBorderRadius,
                        border: Border.all(color: isRead ? AppColors.cardBorder : AppColors.primary.withValues(alpha: 0.3), width: AppColors.cardBorderWidth),
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
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.zero,
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
      ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
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
                        borderRadius: BorderRadius.circular(AppColors.cardRadius),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.cardRadius)),
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
    final educationLevel = EducationLevelHelper.fromGrade(_profile?['grade'], _profile?['educationLevel']);
    final schoolName = _profile?['schoolName']?.toString() ?? EducationLevelHelper.getSchoolName(educationLevel);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SingleChildScrollView(
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
                        border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
                        borderRadius: BorderRadius.zero,
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
                                  'Mã: $studentId · $className · $schoolName',
                                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSub),
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
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
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
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
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
          final currentBg = themeManager?.bgImagePath ?? 'images/school.jpg';

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
                                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                                      width: isSelected ? 2.5 : AppColors.cardBorderWidth,
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
                                                borderRadius: AppColors.cardBorderRadius,
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
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
              width: isSelected ? 2.0 : AppColors.cardBorderWidth,
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

