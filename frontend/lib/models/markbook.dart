/// Model học bạ – ánh xạ với StudentMarkbookResponse từ backend.
library;

/// Dữ liệu điểm một học kỳ của một môn.
class SemesterMark {
  final int semester;

  /// Danh sách điểm thường xuyên (TX), theo thứ tự txIndex.
  final List<double?> txScores;

  /// Điểm giữa kỳ (GK, hệ số 2). Null nếu chưa nhập.
  final double? gkScore;

  /// Điểm cuối kỳ (CK, hệ số 3). Null nếu chưa nhập.
  final double? ckScore;

  /// Điểm trung bình học kỳ (tính theo TT22).
  final double? avg;

  /// Nhận xét văn bản (Tiểu học lớp 1–3).
  final List<String>? comments;

  const SemesterMark({
    required this.semester,
    this.txScores = const [],
    this.gkScore,
    this.ckScore,
    this.avg,
    this.comments,
  });

  factory SemesterMark.fromJson(Map<String, dynamic> json) {
    return SemesterMark(
      semester: json['semester'] as int? ?? 1,
      txScores: (json['txScores'] as List<dynamic>?)
              ?.map((e) => e != null ? (e as num).toDouble() : null)
              .toList() ??
          [],
      gkScore: (json['gkScore'] as num?)?.toDouble(),
      ckScore: (json['ckScore'] as num?)?.toDouble(),
      avg: (json['avg'] as num?)?.toDouble(),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

/// Dữ liệu điểm học bạ của một môn trong cả năm học.
class SubjectMarkbook {
  final int subjectId;
  final String subjectName;
  final SemesterMark? semester1;
  final SemesterMark? semester2;

  /// Điểm trung bình cả năm = (DTB_HK1 + DTB_HK2×2) / 3.
  final double? yearAvg;

  /// Xếp loại học lực môn: "Giỏi", "Khá", "Trung bình", "Xuất sắc"...
  final String? academicClassification;

  const SubjectMarkbook({
    required this.subjectId,
    required this.subjectName,
    this.semester1,
    this.semester2,
    this.yearAvg,
    this.academicClassification,
  });

  factory SubjectMarkbook.fromJson(Map<String, dynamic> json) {
    return SubjectMarkbook(
      subjectId: (json['subjectId'] as num?)?.toInt() ?? 0,
      subjectName: json['subjectName'] as String? ?? '',
      semester1: json['semester1'] != null
          ? SemesterMark.fromJson(json['semester1'] as Map<String, dynamic>)
          : null,
      semester2: json['semester2'] != null
          ? SemesterMark.fromJson(json['semester2'] as Map<String, dynamic>)
          : null,
      yearAvg: (json['yearAvg'] as num?)?.toDouble(),
      academicClassification: json['academicClassification'] as String?,
    );
  }
}

/// Học bạ đầy đủ của một học sinh trong một năm học.
class StudentMarkbook {
  final int studentId;
  final String studentName;
  final String? studentAdmissionNumber;

  /// Tên năm học, ví dụ: "2024-2025".
  final String? academicYear;

  /// Cấp học enum: "PRIMARY" | "SECONDARY" | "HIGH_SCHOOL".
  final String educationLevel;

  /// Tên cấp học tiếng Việt: "Tiểu học" | "THCS" | "THPT".
  final String educationLevelDisplayName;

  /// Tên lớp, ví dụ: "10A1".
  final String? className;

  /// Tên trường.
  final String? schoolName;

  /// Danh sách điểm từng môn học.
  final List<SubjectMarkbook> subjects;

  /// Điểm trung bình chung cả năm.
  final double? overallAvg;

  /// Xếp loại học lực tổng: "Giỏi", "Xuất sắc"...
  final String? overallClassification;

  /// Hạnh kiểm: "Tốt", "Khá", "Trung bình", "Yếu".
  final String? conduct;

  /// Danh hiệu khen thưởng (TT 22/2021): "Học sinh Xuất sắc", "Học sinh Giỏi" hoặc null.
  final String? honorTitle;

  const StudentMarkbook({
    required this.studentId,
    required this.studentName,
    this.studentAdmissionNumber,
    this.academicYear,
    required this.educationLevel,
    required this.educationLevelDisplayName,
    this.className,
    this.schoolName,
    this.subjects = const [],
    this.overallAvg,
    this.overallClassification,
    this.conduct,
    this.honorTitle,
  });

  factory StudentMarkbook.fromJson(Map<String, dynamic> json) {
    return StudentMarkbook(
      studentId: (json['studentId'] as num?)?.toInt() ?? 0,
      studentName: json['studentName'] as String? ?? '',
      studentAdmissionNumber: json['studentAdmissionNumber'] as String?,
      academicYear: json['academicYear'] as String?,
      educationLevel: json['educationLevel'] as String? ?? 'PRIMARY',
      educationLevelDisplayName:
          json['educationLevelDisplayName'] as String? ?? 'Tiểu học',
      className: json['className'] as String?,
      schoolName: json['schoolName'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => SubjectMarkbook.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      overallAvg: (json['overallAvg'] as num?)?.toDouble(),
      overallClassification: json['overallClassification'] as String?,
      conduct: json['conduct'] as String?,
      honorTitle: json['honorTitle'] as String?,
    );
  }

  /// Tiểu học lớp 1–3: dùng nhận xét, không điểm số.
  bool get isNarrativeOnly =>
      educationLevel == 'PRIMARY' && _isLowerPrimary(className);

  static bool _isLowerPrimary(String? className) {
    if (className == null) return false;
    final num = RegExp(r'\d+').firstMatch(className)?.group(0);
    if (num == null) return false;
    final g = int.tryParse(num) ?? 0;
    return g <= 3;
  }
}
