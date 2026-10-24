import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/features/student/screens/student_take_homework_screen.dart';
import 'package:ashadeep/features/student/screens/student_homework_result_screen.dart';
import 'package:ashadeep/core/services/homework_mock_content_provider.dart';
import 'package:ashadeep/core/config/feature_flags.dart';

void main() {
  setUp(() {
    FeatureFlags.useDemoFallback = true;
  });

  group('Student Homework Flow Tests (Multi-Level Alignment)', () {
    testWidgets('TC-HW-FLOW-01: Taking Primary Grade 1 Math (id: 101) - Correct title and rabbit question', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: StudentTakeHomeworkScreen(
            assignmentId: 101,
            initialData: HomeworkMockContentProvider.getAssignmentForTaking(101),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tiêu đề bài tập
      expect(find.textContaining('Đếm và so sánh các số trong phạm vi 10'), findsOneWidget);
      expect(find.textContaining('Toán'), findsWidgets);

      // Câu hỏi đếm thỏ
      expect(find.textContaining('chú thỏ trắng'), findsOneWidget);

      // TUYỆT ĐỐI KHÔNG xuất hiện phép nhân 7 của Toán 3
      expect(find.textContaining('7 x 8'), findsNothing);
      expect(find.textContaining('Phiếu ôn tập môn Tiếng Việt'), findsNothing);
      expect(find.textContaining('5 bao gạo'), findsNothing);
    });

    testWidgets('TC-HW-FLOW-02: Taking High School Grade 10 Math (id: 28) - Correct parabola question', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: StudentTakeHomeworkScreen(
            assignmentId: 28,
            initialData: HomeworkMockContentProvider.getAssignmentForTaking(28),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tiêu đề hàm số bậc hai
      expect(find.textContaining('Khảo sát sự biến thiên hàm số bậc hai'), findsOneWidget);
      expect(find.textContaining('Toán học'), findsWidgets);

      // Câu hỏi parabol
      expect(find.textContaining('y = x² - 4x + 3'), findsOneWidget);

      // TUYỆT ĐỐI KHÔNG bị biến thành Tiếng Việt hay phép nhân 7
      expect(find.textContaining('Phiếu ôn tập môn Tiếng Việt'), findsNothing);
      expect(find.textContaining('7 x 8'), findsNothing);
    });

    testWidgets('TC-HW-FLOW-03: Result Primary Grade 1 English (id: 103) - Correct Family theme and 10.0 score', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: StudentHomeworkResultScreen(
            assignmentId: 103,
            initialData: HomeworkMockContentProvider.getAssignmentResult(103),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tiêu đề và môn
      expect(find.textContaining('Unit 1: Family'), findsOneWidget);
      expect(find.textContaining('Tiếng Anh'), findsWidgets);

      // Điểm số và nhận xét
      expect(find.textContaining('10.0'), findsWidgets);
      expect(find.textContaining('Em làm bài rất tốt'), findsOneWidget);

      // Câu hỏi và đáp án gia đình
      expect(find.textContaining('Mother'), findsWidgets);

      // TUYỆT ĐỐI KHÔNG xuất hiện phép nhân 7
      expect(find.textContaining('Bài tập tuần 5 - Phép nhân'), findsNothing);
      expect(find.textContaining('7 x 8'), findsNothing);
    });

    testWidgets('TC-HW-FLOW-04: Result High School Grade 10 Physics (id: 4) - Correct Kinematics, NOT Rectangle geometry', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: StudentHomeworkResultScreen(
            assignmentId: 4,
            initialData: HomeworkMockContentProvider.getAssignmentResult(4),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tiêu đề và môn Vật lý
      expect(find.textContaining('Động học chất điểm'), findsOneWidget);
      expect(find.textContaining('Vật lý'), findsWidgets);

      // TUYỆT ĐỐI KHÔNG bị biến thành "Trắc nghiệm hình học: Hình chữ nhật" hay Toán học
      expect(find.textContaining('Hình chữ nhật'), findsNothing);
      expect(find.textContaining('7 x 8'), findsNothing);
    });

    testWidgets('TC-HW-FLOW-05: Result High School Grade 10 Literature Essay (id: 3) - Correct Cultural Identity, NOT Reading week 4', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: StudentHomeworkResultScreen(
            assignmentId: 3,
            initialData: HomeworkMockContentProvider.getAssignmentResult(3),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tiêu đề bài luận bản sắc văn hóa
      expect(find.textContaining('Ý thức giữ gìn bản sắc văn hóa dân tộc'), findsOneWidget);
      expect(find.textContaining('Ngữ văn'), findsWidgets);
      expect(find.textContaining('9.5'), findsWidgets);

      // TUYỆT ĐỐI KHÔNG bị biến thành "Đọc hiểu & Kể chuyện tuần 4" hay bao gạo 12kg
      expect(find.textContaining('Đọc hiểu & Kể chuyện tuần 4'), findsNothing);
      expect(find.textContaining('5 bao gạo'), findsNothing);
      expect(find.textContaining('7 x 8'), findsNothing);
    });
  });
}
