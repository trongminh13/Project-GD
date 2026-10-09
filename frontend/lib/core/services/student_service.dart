import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ashadeep/models/student.dart';
import 'package:ashadeep/core/models/paginated_response.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class StudentService {
  static final StudentService _instance = StudentService._internal();

  factory StudentService() {
    return _instance;
  }

  StudentService._internal();

  Future<PaginatedResponse<Student>> getAllStudents({
    int page = 0,
    int size = 20,
    String sortBy = 'id',
    String sortDir = 'asc',
  }) async {
    final token = await AuthService().getToken();
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/students?page=$page&size=$size&sortBy=$sortBy&sortDir=$sortDir',
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
        return PaginatedResponse.fromJson(data, Student.fromJson);
      } else {
        print('Failed to fetch students: ${response.statusCode}');
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
      print('Error fetching students: $e');
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

  /// Fetches ALL students by paginating through all pages
  Future<List<Student>> getAllStudentsFlat() async {
    List<Student> allStudents = [];
    int page = 0;
    const int size = 100;
    bool hasMore = true;

    while (hasMore) {
      final paginated = await getAllStudents(page: page, size: size);
      allStudents.addAll(paginated.content);
      hasMore = !paginated.last;
      page++;
    }

    return allStudents;
  }

  Future<bool> addStudent(Student student) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/students');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(student.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to add student: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding student: $e');
      return false;
    }
  }

  /// Get students filtered by class name (client-side filtering)
  Future<List<Student>> getStudentsByClass(String className) async {
    final allStudents = await getAllStudentsFlat();
    return allStudents.where((s) => s.className == className).toList();
  }

  Future<bool> deleteStudent(int id) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/students/$id');
    print('[DELETE] Attempting to delete student ID: $id at $url');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(
        '[DELETE] Response status: ${response.statusCode}, body: ${response.body}',
      );
      return response.statusCode == 200;
    } catch (e) {
      print('[DELETE] Error deleting student $id: $e');
      return false;
    }
  }

  Future<int> deleteStudents(List<int> ids) async {
    int successCount = 0;
    for (final id in ids) {
      if (await deleteStudent(id)) {
        successCount++;
      }
    }
    return successCount;
  }
}
