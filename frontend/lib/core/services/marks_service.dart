import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/models/markbook.dart';

class MarksService {
  static final MarksService _instance = MarksService._internal();
  factory MarksService() => _instance;
  MarksService._internal();

  /// Fetches published marks for a specific student id
  Future<List<Map<String, dynamic>>> getStudentMarks(String studentId) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/marks/$studentId');

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
    } catch (_) {
      // Return empty on failure
    }
    return [];
  }

  /// Fetches the full Vietnamese học bạ for a student.
  /// [academicYearId] is optional; if null, the backend uses the current year.
  Future<StudentMarkbook?> getStudentMarkbook(
    String studentId, {
    String? academicYearId,
  }) async {
    final token = await AuthService().getToken();
    String path = '${ApiConstants.baseUrl}/marks/student/$studentId/markbook';
    if (academicYearId != null) {
      path += '?academicYearId=$academicYearId';
    }
    final url = Uri.parse(path);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return StudentMarkbook.fromJson(data);
      }
    } catch (_) {
      // Return null on failure – caller shows empty state
    }
    return null;
  }

  /// Teachers bulk submit marks for an assessment
  Future<bool> uploadClassMarks(
    String className,
    String assessmentId,
    Map<String, int> studentMarks, {
    String? subject,
    int? maxMarks,
  }) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/marks/bulk');

    List<Map<String, dynamic>> payload = [];
    studentMarks.forEach((studentId, marks) {
      payload.add({'studentId': studentId, 'marksObtained': marks});
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
          'assessmentId': assessmentId,
          'subject': subject,
          'maxMarks': maxMarks,
          'records': payload,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false; // Correct failure indicator, no mock success
    }
  }
}
