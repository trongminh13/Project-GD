import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class HomeworkService {
  static final HomeworkService _instance = HomeworkService._internal();
  factory HomeworkService() => _instance;
  HomeworkService._internal();

  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ===================== DÀNH CHO GIÁO VIÊN =====================

  /// Lấy danh sách bài tập do giáo viên soạn
  Future<List<dynamic>> getTeacherHomework() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/teacher/homework');
      final res = await http
          .get(url, headers: await _headers())
          .timeout(ApiTimeoutPolicy.fastRead.duration);
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
    } catch (_) {}
    return [];
  }

  /// Giáo viên soạn bài tập mới
  Future<Map<String, dynamic>> createHomework(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/teacher/homework');
      final res = await http
          .post(url, headers: await _headers(), body: jsonEncode(body))
          .timeout(ApiTimeoutPolicy.mutation.duration);
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Lỗi khi tạo bài tập'};
      }
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
      final url = Uri.parse('${ApiConstants.baseUrl}/teacher/homework/$homeworkId/assign');
      final res = await http
          .post(
            url,
            headers: await _headers(),
            body: jsonEncode({
              'classId': classId,
              'dueDate': dueDate,
              'allowLateSubmission': allowLate,
            }),
          )
          .timeout(ApiTimeoutPolicy.mutation.duration);
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Lỗi khi giao bài tập'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối máy chủ: $e'};
    }
  }

  /// Lấy danh sách các bài tập đã giao
  Future<List<dynamic>> getTeacherAssignments() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/teacher/homework/assignments');
      final res = await http
          .get(url, headers: await _headers())
          .timeout(ApiTimeoutPolicy.fastRead.duration);
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
    } catch (_) {}
    return [];
  }

  /// Xem danh sách bài làm của học sinh cho một lần giao bài
  Future<List<dynamic>> getAssignmentSubmissions(int assignmentId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/teacher/homework/assignments/$assignmentId/submissions');
      final res = await http
          .get(url, headers: await _headers())
          .timeout(ApiTimeoutPolicy.fastRead.duration);
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
    } catch (_) {}
    return [];
  }

  /// Xem chi tiết một bài làm để chấm điểm
  Future<Map<String, dynamic>?> getSubmissionDetails(int submissionId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/teacher/homework/submissions/$submissionId');
      final res = await http
          .get(url, headers: await _headers())
          .timeout(ApiTimeoutPolicy.fastRead.duration);
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
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
      final url = Uri.parse('${ApiConstants.baseUrl}/teacher/homework/submissions/$submissionId/grade');
      final res = await http
          .put(
            url,
            headers: await _headers(),
            body: jsonEncode({
              'teacherFeedback': teacherFeedback,
              'answerGrades': answerGrades,
            }),
          )
          .timeout(ApiTimeoutPolicy.mutation.duration);
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (res.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Lỗi khi chấm điểm'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối máy chủ: $e'};
    }
  }

  // ===================== DÀNH CHO HỌC SINH =====================

  /// Học sinh lấy danh sách bài tập được giao
  Future<List<dynamic>> getStudentAssignments() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/student-portal/homework');
      final res = await http
          .get(url, headers: await _headers())
          .timeout(ApiTimeoutPolicy.fastRead.duration);
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
    } catch (_) {}
    return [];
  }

  /// Học sinh mở bài tập để làm
  Future<Map<String, dynamic>?> getAssignmentForTaking(int assignmentId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/student-portal/homework/$assignmentId/take');
      final res = await http
          .get(url, headers: await _headers())
          .timeout(ApiTimeoutPolicy.fastRead.duration);
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
    } catch (_) {}
    return null;
  }

  /// Học sinh lưu nháp câu trả lời
  Future<bool> saveDraft(int submissionId, List<Map<String, dynamic>> answers) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/student-portal/homework/submissions/$submissionId/draft');
      final res = await http
          .post(
            url,
            headers: await _headers(),
            body: jsonEncode({'answers': answers}),
          )
          .timeout(ApiTimeoutPolicy.mutation.duration);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Học sinh nộp bài chính thức
  Future<Map<String, dynamic>> submitHomework(int submissionId, List<Map<String, dynamic>> answers) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/student-portal/homework/submissions/$submissionId/submit');
      final res = await http
          .post(
            url,
            headers: await _headers(),
            body: jsonEncode({'answers': answers}),
          )
          .timeout(ApiTimeoutPolicy.mutation.duration);
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (res.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Lỗi khi nộp bài'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối máy chủ: $e'};
    }
  }

  // ===================== DÀNH CHO PHỤ HUYNH =====================

  /// Phụ huynh xem bài tập và kết quả của con
  Future<List<dynamic>> getWardHomework(int studentId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/parent/wards/$studentId/homework');
      final res = await http
          .get(url, headers: await _headers())
          .timeout(ApiTimeoutPolicy.fastRead.duration);
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
    } catch (_) {}
    return [];
  }

  // ===================== HỌC LIỆU SỐ =====================

  /// Học sinh xem tài liệu học tập của lớp mình
  Future<List<dynamic>> getStudentMaterials() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/student-portal/materials');
      final res = await http
          .get(url, headers: await _headers())
          .timeout(ApiTimeoutPolicy.fastRead.duration);
      if (res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
    } catch (_) {}
    return [];
  }
}
