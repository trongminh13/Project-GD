import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/features/student/screens/student_dashboard_screen.dart';
import 'package:ashadeep/core/config/feature_flags.dart';

void main() {
  setUp(() {
    FeatureFlags.useDemoFallback = true;
  });

  group('Student Dashboard Navigation & Layout Tests', () {
    testWidgets('TC-NAV-01: BottomNavigationBar has 6 items with Bảng điểm at index 4 and Thông báo at index 5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final navBarFinder = find.byType(BottomNavigationBar);
      expect(navBarFinder, findsOneWidget);

      final navBar = tester.widget<BottomNavigationBar>(navBarFinder);
      expect(navBar.items.length, equals(6));

      // Verify labels in exact sequence
      expect(navBar.items[0].label, equals('Trang chủ'));
      expect(navBar.items[1].label, equals('Lịch học'));
      expect(navBar.items[2].label, equals('Sách học'));
      expect(navBar.items[3].label, equals('Bài tập'));
      expect(navBar.items[4].label, equals('Bảng điểm'));
      expect(navBar.items[5].label, equals('Thông báo'));

      // Verify Bảng điểm icon (between homework and notification)
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
      // Verify notification icon
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('TC-NAV-02: AppBar actions has Reload, Thêm, and Logout in exact sequence', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final reloadFinder = find.byIcon(Icons.refresh);
      final moreFinder = find.byIcon(Icons.more_horiz);
      final logoutFinder = find.byIcon(Icons.logout);

      expect(reloadFinder, findsOneWidget);
      expect(moreFinder, findsOneWidget);
      expect(logoutFinder, findsOneWidget);

      // Verify horizontal positions: Reload < Thêm < Logout
      final reloadX = tester.getTopLeft(reloadFinder).dx;
      final moreX = tester.getTopLeft(moreFinder).dx;
      final logoutX = tester.getTopLeft(logoutFinder).dx;

      expect(reloadX, lessThan(moreX));
      expect(moreX, lessThan(logoutX));
    });

    testWidgets('TC-NAV-03: Tapping Thông báo tab switches to notice view and updates AppBar title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Initially on Trang chủ
      expect(find.text('Trang chủ'), findsWidgets);

      // Tap on Thông báo tab (find the icon or label)
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      // Title should now be Thông báo
      expect(find.text('Bảng tin & Thông báo nhà trường'), findsOneWidget);
      expect(find.text('Họp phụ huynh đầu học kỳ 1 năm học 2026–2027'), findsOneWidget);
    });

    testWidgets('TC-NAV-04: Tapping Thêm on AppBar opens student utilities BottomSheet', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the Thêm icon on AppBar
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // Verify Modal BottomSheet opens with utilities
      expect(find.text('Tiện ích học sinh'), findsOneWidget);
      expect(find.text('Bảng điểm & Kết quả học tập'), findsOneWidget);
      expect(find.text('Lịch sử Chuyên cần / Điểm danh'), findsOneWidget);
      expect(find.text('Chế độ Dữ liệu Demo (Demo Mode)'), findsOneWidget);
    });

    testWidgets('TC-NAV-05: Tapping a notice card opens detail modal dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to notification tab
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      // Tap on the first notice card
      await tester.tap(find.text('Họp phụ huynh đầu học kỳ 1 năm học 2026–2027'));
      await tester.pumpAndSettle();

      // Verify detail dialog appears with title, audience and 'Đã hiểu' button
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Đã hiểu'), findsOneWidget);

      // Close modal by tapping 'Đã hiểu'
      await tester.tap(find.text('Đã hiểu'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('TC-NAV-06: Audience filter chips filter notices accurately', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to notification tab
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      // Filter chips should be present
      expect(find.widgetWithText(ChoiceChip, 'Tất cả'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Toàn trường'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Lớp 3A'), findsOneWidget);

      // Tap on 'Lớp 3A' chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'Lớp 3A'));
      await tester.pumpAndSettle();

      // Should display class-specific notice
      expect(find.text('Đổi giờ ra về chiều thứ Sáu ngày 16/10'), findsOneWidget);
    });

    testWidgets('TC-NAV-07: Unread badge is displayed on notification BottomNavigationBar tab', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find Badge widget on bottom navigation bar
      final badgeFinder = find.byType(Badge);
      expect(badgeFinder, findsWidgets);

      // Verify unread count matches unread notices (mock notices has 2 unread: notice 1 and notice 2)
      expect(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('2')), findsOneWidget);
    });

    testWidgets('TC-NAV-08: Tapping Bảng điểm tab switches to marks view and displays GPA and subject marks', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: StudentDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Bảng điểm tab (icon analytics_outlined)
      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pumpAndSettle();

      // Verify KPI Header and Academic Rank
      expect(find.text('ĐIỂM TRUNG BÌNH HỌC KỲ'), findsOneWidget);
      expect(find.text('Học lực Xuất sắc'), findsOneWidget);

      // Verify Subject marks are displayed
      expect(find.text('Toán học'), findsOneWidget);
      expect(find.text('Tiếng Việt'), findsOneWidget);
      expect(find.text('Tiếng Anh'), findsOneWidget);

      // Verify Teacher Remarks Card
      expect(find.text('Đánh giá Rèn luyện & Khen thưởng'), findsOneWidget);
      expect(find.text('Tốt (Xuất sắc)'), findsOneWidget);
    });

    testWidgets('TC-NAV-09: Tapping Bảng điểm in Thêm bottom sheet switches to Marks tab', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open Thêm sheet
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      // Tap on Bảng điểm & Kết quả học tập
      await tester.tap(find.text('Bảng điểm & Kết quả học tập'));
      await tester.pumpAndSettle();

      // Verify navigates directly to Marks tab and displays GPA
      expect(find.text('Tiện ích học sinh'), findsNothing); // Sheet is closed
      expect(find.text('ĐIỂM TRUNG BÌNH HỌC KỲ'), findsOneWidget);
      expect(find.text('Học lực Xuất sắc'), findsOneWidget);
    });
  });
}
