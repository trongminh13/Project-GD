import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class LeaveRequestService {
  static final LeaveRequestService _instance = LeaveRequestService._internal();
  factory LeaveRequestService() => _instance;
  LeaveRequestService._internal();

  /// Phụ huynh nộp đơn xin nghỉ phép
  Future<Map<String, dynamic>> submitLeaveRequest({
    required int studentId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/leave-requests');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'studentId': studentId,
          'startDate': startDate,
          'endDate': endDate,
          'reason': reason,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Lỗi khi gửi đơn'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }

  /// Phụ huynh xem danh sách đơn đã nộp
  Future<List<dynamic>> getMyRequests() async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/leave-requests/my-requests');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}
    return [];
  }

  /// Giáo viên xem các đơn chờ duyệt của lớp chủ nhiệm
  Future<List<dynamic>> getPendingRequestsForTeacher() async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/leave-requests/pending');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}
    return [];
  }

  /// Giáo viên chủ nhiệm duyệt hoặc từ chối đơn
  Future<Map<String, dynamic>> reviewLeaveRequest({
    required int requestId,
    required String decision, // APPROVED hoặc REJECTED
    String? teacherNote,
  }) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/leave-requests/$requestId/review');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'decision': decision,
          'teacherNote': teacherNote ?? '',
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Lỗi khi xử lý đơn'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }
}
