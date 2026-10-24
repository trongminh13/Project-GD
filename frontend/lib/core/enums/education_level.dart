/// Định nghĩa các cấp bậc học theo hệ thống giáo dục Việt Nam
enum EducationLevel {
  primary, // Cấp 1: Lớp 1 - 5 (Tiểu học)
  secondary, // Cấp 2: Lớp 6 - 9 (THCS)
  highSchool, // Cấp 3: Lớp 10 - 12 (THPT)
}

/// Helper tiện ích hỗ trợ phân loại và định dạng dữ liệu theo cấp học
class EducationLevelHelper {
  EducationLevelHelper._();

  /// Phân loại cấp học dựa trên chuỗi tên Enum hoặc mô tả từ Backend API ("HIGH_SCHOOL", "SECONDARY", "PRIMARY", v.v.)
  static EducationLevel? fromString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim().toUpperCase();
    if (str.contains('HIGH') ||
        str.contains('THPT') ||
        str.contains('CẤP 3') ||
        str.contains('CAP 3') ||
        str.contains('PHỔ THÔNG')) {
      return EducationLevel.highSchool;
    }
    if (str.contains('SECOND') ||
        str.contains('THCS') ||
        str.contains('CẤP 2') ||
        str.contains('CAP 2') ||
        str.contains('CƠ SỞ')) {
      return EducationLevel.secondary;
    }
    if (str.contains('PRIM') ||
        str.contains('TIỂU') ||
        str.contains('TIEU') ||
        str.contains('CẤP 1') ||
        str.contains('CAP 1')) {
      return EducationLevel.primary;
    }
    return null;
  }

  /// Phân loại cấp học dựa trên chuỗi grade hoặc cấp học
  static EducationLevel fromGrade(dynamic grade, [dynamic levelStr]) {
    // 1. Ưu tiên cấp học truyền kèm nếu có
    final parsedFromLevel = fromString(levelStr);
    if (parsedFromLevel != null) return parsedFromLevel;

    // 2. Kiểm tra nếu grade thực chất là tên cấp học (ví dụ: "HIGH_SCHOOL", "THPT")
    final parsedFromGrade = fromString(grade);
    if (parsedFromGrade != null) return parsedFromGrade;

    // 3. Phân loại theo khối lớp số (1 đến 12)
    if (grade == null) return EducationLevel.primary;
    final cleanStr = grade.toString().replaceAll(RegExp(r'[^0-9]'), '');
    final g = int.tryParse(cleanStr) ?? 1;
    if (g <= 5) return EducationLevel.primary;
    if (g <= 9) return EducationLevel.secondary;
    return EducationLevel.highSchool;
  }

  /// Tiêu đề đầy đủ kèm cấp
  static String getTitle(EducationLevel level) {
    switch (level) {
      case EducationLevel.primary:
        return 'Tiểu học (Cấp 1)';
      case EducationLevel.secondary:
        return 'Trung học cơ sở (Cấp 2)';
      case EducationLevel.highSchool:
        return 'Trung học phổ thông (Cấp 3)';
    }
  }

  /// Tiêu đề ngắn gọn cho badge / tag hiển thị trên UI
  static String getShortTitle(EducationLevel level) {
    switch (level) {
      case EducationLevel.primary:
        return 'Tiểu học';
      case EducationLevel.secondary:
        return 'THCS';
      case EducationLevel.highSchool:
        return 'THPT';
    }
  }

  /// Tên trường tương ứng theo từng cấp bậc học
  static String getSchoolName(
    EducationLevel level, [
    String? customSchoolName,
  ]) {
    if (customSchoolName != null && customSchoolName.trim().isNotEmpty) {
      return customSchoolName.trim();
    }
    switch (level) {
      case EducationLevel.primary:
        return 'Trường Tiểu học Đại Việt';
      case EducationLevel.secondary:
        return 'Trường THCS Đại Việt';
      case EducationLevel.highSchool:
        return 'Trường THPT Đại Việt';
    }
  }

  /// Danh mục môn học đặc thù theo chuẩn chương trình GDPT 2018 từng cấp
  static List<String> getDefaultSubjects(EducationLevel level) {
    switch (level) {
      case EducationLevel.primary:
        return [
          'Tất cả',
          'Toán',
          'Tiếng Việt',
          'Tiếng Anh',
          'Tự nhiên & Xã hội',
          'Đạo đức',
          'Tin học',
        ];
      case EducationLevel.secondary:
        return [
          'Tất cả',
          'Toán',
          'Ngữ văn',
          'Tiếng Anh',
          'KHTN',
          'Lịch sử & Địa lý',
          'GDCD',
          'Tin học',
        ];
      case EducationLevel.highSchool:
        return [
          'Tất cả',
          'Toán',
          'Ngữ văn',
          'Tiếng Anh',
          'Vật lý',
          'Hóa học',
          'Sinh học',
          'Lịch sử',
          'Địa lý',
          'Tin học',
        ];
    }
  }
}
