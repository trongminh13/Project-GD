import 'package:ashadeep/core/network/api_client.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';

class HomeworkService {
  static final HomeworkService _instance = HomeworkService._internal();
  factory HomeworkService() => _instance;
  HomeworkService._internal() : _apiClient = ApiClient.instance;

  final ApiClient _apiClient;

  // ===================== DÀNH CHO GIÁO VIÊN =====================

  /// Lấy danh sách bài tập do giáo viên soạn
  Future<List<dynamic>> getTeacherHomework() async {
    try {
      final res = await _apiClient.get(
        '/teacher/homework',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is List) return res;
    } catch (_) {}
    return [];
  }

  /// Giáo viên soạn bài tập mới
  Future<Map<String, dynamic>> createHomework(Map<String, dynamic> body) async {
    try {
      final res = await _apiClient.post(
        '/teacher/homework',
        body: body,
        policy: ApiTimeoutPolicy.mutation,
      );
      return {'success': true, 'data': res};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối máy chủ: $e'};
    }
  }

  /// Giáo viên giao bài tập cho một lớp học
  Future<Map<String, dynamic>> assignHomework({
    required int homeworkId,
    required int classId,
    required String dueDate,
    bool allowLate = true,
  }) async {
    try {
      final res = await _apiClient.post(
        '/teacher/homework/$homeworkId/assign',
        body: {
          'classId': classId,
          'dueDate': dueDate,
          'allowLateSubmission': allowLate,
        },
        policy: ApiTimeoutPolicy.mutation,
      );
      return {'success': true, 'data': res};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối máy chủ: $e'};
    }
  }

  /// Lấy danh sách các bài tập đã giao
  Future<List<dynamic>> getTeacherAssignments() async {
    try {
      final res = await _apiClient.get(
        '/teacher/homework/assignments',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is List) return res;
    } catch (_) {}
    return [];
  }

  /// Xem danh sách bài làm của học sinh cho một lần giao bài
  Future<List<dynamic>> getAssignmentSubmissions(int assignmentId) async {
    try {
      final res = await _apiClient.get(
        '/teacher/homework/assignments/$assignmentId/submissions',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is List) return res;
    } catch (_) {}
    return [];
  }

  /// Xem chi tiết một bài làm để chấm điểm
  Future<Map<String, dynamic>?> getSubmissionDetails(int submissionId) async {
    try {
      final res = await _apiClient.get(
        '/teacher/homework/submissions/$submissionId',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is Map<String, dynamic>) return res;
    } catch (_) {}
    return null;
  }

  /// Giáo viên chấm điểm và nhận xét
  Future<Map<String, dynamic>> gradeSubmission({
    required int submissionId,
    required String teacherFeedback,
    required List<Map<String, dynamic>> answerGrades,
  }) async {
    try {
      final res = await _apiClient.put(
        '/teacher/homework/submissions/$submissionId/grade',
        body: {
          'teacherFeedback': teacherFeedback,
          'answerGrades': answerGrades,
        },
        policy: ApiTimeoutPolicy.mutation,
      );
      return {'success': true, 'data': res};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối máy chủ: $e'};
    }
  }

  // ===================== DÀNH CHO HỌC SINH =====================

  /// Học sinh lấy danh sách bài tập được giao
  Future<List<dynamic>> getStudentAssignments() async {
    try {
      final res = await _apiClient.get(
        '/student-portal/homework',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is List) return res;
    } catch (_) {}
    return [];
  }

  /// Học sinh mở bài tập để làm
  Future<Map<String, dynamic>?> getAssignmentForTaking(int assignmentId) async {
    try {
      final res = await _apiClient.get(
        '/student-portal/homework/$assignmentId/take',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is Map<String, dynamic>) return res;
    } catch (_) {}
    return null;
  }

  /// Học sinh lưu nháp câu trả lời
  Future<bool> saveDraft(int submissionId, List<Map<String, dynamic>> answers) async {
    try {
      await _apiClient.post(
        '/student-portal/homework/submissions/$submissionId/draft',
        body: {'answers': answers},
        policy: ApiTimeoutPolicy.mutation,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Học sinh nộp bài chính thức
  Future<Map<String, dynamic>> submitHomework(int submissionId, List<Map<String, dynamic>> answers) async {
    try {
      final res = await _apiClient.post(
        '/student-portal/homework/submissions/$submissionId/submit',
        body: {'answers': answers},
        policy: ApiTimeoutPolicy.mutation,
      );
      return {'success': true, 'data': res};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối máy chủ: $e'};
    }
  }

  // ===================== DÀNH CHO PHỤ HUYNH =====================

  /// Phụ huynh xem bài tập và kết quả của con
  Future<List<dynamic>> getWardHomework(int studentId) async {
    try {
      final res = await _apiClient.get(
        '/parent/wards/$studentId/homework',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is List) return res;
    } catch (_) {}
    return [];
  }

  // ===================== HỌC LIỆU SỐ =====================

  /// Học sinh xem tài liệu học tập của lớp mình
  Future<List<dynamic>> getStudentMaterials() async {
    try {
      final res = await _apiClient.get(
        '/student-portal/materials',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is List) return res;
    } catch (_) {}
    return [];
  }
}
