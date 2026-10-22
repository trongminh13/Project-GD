import 'package:ashadeep/core/network/api_client.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal() : _apiClient = ApiClient.instance;

  final ApiClient _apiClient;

  /// Fetches attendance records for a specific student
  Future<Map<DateTime, String>> getStudentAttendance(String studentId) async {
    try {
      final res = await _apiClient.get(
        '/attendance/student/$studentId',
        policy: ApiTimeoutPolicy.fastRead,
      );

      if (res is List) {
        final Map<DateTime, String> attendanceMap = {};
        for (final record in res) {
          if (record is Map && record['date'] != null) {
            final DateTime date = DateTime.parse(record['date']);
            attendanceMap[DateTime.utc(date.year, date.month, date.day)] =
                record['status']?.toString() ?? 'PRESENT';
          }
        }
        return attendanceMap;
      }
    } catch (_) {}
    return {};
  }

  /// Bulk marks attendance for a list of students
  Future<bool> submitClassAttendance(
    String className,
    String dateISO,
    Map<String, bool> attendanceData,
  ) async {
    final List<Map<String, dynamic>> payload = [];
    attendanceData.forEach((studentId, isPresent) {
      payload.add({
        'studentId': int.tryParse(studentId) ?? studentId,
        'status': isPresent ? 'PRESENT' : 'ABSENT',
      });
    });

    try {
      await _apiClient.post(
        '/attendance/bulk',
        body: {
          'className': className,
          'date': dateISO,
          'records': payload,
        },
        policy: ApiTimeoutPolicy.mutation,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
