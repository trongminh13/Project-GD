import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/widgets/app_loading_button.dart';

void main() {
  group('AppLoadingButton Widget Tests', () {
    testWidgets('renders text and icon correctly in idle state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppLoadingButton(
              text: 'Đăng nhập',
              icon: Icons.login,
              isLoading: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('triggers onPressed callback when tapped in idle state', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppLoadingButton(
              text: 'Xác nhận',
              isLoading: false,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Xác nhận'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays CircularProgressIndicator and disables tap when isLoading is true', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppLoadingButton(
              text: 'Nộp bài',
              loadingText: 'Đang gửi dữ liệu...',
              isLoading: true,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Loading spinner & loading text are shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Đang gửi dữ liệu...'), findsOneWidget);

      // Attempt to tap the button while loading
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(const Duration(milliseconds: 300));

      // Callback must NOT be fired
      expect(tapped, isFalse);
    });

    testWidgets('factory constructors (primary, outlined, danger, success) render properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppLoadingButton.primary(text: 'Primary', onPressed: () {}),
                AppLoadingButton.outlined(text: 'Outlined', onPressed: () {}),
                AppLoadingButton.danger(text: 'Danger', onPressed: () {}),
                AppLoadingButton.success(text: 'Success', onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Outlined'), findsOneWidget);
      expect(find.text('Danger'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
    });
  });
}
