import 'package:ashadeep/core/network/api_client.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';
import 'package:ashadeep/core/models/paginated_response.dart';
import 'package:ashadeep/models/teacher.dart';

class TeacherService {
  static final TeacherService _instance = TeacherService._internal();
  factory TeacherService() => _instance;
  TeacherService._internal() : _apiClient = ApiClient.instance;

  final ApiClient _apiClient;

  Future<PaginatedResponse<Teacher>> getAllTeachers({
    int page = 0,
    int size = 20,
    String sortBy = 'id',
    String sortDir = 'asc',
  }) async {
    try {
      final res = await _apiClient.get(
        '/teachers',
        queryParams: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'sortDir': sortDir,
        },
        policy: ApiTimeoutPolicy.fastRead,
      );

      if (res is Map<String, dynamic>) {
        return PaginatedResponse.fromJson(res, Teacher.fromJson);
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

  /// Fetches all teachers without pagination (for operations that need the full list)
  Future<List<Teacher>> getAllTeachersFlat() async {
    final paginated = await getAllTeachers(page: 0, size: 100);
    return paginated.content;
  }

  Future<bool> addTeacher(Teacher teacher) async {
    try {
      await _apiClient.post(
        '/teachers',
        body: teacher.toJson(),
        policy: ApiTimeoutPolicy.mutation,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // Mock Attendance Methods (kept for compatibility)
  void markAttendance(String teacherId, String date, String status) {
    // API call for attendance if implemented
  }

  Map<String, String> getAttendance(String teacherId) {
    return {};
  }
}
