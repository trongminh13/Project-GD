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
  });
}
