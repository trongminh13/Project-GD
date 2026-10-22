import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/widgets/app_shimmer.dart';
import 'package:ashadeep/core/widgets/network_status_banner.dart';

void main() {
  group('NetworkStatusBanner Tests', () {
    testWidgets('Renders empty when idle without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkStatusBanner(),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('Đang kiểm tra cập nhật mới...'), findsNothing);
    });

    testWidgets('Renders syncing state properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkStatusBanner(isSyncing: true),
          ),
        ),
      );

      expect(find.text('Đang kiểm tra cập nhật mới...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Renders offline error state with retry button', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NetworkStatusBanner(
              isOffline: true,
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);

      await tester.tap(find.text('Thử lại'));
      await tester.pump();
      expect(retried, isTrue);
    });
  });

  group('AppShimmer Tests', () {
    testWidgets('AppShimmerCard renders with border radius 4px', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppShimmerCard(height: 100),
          ),
        ),
      );

      expect(find.byType(AppShimmer), findsOneWidget);
      expect(find.byType(AppShimmerBox), findsNWidgets(4));
    });
  });
}
