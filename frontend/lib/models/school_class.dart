class SchoolClass {
  final String id;
  final String grade; // e.g., "10", "5"
  final String section;
  final String classTeacherId; // ID of the assigned Class Teacher
  final String classTeacherName; // Name for display
  final List<String> subjects; // List of subjects taught in this class
  final Map<String, String> subjectTeachers; // Map<SubjectName, TeacherName>
  final Map<String, List<String>> timetable; // Map<Day, List<Subject>>

  SchoolClass({
    required this.id,
    required this.grade,
    this.section = 'A',
    this.classTeacherId = '',
    this.classTeacherName = 'Not Assigned',
    this.subjects = const [],
    this.subjectTeachers = const {},
    this.timetable = const {},
  });

  String get name => section.isNotEmpty ? '$grade-$section' : grade;

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    String teacherId = '';
    String teacherName = 'Not Assigned';
    final teacher = json['classTeacher'];
    if (teacher != null && teacher is Map) {
      teacherId = teacher['id']?.toString() ?? '';
      teacherName = teacher['name']?.toString() ?? 'Not Assigned';
    }

    return SchoolClass(
      id: json['id']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      section: json['section']?.toString() ?? 'A',
      classTeacherId: teacherId,
      classTeacherName: teacherName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': int.tryParse(id),
      'grade': grade,
      'section': section,
    };
  }
}
