import 'package:ashadeep/core/network/api_client.dart';

class StudentPortalService {
  static final StudentPortalService _instance = StudentPortalService._internal();
  factory StudentPortalService({ApiClient? apiClient}) {
    if (apiClient != null) {
      _instance._apiClient = apiClient;
    }
    return _instance;
  }
  StudentPortalService._internal() : _apiClient = ApiClient();

  ApiClient _apiClient;

  /// Lấy thông tin hồ sơ học sinh
  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final res = await _apiClient.get('/student-portal/profile');
      if (res is Map<String, dynamic>) return res;
    } catch (_) {}
    return null;
  }

  /// Lấy lịch sử điểm danh / chuyên cần
  Future<List<Map<String, dynamic>>> getMyAttendance({int? month, int? year}) async {
    final queryParams = <String, dynamic>{};
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;

    try {
      final res = await _apiClient.get('/student-portal/attendance', queryParams: queryParams.isNotEmpty ? queryParams : null);
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Lấy bảng điểm cá nhân của học sinh
  Future<List<Map<String, dynamic>>> getMyMarks() async {
    try {
      final res = await _apiClient.get('/student-portal/marks');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Lấy danh sách tài liệu học tập của lớp học sinh
  Future<List<Map<String, dynamic>>> getMyMaterials() async {
    try {
      final res = await _apiClient.get('/student-portal/materials');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Lấy thời khóa biểu học sinh
  Future<List<Map<String, dynamic>>> getMyTimetable() async {
    try {
      final res = await _apiClient.get('/student-portal/timetable');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }
}
