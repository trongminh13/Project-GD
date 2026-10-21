import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/enums/education_level.dart';

void main() {
  group('EducationLevelHelper Tests', () {
    test('TC-FLUTTER-LEVEL-01: Maps primary grades (1..5) accurately', () {
      expect(EducationLevelHelper.fromGrade('1'), equals(EducationLevel.primary));
      expect(EducationLevelHelper.fromGrade('3'), equals(EducationLevel.primary));
      expect(EducationLevelHelper.fromGrade('5'), equals(EducationLevel.primary));
      expect(EducationLevelHelper.fromGrade('3A'), equals(EducationLevel.primary));
      expect(EducationLevelHelper.fromGrade('Lớp 4-B'), equals(EducationLevel.primary));
    });

    test('TC-FLUTTER-LEVEL-02: Maps secondary grades (6..9) accurately', () {
      expect(EducationLevelHelper.fromGrade('6'), equals(EducationLevel.secondary));
      expect(EducationLevelHelper.fromGrade('7A'), equals(EducationLevel.secondary));
      expect(EducationLevelHelper.fromGrade('8-C'), equals(EducationLevel.secondary));
      expect(EducationLevelHelper.fromGrade('9'), equals(EducationLevel.secondary));
    });

    test('TC-FLUTTER-LEVEL-03: Maps high school grades (10..12) accurately', () {
      expect(EducationLevelHelper.fromGrade('10'), equals(EducationLevel.highSchool));
      expect(EducationLevelHelper.fromGrade('10A1'), equals(EducationLevel.highSchool));
      expect(EducationLevelHelper.fromGrade('11'), equals(EducationLevel.highSchool));
      expect(EducationLevelHelper.fromGrade('12-B'), equals(EducationLevel.highSchool));
    });

    test('TC-FLUTTER-LEVEL-04: Graceful fallback for null, empty or non-numeric grades', () {
      expect(EducationLevelHelper.fromGrade(null), equals(EducationLevel.primary));
      expect(EducationLevelHelper.fromGrade(''), equals(EducationLevel.primary));
      expect(EducationLevelHelper.fromGrade('SpecialClass'), equals(EducationLevel.primary));
    });

    test('TC-FLUTTER-LEVEL-05: Returns correct full and short titles', () {
      expect(EducationLevelHelper.getTitle(EducationLevel.primary), equals('Tiểu học (Cấp 1)'));
      expect(EducationLevelHelper.getTitle(EducationLevel.secondary), equals('Trung học cơ sở (Cấp 2)'));
      expect(EducationLevelHelper.getTitle(EducationLevel.highSchool), equals('Trung học phổ thông (Cấp 3)'));

      expect(EducationLevelHelper.getShortTitle(EducationLevel.primary), equals('Tiểu học'));
      expect(EducationLevelHelper.getShortTitle(EducationLevel.secondary), equals('THCS'));
      expect(EducationLevelHelper.getShortTitle(EducationLevel.highSchool), equals('THPT'));
    });

    test('TC-FLUTTER-LEVEL-06: Returns distinct subject lists by education level', () {
      final primarySubj = EducationLevelHelper.getDefaultSubjects(EducationLevel.primary);
      final secondarySubj = EducationLevelHelper.getDefaultSubjects(EducationLevel.secondary);
      final highSchoolSubj = EducationLevelHelper.getDefaultSubjects(EducationLevel.highSchool);

      expect(primarySubj.contains('Tiếng Việt'), isTrue);
      expect(primarySubj.contains('Ngữ văn'), isFalse);

      expect(secondarySubj.contains('Ngữ văn'), isTrue);
      expect(secondarySubj.contains('KHTN'), isTrue);
      expect(secondarySubj.contains('Tiếng Việt'), isFalse);

      expect(highSchoolSubj.contains('Vật lý'), isTrue);
      expect(highSchoolSubj.contains('Hóa học'), isTrue);
      expect(highSchoolSubj.contains('Sinh học'), isTrue);
    });

    test('TC-FLUTTER-LEVEL-07: Returns correct school name by education level and supports custom school name', () {
      expect(EducationLevelHelper.getSchoolName(EducationLevel.primary), equals('Trường Tiểu học Astra'));
      expect(EducationLevelHelper.getSchoolName(EducationLevel.secondary), equals('Trường THCS Astra'));
      expect(EducationLevelHelper.getSchoolName(EducationLevel.highSchool), equals('Trường THPT Astra'));
      expect(EducationLevelHelper.getSchoolName(EducationLevel.highSchool, 'Trường Chuyên Đại Việt'), equals('Trường Chuyên Đại Việt'));
    });

    test('TC-FLUTTER-LEVEL-08: fromString accurately parses Backend API enum strings and representations', () {
      expect(EducationLevelHelper.fromString('HIGH_SCHOOL'), equals(EducationLevel.highSchool));
      expect(EducationLevelHelper.fromString('highSchool'), equals(EducationLevel.highSchool));
      expect(EducationLevelHelper.fromString('THPT'), equals(EducationLevel.highSchool));
      expect(EducationLevelHelper.fromString('Trung học phổ thông'), equals(EducationLevel.highSchool));

      expect(EducationLevelHelper.fromString('SECONDARY'), equals(EducationLevel.secondary));
      expect(EducationLevelHelper.fromString('secondary'), equals(EducationLevel.secondary));
      expect(EducationLevelHelper.fromString('THCS'), equals(EducationLevel.secondary));
      expect(EducationLevelHelper.fromString('Trung học cơ sở'), equals(EducationLevel.secondary));

      expect(EducationLevelHelper.fromString('PRIMARY'), equals(EducationLevel.primary));
      expect(EducationLevelHelper.fromString('primary'), equals(EducationLevel.primary));
      expect(EducationLevelHelper.fromString('Tiểu học'), equals(EducationLevel.primary));

      expect(EducationLevelHelper.fromString(null), isNull);
      expect(EducationLevelHelper.fromString('UNKNOWN_XYZ'), isNull);
    });

    test('TC-FLUTTER-LEVEL-09: fromGrade handles levelStr parameter and string level names without falling back to primary', () {
      // 1. Grade is string level name like "HIGH_SCHOOL"
      expect(EducationLevelHelper.fromGrade('HIGH_SCHOOL'), equals(EducationLevel.highSchool));
      expect(EducationLevelHelper.fromGrade('THPT'), equals(EducationLevel.highSchool));

      // 2. Grade with levelStr override
      expect(EducationLevelHelper.fromGrade(null, 'HIGH_SCHOOL'), equals(EducationLevel.highSchool));
      expect(EducationLevelHelper.fromGrade('10', 'HIGH_SCHOOL'), equals(EducationLevel.highSchool));
      expect(EducationLevelHelper.fromGrade('', 'SECONDARY'), equals(EducationLevel.secondary));

      // 3. Normal grade parsing
      expect(EducationLevelHelper.fromGrade('3'), equals(EducationLevel.primary));
      expect(EducationLevelHelper.fromGrade('8'), equals(EducationLevel.secondary));
      expect(EducationLevelHelper.fromGrade('11'), equals(EducationLevel.highSchool));
    });
  });
}
