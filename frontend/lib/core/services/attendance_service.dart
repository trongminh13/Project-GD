import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  /// Fetches attendance records for a specific student
  Future<Map<DateTime, String>> getStudentAttendance(String studentId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/attendance/student/$studentId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        Map<DateTime, String> attendanceMap = {};
        for (var record in data) {
          DateTime date = DateTime.parse(record['date']);
          attendanceMap[DateTime.utc(date.year, date.month, date.day)] =
              record['status'];
        }
        return attendanceMap;
      }
    } catch (_) {
      // Empty on failure
    }
    return {};
  }

  /// Bulk marks attendance for a list of students
  Future<bool> submitClassAttendance(
    String className,
    String dateISO,
    Map<String, bool> attendanceData,
  ) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/attendance/bulk');

    List<Map<String, dynamic>> payload = [];
    attendanceData.forEach((studentId, isPresent) {
      payload.add({
        'studentId': int.tryParse(studentId) ?? studentId,
        'status': isPresent ? 'PRESENT' : 'ABSENT',
      });
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'className': className,
          'date': dateISO,
          'records': payload,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
