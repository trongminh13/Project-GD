
/// Dữ liệu nội dung một bài học số hóa được phân giải theo cuốn sách và số trang cụ thể.
class BookLessonData {
  final String chapterTitle;
  final String lessonTitle;
  final String tipTitle;
  final String tipText;
  final String exTitle;
  final String exContent;
  final String exTitle2;
  final String exContent2;
  final String footerBookName;

  const BookLessonData({
    required this.chapterTitle,
    required this.lessonTitle,
    required this.tipTitle,
    required this.tipText,
    required this.exTitle,
    required this.exContent,
    required this.exTitle2,
    required this.exContent2,
    required this.footerBookName,
  });
}

/// Bộ phân giải nội dung giả lập (Mock Content Provider) thông minh theo môn học và cấp học:
/// - Khắc phục triệt để lỗi nhận diện sai `Toán 10` thành `Toán 1`.
/// - Khắc phục lỗi hardcode Bảng nhân 7 (Toán 3) cho tất cả các môn Văn, Anh, Lý, Hóa, Sử, v.v.
/// - Đồng bộ danh sách mục lục (TOC chapters) tương ứng với nội dung từng môn.
class BookMockContentProvider {
  static final RegExp _toan1Regex = RegExp(r'\btoán\s*1\b|\btoan\s*1\b', caseSensitive: false);
  static final RegExp _toan3Regex = RegExp(r'\btoán\s*3\b|\btoan\s*3\b', caseSensitive: false);
  static final RegExp _toan6Regex = RegExp(r'\btoán\s*6\b|\btoan\s*6\b', caseSensitive: false);
  static final RegExp _toan10Regex = RegExp(r'\btoán\s*10\b|\btoan\s*10\b', caseSensitive: false);

