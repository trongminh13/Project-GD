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
  });
}

