import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/features/student/screens/student_book_reader_screen.dart';
import 'package:ashadeep/core/page_flip/page_flip_view.dart';

void main() {
  final mockBookData = {
    'id': 101,
    'title': 'Sách giáo khoa Toán 1 - Tập 1',
    'subjectName': 'Toán',
    'pageCount': 118,
  };

  group('Student Book Reader with PageFlipView Tests', () {
    testWidgets('TC-READER-01: Khởi chạy mặc định ở Chế độ Lật Trang 3D với PageFlipView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StudentBookReaderScreen(
            data: mockBookData,
            initialPage: 1,
          ),
        ),
      );
      await tester.pump();

      // Kiểm tra tiêu đề sách và môn học
      expect(find.text('Sách giáo khoa Toán 1 - Tập 1'), findsOneWidget);
      expect(find.textContaining('Đang đọc trang 1 / 118'), findsOneWidget);

      // Kiểm tra có widget PageFlipView (chế độ lật 3D mặc định)
      expect(find.byType(PageFlipView), findsOneWidget);
      expect(find.byType(PageView), findsNothing);

      // Kiểm tra có nút toggle chuyển sang chế độ phóng to zoom
      expect(find.byIcon(Icons.zoom_in), findsOneWidget);
    });

    testWidgets('TC-READER-02: Bấm nút Toggle chuyển đổi mượt mà giữa Chế độ Lật 3D và Chế độ Zoom', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StudentBookReaderScreen(
            data: mockBookData,
            initialPage: 1,
          ),
        ),
      );
      await tester.pump();

      // 1. Ban đầu là PageFlipView
      expect(find.byType(PageFlipView), findsOneWidget);
      expect(find.byType(PageView), findsNothing);

      // 2. Chạm nút zoom_in để chuyển sang Chế độ phóng to
      await tester.tap(find.byIcon(Icons.zoom_in));
      await tester.pumpAndSettle();

      // Lúc này hiển thị PageView cho phép InteractiveViewer zoom
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(PageFlipView), findsNothing);
      expect(find.byTooltip('Chuyển sang chế độ lật sách 3D'), findsOneWidget);

      // 3. Chạm nút quay lại Chế độ lật 3D
      await tester.tap(find.byTooltip('Chuyển sang chế độ lật sách 3D'));
      await tester.pumpAndSettle();

      expect(find.byType(PageFlipView), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('TC-READER-03: Mở Mục lục và chọn chương nhảy đúng trang sách', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StudentBookReaderScreen(
            data: mockBookData,
            initialPage: 1,
          ),
        ),
      );
      await tester.pump();

      // Mở mục lục sách
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Mục lục sách điện tử'), findsOneWidget);
      expect(find.text('Chủ đề 2: Làm quen với chữ số & phép so sánh'), findsOneWidget);

      // Chọn Chủ đề 2 (Trang 24)
      await tester.tap(find.text('Chủ đề 2: Làm quen với chữ số & phép so sánh'));
      await tester.pumpAndSettle();

      // Mục lục đóng lại và trang cập nhật thành 24
      expect(find.text('Mục lục sách điện tử'), findsNothing);
      expect(find.textContaining('Đang đọc trang 24 / 118'), findsOneWidget);
    });

    testWidgets('TC-READER-04: Đánh dấu trang Bookmark và đổi Chế độ Ban đêm', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StudentBookReaderScreen(
            data: mockBookData,
            initialPage: 1,
          ),
        ),
      );
      await tester.pump();

      // Đánh dấu bookmark
      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pump();
      expect(find.byIcon(Icons.bookmark), findsOneWidget);

      // Đổi Dark Mode
      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    });
  });
}
