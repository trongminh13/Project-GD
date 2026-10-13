import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class StudentPortalService {
  static final StudentPortalService _instance = StudentPortalService._internal();
  factory StudentPortalService() => _instance;
  StudentPortalService._internal();

  Future<Map<String, dynamic>?> getMyProfile() async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/student-portal/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Error fetching student profile
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getMyAttendance({int? month, int? year}) async {
    final token = await AuthService().getToken();
    String query = '';
    if (month != null && year != null) {
      query = '?month=$month&year=$year';
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/student-portal/attendance$query');

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
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      // Error fetching student attendance
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getMyMarks() async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/student-portal/marks');

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
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      // Error fetching student marks
    }
    return [];
  }
}
