import 'package:ashadeep/core/network/api_client.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';

class LeaveRequestService {
  static final LeaveRequestService _instance = LeaveRequestService._internal();
  factory LeaveRequestService() => _instance;
  LeaveRequestService._internal() : _apiClient = ApiClient.instance;

  final ApiClient _apiClient;

  /// Phụ huynh nộp đơn xin nghỉ phép
  Future<Map<String, dynamic>> submitLeaveRequest({
    required int studentId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    try {
      final data = await _apiClient.post(
        '/leave-requests',
        body: {
          'studentId': studentId,
          'startDate': startDate,
          'endDate': endDate,
          'reason': reason,
        },
        policy: ApiTimeoutPolicy.mutation,
      );
      return {'success': true, 'data': data};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ: $e'};
    }
  }

  /// Phụ huynh xem danh sách đơn đã nộp
  Future<List<dynamic>> getMyRequests() async {
    try {
      final res = await _apiClient.get(
        '/leave-requests/my-requests',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is List) return res;
    } catch (_) {}
    return [];
  }

  /// Giáo viên xem các đơn chờ duyệt của lớp chủ nhiệm
  Future<List<dynamic>> getPendingRequestsForTeacher() async {
    try {
      final res = await _apiClient.get(
        '/leave-requests/pending',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is List) return res;
    } catch (_) {}
    return [];
  }

  /// Giáo viên chủ nhiệm duyệt hoặc từ chối đơn
  Future<Map<String, dynamic>> reviewLeaveRequest({
    required int requestId,
    required String decision, // APPROVED hoặc REJECTED
    String? teacherNote,
  }) async {
    try {
      final data = await _apiClient.put(
        '/leave-requests/$requestId/review',
        body: {
          'decision': decision,
          'teacherNote': teacherNote,
        },
        policy: ApiTimeoutPolicy.mutation,
      );
      return {'success': true, 'data': data};
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối máy chủ: $e'};
    }
  }

  /// Lấy lịch sử nghỉ phép của một học sinh cụ thể
  Future<List<dynamic>> getStudentLeaveHistory(int studentId) async {
    try {
      final res = await _apiClient.get(
        '/leave-requests/student/$studentId',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is List) return res;
    } catch (_) {}
    return [];
  }
}
