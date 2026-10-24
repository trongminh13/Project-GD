import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/widgets/material_card.dart';
import 'package:ashadeep/core/theme/app_colors.dart';


void main() {
  group('MaterialCard Widget Tests', () {
    testWidgets('renders book information correctly', (tester) async {
      final mockData = {
        'id': 1,
        'title': 'Sách giáo khoa Toán 3 - Tập 1',
        'description': 'Ôn luyện kiến thức Toán học theo từng chủ đề.',
        'subjectName': 'Toán',
        'teacherName': 'Cô Lê Thu Hà',
        'fileType': 'PDF',
        'fileSize': '4.8 MB',
        'filePath': 'file:///storage/emulated/0/Download/SGK_Toan_3_Tap_1.pdf',
        'createdAt': '2026-10-12',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialCard(data: mockData),
          ),
        ),
      );

      expect(find.text('Sách giáo khoa Toán 3 - Tập 1'), findsOneWidget);
      expect(find.text('Ôn luyện kiến thức Toán học theo từng chủ đề.'), findsOneWidget);
      expect(find.text('Toán · Cô Lê Thu Hà · 4.8 MB'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    });

    testWidgets('tapping book card opens detail dialog with PDF file path', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = {
        'id': 2,
        'title': 'Vở bài tập Tiếng Việt 3',
        'subjectName': 'Tiếng Việt',
        'teacherName': 'Cô Lê Thu Hà',
        'fileType': 'PDF',
        'fileSize': '3.5 MB',
        'filePath': 'file:///storage/emulated/0/Download/VBT_Tieng_Viet_3.pdf',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialCard(data: mockData),
          ),
        ),
      );

      await tester.tap(find.byType(MaterialCard));
      await tester.pumpAndSettle();

      expect(find.text('Chi tiết sách đọc'), findsOneWidget);

      // Scroll to the PDF path section which may be below the fold
      await tester.scrollUntilVisible(
        find.text('Đường dẫn tệp PDF trên thiết bị:'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Đường dẫn tệp PDF trên thiết bị:'), findsOneWidget);
      expect(find.text('file:///storage/emulated/0/Download/VBT_Tieng_Viet_3.pdf'), findsOneWidget);
      expect(find.text('Đã lưu trong bộ nhớ máy · Sẵn sàng đọc offline'), findsOneWidget);
      expect(find.text('Đọc sách ngay'), findsOneWidget);
    });

    testWidgets('tapping Đọc sách ngay opens StudentBookReaderScreen in-app reader', (tester) async {
      final mockData = {
        'id': 3,
        'title': 'Toán 3 - Tập 2',
        'subjectName': 'Toán',
        'teacherName': 'Cô Lê Thu Hà',
        'fileType': 'PDF',
        'fileSize': '4.2 MB',
        'filePath': 'file:///storage/emulated/0/Download/Toan_3_Tap_2.pdf',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialCard(data: mockData),
          ),
        ),
      );

      await tester.tap(find.byType(MaterialCard));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Đọc sách ngay'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Mục lục'), findsOneWidget);
      expect(find.byTooltip('Đánh dấu trang'), findsOneWidget);
      expect(find.text('CHƯƠNG 2: BẢNG NHÂN & BẢNG CHIA CƠ BẢN'), findsOneWidget);
    });

    testWidgets('supports freeing storage and displays on-demand download prompt', (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = {
        'id': 4,
        'title': 'Tiếng Anh 3',
        'subjectName': 'Tiếng Anh',
        'teacherName': 'Thầy David',
        'fileType': 'PDF',
        'fileSize': '5.0 MB',
        'filePath': 'file:///storage/emulated/0/Download/Tieng_Anh_3.pdf',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialCard(data: mockData),
          ),
        ),
      );

      await tester.tap(find.byType(MaterialCard));
      await tester.pumpAndSettle();

      // 'Giải phóng bộ nhớ' appears as a tooltip on the AppBar action button
      // Scroll down to ensure the free-storage section is visible in the body
      await tester.scrollUntilVisible(
        find.text('Giải phóng bộ nhớ'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Giải phóng bộ nhớ'), findsOneWidget);
      await tester.tap(find.text('Giải phóng bộ nhớ'));
      await tester.pumpAndSettle();

      expect(find.text('Giải phóng bộ nhớ?'), findsOneWidget);
      await tester.tap(find.text('Xác nhận xóa'));
      await tester.pumpAndSettle();

      expect(find.text('Sách chưa lưu trong bộ nhớ máy'), findsOneWidget);
      expect(find.text('Tải về máy ngay (5.0 MB)'), findsOneWidget);
    });

    testWidgets('SGK Toan 1 flip reader navigates pages and displays 118 pages with TOC', (tester) async {
      final toan1Data = {
        'id': 101,
        'fileId': 1,
        'title': 'Sách giáo khoa Toán 1 - Tập 1',
        'subjectName': 'Toán học',
        'teacherName': 'Bộ GD&ĐT',
        'fileType': 'PDF',
        'fileSize': '75.0 MB',
        'pageCount': 118,
        'filePath': 'file:///storage/emulated/0/Download/SGK_Toan_1_Tap_1.pdf',
        'isDownloaded': true,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialCard(data: toan1Data),
          ),
        ),
      );

      await tester.tap(find.byType(MaterialCard));
      await tester.pumpAndSettle();

      expect(find.text('Chi tiết sách đọc'), findsOneWidget);
      expect(find.text('Đọc sách ngay'), findsOneWidget);

      await tester.tap(find.text('Đọc sách ngay'));
      await tester.pumpAndSettle();

      expect(find.text('Sách giáo khoa Toán 1 - Tập 1'), findsOneWidget);
      expect(find.textContaining('118'), findsWidgets);

      // Open TOC sheet inside reader
      await tester.tap(find.byTooltip('Mục lục'));
      await tester.pumpAndSettle();

      expect(find.text('Mục lục sách điện tử'), findsOneWidget);
      expect(find.text('Chủ đề 1: Làm quen với một số hình'), findsOneWidget);
      expect(find.text('Chủ đề 2: Làm quen với chữ số & phép so sánh'), findsOneWidget);

      // Jump to Chu de 2 (Trang 24)
      await tester.tap(find.text('Chủ đề 2: Làm quen với chữ số & phép so sánh'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Đang đọc trang 24 / 118'), findsOneWidget);
    });

    testWidgets('shows a standalone book icon without a PDF frame or badge', (tester) async {
      final mockData = {
        'id': 10,
        'title': 'Vở bài tập Toán 1',
        'subjectName': 'Toán',
        'teacherName': 'Cô Trần Thu Thảo',
        'fileType': 'PDF',
        'fileSize': '2.1 MB',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialCard(data: mockData),
          ),
        ),
      );

      // Verify widget renders
      expect(find.text('Vở bài tập Toán 1'), findsOneWidget);
      expect(find.text('Toán · Cô Trần Thu Thảo · 2.1 MB'), findsOneWidget);

      // Keep the book glyph standalone; file format remains out of the visual thumbnail.
      final inkWellFinder = find.byType(InkWell);
      final inkWell = tester.widget<InkWell>(inkWellFinder);
      // MaterialCard uses AppColors.cardBorderRadius (16px) - design system token
      expect(inkWell.borderRadius, AppColors.cardBorderRadius);
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf), findsNothing);
    });
  });
}
