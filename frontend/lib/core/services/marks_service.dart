import 'package:ashadeep/core/network/api_client.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';
import 'package:ashadeep/models/markbook.dart';

class MarksService {
  static final MarksService _instance = MarksService._internal();
  factory MarksService() => _instance;
  MarksService._internal() : _apiClient = ApiClient.instance;

  final ApiClient _apiClient;

  /// Fetches published marks for a specific student id
  Future<List<Map<String, dynamic>>> getStudentMarks(String studentId) async {
    try {
      final res = await _apiClient.get(
        '/marks/$studentId',
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is List) {
        return List<Map<String, dynamic>>.from(res);
      }
    } catch (_) {}
    return [];
  }

  /// Fetches the full Vietnamese học bạ for a student.
  /// [academicYearId] is optional; if null, the backend uses the current year.
  Future<StudentMarkbook?> getStudentMarkbook(
    String studentId, {
    String? academicYearId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (academicYearId != null) {
      queryParams['academicYearId'] = academicYearId;
    }

    try {
      final res = await _apiClient.get(
        '/marks/student/$studentId/markbook',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        policy: ApiTimeoutPolicy.fastRead,
      );
      if (res is Map<String, dynamic>) {
        return StudentMarkbook.fromJson(res);
      }
    } catch (_) {}
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
    final List<Map<String, dynamic>> payload = [];
    studentMarks.forEach((studentId, marks) {
      payload.add({'studentId': studentId, 'marksObtained': marks});
    });

    try {
      await _apiClient.post(
        '/marks/bulk',
        body: {
          'className': className,
          'assessmentId': assessmentId,
          'subject': subject,
          'maxMarks': maxMarks,
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
