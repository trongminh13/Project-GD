import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/services/homework_mock_content_provider.dart';

void main() {
  group('HomeworkMockContentProvider Tests', () {
    // ==========================================
    // CẤP 1 (TIỂU HỌC - LỚP 1)
    // ==========================================
    test('TC-HW-01: Primary Grade 1 Math (id: 101) - Counting and comparing up to 10', () {
      final hw = HomeworkMockContentProvider.getAssignmentForTaking(101);
      expect(hw['assignmentId'], 101);
      expect(hw['homeworkTitle'], 'Bài tập tuần 5: Đếm và so sánh các số trong phạm vi 10');
      expect(hw['subjectName'], 'Toán');
      expect(hw['submissionStatus'], 'IN_PROGRESS');

      final questions = hw['questions'] as List<dynamic>;
      expect(questions.length, 4);

      // Question 1: Đếm thỏ
      expect(questions[0]['content'], contains('chú thỏ trắng'));
      expect(questions[0]['questionType'], 'SINGLE_CHOICE');

      // Question 2: So sánh số lớn hơn 7
      expect(questions[1]['content'], contains('lớn hơn số 7'));

      // Question 3: Đúng sai
      expect(questions[2]['questionType'], 'TRUE_FALSE');
      expect(questions[2]['content'], contains('9 > 6'));

      // Question 4: Tự luận điền dãy số
      expect(questions[3]['questionType'], 'ESSAY');
      expect(questions[3]['content'], contains('1, 2, 3'));
    });

    test('TC-HW-02: Primary Grade 1 Vietnamese (id: 102) - Letter writing a, b, c', () {
      final hw = HomeworkMockContentProvider.getAssignmentForTaking(102);
      expect(hw['assignmentId'], 102);
      expect(hw['homeworkTitle'], contains('Luyện viết chữ đẹp nét cơ bản và chữ cái a, b, c'));
      expect(hw['subjectName'], 'Tiếng Việt');

      final questions = hw['questions'] as List<dynamic>;
      expect(questions[0]['content'], contains('Chữ cái đầu tiên trong bảng chữ cái'));
      expect(questions[1]['content'], contains('tiếng có chứa âm "c"'));
      expect(questions[2]['content'], contains('chữ cái "o"'));
      expect(questions[3]['questionType'], 'ESSAY');
    });

    test('TC-HW-03: Primary Grade 1 English (id: 103) - Graded result with Family theme', () {
      final result = HomeworkMockContentProvider.getAssignmentResult(103);
      expect(result['assignmentId'], 103);
      expect(result['homeworkTitle'], contains('Unit 1: Family'));
      expect(result['subjectName'], 'Tiếng Anh');
      expect(result['finalScore'], 10.0);
      expect(result['teacherFeedback'], contains('Em làm bài rất tốt'));

      final questions = result['questions'] as List<dynamic>;
      expect(questions[0]['content'], contains('Mẹ'));
      expect(questions[1]['content'], contains('thành viên trong gia đình'));

      final answers = result['savedAnswers'] as List<dynamic>;
      expect(answers.length, 4);
      expect(answers[0]['selectedOptionIds'], [10312]); // Mother
    });

    test('TC-HW-04: Primary Grade 1 Science/Society (id: 104) - Graded result with Human body', () {
      final result = HomeworkMockContentProvider.getAssignmentResult(104);
      expect(result['assignmentId'], 104);
      expect(result['homeworkTitle'], contains('Quan sát và nhận biết các bộ phận trên cơ thể người'));
      expect(result['subjectName'], 'Tự nhiên và Xã hội');
      expect(result['finalScore'], 9.5);
      expect(result['teacherFeedback'], contains('Bài làm rất xuất sắc'));

      final questions = result['questions'] as List<dynamic>;
      expect(questions[0]['content'], contains('nhìn thấy màu sắc'));
      expect(questions[1]['content'], contains('vệ sinh thân thể'));
    });

    // ==========================================
    // CẤP 2 (THCS - LỚP 6)
    // ==========================================
    test('TC-HW-05: Secondary Grade 6 Math (id: 201) - Natural numbers and exponents', () {
      final hw = HomeworkMockContentProvider.getAssignmentForTaking(201);
      expect(hw['assignmentId'], 201);
      expect(hw['homeworkTitle'], contains('Tập hợp các số tự nhiên và phép tính lũy thừa cơ bản'));
      expect(hw['subjectName'], 'Toán');

      final questions = hw['questions'] as List<dynamic>;
      expect(questions[0]['content'], contains('2⁴'));
      expect(questions[1]['content'], contains('A = {x ∈ ℕ | 3 < x ≤ 7}'));
      expect(questions[2]['content'], contains('Số 0 là số tự nhiên nhỏ nhất'));
      expect(questions[3]['content'], contains('3² × 5 - 2³ × 4'));
    });

    test('TC-HW-06: Secondary Grade 6 Literature (id: 202) - Thach Sanh folk tale', () {
      final hw = HomeworkMockContentProvider.getAssignmentForTaking(202);
      expect(hw['assignmentId'], 202);
      expect(hw['homeworkTitle'], contains('Thạch Sanh'));
      expect(hw['subjectName'], 'Ngữ văn');

      final questions = hw['questions'] as List<dynamic>;
      expect(questions[0]['content'], contains('Thạch Sanh'));
      expect(questions[1]['content'], contains('chiến công'));
      expect(questions[2]['content'], contains('Lý Thông'));
      expect(questions[3]['content'], contains('Tiếng đàn thần'));
    });

    test('TC-HW-07: Secondary Grade 6 English (id: 203) - Graded result My New School', () {
      final result = HomeworkMockContentProvider.getAssignmentResult(203);
      expect(result['assignmentId'], 203);
      expect(result['homeworkTitle'], contains('Unit 1: My New School'));
      expect(result['subjectName'], 'Tiếng Anh');
      expect(result['finalScore'], 9.0);
      expect(result['teacherFeedback'], contains('nắm vững thì hiện tại đơn'));

      final questions = result['questions'] as List<dynamic>;
      expect(questions[0]['content'], contains('homework after dinner'));
      expect(questions[1]['content'], contains('school subjects'));
    });

    test('TC-HW-08: Secondary Grade 6 Natural Science (id: 204) - Graded result Measurements', () {
      final result = HomeworkMockContentProvider.getAssignmentResult(204);
      expect(result['assignmentId'], 204);
      expect(result['homeworkTitle'], contains('Các phép đo cơ bản'));
      expect(result['subjectName'], 'Khoa học tự nhiên');
      expect(result['finalScore'], 9.5);

      final questions = result['questions'] as List<dynamic>;
      expect(questions[0]['content'], contains('hệ đo lường quốc tế (SI)'));
      expect(questions[1]['content'], contains('đo khối lượng'));
      expect(questions[2]['content'], contains('Giới hạn đo (GHĐ)'));
    });

    // ==========================================
    // CẤP 3 (THPT - LỚP 10)
    // ==========================================
    test('TC-HW-09: High School Grade 10 Math (id: 28 / 301) - Quadratic function variation', () {
      final hw = HomeworkMockContentProvider.getAssignmentForTaking(28);
      expect(hw['assignmentId'], 28);
      expect(hw['homeworkTitle'], contains('Khảo sát sự biến thiên hàm số bậc hai'));
      expect(hw['subjectName'], 'Toán học');

      final questions = hw['questions'] as List<dynamic>;
      expect(questions[0]['content'], contains('y = x² - 4x + 3'));
      expect(questions[1]['content'], contains('y = -2x² + 4x + 1'));
      expect(questions[2]['content'], contains('x = -b/(2a)'));
      expect(questions[3]['content'], contains('y = x² - 2x - 3'));

      // Also support alias 301
      final hw301 = HomeworkMockContentProvider.getAssignmentForTaking(301);
      expect(hw301['homeworkTitle'], hw['homeworkTitle']);
    });

    test('TC-HW-10: High School Grade 10 Literature (id: 2 / 302) - Chien thang Mtao Mxay', () {
      final hw = HomeworkMockContentProvider.getAssignmentForTaking(2);
      expect(hw['assignmentId'], 2);
      expect(hw['homeworkTitle'], contains('Chiến thắng Mtao Mxây'));
      expect(hw['subjectName'], 'Ngữ văn');

      final questions = hw['questions'] as List<dynamic>;
      expect(questions[0]['content'], contains('sử thi'));
      expect(questions[0]['content'], contains('Mtao Mxây'));
      expect(questions[1]['content'], contains('Đăm Săn'));
    });

    test('TC-HW-11: High School Grade 10 Essay (id: 3 / 303) - Graded result Cultural identity', () {
      final result = HomeworkMockContentProvider.getAssignmentResult(3);
      expect(result['assignmentId'], 3);
      expect(result['homeworkTitle'], contains('Ý thức giữ gìn bản sắc văn hóa dân tộc'));
      expect(result['subjectName'], 'Ngữ văn');
      expect(result['finalScore'], 9.5);
      expect(result['teacherFeedback'], contains('lý tưởng sống đẹp của thanh niên'));

      final questions = result['questions'] as List<dynamic>;
      expect(questions[0]['content'], contains('bản sắc văn hóa'));
      expect(questions[1]['content'], contains('thời đại 4.0'));
      expect(questions[2]['content'], contains('Hội nhập quốc tế'));
    });

    test('TC-HW-12: High School Grade 10 Physics (id: 4 / 304) - Graded result Kinematics', () {
      final result = HomeworkMockContentProvider.getAssignmentResult(4);
      expect(result['assignmentId'], 4);
      expect(result['homeworkTitle'], contains('Động học chất điểm'));
      expect(result['subjectName'], 'Vật lý');
      expect(result['finalScore'], 10.0);
      expect(result['teacherFeedback'], contains('từng đơn vị vật lý'));

      final questions = result['questions'] as List<dynamic>;
      expect(questions[0]['content'], contains('biến đổi đều'));
      expect((questions[0]['options'] as List<dynamic>)[0]['content'], contains('v = v₀ + at'));
      expect(questions[1]['content'], contains('nhanh dần đều'));
      expect(questions[2]['content'], contains('Độ dịch chuyển'));
    });

    // ==========================================
    // LEGACY & BACKWARD COMPATIBILITY
    // ==========================================
    test('TC-HW-13: Legacy Math Grade 3 (id: 1) - Multiplication table 7 fallback', () {
      final hw = HomeworkMockContentProvider.getAssignmentForTaking(1);
      expect(hw['homeworkTitle'], 'Bài tập tuần 5 - Phép nhân');
      expect(hw['subjectName'], 'Toán học');
      expect((hw['questions'] as List<dynamic>)[0]['content'], contains('7 x 8'));

      final result = HomeworkMockContentProvider.getAssignmentResult(1);
      expect(result['homeworkTitle'], 'Bài tập tuần 5 - Phép nhân');
      expect(result['finalScore'], 8.5);
      expect((result['questions'] as List<dynamic>)[0]['content'], contains('7 x 8'));
    });
  });
}
