import 'package:ashadeep/core/network/api_client.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';
import 'package:ashadeep/core/models/paginated_response.dart';
import 'package:ashadeep/models/student.dart';

class StudentService {
  static final StudentService _instance = StudentService._internal();
  factory StudentService() => _instance;
  StudentService._internal() : _apiClient = ApiClient.instance;

  final ApiClient _apiClient;

  Future<PaginatedResponse<Student>> getAllStudents({
    int page = 0,
    int size = 20,
    String sortBy = 'id',
    String sortDir = 'asc',
  }) async {
    try {
      final res = await _apiClient.get(
        '/students',
        queryParams: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'sortDir': sortDir,
        },
        policy: ApiTimeoutPolicy.fastRead,
      );

      if (res is Map<String, dynamic>) {
        return PaginatedResponse.fromJson(res, Student.fromJson);
      }
    } catch (_) {}

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

  /// Fetches ALL students by paginating through all pages
  Future<List<Student>> getAllStudentsFlat() async {
    final List<Student> allStudents = [];
    int page = 0;
    const int size = 100;
    bool hasMore = true;

    while (hasMore) {
      final paginated = await getAllStudents(page: page, size: size);
      allStudents.addAll(paginated.content);
      hasMore = !paginated.last && paginated.content.isNotEmpty;
      page++;
      // Bảo vệ loop vô hạn
      if (page >= 100) break;
    }

    return allStudents;
  }

  Future<bool> addStudent(Student student) async {
    try {
      await _apiClient.post(
        '/students',
        body: student.toJson(),
        policy: ApiTimeoutPolicy.mutation,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get students filtered by class name (client-side filtering)
  Future<List<Student>> getStudentsByClass(String className) async {
    final allStudents = await getAllStudentsFlat();
    return allStudents.where((s) => s.className == className).toList();
  }

  Future<bool> deleteStudent(int id) async {
    try {
      await _apiClient.delete(
        '/students/$id',
        policy: ApiTimeoutPolicy.mutation,
      );
      return true;
    } catch (_) {
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
