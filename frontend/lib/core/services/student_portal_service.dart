import 'package:ashadeep/core/network/api_client.dart';
import 'package:ashadeep/models/markbook.dart';

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

  /// Lấy học bạ đầy đủ theo chuẩn Bộ GD&ĐT Việt Nam
  Future<StudentMarkbook?> getMyMarkbook({String? academicYearId}) async {
    final queryParams = <String, dynamic>{};
    if (academicYearId != null) queryParams['academicYearId'] = academicYearId;
    try {
      final res = await _apiClient.get(
        '/student-portal/markbook',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      if (res is Map<String, dynamic>) {
        return StudentMarkbook.fromJson(res);
      }
    } catch (_) {}
    return null;
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

  /// Lấy danh sách thông báo của học sinh từ backend
  Future<List<Map<String, dynamic>>> getMyNotices({String? audience}) async {
    final queryParams = <String, dynamic>{};
    if (audience != null && audience.isNotEmpty && audience != 'Tất cả') {
      queryParams['audience'] = audience;
    }

    try {
      final res = await _apiClient.get(
        '/notifications/my-notifications',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Đánh dấu một thông báo đã đọc
  Future<bool> markNoticeAsRead(dynamic notificationId) async {
    try {
      final res = await _apiClient.put('/notifications/$notificationId/read');
      if (res is Map && res['success'] == true) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Đăng ký Device Push Token (FCM) lên máy chủ
  Future<bool> registerDeviceToken(String token, String platform, {String? deviceName}) async {
    try {
      final body = <String, dynamic>{
        'deviceToken': token,
        'platform': platform,
      };
      if (deviceName != null) {
        body['deviceName'] = deviceName;
      }
      final res = await _apiClient.post(
        '/notifications/device-token',
        body: body,
      );
      if (res is Map && res['success'] == true) {
        return true;
      }
    } catch (_) {}
    return false;
  }
}
