import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/widgets/app_section_header.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

void main() {
  group('AppSectionHeader Widget Tests', () {
    testWidgets('TC-HEADER-01: renders title correctly without link button when linkLabel is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSectionHeader(
              title: 'Cần làm (3)',
            ),
          ),
        ),
      );

      expect(find.text('Cần làm (3)'), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('TC-HEADER-02: renders link button with black border, rounded corners, and transparent background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSectionHeader(
              title: 'Sách đọc mới',
              linkLabel: 'Xem tất cả',
              onLink: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sách đọc mới'), findsOneWidget);
      final linkFinder = find.text('Xem tất cả');
      expect(linkFinder, findsOneWidget);

      // Verify the link text styling
      final textWidget = tester.widget<Text>(linkFinder);
      expect(textWidget.style?.color, equals(Colors.black));
      expect(textWidget.style?.fontWeight, equals(FontWeight.w600));

      // Verify the container has border viền đen, bo góc, nền không màu
      final containerFinder = find.ancestor(
        of: linkFinder,
        matching: find.byType(Container),
      ).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(AppColors.cardBorderRadius));
      expect(decoration.border?.top.color, equals(Colors.black));
      expect(decoration.border?.top.width, equals(1.0));
    });

    testWidgets('TC-HEADER-03: triggers onLink callback when Xem tất cả is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSectionHeader(
              title: 'Bài tập cần làm',
              linkLabel: 'Xem tất cả',
              onLink: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Xem tất cả'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('TC-HEADER-04: renders Xem tuần button with same black border and triggers callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSectionHeader(
              title: 'Lịch học hôm nay',
              linkLabel: 'Xem tuần',
              onLink: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Lịch học hôm nay'), findsOneWidget);
      final linkFinder = find.text('Xem tuần');
      expect(linkFinder, findsOneWidget);

      final containerFinder = find.ancestor(
        of: linkFinder,
        matching: find.byType(Container),
      ).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, equals(Colors.white));
      expect(decoration.borderRadius, equals(AppColors.cardBorderRadius));
      expect(decoration.border?.top.color, equals(Colors.black));

      await tester.tap(linkFinder);
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
