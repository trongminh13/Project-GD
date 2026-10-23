import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/widgets/homework_card.dart';

void main() {
  group('HomeworkCard Widget Tests', () {
    testWidgets('renders title and subject info correctly', (tester) async {
      final mockData = {
        'id': 101,
        'title': 'Bài tập Toán số 5',
        'subjectName': 'Toán học',
        'dueDate': '20/10/2026',
        'submissionStatus': 'PENDING',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeworkCard(
              data: mockData,
              mode: HomeworkCardMode.studentTake,
            ),
          ),
        ),
      );

      expect(find.text('Bài tập Toán số 5'), findsOneWidget);
      expect(find.text('Toán học · Hạn: 20/10/2026'), findsOneWidget);
      expect(find.text('Làm bài'), findsOneWidget);
    });

    testWidgets('studentTake mode triggers onPrimaryAction when tapped', (tester) async {
      bool actionTriggered = false;
      final mockData = {
        'id': 102,
        'title': 'Luyện từ và câu',
        'subjectName': 'Tiếng Việt',
        'submissionStatus': 'IN_PROGRESS',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeworkCard(
              data: mockData,
              mode: HomeworkCardMode.studentTake,
              onPrimaryAction: () {
                actionTriggered = true;
              },
            ),
          ),
        ),
      );

      final button = find.text('Làm bài');
      expect(button, findsOneWidget);
      await tester.tap(button);
      await tester.pump();

      expect(actionTriggered, isTrue);
    });

    testWidgets('studentTake mode displays submitted state when status is GRADED', (tester) async {
      final mockData = {
        'id': 103,
        'title': 'Hình học phẳng',
        'subjectName': 'Toán học',
        'submissionStatus': 'GRADED',
        'finalScore': 9.5,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeworkCard(
              data: mockData,
              mode: HomeworkCardMode.studentTake,
            ),
          ),
        ),
      );

      expect(find.text('Đã nộp · 9.5 đ'), findsOneWidget);
      expect(find.text('Làm bài'), findsNothing);
    });

    testWidgets('parentView mode displays correct status for parents', (tester) async {
      final submittedData = {
        'id': 104,
        'title': 'Chính tả',
        'subjectName': 'Tiếng Việt',
        'submissionStatus': 'GRADED',
        'finalScore': 10,
      };

      final notSubmittedData = {
        'id': 105,
        'title': 'Khoa học tự nhiên',
        'subjectName': 'Khoa học',
        'submissionStatus': 'NOT_STARTED',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HomeworkCard(
                  data: submittedData,
                  mode: HomeworkCardMode.parentView,
                ),
                HomeworkCard(
                  data: notSubmittedData,
                  mode: HomeworkCardMode.parentView,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Điểm: 10 đ'), findsOneWidget);
      expect(find.text('Chưa nộp'), findsOneWidget);
      expect(find.text('Làm bài'), findsNothing);
    });

    testWidgets('isPrimary: true renders pastel card and rounded pill action button', (tester) async {
      final mockData = {
        'id': 201,
        'title': 'Tập viết chữ đẹp bài 3',
        'subjectName': 'Tiếng Việt',
        'dueDate': '25/10/2026',
        'submissionStatus': 'PENDING',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeworkCard(
              data: mockData,
              mode: HomeworkCardMode.studentTake,
              isPrimary: true,
              paletteIndex: 0, // Sky Blue
            ),
          ),
        ),
      );

      expect(find.text('Tập viết chữ đẹp bài 3'), findsOneWidget);
      expect(find.text('Tiếng Việt · Hạn: 25/10/2026'), findsOneWidget);
      expect(find.text('Làm bài'), findsOneWidget);

      // Verify outer container decoration: Sky Blue (#F0F7FF) and border (#93C5FD)
      final containerFinder = find.descendant(
        of: find.byType(HomeworkCard),
        matching: find.byType(Container),
      ).first;
      final decoration = tester.widget<Container>(containerFinder).decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFF0F7FF));
      expect(decoration.borderRadius, BorderRadius.circular(14));
      expect(decoration.border?.top.color, const Color(0xFF93C5FD));
      expect(decoration.border?.top.width, 1.5);
    });
  });
}
