import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/features/student/widgets/mascot/animal_mascot_data.dart';
import 'package:ashadeep/features/student/widgets/mascot/animal_mascot_painter.dart';
import 'package:ashadeep/features/student/widgets/mascot/primary_animal_identity_card.dart';

void main() {
  group('MascotHashUtil Unit Tests', () {
    test('stripAccents xóa sạch dấu tiếng Việt chuẩn Unicode', () {
      expect(MascotHashUtil.stripAccents('Hoàng Văn Thư'), 'hoang van thu');
      expect(MascotHashUtil.stripAccents('Đỗ Trọng Minh'), 'do trong minh');
      expect(MascotHashUtil.stripAccents('Nguyễn Thị Lan'), 'nguyen thi lan');
    });

    test('makeKey tạo key viết liền không dấu + ddmmyyyy', () {
      final key = MascotHashUtil.makeKey('Hoàng Văn Thư', '20/10/2026');
      expect(key, 'hoangvanthu20102026');
    });

    test('hashString FNV-1a khớp chính xác với kết quả thuật toán gốc', () {
      final hash = MascotHashUtil.hashString('hoangvanthu20102026');
      expect(hash, 877188761);
      expect(hash % 10, 1); // 1 = Cá sấu
    });

    test('pickAnimal trả về cố định 1 con vật cho cùng học sinh (Deterministic)', () {
      final mascot1 = MascotHashUtil.pickAnimal(
        studentName: 'Hoàng Văn Thư',
        dobDMY: '20/10/2026',
      );
      final mascot2 = MascotHashUtil.pickAnimal(
        studentName: 'Hoàng Văn Thư',
        dobDMY: '20/10/2026',
      );

      expect(mascot1.id, 'casau');
      expect(mascot1.name, 'Cá sấu');
      expect(mascot1.primaryColor, const Color(0xFFEE4F8F));
      expect(mascot1.id, mascot2.id);
    });

    test('Danh sách đủ 10 con vật với màu sắc tương ứng', () {
      expect(AnimalMascotData.allMascots.length, 10);
      final ids = AnimalMascotData.allMascots.map((m) => m.id).toList();
      expect(ids, ['gau', 'casau', 'meo', 'ca', 'ngua', 'tho', 'cho', 'voi', 'vit', 'ech']);
    });
  });

  group('PrimaryAnimalIdentityCard Widget Tests', () {
    testWidgets('Hiển thị đầy đủ 4 ô thông tin và linh vật vẫy tay', (tester) async {
      bool moreTapped = false;
      bool logoutTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrimaryAnimalIdentityCard(
                studentName: 'Hoàng Văn Thư',
                className: 'Lớp 1A',
                dateStr: '23/10/2026',
                dobDMY: '20/10/2026',
                teacherName: 'Cô Nguyễn Thị Lan',
                onTapMore: () => moreTapped = true,
                onLogout: () => logoutTapped = true,
              ),
            ),
          ),
        ),
      );

      // Kiểm tra các nhãn thông tin
      expect(find.text('TÊN LỚP'), findsOneWidget);
      expect(find.text('NGÀY'), findsOneWidget);
      expect(find.text('HỌC SINH'), findsOneWidget);
      expect(find.text('GIÁO VIÊN'), findsOneWidget);

      // Kiểm tra giá trị
      expect(find.text('Lớp 1A'), findsOneWidget);
      expect(find.text('23/10/2026'), findsOneWidget);
      expect(find.text('Hoàng Văn Thư'), findsNWidgets(2)); // 1 ở banner bầu trời, 1 ở ô HỌC SINH
      expect(find.text('Cô Nguyễn Thị Lan'), findsOneWidget);

      // Kiểm tra tên linh vật bạn đồng hành (Cá sấu)
      expect(find.text('Cá sấu'), findsOneWidget);
      expect(find.text('Bạn Cá Sấu Dễ Thương'), findsOneWidget);

      // Kiểm tra tương tác nút bấm
      await tester.tap(find.text('Tiện ích'));
      expect(moreTapped, isTrue);

      await tester.tap(find.text('Đăng xuất'));
      expect(logoutTapped, isTrue);
    });

    testWidgets('Vẽ trơn tru cả 10 con vật qua CustomPainter không phát sinh lỗi', (tester) async {
      for (final mascot in AnimalMascotData.allMascots) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: AnimalMascotPainter(
                    type: mascot.type,
                    primaryColor: mascot.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Bo góc ngoài 16px và viền 1.5px theo đúng thiết kế Senior', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryAnimalIdentityCard(
              studentName: 'Nguyễn Minh Anh',
              className: '1A',
              dateStr: '23/10/2026',
              dobDMY: '12/05/2019',
              teacherName: 'Cô Nguyễn Thị Lan',
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.border?.top.width, 1.5);
    });

    testWidgets('PrimarySkyGreetingHeader hiển thị chính xác theo thời gian sáng, chiều, tối', (tester) async {
      // 1. Buổi sáng (08:30)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryAnimalIdentityCard(
              studentName: 'Hoàng Văn Thư',
              className: '1A',
              dateStr: '23/10/2026',
              dobDMY: '20/10/2026',
              teacherName: 'Cô Nguyễn Thị Lan',
              timeOverride: DateTime(2026, 10, 23, 8, 30),
            ),
          ),
        ),
      );
      expect(find.text('Chào buổi sáng ✨'), findsOneWidget);
      expect(find.text('Hoàng Văn Thư'), findsNWidgets(2)); // 1 ở banner bầu trời, 1 ở ô HỌC SINH

      // 2. Buổi chiều (14:30)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryAnimalIdentityCard(
              studentName: 'Hoàng Văn Thư',
              className: '1A',
              dateStr: '23/10/2026',
              dobDMY: '20/10/2026',
              teacherName: 'Cô Nguyễn Thị Lan',
              timeOverride: DateTime(2026, 10, 23, 14, 30),
            ),
          ),
        ),
      );
      expect(find.text('Chào buổi chiều 🌤️'), findsOneWidget);

      // 3. Buổi tối (20:00)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryAnimalIdentityCard(
              studentName: 'Hoàng Văn Thư',
              className: '1A',
              dateStr: '23/10/2026',
              dobDMY: '20/10/2026',
              teacherName: 'Cô Nguyễn Thị Lan',
              timeOverride: DateTime(2026, 10, 23, 20, 0),
            ),
          ),
        ),
      );
      expect(find.text('Chào buổi tối 🌙'), findsOneWidget);
    });
  });
}