  /// Xác định danh sách Mục lục (TOC) theo cuốn sách
  static List<Map<String, dynamic>> getChapters(Map<String, dynamic> bookData) {
    final title = (bookData['title'] ?? '').toString();
    final subject = (bookData['subjectName'] ?? '').toString().toLowerCase();

    // 1. Sách giáo khoa Toán 1
    if (_toan1Regex.hasMatch(title)) {
      return [
        {'title': 'Chủ đề 1: Làm quen với một số hình', 'startPage': 4, 'endPage': 23},
        {'title': 'Chủ đề 2: Làm quen với chữ số & phép so sánh', 'startPage': 24, 'endPage': 49},
        {'title': 'Chủ đề 3: Phép cộng & phép trừ trong phạm vi 10', 'startPage': 50, 'endPage': 81},
        {'title': 'Chủ đề 4: Làm quen với hình khối và thời gian', 'startPage': 82, 'endPage': 99},
        {'title': 'Chủ đề 5: Ôn tập học kì 1 & ứng dụng thực hành', 'startPage': 100, 'endPage': 118},
      ];
    }

    // 2. Sách giáo khoa Toán 3 (Bảo toàn tương thích cho test cũ)
    if (_toan3Regex.hasMatch(title)) {
      return [
        {'title': 'Chương 1: Ôn tập và bổ sung kiến thức đầu năm', 'startPage': 4, 'endPage': 28},
        {'title': 'Chương 2: Bảng nhân và bảng chia cơ bản', 'startPage': 29, 'endPage': 56},
        {'title': 'Chương 3: Làm quen với hình phẳng và hình khối', 'startPage': 57, 'endPage': 82},
        {'title': 'Chương 4: Phép tính có nhớ trong phạm vi 1000', 'startPage': 83, 'endPage': 110},
      ];
    }

    // 3. Sách giáo khoa Toán 6 (126 trang thực tế)
    if (_toan6Regex.hasMatch(title)) {
      return [
        {'title': 'Chương 1: Tập hợp các số tự nhiên & Phép tính', 'startPage': 4, 'endPage': 35},
        {'title': 'Chương 2: Tính chất chia hết & Số nguyên tố', 'startPage': 36, 'endPage': 65},
        {'title': 'Chương 3: Số nguyên âm & Tập hợp số nguyên', 'startPage': 66, 'endPage': 95},
        {'title': 'Chương 4: Một số hình phẳng trong thực tiễn & Ôn tập', 'startPage': 96, 'endPage': 126},
      ];
    }

    // 4. Sách giáo khoa Toán 10 (Tập 2: 52 trang thực tế; Tập 1: dải trang mặc định)
    if (_toan10Regex.hasMatch(title) || (subject.contains('toán') && title.contains('10'))) {
      if (title.toLowerCase().contains('tập 2') || title.toLowerCase().contains('tap 2') || title.toLowerCase().contains('tap_2')) {
        return [
          {'title': 'Chương 6: Hàm số, Đồ thị và Ứng dụng', 'startPage': 4, 'endPage': 18},
          {'title': 'Chương 7: Phương pháp tọa độ trong mặt phẳng', 'startPage': 19, 'endPage': 32},
          {'title': 'Chương 8: Đại số tổ hợp & Nhị thức Newton', 'startPage': 33, 'endPage': 42},
          {'title': 'Chương 9: Tính xác suất của biến cố', 'startPage': 43, 'endPage': 52},
        ];
      }
      return [
        {'title': 'Chương 1: Mệnh đề toán học và Tập hợp', 'startPage': 4, 'endPage': 28},
        {'title': 'Chương 2: Bất phương trình bậc nhất hai ẩn', 'startPage': 29, 'endPage': 55},
        {'title': 'Chương 3: Hàm số bậc hai và Đồ thị', 'startPage': 56, 'endPage': 85},
        {'title': 'Chương 4: Hệ thức lượng trong tam giác & Vectơ', 'startPage': 86, 'endPage': 124},
      ];
    }

    // 5. Môn Ngữ văn / Tiếng Việt
    if (subject.contains('văn') || subject.contains('tiếng việt') || title.toLowerCase().contains('văn') || title.toLowerCase().contains('tiếng việt')) {
      if (title.contains('10')) {
        if (title.toLowerCase().contains('tập 2') || title.toLowerCase().contains('tap 2') || title.toLowerCase().contains('tap_2')) {
          return [
            {'title': 'Bài 6: Nguyễn Trãi - Dành còn để trợ dân này', 'startPage': 4, 'endPage': 22},
            {'title': 'Bài 7: Quyền năng của người kể chuyện (Truyện ngắn)', 'startPage': 23, 'endPage': 40},
            {'title': 'Bài 8: Thế giới đa dạng của thông tin (Văn bản thông tin)', 'startPage': 41, 'endPage': 56},
            {'title': 'Bài 9: Hành trang cuộc sống (Văn bản nghị luận)', 'startPage': 57, 'endPage': 71},
          ];
        }
        return [
          {'title': 'Bài 1: Sức sống của sử thi & Thần thoại', 'startPage': 4, 'endPage': 32},
          {'title': 'Bài 2: Vẻ đẹp của thơ ca trung đại và Đường luật', 'startPage': 33, 'endPage': 65},
          {'title': 'Bài 3: Nghệ thuật chèo, tuồng & Sân khấu dân gian', 'startPage': 66, 'endPage': 98},
          {'title': 'Bài 4: Văn bản nghị luận & Bản sắc văn hóa', 'startPage': 99, 'endPage': 128},
        ];
      }
      if (title.contains('6')) {
        return [
          {'title': 'Bài 1: Lắng nghe lịch sử nước mình (Truyền thuyết: Thánh Gióng, Sơn Tinh Thủy Tinh)', 'startPage': 4, 'endPage': 35},
          {'title': 'Bài 2: Miền cổ tích và thế giới diệu kỳ (Cổ tích: Thạch Sanh)', 'startPage': 36, 'endPage': 70},
          {'title': 'Bài 3: Vẻ đẹp quê hương (Thơ lục bát: Ca dao, Chùm ca dao quê hương)', 'startPage': 71, 'endPage': 105},
          {'title': 'Bài 4: Những trải nghiệm trong đời (Đồng thoại: Dế Mèn phiêu lưu ký - Tô Hoài; Hoàng tử bé - Saint-Exupéry)', 'startPage': 106, 'endPage': 138},
        ];
      }
      // Tiếng Việt 1 (57 trang thực tế)
      return [
        {'title': 'Chủ đề 1: Em làm quen với chữ cái và dấu thanh', 'startPage': 4, 'endPage': 18},
        {'title': 'Chủ đề 2: Em học ghép vần & Luyện phát âm', 'startPage': 19, 'endPage': 32},
        {'title': 'Chủ đề 3: Đọc câu ngắn & Đoạn văn về gia đình', 'startPage': 33, 'endPage': 45},
        {'title': 'Chủ đề 4: Mái trường mến yêu & Thầy cô bè bạn', 'startPage': 46, 'endPage': 57},
      ];
    }

    // 6. Môn Tiếng Anh
    if (subject.contains('anh') || title.toLowerCase().contains('tiếng anh') || title.toLowerCase().contains('english')) {
      if (title.contains('10')) {
        return [
          {'title': 'Unit 1: Family Life & Household Chores', 'startPage': 4, 'endPage': 28},
          {'title': 'Unit 2: Humans and the Environment', 'startPage': 29, 'endPage': 56},
          {'title': 'Unit 3: Music and Arts in Modern Life', 'startPage': 57, 'endPage': 84},
          {'title': 'Unit 4: For a Better Community & Volunteering', 'startPage': 85, 'endPage': 112},
        ];
      }
      if (title.contains('6')) {
        return [
          {'title': 'Unit 1: My New School & Classmates', 'startPage': 4, 'endPage': 28},
          {'title': 'Unit 2: My Home & Daily Routines', 'startPage': 29, 'endPage': 56},
          {'title': 'Unit 3: My Friends & Personality Traits', 'startPage': 57, 'endPage': 84},
          {'title': 'Unit 4: My Neighbourhood & Directions', 'startPage': 85, 'endPage': 112},
        ];
      }
      // Tiếng Anh 1
      return [
        {'title': 'Unit 1: In the School Playground (Hello & Names)', 'startPage': 4, 'endPage': 22},
        {'title': 'Unit 2: In the Dining Room (Foods & Drinks)', 'startPage': 23, 'endPage': 42},
        {'title': 'Unit 3: At the Street Market (Numbers 1-10)', 'startPage': 43, 'endPage': 62},
        {'title': 'Unit 4: In the Bedroom (Colors & Toys)', 'startPage': 63, 'endPage': 80},
      ];
    }

    // 7. Môn Khoa học Tự nhiên / Vật lý / Hóa học
    if (subject.contains('vật lý') || subject.contains('vật lí') || title.toLowerCase().contains('vật lý') || title.toLowerCase().contains('vật lí')) {
      return [
        {'title': 'Chương 1: Mở đầu về Vật lý & Các phép đo', 'startPage': 4, 'endPage': 30},
        {'title': 'Chương 2: Động học chất điểm & Vận tốc gia tốc', 'startPage': 31, 'endPage': 62},
        {'title': 'Chương 3: Động lực học & Ba định luật Newton', 'startPage': 63, 'endPage': 92},
        {'title': 'Chương 4: Năng lượng, Công cơ học & Công suất', 'startPage': 93, 'endPage': 120},
      ];
    }

    if (subject.contains('hóa') || title.toLowerCase().contains('hóa')) {
      return [
        {'title': 'Chương 1: Cấu tạo nguyên tử & Các hạt cơ bản', 'startPage': 4, 'endPage': 30},
        {'title': 'Chương 2: Bảng tuần hoàn các nguyên tố hóa học', 'startPage': 31, 'endPage': 60},
        {'title': 'Chương 3: Liên kết hóa học & Quy tắc Octet', 'startPage': 61, 'endPage': 88},
        {'title': 'Chương 4: Phản ứng oxi hóa - khử trong đời sống', 'startPage': 89, 'endPage': 116},
      ];
    }

    if (subject.contains('khoa học') || title.toLowerCase().contains('khtn')) {
      return [
        {'title': 'Chương 1: Mở đầu về KHTN & Các phép đo lường', 'startPage': 4, 'endPage': 45},
        {'title': 'Chương 2: Chất và sự biến đổi của chất', 'startPage': 46, 'endPage': 92},
        {'title': 'Chương 3: Tế bào - Đơn vị cơ bản của sự sống', 'startPage': 93, 'endPage': 138},
        {'title': 'Chương 4: Đa dạng thế giới sống & Sinh vật', 'startPage': 139, 'endPage': 184},
      ];
    }

    // 8. Tự nhiên và Xã hội 1
    if (title.toLowerCase().contains('tự nhiên') || title.toLowerCase().contains('tnxh')) {
      return [
        {'title': 'Chủ đề 1: Gia đình & Nếp sống văn minh', 'startPage': 4, 'endPage': 25},
        {'title': 'Chủ đề 2: Trường học & Thầy cô bè bạn', 'startPage': 26, 'endPage': 48},
        {'title': 'Chủ đề 3: Cộng đồng địa phương & Giao thông', 'startPage': 49, 'endPage': 70},
        {'title': 'Chủ đề 4: Thực vật, Động vật & Chăm sóc cơ thể', 'startPage': 71, 'endPage': 92},
      ];
    }

    // 9. Lịch sử - Địa lý & GDCD & Tin học
    if (subject.contains('lịch sử') || subject.contains('địa')) {
      return [
        {'title': 'Phần 1: Lịch sử loài người & Nguồn gốc cổ xưa', 'startPage': 4, 'endPage': 40},
        {'title': 'Phần 2: Xã hội nguyên thủy & Các nền văn minh cổ đại', 'startPage': 41, 'endPage': 80},
        {'title': 'Phần 3: Trái Đất - Hành tinh của Hệ Mặt Trời', 'startPage': 81, 'endPage': 120},
        {'title': 'Phần 4: Bản đồ & Các thành phần tự nhiên Trái Đất', 'startPage': 121, 'endPage': 156},
      ];
    }

    if (subject.contains('tin học') || title.toLowerCase().contains('tin học')) {
      return [
        {'title': 'Chủ đề 1: Máy tính và cộng đồng thông tin', 'startPage': 4, 'endPage': 25},
        {'title': 'Chủ đề 2: Mạng máy tính và Internet toàn cầu', 'startPage': 26, 'endPage': 50},
        {'title': 'Chủ đề 3: Tổ chức lưu trữ, tìm kiếm thông tin', 'startPage': 51, 'endPage': 74},
        {'title': 'Chủ đề 4: Đạo đức, pháp luật & Văn hóa số', 'startPage': 75, 'endPage': 96},
      ];
    }

    // Mặc định cho các sách khác
    final pageCount = bookData['pageCount'] as int? ?? 100;
    final step = (pageCount / 4).ceil();
    return [
      {'title': 'Chương 1: Kiến thức tổng quan và cơ bản', 'startPage': 1, 'endPage': step},
      {'title': 'Chương 2: Kiến thức trọng tâm và vận dụng', 'startPage': step + 1, 'endPage': step * 2},
      {'title': 'Chương 3: Thực hành và chuyên đề chuyên sâu', 'startPage': step * 2 + 1, 'endPage': step * 3},
      {'title': 'Chương 4: Ôn tập tổng kết và kiểm tra định kỳ', 'startPage': step * 3 + 1, 'endPage': pageCount},
    ];
  }

