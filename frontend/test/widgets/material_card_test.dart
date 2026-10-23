import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/widgets/material_card.dart';

void main() {
  group('MaterialCard Widget Tests', () {
    testWidgets('renders book information correctly', (tester) async {
      final mockData = {
        'id': 1,
        'title': 'Sách giáo khoa Toán 3 - Tập 1',
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
      expect(find.text('Toán · Cô Lê Thu Hà · 4.8 MB'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('tapping book card opens detail dialog with PDF file path', (tester) async {
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

    testWidgets('isPrimary: true renders pastel background and rounded 14px border', (tester) async {
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
            body: MaterialCard(
              data: mockData,
              isPrimary: true,
              paletteIndex: 2, // Sweet Blossom Pink
            ),
          ),
        ),
      );

      // Verify widget renders
      expect(find.text('Vở bài tập Toán 1'), findsOneWidget);
      expect(find.text('Toán · Cô Trần Thu Thảo · 2.1 MB'), findsOneWidget);

      // Verify decoration: Sweet Blossom background (#FDF2F8) and border (#F472B6)
      final inkWellFinder = find.byType(InkWell);
      final inkWell = tester.widget<InkWell>(inkWellFinder);
      expect(inkWell.borderRadius, BorderRadius.circular(14));

      final containerFinder = find.descendant(
        of: find.byType(MaterialCard),
        matching: find.byType(Container),
      ).first;
      final decoration = tester.widget<Container>(containerFinder).decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFFDF2F8));
      expect(decoration.borderRadius, BorderRadius.circular(14));
      expect(decoration.border?.top.color, const Color(0xFFF472B6));
      expect(decoration.border?.top.width, 1.5);
    });
  });
}
