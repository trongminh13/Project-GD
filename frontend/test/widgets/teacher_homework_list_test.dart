import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/features/teacher/screens/teacher_homework_list_screen.dart';
import 'package:ashadeep/core/widgets/app_empty_card.dart';
import 'package:ashadeep/core/widgets/homework_card.dart';
import 'package:ashadeep/core/config/feature_flags.dart';

void main() {
  setUp(() {
    FeatureFlags.useDemoFallback = true;
  });

  group('TeacherHomeworkListScreen Widget Tests', () {
    testWidgets('TC-TEACHER-HW-01: Empty state displays AppEmptyCard in Kho Bài Tập tab', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TeacherHomeworkListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyCard), findsOneWidget);
      expect(find.text('Chưa có bài tập nào được soạn'), findsOneWidget);
      expect(find.text('Nhấn "Soạn bài mới" để tạo bài tập đầu tiên cho lớp của bạn.'), findsOneWidget);
    });

    testWidgets('TC-TEACHER-HW-02: HomeworkCard in teacherGrade mode renders action button', (tester) async {
      bool actionTapped = false;
      final mockHomework = {
        'id': 1,
        'title': 'Ôn tập phép nhân',
        'subjectName': 'Toán học',
        'dueDate': '25/10/2026',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeworkCard(
              data: mockHomework,
              mode: HomeworkCardMode.teacherGrade,
              onPrimaryAction: () {
                actionTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Ôn tập phép nhân'), findsOneWidget);
      expect(find.text('Toán học · Hạn: 25/10/2026'), findsOneWidget);
      expect(find.text('Chấm bài'), findsOneWidget);

      await tester.tap(find.text('Chấm bài'));
      await tester.pump();
      expect(actionTapped, isTrue);
    });

    testWidgets('TC-TEACHER-HW-03: Switching to Lớp Đã Giao tab displays assigned assignments empty card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TeacherHomeworkListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Tab 'Lớp Đã Giao'
      await tester.tap(find.text('Lớp Đã Giao'));
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyCard), findsOneWidget);
      expect(find.text('Chưa có bài tập nào được giao cho lớp'), findsOneWidget);
      expect(find.text('Chọn một bài tập trong tab "Kho Bài Tập" và nhấn "Giao bài cho Lớp".'), findsOneWidget);
    });
  });
}