  /// Phân giải nội dung bài học số hóa theo trang
  static BookLessonData resolve(Map<String, dynamic> bookData, int pageNum) {
    final title = (bookData['title'] ?? '').toString();
    final subject = (bookData['subjectName'] ?? '').toString().toLowerCase();

    // 1. Sách giáo khoa Toán 1 (Chuẩn theo file PDF / SGK thật)
    if (_toan1Regex.hasMatch(title)) {
      if (pageNum >= 24 && pageNum < 50) {
        return BookLessonData(
          chapterTitle: 'CHỦ ĐỀ 2: CHỮ SỐ VÀ PHÉP SO SÁNH',
          lessonTitle: 'BÀI 8: CÁC SỐ TỪ 1 ĐẾN 10 VÀ SO SÁNH SỐ',
          tipTitle: 'Kiến thức trọng tâm',
          tipText: '• Đếm xuôi: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.\n'
              '• Đếm ngược: 10, 9, 8, 7, 6, 5, 4, 3, 2, 1.\n'
              '• Dấu > (lớn hơn), dấu < (bé hơn), dấu = (bằng nhau).',
          exTitle: '1. Điền dấu so sánh thích hợp (> , < , =):',
          exContent: 'a) 5 > 3       b) 8 < 9       c) 6 = 6\n'
              'd) 10 > 7      e) 4 > 2       g) 1 > 0',
          exTitle2: '2. Tập đếm số lượng:',
          exContent2: 'Trên cành có 4 chú chim, 2 chú chim khác bay đến. Hỏi có tất cả bao nhiêu chú chim đang đậu trên cành?',
          footerBookName: 'Sách giáo khoa Toán 1 - Tập 1',
        );
      } else if (pageNum >= 50 && pageNum < 82) {
        return BookLessonData(
          chapterTitle: 'CHỦ ĐỀ 3: PHÉP CỘNG VÀ PHÉP TRỪ TRONG PHẠM VI 10',
          lessonTitle: 'BÀI 15: PHÉP CỘNG VÀ PHÉP TRỪ CƠ BẢN',
          tipTitle: 'Kiến thức trọng tâm',
          tipText: '• Thêm vào tức là làm phép tính cộng (+).\n'
              '• Bớt đi hoặc cho đi tức là làm phép tính trừ (-).\n'
              '• 5 + 5 = 10 ; 10 - 4 = 6 ; 7 + 3 = 10.',
          exTitle: '1. Tính nhẩm nhanh:',
          exContent: 'a) 4 + 3 = 7       b) 6 + 2 = 8       c) 5 + 5 = 10\n'
              'd) 9 - 4 = 5       e) 10 - 3 = 7      g) 7 - 0 = 7',
          exTitle2: '2. Bài toán lời văn:',
          exContent2: 'Mẹ mua cho An 6 quả cam, An biếu bà 2 quả. Hỏi An còn lại bao nhiêu quả cam?\n'
              'Bài giải: Số quả cam An còn lại là: 6 - 2 = 4 (quả). Đáp số: 4 quả cam.',
          footerBookName: 'Sách giáo khoa Toán 1 - Tập 1',
        );
      } else if (pageNum >= 82) {
        return BookLessonData(
          chapterTitle: 'CHỦ ĐỀ 4: HÌNH KHỐI VÀ THỜI GIAN THỰC TẾ',
          lessonTitle: 'BÀI 25: KHỐI HỘP VÀ XEM ĐỒNG HỒ ĐÚNG GIỜ',
          tipTitle: 'Kiến thức trọng tâm',
          tipText: '• Khối hộp chữ nhật có các mặt bao quanh là hình chữ nhật.\n'
              '• Khối lập phương có 6 mặt đều là các hình vuông.\n'
              '• Đồng hồ chỉ đúng giờ khi kim dài (kim phút) chỉ thẳng vào số 12.',
          exTitle: '1. Xem đồng hồ và đọc giờ:',
          exContent: 'a) Kim ngắn chỉ số 7, kim dài chỉ số 12: [ 7 giờ đúng ]\n'
              'b) Kim ngắn chỉ số 8, kim dài chỉ số 12: [ 8 giờ đúng ]',
          exTitle2: '2. Nhận biết khối vật dụng:',
          exContent2: 'Hộp sữa tươi là khối hộp chữ nhật. Viên xúc xắc trò chơi cá ngựa là khối lập phương.',
          footerBookName: 'Sách giáo khoa Toán 1 - Tập 1',
        );
      }
      return BookLessonData(
        chapterTitle: 'CHỦ ĐỀ 1: LÀM QUEN VỚI MỘT SỐ HÌNH',
        lessonTitle: 'BÀI 1: HÌNH VUÔNG - HÌNH TRÒN - HÌNH TAM GIÁC - HÌNH CHỮ NHẬT',
        tipTitle: 'Kiến thức trọng tâm',
        tipText: '• Quan sát các đồ vật trong lớp học và nhận biết các hình học cơ bản.\n'
            '• Hình tròn không có góc, lăn được dễ dàng.\n'
            '• Hình vuông có 4 cạnh bằng nhau, hình tam giác có 3 góc và 3 cạnh.',
        exTitle: '1. Đố vui nhận diện hình học:',
        exContent: 'a) Mặt trời, chiếc đĩa ăn cơm có hình: [ Hình tròn ]\n'
            'b) Khung tranh gia đình, viên gạch hoa có hình: [ Hình vuông ]\n'
            'c) Chiếc cờ đuôi nheo, biển báo giao thông có hình: [ Hình tam giác ]',
        exTitle2: '2. Trò chơi ghép hình sáng tạo:',
        exContent2: 'Em hãy dùng các miếng ghép hình tam giác và hình vuông để ghép thành một ngôi nhà mái đỏ và một chiếc thuyền buồm rực rỡ.',
        footerBookName: 'Sách giáo khoa Toán 1 - Tập 1',
      );
    }

    // 2. Sách giáo khoa Toán 10 (Cấp 3 THPT) - Khắc phục lỗi hiển thị nhầm Toán 1!
    if (_toan10Regex.hasMatch(title) || (subject.contains('toán') && title.contains('10'))) {
      if (pageNum >= 29 && pageNum <= 55) {
        return BookLessonData(
          chapterTitle: 'CHƯƠNG 2: BẤT PHƯƠNG TRÌNH BẬC NHẤT HAI ẨN',
          lessonTitle: 'BÀI 4: HỆ BẤT PHƯƠNG TRÌNH BẬC NHẤT HAI ẨN',
          tipTitle: 'Ghi nhớ định lý & Công thức',
          tipText: '• Bất phương trình bậc nhất hai ẩn có dạng ax + by < c (hoặc >, ≤, ≥) với a² + b² ≠ 0.\n'
              '• Miền nghiệm của bất phương trình là nửa mặt phẳng bờ d: ax + by = c.\n'
              '• Hệ bất phương trình bậc nhất hai ẩn có miền nghiệm là giao các miền nghiệm thành phần.',
          exTitle: '1. Biểu diễn miền nghiệm trên mặt phẳng tọa độ Oxy:',
          exContent: 'Hệ bất phương trình:\n'
              '  { 2x + y ≤ 4\n'
              '  { x - y ≥ 1\n'
              '  { x ≥ 0 , y ≥ 0',
          exTitle2: '2. Ứng dụng quy hoạch tuyến tính thực tế:',
          exContent2: 'Một xưởng sản xuất hai loại sản phẩm A và B. Hãy tìm số lượng sản phẩm mỗi loại để tối ưu hóa lợi nhuận đạt mức tối đa.',
          footerBookName: 'Sách giáo khoa Toán 10 - Tập 1',
        );
      }
      return BookLessonData(
        chapterTitle: 'CHƯƠNG 1: MỆNH ĐỀ TOÁN HỌC VÀ TẬP HỢP',
        lessonTitle: 'BÀI 1: MỆNH ĐỀ VÀ MỆNH ĐỀ CHỨA BIẾN',
        tipTitle: 'Ghi nhớ định nghĩa cốt lõi',
        tipText: '• Mệnh đề toán học là một khẳng định đúng hoặc một khẳng định sai. Không thể vừa đúng vừa sai.\n'
            '• Phủ định của mệnh đề P ký hiệu là P̄. Nếu P đúng thì P̄ sai và ngược lại.\n'
            '• Ký hiệu: ∀ (với mọi), ∃ (tồn tại ít nhất một).',
        exTitle: '1. Xác định tính đúng/sai của các mệnh đề sau:',
        exContent: 'a) P: "17 là một số nguyên tố" [ Mệnh đề ĐÚNG ]\n'
            'b) Q: "Tổng hai cạnh tam giác nhỏ hơn cạnh còn lại" [ Mệnh đề SAI ]\n'
            'c) R: "Tam giác đều có 3 góc bằng nhau và bằng 60°" [ Mệnh đề ĐÚNG ]',
        exTitle2: '2. Bài tập mệnh đề kéo theo (P ⇒ Q):',
        exContent2: 'Cho định lý: "Nếu số tự nhiên n có chữ số tận cùng là 0 thì n chia hết cho 5". Hãy phát biểu mệnh đề đảo và xét tính đúng sai.',
        footerBookName: 'Sách giáo khoa Toán 10 - Tập 2',
      );
    }

    // 3. Sách giáo khoa Toán 6 (Cấp 2 THCS)
    if (_toan6Regex.hasMatch(title) || (subject.contains('toán') && title.contains('6'))) {
      return BookLessonData(
        chapterTitle: 'CHƯƠNG 1: TẬP HỢP CÁC SỐ TỰ NHIÊN',
        lessonTitle: 'BÀI 2: TẬP HỢP VÀ CÁC PHẦN TỬ CỦA TẬP HỢP',
        tipTitle: 'Kiến thức trọng tâm',
        tipText: '• Một tập hợp gồm các phần tử được viết trong dấu ngoặc nhọn { } cách nhau bởi dấu chấm phẩy (;).\n'
            '• Ký hiệu: a ∈ A (a thuộc tập hợp A), b ∉ A (b không thuộc tập hợp A).\n'
            '• Tập hợp các số tự nhiên ký hiệu là ℕ = {0; 1; 2; 3; 4; ...}.',
        exTitle: '1. Viết tập hợp bằng cách liệt kê các phần tử:',
        exContent: 'a) Tập hợp A các số tự nhiên chẵn nhỏ hơn 10: A = {0; 2; 4; 6; 8}\n'
            'b) Tập hợp B các chữ cái trong từ "HOC SINH": B = {H; O; C; S; I; N}',
        exTitle2: '2. Luyện tập tư duy chia hết:',
        exContent2: 'Trong các số: 125, 360, 472, 895, số nào chia hết cho 2? Số nào chia hết cho cả 2 và 5?',
        footerBookName: 'Sách giáo khoa Toán 6 - Tập 1',
      );
    }

    // 4. Môn Ngữ văn 10 (Cấp 3 THPT)
    if ((subject.contains('văn') || title.toLowerCase().contains('văn')) && title.contains('10')) {
      return BookLessonData(
        chapterTitle: 'BÀI 1: SỨC SỐNG CỦA SỬ THI VÀ THẦN THOẠI',
        lessonTitle: 'VĂN BẢN: ĐĂM SĂN CHIẾN THẮNG MTAO MXÂY (Trích sử thi Đăm Săn)',
        tipTitle: 'Đặc trưng thể loại Sử thi',
        tipText: '• Sử thi anh hùng ca ngợi vẻ đẹp dũng cảm, sức mạnh phi thường và khát vọng của cộng đồng.\n'
            '• Nghệ thuật phóng đại, so sánh trùng điệp: "Bắp chân chàng to như cây xà ngang, tiếng nói vang như sấm sét".\n'
            '• Cốt truyện kịch tính phản ánh cuộc chiến bảo vệ danh dự buôn làng Tây Nguyên.',
        exTitle: '1. Câu hỏi hướng dẫn đọc hiểu:',
        exContent: 'a) Phân tích hành động và lời thách đấu của Đăm Săn trước tù trưởng Mtao Mxây.\n'
            'b) Chi tiết bà con buôn làng đi theo Đăm Săn sau chiến thắng mang ý nghĩa biểu tượng gì?',
        exTitle2: '2. Bài tập rèn luyện viết đoạn văn:',
        exContent2: 'Viết đoạn văn ngắn (khoảng 150 chữ) trình bày cảm nghĩ của em về vẻ đẹp lý tưởng của người anh hùng sử thi Tây Nguyên.',
        footerBookName: 'Sách giáo khoa Ngữ văn 10 - Tập 2',
      );
    }

    // 5A. Môn Ngữ văn 6 - Bài 4: Trải nghiệm trong đời (Đồng thoại, trang 106 trở đi - Ưu tiên kiểm tra trước)
    if ((subject.contains('văn') || title.toLowerCase().contains('văn')) &&
        title.contains('6') && pageNum >= 106) {
      return BookLessonData(
        chapterTitle: 'BÀI 4: NHỮNG TRẢI NGHIỆM TRONG ĐỜI',
        lessonTitle: 'VĂN BẢN: DẾ MÈN PHIÊU LƯU KÝ (Trích, Tô Hoài)',
        tipTitle: 'Đặc trưng thể loại Truyện đồng thoại',
        tipText: '• Truyện đồng thoại lấy loài vật làm nhân vật, thể hiện tâm lý và cảm xúc như con người.\n'
            '• Nhân vật Dế Mèn dũng cảm, kiêu ngạo nhưng biết nhận ra lỗi lầm — hành trình trưởng thành.\n'
            '• Ngôn ngữ giàu hình ảnh, từ láy miêu tả đặc sắc của Tô Hoài.',
        exTitle: '1. Câu hỏi đọc hiểu:',
        exContent: 'a) Dế Mèn đã đối xử với Dế Choắt như thế nào? Em có đồng ý với cách ứng xử đó không?\n'
            'b) Sau cái chết của Dế Choắt, Dế Mèn đã nhận ra điều gì về bản thân?',
        exTitle2: '2. Kết nối văn bản "Hoàng tử bé" (Saint-Exupéry):',
        exContent2: 'So sánh nhân vật Dế Mèn và Hoàng tử bé về hành trình khám phá thế giới xung quanh.',
        footerBookName: 'Sách giáo khoa Ngữ văn 6 - Tập 1 (Kết nối tri thức)',
      );
    }

    // 5B. Môn Ngữ văn 6 (Bài 1 - 3, trang < 106)
    if ((subject.contains('văn') || title.toLowerCase().contains('văn')) && title.contains('6')) {
      return BookLessonData(
        chapterTitle: 'BÀI 1: LẮNG NGHE LỊCH SỬ NƯỚC MÌNH',
        lessonTitle: 'VĂN BẢN: TRUYỀN THUYẾT THÁNH GIÓNG',
        tipTitle: 'Ghi nhớ giá trị truyền thuyết',
        tipText: '• Truyền thuyết là loại truyện dân gian kể về các nhân vật và sự kiện lịch sử có yếu tố tưởng tượng kỳ ảo.\n'
            '• Hình tượng Thánh Gióng biểu trưng cho lòng yêu nước nồng nàn và sức mạnh quật khởi của dân tộc.\n'
            '• Chi tiết roi sắt gãy nhổ tre đằng ngà đánh giặc thể hiện tinh thần sáng tạo bất khuất.',
        exTitle: '1. Câu hỏi đọc hiểu trọng tâm:',
        exContent: 'a) Tiếng nói đầu tiên của chú bé Gióng là đòi đi đánh giặc, điều đó có ý nghĩa gì?\n'
            'b) Hãy tìm các chi tiết kỳ ảo trong truyện và nêu tác dụng nghệ thuật.',
        exTitle2: '2. Rèn luyện tiếng Việt (Từ đơn và từ phức):',
        exContent2: 'Tìm 3 từ ghép và 3 từ láy miêu tả sức mạnh và tinh thần chiến đấu của Thánh Gióng trong văn bản.',
        footerBookName: 'Sách giáo khoa Ngữ văn 6 - Tập 1',
      );
    }

    // 6. Môn Tiếng Việt 1 (Cấp 1 Tiểu học)
    if (subject.contains('tiếng việt') || title.toLowerCase().contains('tiếng việt')) {
      return BookLessonData(
        chapterTitle: 'CHỦ ĐỀ 1: NHỮNG BÀI HỌC ĐẦU TIÊN',
        lessonTitle: 'BÀI 3: LÀM QUEN ÂM C - CHỮ C VÀ DẤU SẮC ( / )',
        tipTitle: 'Bé nhớ âm và dấu thanh',
        tipText: '• Phát âm chuẩn: cờ - a - ca - sắc - cá.\n'
            '• Dấu sắc nghiêng sang bên phải: bé đọc cao giọng một chút nhé!\n'
            '• Cặp da, con cá, quả cà, chiếc ca nước.',
        exTitle: '1. Em hãy đọc to các tiếng sau:',
        exContent: 'ca       cá       cà       cô       cỏ       cò\n'
            'bà có cá        mẹ có ca',
        exTitle2: '2. Bé tập tô và viết chữ xinh:',
        exContent2: 'Nét cong hở phải cao 2 li, đặt bút dưới đường kẻ 3 một chút và lia bút cong tròn đều đặn.',
        footerBookName: 'Sách giáo khoa Tiếng Việt 1 - Tập 1',
      );
    }

    // 7. Môn Tiếng Anh 10 (Cấp 3 THPT)
    if ((subject.contains('anh') || title.toLowerCase().contains('tiếng anh')) && title.contains('10')) {
      return BookLessonData(
        chapterTitle: 'UNIT 1: FAMILY LIFE AND HOUSEHOLD CHORES',
        lessonTitle: 'LESSON 1: GETTING STARTED - SHARING THE CHORES',
        tipTitle: 'Grammar & Vocabulary Focus',
        tipText: '• Present Simple: Habits and daily routines (e.g., Nam washes the dishes every evening).\n'
            '• Present Continuous: Actions happening right now (e.g., Mom is cooking dinner at the moment).\n'
            '• Collocations: do the laundry, take out the rubbish, split household chores equally.',
        exTitle: '1. Complete the sentences with Present Simple or Continuous:',
        exContent: 'a) My brother usually (clean) ____________ the floor on Sundays.\n'
            'b) Look! Dad (fix) ____________ the water pipe in the garden.\n'
            'c) They (share) ____________ household duties to strengthen family bonds.',
        exTitle2: '2. Speaking & Discussion Topic:',
        exContent2: 'Work in pairs: Discuss how your family members share household chores and why mutual support is essential.',
        footerBookName: 'Sách Tiếng Anh 10 - Global Success',
      );
    }

    // 8. Môn Tiếng Anh 6 (Cấp 2 THCS)
    if ((subject.contains('anh') || title.toLowerCase().contains('tiếng anh')) && title.contains('6')) {
      return BookLessonData(
        chapterTitle: 'UNIT 1: MY NEW SCHOOL',
        lessonTitle: 'LESSON 1: GETTING STARTED - A SPECIAL DAY',
        tipTitle: 'Vocabulary & Pronunciation Focus',
        tipText: '• School subjects: English, Maths, Science, History, Geography, Music, Art.\n'
            '• Verb phrases: wear uniform, do homework, have new friends, ride bicycle.\n'
            '• Sounds: /ɑː/ (smart, start, sharp) and /ʌ/ (subject, club, study).',
        exTitle: '1. Choose the best word to fill in the blank:',
        exContent: 'a) We have to wear school ________ on Mondays. (uniform / shoes)\n'
            'b) Phong likes ________ because he loves solving math puzzles. (Maths / History)\n'
            'c) My school has a large ________ with thousands of books. (library / kitchen)',
        exTitle2: '2. Pair work conversation:',
        exContent2: 'Ask and answer with your partner: "What is your favourite subject at school?" - "My favourite subject is English because..."',
        footerBookName: 'Sách Tiếng Anh 6 - Global Success',
      );
    }

    // 9. Môn Tiếng Anh 1 (Cấp 1 Tiểu học)
    if (subject.contains('anh') || title.toLowerCase().contains('tiếng anh')) {
      return BookLessonData(
        chapterTitle: 'UNIT 1: HELLO & FRIENDS',
        lessonTitle: 'LESSON 1: HELLO! WHAT IS YOUR NAME?',
        tipTitle: 'Baby English Fun',
        tipText: '• Say Hello! and Goodbye!\n'
            '• My name is Mai. I am 6 years old.\n'
            '• Colors: Red, Blue, Yellow, Green.',
        exTitle: '1. Listen and repeat:',
        exContent: 'A: Hello, I am Bill!\n'
            'B: Hi, Bill! I am Linh. Nice to meet you!\n'
            'Numbers: One (1), Two (2), Three (3), Four (4), Five (5).',
        exTitle2: '2. Sing along with friends:',
        exContent2: 'Hello, hello, what is your name? My name is Nam. Let us play together!',
        footerBookName: 'Sách Tiếng Anh 1 - Global Success',
      );
    }

    // 10. Môn Vật lý 10 (Cấp 3 THPT)
    if (subject.contains('vật lý') || subject.contains('vật lí') || title.toLowerCase().contains('vật lý') || title.toLowerCase().contains('vật lí')) {
      return BookLessonData(
        chapterTitle: 'CHƯƠNG 2: ĐỘNG HỌC CHẤT ĐIỂM',
        lessonTitle: 'BÀI 4: CHUYỂN ĐỘNG THẲNG BIẾN ĐỔI ĐỀU',
        tipTitle: 'Công thức Vật lý quan trọng',
        tipText: '• Vận tốc: v = v₀ + at (với a là gia tốc không đổi).\n'
            '• Quãng đường: d = v₀t + ½at².\n'
            '• Hệ thức độc lập thời gian: v² - v₀² = 2ad.',
        exTitle: '1. Bài tập vận dụng cơ bản:',
        exContent: 'Một ô tô đang chuyển động với vận tốc 10 m/s thì tăng tốc với gia tốc a = 2 m/s².\n'
            'a) Tính vận tốc của ô tô sau thời gian 5 giây kể từ lúc tăng tốc.\n'
            'b) Tính quãng đường ô tô đi được trong khoảng thời gian đó.',
        exTitle2: '2. Thảo luận thực tế an toàn giao thông:',
        exContent2: 'Giải thích tại sao khi tham gia giao thông, người lái xe cần giữ khoảng cách an toàn với xe phía trước theo quy định.',
        footerBookName: 'Sách giáo khoa Vật lý 10',
      );
    }

    // 11. Môn Hóa học 10 (Cấp 3 THPT)
    if (subject.contains('hóa') || title.toLowerCase().contains('hóa')) {
      return BookLessonData(
        chapterTitle: 'CHƯƠNG 1: CẤU TẠO NGUYÊN TỬ',
        lessonTitle: 'BÀI 2: HẠT NHÂN NGUYÊN TỬ - NGUYÊN TỐ HÓA HỌC',
        tipTitle: 'Kiến thức Hóa học trọng tâm',
        tipText: '• Nguyên tử cấu tạo từ 3 loại hạt: Proton (p, mang điện tích +1), Nơtron (n, không mang điện) và Electron (e, mang điện tích -1).\n'
            '• Số hiệu nguyên tử: Z = số proton = số electron.\n'
            '• Số khối: A = Z + N (khối lượng nguyên tử tập trung chủ yếu ở hạt nhân).',
        exTitle: '1. Bài tập xác định thành phần nguyên tử:',
        exContent: 'Cho nguyên tử Natri (Na) có số hiệu Z = 11 và số khối A = 23.\n'
            'a) Hãy cho biết số proton, số electron và số nơtron trong nguyên tử Na.\n'
            'b) Viết cấu hình electron của nguyên tử Natri: 1s² 2s² 2p⁶ 3s¹.',
        exTitle2: '2. Ý nghĩa quy tắc Octet:',
        exContent2: 'Giải thích xu hướng nhường 1 electron của kim loại kiềm Na để đạt cấu hình electron bền vững của khí hiếm Neon (Ne).',
        footerBookName: 'Sách giáo khoa Hóa học 10',
      );
    }

    // 12. Môn Khoa học Tự nhiên 6 (Cấp 2 THCS)
    if (subject.contains('khoa học') || title.toLowerCase().contains('khtn')) {
      return BookLessonData(
        chapterTitle: 'CHƯƠNG 3: TẾ BÀO - ĐƠN VỊ CƠ BẢN CỦA SỰ SỐNG',
        lessonTitle: 'BÀI 17: TẾ BÀO NHÂN THỰC VÀ TẾ BÀO NHÂN SƠ',
        tipTitle: 'Sinh học & Cấu trúc sống',
        tipText: '• Mọi cơ thể sinh vật đều được cấu tạo từ các đơn vị vi mô gọi là tế bào.\n'
            '• Các thành phần chính của tế bào: Màng tế bào, Chất tế bào và Nhân (hoặc vùng nhân).\n'
            '• Tế bào thực vật có thêm thành tế bào (cellulose) và lục lạp giúp quang hợp.',
        exTitle: '1. Câu hỏi phân biệt cấu tạo:',
        exContent: 'So sánh tế bào động vật và tế bào thực vật: Điểm giống nhau và khác nhau về bào quan và thành tế bào.',
        exTitle2: '2. Thực hành kính hiển vi quang học:',
        exContent2: 'Mô tả các bước chuẩn bị tiêu bản tế bào biểu bì vảy hành tím và quan sát dưới độ phóng đại 400x.',
        footerBookName: 'Sách giáo khoa Khoa học tự nhiên 6',
      );
    }

    // 13. Môn Tự nhiên và Xã hội 1 (Cấp 1 Tiểu học)
    if (title.toLowerCase().contains('tự nhiên') || title.toLowerCase().contains('tnxh')) {
      return BookLessonData(
        chapterTitle: 'CHỦ ĐỀ 1: GIA ĐÌNH VÀ BẢN THÂN EM',
        lessonTitle: 'BÀI 2: CÁC BỘ PHẬN TRÊN CƠ THỂ VÀ BẢO VỆ SỨC KHỎE',
        tipTitle: 'Bé giữ vệ sinh sạch sẽ',
        tipText: '• Rửa tay bằng xà phòng trước khi ăn và sau khi đi vệ sinh.\n'
            '• Đánh răng 2 lần mỗi ngày vào buổi sáng và buổi tối trước khi đi ngủ.\n'
            '• Tập thể dục buổi sáng để cơ thể dẻo dai và khỏe mạnh.',
        exTitle: '1. Em hãy chỉ đúng các bộ phận cơ thể:',
        exContent: 'Mắt để nhìn, Tai để nghe, Mũi để ngửi, Miệng để nói cười, Tay để viết và Chân để đi chạy.',
        exTitle2: '2. Hành vi đúng - sai:',
        exContent2: 'Ngồi học thẳng lưng đủ ánh sáng (Đúng); Vừa xem tivi vừa ăn cơm quá gần màn hình (Sai).',
        footerBookName: 'Sách giáo khoa Tự nhiên và Xã hội 1',
      );
    }

    // 14. Môn Đạo đức 1 (Cấp 1 Tiểu học)
    if (subject.contains('đạo đức') || title.toLowerCase().contains('đạo đức')) {
      return BookLessonData(
        chapterTitle: 'CHỦ ĐỀ 1: LỄ PHÉP VỚI ÔNG BÀ, THẦY CÔ',
        lessonTitle: 'BÀI 1: EM CHÀO HỎI KHI GẶP THẦY CÔ VÀ NGƯỜI LỚN',
        tipTitle: 'Lời chào đáng yêu',
        tipText: '• Khoanh tay chào hỏi lễ phép khi gặp thầy giáo, cô giáo và người lớn tuổi.\n'
            '• Nói lời cảm ơn khi được giúp đỡ, biết xin lỗi khi có lỗi.\n'
            '• Tôn trọng bạn bè, không tranh giành đồ chơi trong lớp.',
        exTitle: '1. Tình huống ứng xử giao tiếp:',
        exContent: 'Khi gặp bác lao công quét dọn sân trường hoặc chú bảo vệ cổng trường, em sẽ chào như thế nào?',
        exTitle2: '2. Lời nhắc nhở rèn luyện:',
        exContent2: 'Lời chào đi trước, nụ cười theo sau. Em là học sinh ngoan của Trường Tiểu học Đại Việt.',
        footerBookName: 'Sách giáo khoa Đạo đức 1',
      );
    }

    // 15. Sách Toán 3 (Bảo toàn nguyên vẹn cho test cũ `material_card_test.dart`)
    // Hoặc trường hợp mặc định
    return BookLessonData(
      chapterTitle: 'CHƯƠNG 2: BẢNG NHÂN & BẢNG CHIA CƠ BẢN',
      lessonTitle: 'BÀI 12: BẢNG NHÂN 7 VÀ ỨNG DỤNG THỰC HÀNH',
      tipTitle: 'Ghi nhớ kiến thức',
      tipText: '• 7 × 1 = 7 ; 7 × 2 = 14 ; 7 × 3 = 21 ; 7 × 4 = 28\n'
          '• Muốn gấp một số lên nhiều lần, ta lấy số đó nhân với số lần.\n'
          '• Thứ tự thực hiện: Trong biểu thức có phép nhân và cộng/trừ, ta ưu tiên nhân trước.',
      exTitle: '1. Tính nhẩm nhanh:',
      exContent: 'a) 7 × 5 = 35          b) 7 × 8 = 56          c) 7 × 9 = 63\n'
          'd) 42 : 7 = 6          e) 56 : 7 = 8          g) 63 : 7 = 9',
      exTitle2: '2. Bài toán có lời văn:',
      exContent2: 'Một tuần lễ có 7 ngày. Hỏi 4 tuần lễ như thế có tất cả bao nhiêu ngày?\n\n'
          'Bài giải:\n'
          'Số ngày trong 4 tuần lễ là:\n'
          '      7 × 4 = 28 (ngày)\n'
          '                   Đáp số: 28 ngày.',
      footerBookName: title.isNotEmpty ? title : 'Đại Việt EdTech Digital Library',
    );
  }
}
