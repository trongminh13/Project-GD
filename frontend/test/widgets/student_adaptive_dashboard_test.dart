import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/features/student/screens/student_dashboard_screen.dart';
import 'package:ashadeep/core/config/feature_flags.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/features/student/widgets/mascot/primary_animal_identity_card.dart';

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

    testWidgets('TC-ADAPTIVE-03: Switching to Bảng điểm shows Sổ Học Bạ Điện Tử, TT22 criteria card & formula', (tester) async {
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

      // Check Vietnamese Academic Header
      expect(find.textContaining('HỌC BẠ ĐIỆN TỬ'), findsWidgets);

      // Check Semester dropdown default
      expect(find.text('Học kỳ I'), findsOneWidget);

      // Check TT22 Criteria Card for High School
      expect(find.text('TIÊU CHUẨN DANH HIỆU THPT (TT 22/2021)'), findsOneWidget);
      expect(find.textContaining('Học sinh giỏi'), findsWidgets);
    });

    testWidgets('TC-ADAPTIVE-04: Toggle between Accordion View and Grid Table View', (tester) async {
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

      // Switch to Marks tab
      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pumpAndSettle();

      // Find Table chart icon to switch to Grid Table View
      final tableToggle = find.byIcon(Icons.table_chart_outlined);
      expect(tableToggle, findsOneWidget);

      await tester.tap(tableToggle);
      await tester.pumpAndSettle();

      // Should now show DataTable with official columns
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('TX HK1'), findsOneWidget);
      expect(find.text('ĐTB Năm'), findsOneWidget);

      // Tap Card list icon to switch back
      final cardToggle = find.byIcon(Icons.view_agenda_outlined);
      expect(cardToggle, findsOneWidget);

      await tester.tap(cardToggle);
      await tester.pumpAndSettle();
      expect(find.byType(DataTable), findsNothing);
    });

    testWidgets('TC-ADAPTIVE-05: Tapping In Phiếu Điểm opens A4 Print Preview BottomSheet', (tester) async {
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

      // Switch to Marks tab
      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pumpAndSettle();

      // Find In Phiếu Điểm button
      final printBtn = find.text('In Phiếu Điểm');
      expect(printBtn, findsOneWidget);

      await tester.tap(printBtn);
      await tester.pumpAndSettle();

      // Verify A4 Preview sheet appears with national motto
      expect(find.textContaining('CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM'), findsOneWidget);
      expect(find.textContaining('PHIẾU BÁO ĐIỂM HỌC TẬP'), findsOneWidget);
    });

    testWidgets('TC-ADAPTIVE-06: Secondary and High School students do NOT display PrimaryAnimalIdentityCard; only Primary student displays it', (tester) async {
      // 1. Kiểm tra Cấp 3 THPT (student03) - KHÔNG ĐƯỢC có Thẻ Con Vật
      AuthService.currentSessionUser = {
        'username': 'student03',
        'roles': ['STUDENT'],
      };
      await tester.pumpWidget(
        MaterialApp(
          home: StudentDashboardScreen(key: UniqueKey()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Lớp 10A1'), findsOneWidget);
      expect(find.byType(PrimaryAnimalIdentityCard), findsNothing);

      // 2. Kiểm tra Cấp 2 THCS (student02) - KHÔNG ĐƯỢC có Thẻ Con Vật
      AuthService.currentSessionUser = {
        'username': 'student02',
        'roles': ['STUDENT'],
      };
      await tester.pumpWidget(
        MaterialApp(
          home: StudentDashboardScreen(key: UniqueKey()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Lớp 6A'), findsOneWidget);
      expect(find.byType(PrimaryAnimalIdentityCard), findsNothing);

      // 3. Kiểm tra Cấp 1 Tiểu học (student01) - BẮT BUỘC có Thẻ Con Vật
      AuthService.currentSessionUser = {
        'username': 'student01',
        'roles': ['STUDENT'],
      };
      await tester.pumpWidget(
        MaterialApp(
          home: StudentDashboardScreen(key: UniqueKey()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PrimaryAnimalIdentityCard), findsOneWidget);
      expect(find.text('TÊN LỚP'), findsOneWidget);
      expect(find.text('HỌC SINH'), findsOneWidget);
      expect(find.text('GIÁO VIÊN'), findsOneWidget);

      // Dọn dẹp session sau test
      AuthService.currentSessionUser = null;
    });

    testWidgets('TC-ADAPTIVE-07: Primary student displays pastel home cards and weekly timetable with 5 rainbow cards', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AuthService.currentSessionUser = {
        'username': 'student01',
        'roles': ['STUDENT'],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: StudentDashboardScreen(key: UniqueKey()),
        ),
      );
      await tester.pumpAndSettle();

      // Kiểm tra trang chủ có các tiêu đề của Cấp 1
      expect(find.text('Lịch học hôm nay'), findsOneWidget);
      expect(find.text('Sách đọc mới'), findsOneWidget);
      expect(find.text('Bài tập cần làm'), findsOneWidget);

      // Chuyển sang Tab 1: Lịch học (calendar_today_outlined)
      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();

      // Kiểm tra có bộ chuyển đổi Theo ngày / Theo tuần
      expect(find.text('Theo ngày'), findsOneWidget);
      expect(find.textContaining('Theo tuần'), findsOneWidget);

      // Bấm chuyển sang chế độ "Theo tuần"
      await tester.tap(find.textContaining('Theo tuần'));
      await tester.pumpAndSettle();

      // Kiểm tra hiển thị đủ cả 5 ngày Thứ 2 đến Thứ 6 với 5 khung thẻ pastel
      expect(find.textContaining('THỨ HAI'), findsWidgets);
      expect(find.textContaining('THỨ BA'), findsWidgets);
      expect(find.textContaining('THỨ TƯ'), findsWidgets);
      expect(find.textContaining('THỨ NĂM'), findsWidgets);
      expect(find.textContaining('THỨ SÁU'), findsWidgets);

      // Dọn dẹp session sau test
      AuthService.currentSessionUser = null;
    });

    testWidgets('TC-ADAPTIVE-08: Primary student (student01) data isolation - ONLY grade 1 books, primary homework and 35min primary lessons', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AuthService.currentSessionUser = {
        'username': 'student01',
        'roles': ['STUDENT'],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: StudentDashboardScreen(key: UniqueKey()),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Kiểm tra Trang chủ: Bài tập và Sách Cấp 1
      expect(find.textContaining('Đếm và so sánh các số trong phạm vi 10'), findsWidgets);
      expect(find.textContaining('Luyện viết chữ đẹp'), findsWidgets);
      // Đảm bảo TUYỆT ĐỐI KHÔNG xuất hiện bài tập Lớp 10
      expect(find.textContaining('Chiến thắng Mtao Mxây'), findsNothing);
      expect(find.textContaining('hàm số bậc hai'), findsNothing);

      // 2. Chuyển sang Tab 2: Sách học (Icons.menu_book_outlined)
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();

      // Kiểm tra có sách Cấp 1
      expect(find.text('Sách giáo khoa Toán 1 - Tập 1'), findsOneWidget);
      expect(find.text('Sách giáo khoa Tiếng Việt 1 - Tập 1'), findsOneWidget);
      expect(find.text('Sách giáo khoa Tự nhiên và Xã hội 1'), findsOneWidget);
      expect(find.text('Sách giáo khoa Đạo đức 1'), findsOneWidget);
      // Đảm bảo TUYỆT ĐỐI KHÔNG xuất hiện sách Cấp 3 (Lớp 10)
      expect(find.text('Sách giáo khoa Toán 10 - Tập 1'), findsNothing);
      expect(find.text('Sách giáo khoa Ngữ văn 10 - Tập 1'), findsNothing);
      expect(find.text('Sách giáo khoa Vật lý 10'), findsNothing);

      // 3. Chuyển sang Tab 1: Lịch học (Icons.calendar_today_outlined)
      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();

      // Kiểm tra có môn Tiểu học và phòng Lớp 1A
      expect(find.textContaining('Lớp 1A'), findsWidgets);
      // Đảm bảo TUYỆT ĐỐI KHÔNG xuất hiện môn Cấp 3
      expect(find.text('GDQP-AN'), findsNothing);
      expect(find.text('P.Lý'), findsNothing);
      expect(find.text('P.Hóa'), findsNothing);

      AuthService.currentSessionUser = null;
    });

    testWidgets('TC-ADAPTIVE-09: Secondary student (student02) data isolation - ONLY grade 6 books, secondary homework and secondary schedule', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AuthService.currentSessionUser = {
        'username': 'student02',
        'roles': ['STUDENT'],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: StudentDashboardScreen(key: UniqueKey()),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Kiểm tra Trang chủ: Bài tập Cấp 2
      expect(find.textContaining('Tập hợp các số tự nhiên và phép tính lũy thừa'), findsWidgets);
      expect(find.textContaining('Thạch Sanh'), findsWidgets);
      expect(find.textContaining('Đếm và so sánh các số trong phạm vi 10'), findsNothing);
      expect(find.textContaining('Chiến thắng Mtao Mxây'), findsNothing);

      // 2. Chuyển sang Tab 2: Sách học (Icons.menu_book_outlined)
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();

      // Kiểm tra sách Cấp 2
      expect(find.text('Sách giáo khoa Toán 6 - Tập 1'), findsOneWidget);
      expect(find.text('Sách giáo khoa Ngữ văn 6 - Tập 1'), findsOneWidget);
      expect(find.text('Sách giáo khoa Khoa học tự nhiên 6'), findsOneWidget);
      expect(find.text('Sách giáo khoa Lịch sử và Địa lí 6'), findsOneWidget);
      // Đảm bảo KHÔNG có sách Cấp 1 hay Cấp 3
      expect(find.text('Sách giáo khoa Toán 1 - Tập 1'), findsNothing);
      expect(find.text('Sách giáo khoa Toán 10 - Tập 1'), findsNothing);

      AuthService.currentSessionUser = null;
    });

    testWidgets('TC-ADAPTIVE-10: High School student (student03) - preserves 100% Grade 10 THPT books, homework and specialized schedule', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AuthService.currentSessionUser = {
        'username': 'student03',
        'roles': ['STUDENT'],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: StudentDashboardScreen(key: UniqueKey()),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Kiểm tra Trang chủ: Bài tập THPT Lớp 10
      expect(find.textContaining('Khảo sát sự biến thiên hàm số bậc hai'), findsWidgets);
      expect(find.textContaining('Chiến thắng Mtao Mxây'), findsWidgets);

      // 2. Chuyển sang Tab 2: Sách học (Icons.menu_book_outlined)
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();

      // Kiểm tra sách Lớp 10 THPT
      expect(find.text('Sách giáo khoa Toán 10 - Tập 1'), findsOneWidget);
      expect(find.text('Sách giáo khoa Ngữ văn 10 - Tập 1'), findsOneWidget);
      expect(find.text('Sách giáo khoa Vật lý 10'), findsOneWidget);

      AuthService.currentSessionUser = null;
    });
  });
}

