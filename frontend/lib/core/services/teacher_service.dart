import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ashadeep/models/teacher.dart';
import 'package:ashadeep/core/models/paginated_response.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class TeacherService {
  static final TeacherService _instance = TeacherService._internal();

  factory TeacherService() {
    return _instance;
  }

  TeacherService._internal();

  Future<PaginatedResponse<Teacher>> getAllTeachers({
    int page = 0,
    int size = 20,
    String sortBy = 'id',
    String sortDir = 'asc',
  }) async {
    final token = await AuthService().getToken();
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/teachers?page=$page&size=$size&sortBy=$sortBy&sortDir=$sortDir',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PaginatedResponse.fromJson(data, Teacher.fromJson);
      } else {
        print('Failed to fetch teachers: ${response.statusCode}');
        return PaginatedResponse(
          content: [],
          totalPages: 0,
          totalElements: 0,
          number: 0,
          size: size,
          first: true,
          last: true,
        );
      }
    } catch (e) {
      print('Error fetching teachers: $e');
      return PaginatedResponse(
        content: [],
        totalPages: 0,
        totalElements: 0,
        number: 0,
        size: size,
        first: true,
        last: true,
      );
    }
  }

  /// Fetches all teachers without pagination (for operations that need the full list)
  Future<List<Teacher>> getAllTeachersFlat() async {
    final paginated = await getAllTeachers(page: 0, size: 100);
    return paginated.content;
  }

  Future<bool> addTeacher(Teacher teacher) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/teachers');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(teacher.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to add teacher: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding teacher: $e');
      return false;
    }
  }

  // Mock Attendance Methods (kept for compatibility)
  void markAttendance(String teacherId, String date, String status) {
    // TODO: Implement API call for attendance
  }

  Future<List<Map<String, String>>> getAttendance(String teacherId) async {
    // TODO: Implement API call for attendance history
    return [];
  }
}
