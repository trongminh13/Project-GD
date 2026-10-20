import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/features/student/screens/student_dashboard_screen.dart';
import 'package:ashadeep/core/config/feature_flags.dart';

void main() {
  setUp(() {
    FeatureFlags.useDemoFallback = true;
  });

  group('Student Adaptive Dashboard Tests', () {
    testWidgets('TC-ADAPTIVE-01: Displays THPT level badge on default mock student profile (Grade 10)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check student name
      expect(find.text('Nguyễn Minh Anh'), findsOneWidget);

      // Check adaptive THPT badge
      expect(find.text('THPT'), findsOneWidget);
    });

    testWidgets('TC-ADAPTIVE-02: Switching to Sách học tab shows high school subjects and banner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Sách học tab (index 2)
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();

      // Verify banner includes "Trung học phổ thông (Cấp 3)"
      expect(find.textContaining('Trung học phổ thông (Cấp 3)'), findsOneWidget);

      // Verify high school subjects are available as filter chips
      expect(find.text('Toán'), findsOneWidget);
      expect(find.text('Ngữ văn'), findsOneWidget);
      expect(find.text('Tiếng Anh'), findsOneWidget);
      expect(find.text('Vật lý'), findsOneWidget);
      expect(find.text('Hóa học'), findsOneWidget);

      // Verify primary school subject is NOT present in high school
      expect(find.text('Tiếng Việt'), findsNothing);
    });
  });
}
