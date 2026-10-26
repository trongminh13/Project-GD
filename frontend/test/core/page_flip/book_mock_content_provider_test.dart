import 'package:flutter_test/flutter_test.dart';
import 'package:ashadeep/core/page_flip/book_mock_content_provider.dart';

void main() {
  group('BookMockContentProvider Tests - Cấp 1 (Tiểu học)', () {
    test('Toán 1 trả về đúng các chủ đề số học và hình học lớp 1', () {
      final book = {'title': 'Sách giáo khoa Toán 1 - Tập 1', 'subjectName': 'Toán'};
      final lessonP1 = BookMockContentProvider.resolve(book, 1);
      expect(lessonP1.chapterTitle, 'CHỦ ĐỀ 1: LÀM QUEN VỚI MỘT SỐ HÌNH');
      expect(lessonP1.lessonTitle, contains('HÌNH VUÔNG'));

      final lessonP25 = BookMockContentProvider.resolve(book, 25);
      expect(lessonP25.chapterTitle, 'CHỦ ĐỀ 2: CHỮ SỐ VÀ PHÉP SO SÁNH');
      expect(lessonP25.tipText, contains('Đếm xuôi: 1, 2, 3'));

      final chapters = BookMockContentProvider.getChapters(book);
      expect(chapters.length, 5);
      expect(chapters.first['title'], contains('Chủ đề 1'));
    });

    test('Tiếng Việt 1 trả về đúng âm vần chữ cái, không bị lệch sang Bảng nhân 7', () {
      final book = {'title': 'Sách giáo khoa Tiếng Việt 1 - Tập 1', 'subjectName': 'Tiếng Việt'};
      final lesson = BookMockContentProvider.resolve(book, 5);
      expect(lesson.chapterTitle, 'CHỦ ĐỀ 1: NHỮNG BÀI HỌC ĐẦU TIÊN');
      expect(lesson.lessonTitle, contains('LÀM QUEN ÂM C'));
      expect(lesson.tipText, contains('cờ - a - ca'));
      expect(lesson.tipText, isNot(contains('7 × 1 = 7')));
    });

    test('Tiếng Anh 1 trả về Hello & Friends, không bị lệch sang Bảng nhân 7', () {
      final book = {'title': 'Sách Tiếng Anh 1 - Global Success', 'subjectName': 'Tiếng Anh'};
      final lesson = BookMockContentProvider.resolve(book, 1);
      expect(lesson.chapterTitle, 'UNIT 1: HELLO & FRIENDS');
      expect(lesson.tipText, contains('Say Hello!'));
      expect(lesson.tipText, isNot(contains('7 × 1 = 7')));
    });

    test('Tự nhiên và Xã hội 1 trả về bảo vệ sức khỏe và cơ thể em', () {
      final book = {'title': 'Sách giáo khoa Tự nhiên và Xã hội 1', 'subjectName': 'Tự nhiên và Xã hội'};
      final lesson = BookMockContentProvider.resolve(book, 10);
      expect(lesson.chapterTitle, contains('GIA ĐÌNH VÀ BẢN THÂN EM'));
      expect(lesson.tipText, contains('Rửa tay bằng xà phòng'));
    });

    test('Đạo đức 1 trả về bài học chào hỏi lễ phép', () {
      final book = {'title': 'Sách giáo khoa Đạo đức 1', 'subjectName': 'Đạo đức'};
      final lesson = BookMockContentProvider.resolve(book, 8);
      expect(lesson.chapterTitle, contains('LỄ PHÉP VỚI ÔNG BÀ'));
      expect(lesson.tipText, contains('Khoanh tay chào hỏi'));
    });
  });

  group('BookMockContentProvider Tests - Cấp 2 (THCS)', () {
    test('Toán 6 trả về Tập hợp các số tự nhiên, không phải Bảng nhân 7', () {
      final book = {'title': 'Sách giáo khoa Toán 6 - Tập 1', 'subjectName': 'Toán'};
      final lesson = BookMockContentProvider.resolve(book, 10);
      expect(lesson.chapterTitle, 'CHƯƠNG 1: TẬP HỢP CÁC SỐ TỰ NHIÊN');
      expect(lesson.lessonTitle, contains('TẬP HỢP VÀ CÁC PHẦN TỬ'));
      expect(lesson.tipText, contains('a ∈ A'));
    });

    test('Ngữ văn 6 trả về Truyền thuyết Thánh Gióng', () {
      final book = {'title': 'Sách giáo khoa Ngữ văn 6 - Tập 1', 'subjectName': 'Ngữ văn'};
      final lesson = BookMockContentProvider.resolve(book, 15);
      expect(lesson.chapterTitle, contains('LẮNG NGHE LỊCH SỬ NƯỚC MÌNH'));
      expect(lesson.lessonTitle, contains('TRUYỀN THUYẾT THÁNH GIÓNG'));
      expect(lesson.tipText, contains('lòng yêu nước nồng nàn'));
    });

    test('Tiếng Anh 6 trả về My New School', () {
      final book = {'title': 'Sách Tiếng Anh 6 - Global Success', 'subjectName': 'Tiếng Anh'};
      final lesson = BookMockContentProvider.resolve(book, 5);
      expect(lesson.chapterTitle, 'UNIT 1: MY NEW SCHOOL');
      expect(lesson.tipText, contains('wear uniform'));
    });

    test('Khoa học tự nhiên 6 trả về Tế bào nhân thực & nhân sơ', () {
      final book = {'title': 'Sách giáo khoa Khoa học tự nhiên 6', 'subjectName': 'Khoa học tự nhiên'};
      final lesson = BookMockContentProvider.resolve(book, 20);
      expect(lesson.chapterTitle, contains('TẾ BÀO'));
      expect(lesson.tipText, contains('Màng tế bào, Chất tế bào'));
    });

    test('Ngữ văn 6 trang 110 trả về Bài 4 Dế Mèn phiêu lưu ký & kết nối Hoàng tử bé', () {
      final book = {'title': 'Sách giáo khoa Ngữ văn 6 - Tập 1', 'subjectName': 'Ngữ văn'};
      final lesson = BookMockContentProvider.resolve(book, 110);
      expect(lesson.chapterTitle, contains('NHỮNG TRẢI NGHIỆM TRONG ĐỜI'));
      expect(lesson.lessonTitle, contains('DẾ MÈN PHIÊU LƯU KÝ'));
      expect(lesson.exContent2, contains('Hoàng tử bé'));
      expect(lesson.footerBookName, contains('Kết nối tri thức'));
    });
  });

  group('BookMockContentProvider Tests - Cấp 3 (THPT)', () {
    test('KHẮC PHỤC LỖI: Toán 10 TUYỆT ĐỐI KHÔNG bị nhận diện nhầm thành Toán 1', () {
      final book = {'title': 'Sách giáo khoa Toán 10 - Tập 1', 'subjectName': 'Toán'};
      final lesson = BookMockContentProvider.resolve(book, 1);
      // Khẳng định chương trình lớp 10, không phải đếm 1..10 của lớp 1!
      expect(lesson.chapterTitle, 'CHƯƠNG 1: MỆNH ĐỀ TOÁN HỌC VÀ TẬP HỢP');
      expect(lesson.lessonTitle, contains('MỆNH ĐỀ VÀ MỆNH ĐỀ CHỨA BIẾN'));
      expect(lesson.tipText, contains('Mệnh đề toán học là một khẳng định đúng hoặc một khẳng định sai'));
      expect(lesson.tipText, isNot(contains('Đếm xuôi: 1, 2, 3')));

      final chapters = BookMockContentProvider.getChapters(book);
      expect(chapters.first['title'], contains('Mệnh đề toán học'));
      expect(chapters.first['title'], isNot(contains('Làm quen với một số hình')));
    });

    test('Toán 10 ở trang 35 trả về Bất phương trình bậc nhất hai ẩn', () {
      final book = {'title': 'Sách giáo khoa Toán 10 - Tập 1', 'subjectName': 'Toán'};
      final lesson = BookMockContentProvider.resolve(book, 35);
      expect(lesson.chapterTitle, 'CHƯƠNG 2: BẤT PHƯƠNG TRÌNH BẬC NHẤT HAI ẨN');
      expect(lesson.tipText, contains('ax + by < c'));
    });

    test('Ngữ văn 10 trả về Sử thi Đăm Săn chiến thắng Mtao Mxây', () {
      final book = {'title': 'Sách giáo khoa Ngữ văn 10 - Tập 1', 'subjectName': 'Ngữ văn'};
      final lesson = BookMockContentProvider.resolve(book, 12);
      expect(lesson.chapterTitle, contains('SỨC SỐNG CỦA SỬ THI'));
      expect(lesson.lessonTitle, contains('ĐĂM SĂN CHIẾN THẮNG MTAO MXÂY'));
      expect(lesson.tipText, contains('anh hùng ca ngợi vẻ đẹp dũng cảm'));
      expect(lesson.tipText, isNot(contains('7 × 1 = 7')));
    });

    test('Vật lý 10 trả về Chuyển động thẳng biến đổi đều & Định luật Newton', () {
      final book = {'title': 'Sách giáo khoa Vật lý 10', 'subjectName': 'Vật lý'};
      final lesson = BookMockContentProvider.resolve(book, 35);
      expect(lesson.chapterTitle, 'CHƯƠNG 2: ĐỘNG HỌC CHẤT ĐIỂM');
      expect(lesson.lessonTitle, contains('CHUYỂN ĐỘNG THẲNG BIẾN ĐỔI ĐỀU'));
      expect(lesson.tipText, contains('v = v₀ + at'));
      expect(lesson.tipText, isNot(contains('7 × 1 = 7')));
    });

    test('Hóa học 10 trả về Cấu tạo nguyên tử & Bảng tuần hoàn', () {
      final book = {'title': 'Sách giáo khoa Hóa học 10', 'subjectName': 'Hóa học'};
      final lesson = BookMockContentProvider.resolve(book, 10);
      expect(lesson.chapterTitle, 'CHƯƠNG 1: CẤU TẠO NGUYÊN TỬ');
      expect(lesson.lessonTitle, contains('HẠT NHÂN NGUYÊN TỬ'));
      expect(lesson.tipText, contains('Proton (p, mang điện tích +1)'));
      expect(lesson.tipText, isNot(contains('7 × 1 = 7')));
    });

    test('Tiếng Anh 10 trả về Family Life & Household Chores', () {
      final book = {'title': 'Sách Tiếng Anh 10 - Global Success', 'subjectName': 'Tiếng Anh'};
      final lesson = BookMockContentProvider.resolve(book, 5);
      expect(lesson.chapterTitle, contains('FAMILY LIFE AND HOUSEHOLD CHORES'));
      expect(lesson.tipText, contains('Present Simple: Habits'));
      expect(lesson.tipText, isNot(contains('7 × 1 = 7')));
    });

    test('Toán 10 và Ngữ văn 10 hiển thị đúng nhãn Tập 2', () {
      final toan10 = {'title': 'Sách giáo khoa Toán 10 - Tập 2', 'subjectName': 'Toán'};
      final nv10 = {'title': 'Sách giáo khoa Ngữ văn 10 - Tập 2', 'subjectName': 'Ngữ văn'};
      expect(BookMockContentProvider.resolve(toan10, 1).footerBookName, 'Sách giáo khoa Toán 10 - Tập 2');
      expect(BookMockContentProvider.resolve(nv10, 1).footerBookName, 'Sách giáo khoa Ngữ văn 10 - Tập 2');
    });

    test('Dải trang mục lục (TOC) không bị tràn quá số trang thực tế của sách', () {
      final tv1 = {'title': 'Sách giáo khoa Tiếng Việt 1 - Tập 1', 'subjectName': 'Tiếng Việt'};
      final chTv1 = BookMockContentProvider.getChapters(tv1);
      expect(chTv1.last['endPage'], 57);

      final toan10 = {'title': 'Sách giáo khoa Toán 10 - Tập 2', 'subjectName': 'Toán'};
      final chToan10 = BookMockContentProvider.getChapters(toan10);
      expect(chToan10.last['endPage'], 52);

      final nv10 = {'title': 'Sách giáo khoa Ngữ văn 10 - Tập 2', 'subjectName': 'Ngữ văn'};
      final chNv10 = BookMockContentProvider.getChapters(nv10);
      expect(chNv10.last['endPage'], 71);

      final toan6 = {'title': 'Sách giáo khoa Toán 6 - Tập 1', 'subjectName': 'Toán'};
      final chToan6 = BookMockContentProvider.getChapters(toan6);
      expect(chToan6.last['endPage'], 126);

      final nv6 = {'title': 'Sách giáo khoa Ngữ văn 6 - Tập 1', 'subjectName': 'Ngữ văn'};
      final chNv6 = BookMockContentProvider.getChapters(nv6);
      expect(chNv6.last['endPage'], 138);
    });
  });

  group('BookMockContentProvider Backward Compatibility Tests', () {
    test('Toán 3 vẫn giữ nguyên Bảng nhân 7 để tương thích 100% với test cũ', () {
      final book = {'title': 'Toán 3 - Tập 2', 'subjectName': 'Toán'};
      final lesson = BookMockContentProvider.resolve(book, 1);
      expect(lesson.chapterTitle, 'CHƯƠNG 2: BẢNG NHÂN & BẢNG CHIA CƠ BẢN');
      expect(lesson.lessonTitle, contains('BÀI 12: BẢNG NHÂN 7 VÀ ỨNG DỤNG THỰC HÀNH'));
      expect(lesson.tipText, contains('7 × 1 = 7'));

      final chapters = BookMockContentProvider.getChapters(book);
      expect(chapters[1]['title'], 'Chương 2: Bảng nhân và bảng chia cơ bản');
    });
  });
}
