import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/features/parent/screens/parent_homework_screen.dart';
import 'package:ashadeep/core/widgets/app_empty_card.dart';
import 'package:ashadeep/core/widgets/homework_card.dart';
import 'package:ashadeep/core/config/feature_flags.dart';

void main() {
  setUp(() {
    FeatureFlags.useDemoFallback = true;
  });

  group('ParentHomeworkScreen Widget Tests', () {
    testWidgets('TC-PARENT-HW-01: Displays AppEmptyCard for empty homework list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ParentHomeworkScreen(studentId: 999),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyCard), findsOneWidget);
      expect(find.text('Không có bài tập nào cần làm'), findsOneWidget);
      expect(find.text('Hiện tại con không có bài tập nào cần làm.'), findsOneWidget);
    });

    testWidgets('TC-PARENT-HW-02: Switching to Đã nộp / Đã có điểm tab displays submitted empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ParentHomeworkScreen(studentId: 999),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Đã nộp / Đã có điểm'));
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyCard), findsOneWidget);
      expect(find.text('Chưa có bài tập nào đã nộp'), findsOneWidget);
      expect(find.text('Con chưa hoàn thành hoặc chưa nộp bài tập nào.'), findsOneWidget);
    });

    testWidgets('TC-PARENT-HW-03: HomeworkCard in parentView mode shows submission status and score badge', (tester) async {
      final unsubmittedTask = {
        'id': 101,
        'title': 'Tập đọc bài 12',
        'subjectName': 'Tiếng Việt',
        'dueDate': '20/10/2026',
        'submissionStatus': 'NOT_STARTED',
      };

      final gradedTask = {
        'id': 102,
        'title': 'Phép cộng có nhớ',
        'subjectName': 'Toán học',
        'dueDate': '18/10/2026',
        'submissionStatus': 'GRADED',
        'finalScore': 9.5,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HomeworkCard(
                  data: unsubmittedTask,
                  mode: HomeworkCardMode.parentView,
                ),
                HomeworkCard(
                  data: gradedTask,
                  mode: HomeworkCardMode.parentView,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tập đọc bài 12'), findsOneWidget);
      expect(find.text('Chưa nộp'), findsOneWidget);
      expect(find.text('Phép cộng có nhớ'), findsOneWidget);
      expect(find.text('Điểm: 9.5 đ'), findsOneWidget);
    });
  });
}
