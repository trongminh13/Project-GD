import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ashadeep/models/school_class.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';

class ClassService {
  static final ClassService _instance = ClassService._internal();

  factory ClassService() {
    return _instance;
  }

  ClassService._internal();

  final List<SchoolClass> _classes = [];

  List<SchoolClass> getAllClasses() {
    return _classes;
  }

  /// Fetches classes from backend API and updates local cache
  Future<List<SchoolClass>> fetchClassesFromBackend() async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/classes');

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
        _classes.clear();
        for (var item in data) {
          _classes.add(SchoolClass.fromJson(item));
        }
      }
    } catch (_) {}

    return _classes;
  }

  Future<bool> createClassBackend(String grade, String section) async {
    final token = await AuthService().getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/classes');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'grade': grade,
          'section': section.isNotEmpty ? section : 'A',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newClass = SchoolClass.fromJson(data);
        _classes.add(newClass);
        return true;
      }
    } catch (_) {}

    return false;
  }

  void addClass(SchoolClass newClass) {
    _classes.add(newClass);
  }

  void updateClassTeacher(
    String classId,
    String teacherId,
    String teacherName,
  ) {
    final index = _classes.indexWhere((c) => c.id == classId);
    if (index != -1) {
      final oldClass = _classes[index];
      _classes[index] = SchoolClass(
        id: oldClass.id,
        grade: oldClass.grade,
        section: oldClass.section,
        subjects: oldClass.subjects,
        classTeacherId: teacherId,
        classTeacherName: teacherName,
        subjectTeachers: oldClass.subjectTeachers,
      );
    }
  }

  void updateSubjectTeacher(
    String classId,
    String subject,
    String teacherName,
  ) {
    final index = _classes.indexWhere((c) => c.id == classId);
    if (index != -1) {
      final oldClass = _classes[index];
      final newSubjectTeachers = Map<String, String>.from(
        oldClass.subjectTeachers,
      );
      newSubjectTeachers[subject] = teacherName;

      _classes[index] = SchoolClass(
        id: oldClass.id,
        grade: oldClass.grade,
        section: oldClass.section,
        subjects: oldClass.subjects,
        classTeacherId: oldClass.classTeacherId,
        classTeacherName: oldClass.classTeacherName,
        subjectTeachers: newSubjectTeachers,
      );
    }
  }

  void updateTimetable(String classId, String day, List<String> subjects) {
    final index = _classes.indexWhere((c) => c.id == classId);
    if (index != -1) {
      final oldClass = _classes[index];
      final newTimetable = Map<String, List<String>>.from(oldClass.timetable);
      newTimetable[day] = subjects;

      _classes[index] = SchoolClass(
        id: oldClass.id,
        grade: oldClass.grade,
        section: oldClass.section,
        subjects: oldClass.subjects,
        classTeacherId: oldClass.classTeacherId,
        classTeacherName: oldClass.classTeacherName,
        subjectTeachers: oldClass.subjectTeachers,
        timetable: newTimetable,
      );
    }
  }

  SchoolClass? getClassByClassTeacherId(String teacherId) {
    try {
      return _classes.firstWhere((c) => c.classTeacherId == teacherId);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> getTeacherSchedule(String teacherName) {
    List<Map<String, dynamic>> schedule = [];

    for (var schoolClass in _classes) {
      schoolClass.timetable.forEach((day, subjects) {
        for (int i = 0; i < subjects.length; i++) {
          final subject = subjects[i];
          final assignedTeacher = schoolClass.subjectTeachers[subject];

          if (assignedTeacher == teacherName) {
            schedule.add({
              'day': day,
              'period': i + 1,
              'subject': subject,
              'class': schoolClass.grade,
              'room': '201',
            });
          }
        }
      });
    }
    return schedule;
  }
}
