import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/features/student/screens/student_dashboard_screen.dart';
import 'package:ashadeep/core/config/feature_flags.dart';
import 'package:ashadeep/core/widgets/material_card.dart';
import 'package:ashadeep/core/widgets/homework_card.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

void main() {
  setUp(() {
    FeatureFlags.useDemoFallback = true;
  });

  group('Student Dashboard Navigation & Layout Tests', () {
    testWidgets(
      'TC-NAV-01: BottomNavigationBar has 6 items with Bảng điểm at index 4 and Thông báo at index 5',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
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
      },
    );

    testWidgets(
      'TC-NAV-02: Clean layout without top AppBar; Pull-to-Refresh indicator exists',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
        );
        await tester.pumpAndSettle();

        // Verify AppBar is eliminated to maximize screen real estate
        expect(find.byType(AppBar), findsNothing);

        // Verify RefreshIndicator exists for pull-to-refresh
        expect(find.byType(RefreshIndicator), findsWidgets);
      },
    );

    testWidgets('TC-NAV-03: Tapping Thông báo tab switches to notice view', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: StudentDashboardScreen()),
      );
      await tester.pumpAndSettle();

      // Initially on Trang chủ
      expect(find.text('Trang chủ'), findsWidgets);

      // Tap on Thông báo tab (find the icon or label)
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      // Title should now be Thông báo
      expect(find.text('Bảng tin & Thông báo nhà trường'), findsOneWidget);
      expect(
        find.text('Họp phụ huynh đầu học kỳ 1 năm học 2026–2027'),
        findsOneWidget,
      );
    });

    testWidgets(
      'TC-NAV-04: Tapping Cài đặt on Hero Card opens student utilities BottomSheet',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
        );
        await tester.pumpAndSettle();

        // Tap the Cài đặt & Tiện ích button on Hero Card
        await tester.tap(find.text('Cài đặt & Tiện ích'));
        await tester.pumpAndSettle();

        // Verify Modal BottomSheet opens with utilities
        expect(find.text('Tiện ích học sinh'), findsOneWidget);
        expect(find.text('Bảng điểm & Kết quả học tập'), findsOneWidget);
        expect(find.text('Lịch sử Chuyên cần / Điểm danh'), findsOneWidget);
        expect(find.text('Chế độ Dữ liệu Demo (Demo Mode)'), findsOneWidget);
      },
    );

    testWidgets('TC-NAV-05: Tapping a notice card opens detail modal dialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: StudentDashboardScreen()),
      );
      await tester.pumpAndSettle();

      // Switch to notification tab
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      // Tap on the first notice card
      await tester.tap(
        find.text('Họp phụ huynh đầu học kỳ 1 năm học 2026–2027'),
      );
      await tester.pumpAndSettle();

      // Verify detail dialog appears with title, audience and 'Đã hiểu' button
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Đã hiểu'), findsOneWidget);

      // Close modal by tapping 'Đã hiểu'
      await tester.tap(find.text('Đã hiểu'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('TC-NAV-06: Audience filter chips filter notices accurately', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: StudentDashboardScreen()),
      );
      await tester.pumpAndSettle();

      // Switch to notification tab
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      // Filter chips should be present (default profile = THPT grade 10)
      expect(find.widgetWithText(ChoiceChip, 'Tất cả'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Toàn trường'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Lớp 10A1'), findsOneWidget);

      // Tap on 'Lớp 10A1' chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'Lớp 10A1'));
      await tester.pumpAndSettle();

      // Should display class-specific notice
      expect(
        find.text('Đổi giờ ra về chiều thứ Sáu ngày 16/10'),
        findsOneWidget,
      );
    });

    testWidgets(
      'TC-NAV-07: Unread badge is displayed on notification BottomNavigationBar tab',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
        );
        await tester.pumpAndSettle();

        // Find Badge widget on bottom navigation bar
        final badgeFinder = find.byType(Badge);
        expect(badgeFinder, findsWidgets);

        // Verify unread count matches unread notices (mock notices has 2 unread: notice 1 and notice 2)
        expect(
          find.descendant(
            of: find.byType(BottomNavigationBar),
            matching: find.text('2'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'TC-NAV-08: Tapping Bảng điểm tab switches to marks view and displays GPA and subject marks',
      (tester) async {
        tester.view.physicalSize = const Size(600, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
        );
        await tester.pumpAndSettle();

        // Tap on Bảng điểm tab (icon analytics_outlined)
        await tester.tap(find.byIcon(Icons.analytics_outlined));
        await tester.pumpAndSettle();

        // Verify KPI Header and Academic Rank
        expect(find.textContaining('ĐIỂM TRUNG BÌNH'), findsOneWidget);
        expect(find.text('Xuất sắc'), findsWidgets);

        // Verify LinearProgressIndicator is removed as requested
        expect(find.byType(LinearProgressIndicator), findsNothing);

        // Verify Subject marks are displayed (THPT Grade 10 subjects)
        expect(find.text('Toán học'), findsOneWidget);
        expect(find.text('Ngữ văn'), findsOneWidget);
        expect(find.text('Tiếng Anh'), findsOneWidget);

        // Verify Teacher Remarks Card
        expect(find.text('Đánh giá Rèn luyện & Khen thưởng'), findsOneWidget);
        expect(find.text('Tốt (Xuất sắc)'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-NAV-09: Tapping Bảng điểm in Thêm bottom sheet switches to Marks tab',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
        );
        await tester.pumpAndSettle();

        // Open Tiện ích sheet via Cài đặt button in Hero Card
        await tester.tap(find.text('Cài đặt & Tiện ích'));
        await tester.pumpAndSettle();

        // Tap on Bảng điểm & Kết quả học tập
        await tester.tap(find.text('Bảng điểm & Kết quả học tập'));
        await tester.pumpAndSettle();

        // Verify navigates directly to Marks tab and displays GPA
        expect(find.text('Tiện ích học sinh'), findsNothing); // Sheet is closed
        expect(find.textContaining('ĐIỂM TRUNG BÌNH'), findsOneWidget);
        expect(find.text('Xuất sắc'), findsWidgets);
      },
    );

    testWidgets(
      'TC-NAV-10: Timetable defaults to Daily view and shows weekday tabs',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
        );
        await tester.pumpAndSettle();

        // Tap on Lịch học tab (BottomNavigationBar item at index 1)
        await tester.tap(find.byIcon(Icons.calendar_today_outlined));
        await tester.pumpAndSettle();

        // Verify View Mode Switcher buttons exist
        expect(find.text('Theo ngày'), findsOneWidget);
        expect(find.text('Theo tuần (Toàn bộ)'), findsOneWidget);

        // Verify Weekday tabs (Thứ 2 đến Thứ 6) are displayed
        expect(find.text('Thứ 2'), findsOneWidget);
        expect(find.text('Thứ 3'), findsOneWidget);
        expect(find.text('Thứ 4'), findsOneWidget);
        expect(find.text('Thứ 5'), findsOneWidget);
        expect(find.text('Thứ 6'), findsOneWidget);

        // Verify lessons of selected day (Thứ 2) are displayed (THPT Grade 10 subjects)
        expect(find.text('Toán'), findsWidgets);
        expect(find.text('Ngữ văn'), findsWidgets);
      },
    );

    testWidgets(
      'TC-NAV-11: Tapping Theo tuần switches to Weekly full view and displays all 5 days',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
        );
        await tester.pumpAndSettle();

        // Tap on Lịch học tab
        await tester.tap(find.byIcon(Icons.calendar_today_outlined));
        await tester.pumpAndSettle();

        // Switch to Weekly view
        await tester.tap(find.text('Theo tuần (Toàn bộ)'));
        await tester.pumpAndSettle();

        // Verify weekdays headers are rendered (scroll down for later days)
        expect(find.textContaining('THỨ HAI'), findsOneWidget);
        expect(find.textContaining('THỨ BA'), findsOneWidget);

        // Scroll to verify remaining days till Friday
        await tester.scrollUntilVisible(find.textContaining('THỨ TƯ'), 150);
        await tester.pumpAndSettle();
        expect(find.textContaining('THỨ TƯ'), findsOneWidget);

        await tester.scrollUntilVisible(find.textContaining('THỨ NĂM'), 150);
        await tester.pumpAndSettle();
        expect(find.textContaining('THỨ NĂM'), findsOneWidget);

        await tester.scrollUntilVisible(find.textContaining('THỨ SÁU'), 150);
        await tester.pumpAndSettle();
        expect(find.textContaining('THỨ SÁU'), findsOneWidget);

        // Verify lessons count badge
        expect(find.text('4 tiết'), findsWidgets);
      },
    );

    testWidgets('TC-NAV-12: Tapping Theo ngày switches back to daily view', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: StudentDashboardScreen()),
      );
      await tester.pumpAndSettle();

      // Tap on Lịch học tab
      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();

      // Switch to Weekly view
      await tester.tap(find.text('Theo tuần (Toàn bộ)'));
      await tester.pumpAndSettle();
      expect(find.textContaining('THỨ HAI'), findsOneWidget);

      // Switch back to Daily view
      await tester.tap(find.text('Theo ngày'));
      await tester.pumpAndSettle();

      // Weekday tab selector is back
      expect(find.text('Thứ 2'), findsOneWidget);
      expect(find.text('Thứ 3'), findsOneWidget);
      expect(find.textContaining('THỨ HAI ·'), findsNothing);
    });

    testWidgets(
      'TC-NAV-13: Hero Card has Settings/Logout and Footer has standalone Logout button (px=0) with Flat Square Design',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
        );
        await tester.pumpAndSettle();

        // Hero Card buttons
        expect(find.text('Cài đặt & Tiện ích'), findsOneWidget);
        expect(find.text('Đăng xuất'), findsOneWidget);

        // Scroll to Footer
        await tester.scrollUntilVisible(find.text('Đăng xuất tài khoản'), 300);
        await tester.pumpAndSettle();

        // Footer has only Logout button (Cài đặt giao diện removed as requested)
        expect(find.text('Cài đặt giao diện'), findsNothing);
        expect(find.text('Đăng xuất tài khoản'), findsOneWidget);
        expect(
          find.textContaining(
            'Đại Việt School Portal · Hệ thống Giáo dục Liên cấp Đại Việt',
          ),
          findsOneWidget,
        );

        // Tap Logout in Footer to verify dialog opens
        await tester.tap(find.text('Đăng xuất tài khoản'));
        await tester.pumpAndSettle();

        expect(find.text('Đăng xuất?'), findsOneWidget);
        expect(
          find.text('Em có chắc chắn muốn đăng xuất khỏi hệ thống không?'),
          findsOneWidget,
        );

        // Verify logout dialog has rounded border radius (16px)
        final alertDialog = tester.widget<AlertDialog>(
          find.byType(AlertDialog),
        );
        expect(alertDialog.shape, isA<RoundedRectangleBorder>());
        final shape = alertDialog.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(AppColors.cardRadius));

        // Dismiss dialog
        await tester.tap(find.text('Hủy'));
        await tester.pumpAndSettle();

        expect(find.text('Đăng xuất?'), findsNothing);
      },
    );

    testWidgets(
      'TC-NAV-14: Left edge swipe opens Navigation Drawer with student info, utilities, sync, and fixed logout',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
        );
        await tester.pumpAndSettle();

        // Verify Drawer is initially closed
        expect(find.text('Trường Phổ thông Liên cấp Đại Việt'), findsNothing);

        // Open drawer using ScaffoldState openDrawer
        final scaffoldFinder = find.byType(Scaffold);
        expect(scaffoldFinder, findsOneWidget);
        final scaffoldState = tester.state<ScaffoldState>(scaffoldFinder);
        scaffoldState.openDrawer();
        await tester.pumpAndSettle();

        // 1. Verify Student Info Header in Drawer
        final drawerFinder = find.byType(Drawer);
        expect(drawerFinder, findsOneWidget);
        expect(
          find.descendant(
            of: drawerFinder,
            matching: find.text('Trường THPT Đại Việt'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: drawerFinder,
            matching: find.text('Nguyễn Minh Anh'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: drawerFinder,
            matching: find.textContaining('Mã HS:'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: drawerFinder,
            matching: find.textContaining('GVCN'),
          ),
          findsOneWidget,
        );

        // 2. Verify Utility & Configuration Menu Items
        expect(
          find.descendant(
            of: drawerFinder,
            matching: find.text('Cài đặt giao diện & Màu sắc'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: drawerFinder,
            matching: find.text('Đổi mật khẩu'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: drawerFinder,
            matching: find.text('Trợ giúp & Liên hệ nhà trường'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: drawerFinder,
            matching: find.text('Đồng bộ / Tải lại dữ liệu'),
          ),
          findsOneWidget,
        );

        // 3. Verify Fixed Logout at Drawer Footer
        expect(
          find.descendant(
            of: drawerFinder,
            matching: find.text('Đăng xuất tài khoản'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: drawerFinder,
            matching: find.text('Đại Việt School Portal · v2.4 (Build 2026)'),
          ),
          findsOneWidget,
        );

        // 4. Test tapping an item (e.g., Trợ giúp & Liên hệ nhà trường)
        await tester.tap(find.text('Trợ giúp & Liên hệ nhà trường'));
        await tester.pumpAndSettle();

        expect(find.text('Trợ giúp & Liên hệ'), findsOneWidget);
        expect(find.textContaining('1900 8888'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('Đã hiểu'));
        await tester.pumpAndSettle();
        expect(find.text('Trợ giúp & Liên hệ'), findsNothing);
      },
    );

    testWidgets(
      'TC-NAV-15: Student Dashboard cards and boxes have High-Contrast Black Border and Flat Square Design',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
        );
        await tester.pumpAndSettle();

        // Navigate to Sách học tab (index 2) to find MaterialCard
        await tester.tap(find.byIcon(Icons.menu_book_outlined));
        await tester.pumpAndSettle();

        // Verify MaterialCard has border and correct border radius
        final materialCardFinder = find.byType(MaterialCard).first;
        expect(materialCardFinder, findsOneWidget);
        final materialCardContainer = tester.widget<Container>(
          find
              .descendant(
                of: materialCardFinder,
                matching: find.byType(Container),
              )
              .first,
        );
        final matDeco = materialCardContainer.decoration as BoxDecoration;
        // MaterialCard uses AppColors.cardBorder (black) with width 1.0
        expect(matDeco.border?.top.color, AppColors.cardBorder);
        expect(matDeco.border?.top.width, 1.0);
        expect(matDeco.borderRadius, AppColors.cardBorderRadius);

        // Navigate to Bài tập tab (index 3) to find HomeworkCard
        await tester.tap(find.byIcon(Icons.assignment_outlined));
        await tester.pumpAndSettle();

        // Verify HomeworkCard has border and correct border radius
        final homeworkCardFinder = find.byType(HomeworkCard).first;
        expect(homeworkCardFinder, findsOneWidget);
        final homeworkCardContainer = tester.widget<Container>(
          find
              .descendant(
                of: homeworkCardFinder,
                matching: find.byType(Container),
              )
              .first,
        );
        final hwDeco = homeworkCardContainer.decoration as BoxDecoration;
        expect(hwDeco.border?.top.color, Colors.black);
        expect(hwDeco.border?.top.width, 1.0);
        expect(hwDeco.borderRadius, AppColors.cardBorderRadius);
      },
    );


    testWidgets(
      'TC-NAV-16: Marks tab features Hero KPI Card with prominent Rank Box, solid black grid dividers, and no progress bars',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
        );
        await tester.pumpAndSettle();

        // Switch to Bảng điểm tab
        await tester.tap(find.byIcon(Icons.analytics_outlined));
        await tester.pumpAndSettle();

        // 1. Verify Rank Box contains large icon and short title 'Xuất sắc'
        expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
        expect(find.text('Xuất sắc'), findsWidgets);

        // 2. Verify LinearProgressIndicator is completely removed from subject cards
        expect(find.byType(LinearProgressIndicator), findsNothing);

        // 3. Verify KPI dividers use solid black border color
        final dividers = tester.widgetList<Container>(
          find.byWidgetPredicate((widget) {
            if (widget is Container && widget.color == Colors.black) {
              return true;
            }
            return false;
          }),
        );
        // At least horizontal divider + 2 vertical dividers = 3 black dividing line containers
        expect(dividers.length, greaterThanOrEqualTo(3));
      },
    );

    testWidgets(
      'TC-NAV-17: Student Header Card displays time greeting, school name, and tapping header card opens utilities sheet',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: StudentDashboardScreen()),
        );
        await tester.pumpAndSettle();

        // 1. Verify greeting by time exists
        expect(find.textContaining('Chào buổi'), findsOneWidget);

        // 2. Verify student name, THPT badge, and school name
        expect(find.text('Nguyễn Minh Anh'), findsOneWidget);
        expect(find.text('THPT'), findsWidgets);
        expect(find.textContaining('Trường THPT Đại Việt'), findsWidgets);

        // 3. Tap on the student name inside Header Card to verify it opens utilities sheet
        await tester.tap(find.text('Nguyễn Minh Anh'));
        await tester.pumpAndSettle();

        expect(find.text('Tiện ích học sinh'), findsOneWidget);
        expect(find.textContaining('Trường THPT Đại Việt'), findsWidgets);

        // Dismiss sheet
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        expect(find.text('Tiện ích học sinh'), findsNothing);
      },
    );
  });
}
