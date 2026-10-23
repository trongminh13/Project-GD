import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/widgets/lesson_row.dart';

void main() {
  group('LessonRow Widget Tests', () {
    testWidgets('renders lesson information correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LessonRow(
              lessonIndex: 1,
              subject: 'Toán học',
              time: '07:30–08:15',
              teacher: 'Cô Lê Thu Hà',
              room: 'P.201',
              isCompact: false,
            ),
          ),
        ),
      );

      expect(find.text('Tiết 1'), findsOneWidget);
      expect(find.text('Toán học'), findsOneWidget);
      expect(find.text('Cô Lê Thu Hà · P.201'), findsOneWidget);
      expect(find.text('07:30–08:15'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when user taps row', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonRow(
              lessonIndex: 2,
              subject: 'Tiếng Anh',
              time: '08:20–09:05',
              teacher: 'Thầy Phạm Quốc Bảo',
              room: 'P.Anh 1',
              isCompact: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Tiếng Anh'), findsOneWidget);
      await tester.tap(find.byType(LessonRow));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('isPrimary: true renders colored badge with palette styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LessonRow(
              lessonIndex: 1,
              subject: 'Toán học',
              time: '07:30–08:15',
              teacher: 'Cô Mai',
              room: 'Lớp 1A',
              isPrimary: true,
              paletteIndex: 1, // Warm Amber
            ),
          ),
        ),
      );

      expect(find.text('Tiết 1'), findsOneWidget);
      expect(find.text('Toán học'), findsOneWidget);
      expect(find.text('Cô Mai · Lớp 1A'), findsOneWidget);

      // Verify badge container decoration has Warm Amber background (#FFFBEB) and border (#FCD34D)
      final badgeContainerFinder = find.ancestor(
        of: find.text('Tiết 1'),
        matching: find.byType(Container),
      ).first;
      final decoration = tester.widget<Container>(badgeContainerFinder).decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFFFFBEB));
      expect(decoration.borderRadius, BorderRadius.circular(6));
      expect(decoration.border?.top.color, const Color(0xFFFCD34D));
    });
  });
}
