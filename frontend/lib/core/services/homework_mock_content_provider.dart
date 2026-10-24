/// Bộ cung cấp dữ liệu giả lập (Mock Content Provider) chuẩn hóa cho Bài tập học sinh.
/// 
/// Đảm bảo nội dung câu hỏi, trắc nghiệm, tự luận, điểm số và lời phê
/// đồng bộ 100% với cấp học (Cấp 1 Tiểu học, Cấp 2 THCS, Cấp 3 THPT),
/// môn học và tiêu đề hiển thị trên Dashboard.
class HomeworkMockContentProvider {
  HomeworkMockContentProvider._();

  /// Trả về đề bài tập để học sinh làm bài (StudentTakeHomeworkScreen).
  static Map<String, dynamic> getAssignmentForTaking(int assignmentId) {
    switch (assignmentId) {
      // ==========================================
      // CẤP 1 (TIỂU HỌC - LỚP 1)
      // ==========================================
      case 101:
        return {
          'assignmentId': 101,
          'submissionId': 10100,
          'homeworkTitle': 'Bài tập tuần 5: Đếm và so sánh các số trong phạm vi 10',
          'subjectName': 'Toán',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 1011,
              'content': 'Có 5 chú thỏ trắng đang ăn cà rốt, thêm 2 chú thỏ chạy tới. Hỏi có tất cả bao nhiêu chú thỏ?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 10111, 'content': '6 chú thỏ'},
                {'id': 10112, 'content': '7 chú thỏ'},
                {'id': 10113, 'content': '8 chú thỏ'},
                {'id': 10114, 'content': '5 chú thỏ'},
              ],
            },
            {
              'id': 1012,
              'content': 'Số nào sau đây lớn hơn số 7 và nhỏ hơn số 10?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 10121, 'content': 'Số 6'},
                {'id': 10122, 'content': 'Số 7'},
                {'id': 10123, 'content': 'Số 8'},
                {'id': 10124, 'content': 'Số 10'},
              ],
            },
            {
              'id': 1013,
              'content': 'Phép so sánh: 9 > 6 là Đúng hay Sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 10131, 'content': 'Đúng'},
                {'id': 10132, 'content': 'Sai'},
              ],
            },
            {
              'id': 1014,
              'content': 'Em hãy điền số thích hợp vào chỗ trống để hoàn thành dãy số: 1, 2, 3, [..], 5, [..], 7, 8, 9, 10.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };

      case 102:
        return {
          'assignmentId': 102,
          'submissionId': 10200,
          'homeworkTitle': 'Luyện viết chữ đẹp nét cơ bản và chữ cái a, b, c',
          'subjectName': 'Tiếng Việt',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 1021,
              'content': 'Chữ cái đầu tiên trong bảng chữ cái tiếng Việt là chữ nào?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 10211, 'content': 'Chữ b'},
                {'id': 10212, 'content': 'Chữ a'},
                {'id': 10213, 'content': 'Chữ c'},
                {'id': 10214, 'content': 'Chữ d'},
              ],
            },
            {
              'id': 1022,
              'content': 'Chọn những tiếng có chứa âm "c" trong các từ sau:',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 10221, 'content': 'cá'},
                {'id': 10222, 'content': 'cờ'},
                {'id': 10223, 'content': 'ba'},
                {'id': 10224, 'content': 'cô'},
              ],
            },
            {
              'id': 1023,
              'content': 'Nét cong kín là nét viết chữ cái "o" đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 10231, 'content': 'Đúng'},
                {'id': 10232, 'content': 'Sai'},
              ],
            },
            {
              'id': 1024,
              'content': 'Em hãy tìm và viết lại 2 từ ngữ chỉ con vật bắt đầu bằng chữ cái "c" mà em biết.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };

      case 103:
        return {
          'assignmentId': 103,
          'submissionId': 10300,
          'homeworkTitle': 'Unit 1: Family - Tô màu và đọc tên các thành viên trong gia đình',
          'subjectName': 'Tiếng Anh',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 1031,
              'content': 'Từ nào trong tiếng Anh có nghĩa là "Mẹ"?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 10311, 'content': 'Father'},
                {'id': 10312, 'content': 'Mother'},
                {'id': 10313, 'content': 'Brother'},
                {'id': 10314, 'content': 'Sister'},
              ],
            },
            {
              'id': 1032,
              'content': 'Chọn các từ chỉ thành viên trong gia đình:',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 10321, 'content': 'Father'},
                {'id': 10322, 'content': 'Sister'},
                {'id': 10323, 'content': 'Apple'},
                {'id': 10324, 'content': 'Brother'},
              ],
            },
            {
              'id': 1033,
              'content': '"Baby" trong tiếng Anh có nghĩa là em bé đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 10331, 'content': 'Đúng'},
                {'id': 10332, 'content': 'Sai'},
              ],
            },
            {
              'id': 1034,
              'content': 'Write the answer: How many people are there in your family? (Gia đình em có mấy người?)',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };

      case 104:
        return {
          'assignmentId': 104,
          'submissionId': 10400,
          'homeworkTitle': 'Quan sát và nhận biết các bộ phận trên cơ thể người',
          'subjectName': 'Tự nhiên và Xã hội',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 1041,
              'content': 'Bộ phận nào trên cơ thể giúp chúng ta nhìn thấy màu sắc của cảnh vật xung quanh?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 10411, 'content': 'Đôi tai'},
                {'id': 10412, 'content': 'Đôi mắt'},
                {'id': 10413, 'content': 'Cái mũi'},
                {'id': 10414, 'content': 'Đôi bàn tay'},
              ],
            },
            {
              'id': 1042,
              'content': 'Chọn những thói quen tốt giúp giữ gìn vệ sinh thân thể:',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 10421, 'content': 'Rửa tay bằng xà phòng trước khi ăn'},
                {'id': 10422, 'content': 'Đánh răng sáng và tối trước khi đi ngủ'},
                {'id': 10423, 'content': 'Đi chân đất trên nền đất bẩn'},
                {'id': 10424, 'content': 'Tắm rửa sạch sẽ mỗi ngày'},
              ],
            },
            {
              'id': 1043,
              'content': 'Rửa tay sạch bằng xà phòng giúp phòng tránh vi khuẩn gây bệnh đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 10431, 'content': 'Đúng'},
                {'id': 10432, 'content': 'Sai'},
              ],
            },
            {
              'id': 1044,
              'content': 'Em cần làm những gì để bảo vệ đôi mắt luôn sáng và khỏe mạnh khi học bài?',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };

      // ==========================================
      // CẤP 2 (THCS - LỚP 6)
      // ==========================================
      case 201:
        return {
          'assignmentId': 201,
          'submissionId': 20100,
          'homeworkTitle': 'Tập hợp các số tự nhiên và phép tính lũy thừa cơ bản',
          'subjectName': 'Toán',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 2011,
              'content': 'Giá trị của lũy thừa 2⁴ bằng bao nhiêu?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 20111, 'content': '8'},
                {'id': 20112, 'content': '16'},
                {'id': 20113, 'content': '12'},
                {'id': 20114, 'content': '32'},
              ],
            },
            {
              'id': 2012,
              'content': 'Cho tập hợp A = {x ∈ ℕ | 3 < x ≤ 7}. Những phần tử nào sau đây thuộc tập hợp A?',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 20121, 'content': '4'},
                {'id': 20122, 'content': '5'},
                {'id': 20123, 'content': '3'},
                {'id': 20124, 'content': '7'},
              ],
            },
            {
              'id': 2013,
              'content': 'Số 0 là số tự nhiên nhỏ nhất đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 20131, 'content': 'Đúng'},
                {'id': 20132, 'content': 'Sai'},
              ],
            },
            {
              'id': 2014,
              'content': 'Tính giá trị của biểu thức: A = 3² × 5 - 2³ × 4. Em hãy trình bày chi tiết từng bước tính.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };

      case 202:
        return {
          'assignmentId': 202,
          'submissionId': 20200,
          'homeworkTitle': 'Tóm tắt truyện dân gian Thạch Sanh và rút ra bài học ý nghĩa',
          'subjectName': 'Ngữ văn',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 2021,
              'content': 'Truyện dân gian "Thạch Sanh" thuộc thể loại văn học nào?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 20211, 'content': 'Truyền thuyết'},
                {'id': 20212, 'content': 'Truyện cổ tích thần kỳ'},
                {'id': 20213, 'content': 'Truyện ngụ ngôn'},
                {'id': 20214, 'content': 'Truyện cười'},
              ],
            },
            {
              'id': 2022,
              'content': 'Chọn các chiến công vẻ vang của chàng Thạch Sanh trong tác phẩm:',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 20221, 'content': 'Diệt Chằn tinh thu gươm thần'},
                {'id': 20222, 'content': 'Bắn Đại bàng cứu công chúa Quỳnh Nga'},
                {'id': 20223, 'content': 'Dùng tiếng đàn và niêu cơm thần lui giặc 18 nước chư hầu'},
                {'id': 20224, 'content': 'Bán rượu cất vàng ở gốc đa'},
              ],
            },
            {
              'id': 2023,
              'content': 'Lý Thông là nhân vật đại diện cho cái thiện và sự trung hậu đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 20231, 'content': 'Đúng'},
                {'id': 20232, 'content': 'Sai'},
              ],
            },
            {
              'id': 2024,
              'content': 'Nêu ý nghĩa biểu tượng của "Tiếng đàn thần" và "Niêu cơm thần" trong truyện Thạch Sanh.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };

      case 203:
        return {
          'assignmentId': 203,
          'submissionId': 20300,
          'homeworkTitle': 'Unit 1: My New School - Vocabulary & Grammar Practice',
          'subjectName': 'Tiếng Anh',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 2031,
              'content': 'She usually ______ her homework after dinner every evening.',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 20311, 'content': 'do'},
                {'id': 20312, 'content': 'does'},
                {'id': 20313, 'content': 'doing'},
                {'id': 20314, 'content': 'is do'},
              ],
            },
            {
              'id': 2032,
              'content': 'Which of the following words are school subjects?',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 20321, 'content': 'History'},
                {'id': 20322, 'content': 'Science'},
                {'id': 20323, 'content': 'English'},
                {'id': 20324, 'content': 'Pencil case'},
              ],
            },
            {
              'id': 2033,
              'content': '"Uniform" means the special set of clothes worn by students at school.',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 20331, 'content': 'Đúng'},
                {'id': 20332, 'content': 'Sai'},
              ],
            },
            {
              'id': 2034,
              'content': 'Write 3 short sentences about your new secondary school in English.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };

      case 204:
        return {
          'assignmentId': 204,
          'submissionId': 20400,
          'homeworkTitle': 'Các phép đo cơ bản: Đo chiều dài, khối lượng và nhiệt độ',
          'subjectName': 'Khoa học tự nhiên',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 2041,
              'content': 'Đơn vị đo chiều dài tiêu chuẩn trong hệ đo lường quốc tế (SI) là gì?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 20411, 'content': 'Milimét (mm)'},
                {'id': 20412, 'content': 'Mét (m)'},
                {'id': 20413, 'content': 'Kilômét (km)'},
                {'id': 20414, 'content': 'Xentimét (cm)'},
              ],
            },
            {
              'id': 2042,
              'content': 'Những dụng cụ nào sau đây thường được dùng để đo khối lượng?',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 20421, 'content': 'Cân đồng hồ'},
                {'id': 20422, 'content': 'Cân điện tử'},
                {'id': 20423, 'content': 'Nhiệt kế'},
                {'id': 20424, 'content': 'Cân Rô-béc-van'},
              ],
            },
            {
              'id': 2043,
              'content': 'Giới hạn đo (GHĐ) của thước là độ dài giữa 2 vạch chia liên tiếp đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 20431, 'content': 'Đúng'},
                {'id': 20432, 'content': 'Sai'},
              ],
            },
            {
              'id': 2044,
              'content': 'Em hãy nêu các bước đo thể tích của một hòn sỏi nhỏ không thấm nước bằng bình chia độ.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };

      // ==========================================
      // CẤP 3 (THPT - LỚP 10)
      // ==========================================
      case 28:
      case 301:
        return {
          'assignmentId': assignmentId,
          'submissionId': assignmentId * 100,
          'homeworkTitle': 'Bài tập tuần 5: Khảo sát sự biến thiên hàm số bậc hai',
          'subjectName': 'Toán học',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 3011,
              'content': 'Tọa độ đỉnh I của parabol y = x² - 4x + 3 là:',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 30111, 'content': 'I(2; -1)'},
                {'id': 30112, 'content': 'I(-2; 15)'},
                {'id': 30113, 'content': 'I(4; 3)'},
                {'id': 30114, 'content': 'I(1; 0)'},
              ],
            },
            {
              'id': 3012,
              'content': 'Cho hàm số y = -2x² + 4x + 1. Chọn những khẳng định đúng:',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 30121, 'content': 'Hàm số đồng biến trên khoảng (-∞; 1)'},
                {'id': 30122, 'content': 'Hàm số nghịch biến trên khoảng (1; +∞)'},
                {'id': 30123, 'content': 'Hàm số có giá trị lớn nhất bằng 3 tại x = 1'},
                {'id': 30124, 'content': 'Bề lõm của parabol quay lên trên'},
              ],
            },
            {
              'id': 3013,
              'content': 'Trục đối xứng của parabol y = ax² + bx + c (a ≠ 0) là đường thẳng x = -b/(2a) đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 30131, 'content': 'Đúng'},
                {'id': 30132, 'content': 'Sai'},
              ],
            },
            {
              'id': 3014,
              'content': 'Khảo sát sự biến thiên và lập bảng biến thiên của hàm số bậc hai: y = x² - 2x - 3.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };

      case 2:
      case 302:
        return {
          'assignmentId': assignmentId,
          'submissionId': assignmentId * 100,
          'homeworkTitle': 'Đọc hiểu & Phân tích văn bản: Chiến thắng Mtao Mxây',
          'subjectName': 'Ngữ văn',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 3021,
              'content': 'Đoạn trích "Chiến thắng Mtao Mxây" trích từ sử thi nào của đồng bào Tây Nguyên?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 30211, 'content': 'Sử thi Đẻ đất đẻ nước (Mường)'},
                {'id': 30212, 'content': 'Sử thi Đăm Săn (Ê-đê)'},
                {'id': 30213, 'content': 'Sử thi Xinh Nhã (Ê-đê)'},
                {'id': 30214, 'content': 'Sử thi Khinh Dú (Mnông)'},
              ],
            },
            {
              'id': 3022,
              'content': 'Nghệ thuật nổi bật trong đoạn trích miêu tả vẻ đẹp của tù trưởng Đăm Săn là:',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 30221, 'content': 'Nghệ thuật so sánh và phóng đại hoành tráng'},
                {'id': 30222, 'content': 'Ngôn ngữ trùng điệp giàu nhịp điệu và hình ảnh'},
                {'id': 30223, 'content': 'Cách miêu tả hòa quyện với thiên nhiên đại ngàn'},
                {'id': 30224, 'content': 'Nghệ thuật châm biếm sâu cay'},
              ],
            },
            {
              'id': 3023,
              'content': 'Đăm Săn khiêu chiến Mtao Mxây nhằm bảo vệ danh dự buôn làng và giải cứu vợ đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 30231, 'content': 'Đúng'},
                {'id': 30232, 'content': 'Sai'},
              ],
            },
            {
              'id': 3024,
              'content': 'Phân tích ý nghĩa của cảnh ăn mừng chiến thắng hoan hỉ, linh đình ở phần cuối đoạn trích đối với cộng đồng người Ê-đê.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };

      case 3:
      case 303:
        return {
          'assignmentId': assignmentId,
          'submissionId': assignmentId * 100,
          'homeworkTitle': 'Bài luận ngắn: Ý thức giữ gìn bản sắc văn hóa dân tộc',
          'subjectName': 'Ngữ văn',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 3031,
              'content': 'Yếu tố nào sau đây đóng vai trò cốt lõi tạo nên bản sắc văn hóa của một dân tộc?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 30311, 'content': 'Thu nhập bình quân đầu người'},
                {'id': 30312, 'content': 'Tiếng nói, chữ viết, phong tục và truyền thống lịch sử'},
                {'id': 30313, 'content': 'Số lượng nhà cao tầng và đô thị'},
                {'id': 30314, 'content': 'Vị trí địa lý'},
              ],
            },
            {
              'id': 3032,
              'content': 'Những hành động cụ thể thể hiện ý thức giữ gìn bản sắc văn hóa trong thời đại 4.0:',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 30321, 'content': 'Giữ gìn sự trong sáng của Tiếng Việt'},
                {'id': 30322, 'content': 'Tôn vinh và mặc trang phục truyền thống dịp lễ tết'},
                {'id': 30323, 'content': 'Quảng bá văn hóa ẩm thực và di sản dân tộc ra thế giới'},
                {'id': 30324, 'content': 'Sao chép văn hóa ngoại lai không chọn lọc'},
              ],
            },
            {
              'id': 3033,
              'content': 'Hội nhập quốc tế đồng nghĩa với việc hòa tan và từ bỏ bản sắc văn hóa dân tộc đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 30331, 'content': 'Đúng'},
                {'id': 30332, 'content': 'Sai'},
              ],
            },
            {
              'id': 3034,
              'content': 'Viết một đoạn văn (khoảng 150 chữ) bàn về trách nhiệm của học sinh THPT trong việc bảo tồn văn hóa truyền thống.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };

      case 4:
      case 304:
        return {
          'assignmentId': assignmentId,
          'submissionId': assignmentId * 100,
          'homeworkTitle': 'Trắc nghiệm: Động học chất điểm và chuyển động thẳng đều',
          'subjectName': 'Vật lý',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 3041,
              'content': 'Công thức tính vận tốc của chuyển động thẳng biến đổi đều là:',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 30411, 'content': 'v = v₀ + at'},
                {'id': 30412, 'content': 'v = v₀ + 0.5at²'},
                {'id': 30413, 'content': 'v = s / t²'},
                {'id': 30414, 'content': 'v² - v₀² = at'},
              ],
            },
            {
              'id': 3042,
              'content': 'Đặc điểm nào sau đây đúng với chuyển động thẳng nhanh dần đều?',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 30421, 'content': 'Gia tốc a không đổi theo thời gian (a = const)'},
                {'id': 30422, 'content': 'Gia tốc và vận tốc cùng dấu (a · v > 0)'},
                {'id': 30423, 'content': 'Vận tốc tăng đều theo thời gian'},
                {'id': 30424, 'content': 'Gia tốc và vận tốc ngược chiều nhau'},
              ],
            },
            {
              'id': 3043,
              'content': 'Độ dịch chuyển luôn luôn bằng quãng đường đi được trong mọi trường hợp đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 30431, 'content': 'Đúng'},
                {'id': 30432, 'content': 'Sai'},
              ],
            },
            {
              'id': 3044,
              'content': 'Một ô tô chuyển động thẳng nhanh dần đều từ trạng thái nghỉ với gia tốc a = 2 m/s². Tính vận tốc và quãng đường ô tô đi được sau 5 giây.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };

      // ==========================================
      // LEGACY / FALLBACK (TOÁN 3 - PHÉP NHÂN)
      // ==========================================
      default:
        return {
          'assignmentId': assignmentId,
          'submissionId': assignmentId * 100,
          'homeworkTitle': 'Bài tập tuần 5 - Phép nhân',
          'subjectName': 'Toán học',
          'totalPoints': 10.0,
          'submissionStatus': 'IN_PROGRESS',
          'questions': [
            {
              'id': 101,
              'content': 'Kết quả của phép tính 7 x 8 là bao nhiêu?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 1001, 'content': '54'},
                {'id': 1002, 'content': '56'},
                {'id': 1003, 'content': '64'},
                {'id': 1004, 'content': '48'},
              ],
            },
            {
              'id': 102,
              'content': 'Chọn các phép tính có kết quả bằng 36:',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'options': [
                {'id': 1005, 'content': '6 x 6'},
                {'id': 1006, 'content': '4 x 9'},
                {'id': 1007, 'content': '5 x 7'},
                {'id': 1008, 'content': '3 x 12'},
              ],
            },
            {
              'id': 103,
              'content': 'Phép tính 9 x 0 có kết quả bằng 9 đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'options': [
                {'id': 1009, 'content': 'Đúng'},
                {'id': 1010, 'content': 'Sai'},
              ],
            },
            {
              'id': 104,
              'content': 'Một cửa hàng có 5 bao gạo, mỗi bao cân nặng 12kg. Hỏi cửa hàng có tất cả bao nhiêu ki-lô-gam gạo? Hãy trình bày lời giải của em.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'options': [],
            },
          ],
          'savedAnswers': [],
        };
    }
  }

  /// Trả về kết quả bài nộp của học sinh (StudentHomeworkResultScreen).
  static Map<String, dynamic> getAssignmentResult(int assignmentId) {
    switch (assignmentId) {
      // ==========================================
      // CẤP 1 (TIỂU HỌC - LỚP 1)
      // ==========================================
      case 103:
        return {
          'assignmentId': 103,
          'homeworkTitle': 'Unit 1: Family - Tô màu và đọc tên các thành viên trong gia đình',
          'subjectName': 'Tiếng Anh',
          'totalPoints': 10.0,
          'submissionStatus': 'GRADED',
          'finalScore': 10.0,
          'autoScore': 7.0,
          'teacherFeedback': 'Em làm bài rất tốt, từ vựng chuẩn xác và viết câu hoàn chỉnh! Tiếp tục phát huy nhé!',
          'isLate': false,
          'questions': [
            {
              'id': 1031,
              'content': 'Từ nào trong tiếng Anh có nghĩa là "Mẹ"?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'explanation': 'Mother = Mẹ; Father = Bố; Brother = Anh/Em trai; Sister = Chị/Em gái.',
              'options': [
                {'id': 10311, 'content': 'Father', 'isCorrect': false},
                {'id': 10312, 'content': 'Mother', 'isCorrect': true},
                {'id': 10313, 'content': 'Brother', 'isCorrect': false},
                {'id': 10314, 'content': 'Sister', 'isCorrect': false},
              ],
            },
            {
              'id': 1032,
              'content': 'Chọn các từ chỉ thành viên trong gia đình:',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'explanation': 'Father, Sister, Brother là các thành viên gia đình. Apple là quả táo.',
              'options': [
                {'id': 10321, 'content': 'Father', 'isCorrect': true},
                {'id': 10322, 'content': 'Sister', 'isCorrect': true},
                {'id': 10323, 'content': 'Apple', 'isCorrect': false},
                {'id': 10324, 'content': 'Brother', 'isCorrect': true},
              ],
            },
            {
              'id': 1033,
              'content': '"Baby" trong tiếng Anh có nghĩa là em bé đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'explanation': 'Baby có nghĩa là em bé sơ sinh/nhỏ tuổi.',
              'options': [
                {'id': 10331, 'content': 'Đúng', 'isCorrect': true},
                {'id': 10332, 'content': 'Sai', 'isCorrect': false},
              ],
            },
            {
              'id': 1034,
              'content': 'Write the answer: How many people are there in your family?',
              'questionType': 'ESSAY',
              'points': 3.0,
              'correctAnswerText': 'There are 4 people in my family: my father, my mother, my brother and me.',
              'explanation': 'Câu trả lời đầy đủ có cấu trúc There are [number] people in my family.',
              'options': [],
            },
          ],
          'savedAnswers': [
            {'questionId': 1031, 'selectedOptionIds': [10312], 'score': 2.5, 'teacherNote': null},
            {'questionId': 1032, 'selectedOptionIds': [10321, 10322, 10324], 'score': 2.5, 'teacherNote': null},
            {'questionId': 1033, 'selectedOptionIds': [10331], 'score': 2.0, 'teacherNote': null},
            {
              'questionId': 1034,
              'answerText': 'There are 4 people in my family: father, mother, brother and me.',
              'score': 3.0,
              'teacherNote': 'Câu trả lời rất rõ ràng và viết đúng ngữ pháp tiếng Anh!',
            },
          ],
        };

      case 104:
        return {
          'assignmentId': 104,
          'homeworkTitle': 'Quan sát và nhận biết các bộ phận trên cơ thể người',
          'subjectName': 'Tự nhiên và Xã hội',
          'totalPoints': 10.0,
          'submissionStatus': 'GRADED',
          'finalScore': 9.5,
          'autoScore': 7.0,
          'teacherFeedback': 'Bài làm rất xuất sắc, hiểu bài và biết vận dụng giữ gìn vệ sinh thân thể!',
          'isLate': false,
          'questions': [
            {
              'id': 1041,
              'content': 'Bộ phận nào trên cơ thể giúp chúng ta nhìn thấy màu sắc của cảnh vật xung quanh?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'explanation': 'Đôi mắt là cơ quan thị giác giúp nhìn thấy cảnh vật và màu sắc.',
              'options': [
                {'id': 10411, 'content': 'Đôi tai', 'isCorrect': false},
                {'id': 10412, 'content': 'Đôi mắt', 'isCorrect': true},
                {'id': 10413, 'content': 'Cái mũi', 'isCorrect': false},
                {'id': 10414, 'content': 'Đôi bàn tay', 'isCorrect': false},
              ],
            },
            {
              'id': 1042,
              'content': 'Chọn những thói quen tốt giúp giữ gìn vệ sinh thân thể:',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'explanation': 'Rửa tay xà phòng, đánh răng và tắm rửa hằng ngày là thói quen lành mạnh.',
              'options': [
                {'id': 10421, 'content': 'Rửa tay bằng xà phòng trước khi ăn', 'isCorrect': true},
                {'id': 10422, 'content': 'Đánh răng sáng và tối trước khi đi ngủ', 'isCorrect': true},
                {'id': 10423, 'content': 'Đi chân đất trên nền đất bẩn', 'isCorrect': false},
                {'id': 10424, 'content': 'Tắm rửa sạch sẽ mỗi ngày', 'isCorrect': true},
              ],
            },
            {
              'id': 1043,
              'content': 'Rửa tay sạch bằng xà phòng giúp phòng tránh vi khuẩn gây bệnh đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'explanation': 'Xà phòng tiêu diệt và cuốn trôi vi khuẩn trên da tay.',
              'options': [
                {'id': 10431, 'content': 'Đúng', 'isCorrect': true},
                {'id': 10432, 'content': 'Sai', 'isCorrect': false},
              ],
            },
            {
              'id': 1044,
              'content': 'Em cần làm những gì để bảo vệ đôi mắt luôn sáng và khỏe mạnh khi học bài?',
              'questionType': 'ESSAY',
              'points': 3.0,
              'correctAnswerText': 'Em ngồi học ngay ngắn ở nơi đủ ánh sáng, giữ khoảng cách mắt đến sách vở từ 25 - 30cm, không xem điện thoại quá lâu.',
              'explanation': 'Ngồi học đúng tư thế và đủ sáng giúp phòng tránh cận thị học đường.',
              'options': [],
            },
          ],
          'savedAnswers': [
            {'questionId': 1041, 'selectedOptionIds': [10412], 'score': 2.5, 'teacherNote': null},
            {'questionId': 1042, 'selectedOptionIds': [10421, 10422, 10424], 'score': 2.5, 'teacherNote': null},
            {'questionId': 1043, 'selectedOptionIds': [10431], 'score': 2.0, 'teacherNote': null},
            {
              'questionId': 1044,
              'answerText': 'Em ngồi học ngay ngắn nơi đủ ánh sáng và không nhìn màn hình quá gần.',
              'score': 2.5,
              'teacherNote': 'Ý thức bảo vệ mắt rất tốt, chú ý thêm việc chớp mắt nghỉ ngơi sau 30 phút nhé.',
            },
          ],
        };

      // ==========================================
      // CẤP 2 (THCS - LỚP 6)
      // ==========================================
      case 203:
        return {
          'assignmentId': 203,
          'homeworkTitle': 'Unit 1: My New School - Vocabulary & Grammar Practice',
          'subjectName': 'Tiếng Anh',
          'totalPoints': 10.0,
          'submissionStatus': 'GRADED',
          'finalScore': 9.0,
          'autoScore': 7.0,
          'teacherFeedback': 'Tốt lắm! Em nắm vững thì hiện tại đơn, câu văn mạch lạc, chỉ cần chú ý mạo từ.',
          'isLate': false,
          'questions': [
            {
              'id': 2031,
              'content': 'She usually ______ her homework after dinner every evening.',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'explanation': 'Chủ ngữ "She" ngôi thứ 3 số ít chia ở thì hiện tại đơn: does.',
              'options': [
                {'id': 20311, 'content': 'do', 'isCorrect': false},
                {'id': 20312, 'content': 'does', 'isCorrect': true},
                {'id': 20313, 'content': 'doing', 'isCorrect': false},
                {'id': 20314, 'content': 'is do', 'isCorrect': false},
              ],
            },
            {
              'id': 2032,
              'content': 'Which of the following words are school subjects?',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'explanation': 'History, Science, English là tên các môn học.',
              'options': [
                {'id': 20321, 'content': 'History', 'isCorrect': true},
                {'id': 20322, 'content': 'Science', 'isCorrect': true},
                {'id': 20323, 'content': 'English', 'isCorrect': true},
                {'id': 20324, 'content': 'Pencil case', 'isCorrect': false},
              ],
            },
            {
              'id': 2033,
              'content': '"Uniform" means the special set of clothes worn by students at school.',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'explanation': 'Uniform = Đồng phục học sinh.',
              'options': [
                {'id': 20331, 'content': 'Đúng', 'isCorrect': true},
                {'id': 20332, 'content': 'Sai', 'isCorrect': false},
              ],
            },
            {
              'id': 2034,
              'content': 'Write 3 short sentences about your new secondary school in English.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'correctAnswerText': 'My new school is very large and modern. It has a big library with many interesting books. Teachers and friends are always friendly.',
              'explanation': 'Dùng thì hiện tại đơn miêu tả trường học.',
              'options': [],
            },
          ],
          'savedAnswers': [
            {'questionId': 2031, 'selectedOptionIds': [20312], 'score': 2.5, 'teacherNote': null},
            {'questionId': 2032, 'selectedOptionIds': [20321, 20322, 20323], 'score': 2.5, 'teacherNote': null},
            {'questionId': 2033, 'selectedOptionIds': [20331], 'score': 2.0, 'teacherNote': null},
            {
              'questionId': 2034,
              'answerText': 'My school is big. It has a beautiful library. My teachers are friendly.',
              'score': 2.0,
              'teacherNote': 'Viết đúng ngữ pháp, cần mở rộng vốn từ miêu tả phong phú hơn.',
            },
          ],
        };

      case 204:
        return {
          'assignmentId': 204,
          'homeworkTitle': 'Các phép đo cơ bản: Đo chiều dài, khối lượng và nhiệt độ',
          'subjectName': 'Khoa học tự nhiên',
          'totalPoints': 10.0,
          'submissionStatus': 'GRADED',
          'finalScore': 9.5,
          'autoScore': 7.0,
          'teacherFeedback': 'Bài làm rất chuẩn xác, trình bày khoa học và nắm vững thao tác thực nghiệm!',
          'isLate': false,
          'questions': [
            {
              'id': 2041,
              'content': 'Đơn vị đo chiều dài tiêu chuẩn trong hệ đo lường quốc tế (SI) là gì?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'explanation': 'Đơn vị đo chiều dài trong hệ SI là mét (kí hiệu: m).',
              'options': [
                {'id': 20411, 'content': 'Milimét (mm)', 'isCorrect': false},
                {'id': 20412, 'content': 'Mét (m)', 'isCorrect': true},
                {'id': 20413, 'content': 'Kilômét (km)', 'isCorrect': false},
                {'id': 20414, 'content': 'Xentimét (cm)', 'isCorrect': false},
              ],
            },
            {
              'id': 2042,
              'content': 'Những dụng cụ nào sau đây thường được dùng để đo khối lượng?',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'explanation': 'Cân đồng hồ, cân điện tử, cân Rô-béc-van dùng đo khối lượng. Nhiệt kế đo nhiệt độ.',
              'options': [
                {'id': 20421, 'content': 'Cân đồng hồ', 'isCorrect': true},
                {'id': 20422, 'content': 'Cân điện tử', 'isCorrect': true},
                {'id': 20423, 'content': 'Nhiệt kế', 'isCorrect': false},
                {'id': 20424, 'content': 'Cân Rô-béc-van', 'isCorrect': true},
              ],
            },
            {
              'id': 2043,
              'content': 'Giới hạn đo (GHĐ) của thước là độ dài giữa 2 vạch chia liên tiếp đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'explanation': 'GHĐ là độ dài lớn nhất ghi trên thước. Độ dài giữa 2 vạch chia liên tiếp là ĐCNN.',
              'options': [
                {'id': 20431, 'content': 'Đúng', 'isCorrect': false},
                {'id': 20432, 'content': 'Sai', 'isCorrect': true},
              ],
            },
            {
              'id': 2044,
              'content': 'Em hãy nêu các bước đo thể tích của một hòn sỏi nhỏ không thấm nước bằng bình chia độ.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'correctAnswerText': 'Bước 1: Đổ nước vào bình chia độ, đọc thể tích V1.\nBước 2: Thả chìm hòn sỏi vào bình, đọc thể tích V2.\nBước 3: Thể tích hòn sỏi là V = V2 - V1.',
              'explanation': 'Phương pháp dâng nước dùng đo thể tích vật rắn không thấm nước.',
              'options': [],
            },
          ],
          'savedAnswers': [
            {'questionId': 2041, 'selectedOptionIds': [20412], 'score': 2.5, 'teacherNote': null},
            {'questionId': 2042, 'selectedOptionIds': [20421, 20422, 20424], 'score': 2.5, 'teacherNote': null},
            {'questionId': 2043, 'selectedOptionIds': [20432], 'score': 2.0, 'teacherNote': null},
            {
              'questionId': 2044,
              'answerText': 'Đo thể tích nước ban đầu V1. Thả hòn sỏi ngập trong nước rồi đọc V2. Thể tích sỏi là V2 - V1.',
              'score': 2.5,
              'teacherNote': 'Các bước chính xác, lưu ý nêu rõ việc tránh bọt khí bám vào sỏi khi làm thực nghiệm.',
            },
          ],
        };

      // ==========================================
      // CẤP 3 (THPT - LỚP 10)
      // ==========================================
      case 3:
      case 303:
        return {
          'assignmentId': assignmentId,
          'homeworkTitle': 'Bài luận ngắn: Ý thức giữ gìn bản sắc văn hóa dân tộc',
          'subjectName': 'Ngữ văn',
          'totalPoints': 10.0,
          'submissionStatus': 'GRADED',
          'finalScore': 9.5,
          'autoScore': 7.0,
          'teacherFeedback': 'Bài viết sâu sắc, lập luận chặt chẽ, dẫn chứng xác thực và thể hiện lý tưởng sống đẹp của thanh niên!',
          'isLate': false,
          'questions': [
            {
              'id': 3031,
              'content': 'Yếu tố nào sau đây đóng vai trò cốt lõi tạo nên bản sắc văn hóa của một dân tộc?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'explanation': 'Bản sắc văn hóa thể hiện sâu sắc qua tiếng nói, chữ viết, phong tục và truyền thống lịch sử.',
              'options': [
                {'id': 30311, 'content': 'Thu nhập bình quân đầu người', 'isCorrect': false},
                {'id': 30312, 'content': 'Tiếng nói, chữ viết, phong tục và truyền thống lịch sử', 'isCorrect': true},
                {'id': 30313, 'content': 'Số lượng nhà cao tầng và đô thị', 'isCorrect': false},
                {'id': 30314, 'content': 'Vị trí địa lý', 'isCorrect': false},
              ],
            },
            {
              'id': 3032,
              'content': 'Những hành động cụ thể thể hiện ý thức giữ gìn bản sắc văn hóa trong thời đại 4.0:',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'explanation': 'Bảo tồn tiếng Việt, gìn giữ trang phục truyền thống và quảng bá di sản là hành động thiết thực.',
              'options': [
                {'id': 30321, 'content': 'Giữ gìn sự trong sáng của Tiếng Việt', 'isCorrect': true},
                {'id': 30322, 'content': 'Tôn vinh và mặc trang phục truyền thống dịp lễ tết', 'isCorrect': true},
                {'id': 30323, 'content': 'Quảng bá văn hóa ẩm thực và di sản dân tộc ra thế giới', 'isCorrect': true},
                {'id': 30324, 'content': 'Sao chép văn hóa ngoại lai không chọn lọc', 'isCorrect': false},
              ],
            },
            {
              'id': 3033,
              'content': 'Hội nhập quốc tế đồng nghĩa với việc hòa tan và từ bỏ bản sắc văn hóa dân tộc đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'explanation': 'Hội nhập là "hòa nhập chứ không hòa tan", tiếp thu tinh hoa nhưng bảo tồn cốt cách dân tộc.',
              'options': [
                {'id': 30331, 'content': 'Đúng', 'isCorrect': false},
                {'id': 30332, 'content': 'Sai', 'isCorrect': true},
              ],
            },
            {
              'id': 3034,
              'content': 'Viết một đoạn văn (khoảng 150 chữ) bàn về trách nhiệm của học sinh THPT trong việc bảo tồn văn hóa truyền thống.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'correctAnswerText': 'Thế hệ trẻ là chủ nhân tương lai, giữ vai trò rường cột trong việc kế thừa và phát huy di sản văn hóa dân tộc. Học sinh THPT cần tích cực tìm hiểu lịch sử, sử dụng tiếng Việt chuẩn mực, tôn trọng phong tục tốt đẹp và ứng dụng công nghệ số để lan tỏa giá trị văn hóa Việt Nam ra năm châu.',
              'explanation': 'Đoạn văn cần có mở đoạn, thân đoạn nêu rõ giải pháp hành động và kết đoạn bài học nhận thức.',
              'options': [],
            },
          ],
          'savedAnswers': [
            {'questionId': 3031, 'selectedOptionIds': [30312], 'score': 2.5, 'teacherNote': null},
            {'questionId': 3032, 'selectedOptionIds': [30321, 30322, 30323], 'score': 2.5, 'teacherNote': null},
            {'questionId': 3033, 'selectedOptionIds': [30332], 'score': 2.0, 'teacherNote': null},
            {
              'questionId': 3034,
              'answerText': 'Thế hệ trẻ cần có trách nhiệm bảo tồn bản sắc văn hóa bằng việc trau dồi tri thức lịch sử, nói và viết tiếng Việt trong sáng, quảng bá nét đẹp truyền thống và chủ động hội nhập văn minh nhưng không đánh mất cội nguồn.',
              'score': 2.5,
              'teacherNote': 'Văn phong truyền cảm, lập luận thuyết phục và có dẫn chứng hành động cụ thể.',
            },
          ],
        };

      case 4:
      case 304:
        return {
          'assignmentId': assignmentId,
          'homeworkTitle': 'Trắc nghiệm: Động học chất điểm và chuyển động thẳng đều',
          'subjectName': 'Vật lý',
          'totalPoints': 10.0,
          'submissionStatus': 'GRADED',
          'finalScore': 10.0,
          'autoScore': 7.0,
          'teacherFeedback': 'Xuất sắc! Lời giải rõ ràng, tính toán chuẩn xác tuyệt đối từng đơn vị vật lý!',
          'isLate': false,
          'questions': [
            {
              'id': 3041,
              'content': 'Công thức tính vận tốc của chuyển động thẳng biến đổi đều là:',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'explanation': 'Chuyển động biến đổi đều có công thức vận tốc: v = v₀ + at.',
              'options': [
                {'id': 30411, 'content': 'v = v₀ + at', 'isCorrect': true},
                {'id': 30412, 'content': 'v = v₀ + 0.5at²', 'isCorrect': false},
                {'id': 30413, 'content': 'v = s / t²', 'isCorrect': false},
                {'id': 30414, 'content': 'v² - v₀² = at', 'isCorrect': false},
              ],
            },
            {
              'id': 3042,
              'content': 'Đặc điểm nào sau đây đúng với chuyển động thẳng nhanh dần đều?',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'explanation': 'Nhanh dần đều: gia tốc a hằng số, a và v cùng chiều (a · v > 0), vận tốc tăng đều.',
              'options': [
                {'id': 30421, 'content': 'Gia tốc a không đổi theo thời gian (a = const)', 'isCorrect': true},
                {'id': 30422, 'content': 'Gia tốc và vận tốc cùng dấu (a · v > 0)', 'isCorrect': true},
                {'id': 30423, 'content': 'Vận tốc tăng đều theo thời gian', 'isCorrect': true},
                {'id': 30424, 'content': 'Gia tốc và vận tốc ngược chiều nhau', 'isCorrect': false},
              ],
            },
            {
              'id': 3043,
              'content': 'Độ dịch chuyển luôn luôn bằng quãng đường đi được trong mọi trường hợp đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'explanation': 'Độ dịch chuyển d chỉ bằng quãng đường s khi chất điểm chuyển động thẳng không đổi chiều.',
              'options': [
                {'id': 30431, 'content': 'Đúng', 'isCorrect': false},
                {'id': 30432, 'content': 'Sai', 'isCorrect': true},
              ],
            },
            {
              'id': 3044,
              'content': 'Một ô tô chuyển động thẳng nhanh dần đều từ trạng thái nghỉ với gia tốc a = 2 m/s². Tính vận tốc và quãng đường ô tô đi được sau 5 giây.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'correctAnswerText': 'Vận tốc sau 5s: v = v₀ + at = 0 + 2 · 5 = 10 m/s.\nQuãng đường: s = v₀t + 0.5at² = 0 + 0.5 · 2 · 5² = 25 m.',
              'explanation': 'Áp dụng công thức v = v₀ + at và s = v₀t + 0.5at² với v₀ = 0.',
              'options': [],
            },
          ],
          'savedAnswers': [
            {'questionId': 3041, 'selectedOptionIds': [30411], 'score': 2.5, 'teacherNote': null},
            {'questionId': 3042, 'selectedOptionIds': [30421, 30422, 30423], 'score': 2.5, 'teacherNote': null},
            {'questionId': 3043, 'selectedOptionIds': [30432], 'score': 2.0, 'teacherNote': null},
            {
              'questionId': 3044,
              'answerText': 'Vận tốc ô tô sau 5 giây là:\nv = 0 + 2 × 5 = 10 (m/s)\nQuãng đường ô tô đi được là:\ns = 0 × 5 + 0.5 × 2 × 5² = 25 (m)\nĐáp số: v = 10 m/s; s = 25 m.',
              'score': 3.0,
              'teacherNote': 'Lời giải chi tiết, rõ ràng và kết quả hoàn toàn chính xác!',
            },
          ],
        };

      // ==========================================
      // LEGACY / FALLBACK (TOÁN 3 - PHÉP NHÂN)
      // ==========================================
      default:
        return {
          'assignmentId': assignmentId,
          'homeworkTitle': 'Bài tập tuần 5 - Phép nhân',
          'subjectName': 'Toán học',
          'totalPoints': 10.0,
          'submissionStatus': 'GRADED',
          'finalScore': 8.5,
          'autoScore': 6.0,
          'teacherFeedback': 'Em làm bài rất tốt, các bước tính toán chính xác và trình bày rõ ràng. Cần phát huy hơn nữa ở phần câu hỏi tư duy nâng cao!',
          'isLate': false,
          'questions': [
            {
              'id': 101,
              'content': 'Kết quả của phép tính 7 x 8 là bao nhiêu?',
              'questionType': 'SINGLE_CHOICE',
              'points': 2.5,
              'explanation': 'Bảng nhân 7: 7 x 8 = 56.',
              'options': [
                {'id': 1001, 'content': '54', 'isCorrect': false},
                {'id': 1002, 'content': '56', 'isCorrect': true},
                {'id': 1003, 'content': '64', 'isCorrect': false},
                {'id': 1004, 'content': '48', 'isCorrect': false},
              ],
            },
            {
              'id': 102,
              'content': 'Chọn các phép tính có kết quả bằng 36:',
              'questionType': 'MULTIPLE_CHOICE',
              'points': 2.5,
              'explanation': '6 x 6 = 36; 4 x 9 = 36; 3 x 12 = 36.',
              'options': [
                {'id': 1005, 'content': '6 x 6', 'isCorrect': true},
                {'id': 1006, 'content': '4 x 9', 'isCorrect': true},
                {'id': 1007, 'content': '5 x 7', 'isCorrect': false},
                {'id': 1008, 'content': '3 x 12', 'isCorrect': true},
              ],
            },
            {
              'id': 103,
              'content': 'Phép tính 9 x 0 có kết quả bằng 9 đúng hay sai?',
              'questionType': 'TRUE_FALSE',
              'points': 2.0,
              'explanation': 'Bất kỳ số nào nhân với 0 cũng có kết quả bằng 0.',
              'options': [
                {'id': 1009, 'content': 'Đúng', 'isCorrect': false},
                {'id': 1010, 'content': 'Sai', 'isCorrect': true},
              ],
            },
            {
              'id': 104,
              'content': 'Một cửa hàng có 5 bao gạo, mỗi bao cân nặng 12kg. Hỏi cửa hàng có tất cả bao nhiêu ki-lô-gam gạo? Hãy trình bày lời giải của em.',
              'questionType': 'ESSAY',
              'points': 3.0,
              'correctAnswerText': 'Lời giải:\nCửa hàng có tất cả số ki-lô-gam gạo là:\n12 x 5 = 60 (kg)\nĐáp số: 60 kg gạo.',
              'explanation': 'Muốn tìm số kg của 5 bao, lấy khối lượng 1 bao nhân với 5.',
              'options': [],
            },
          ],
          'savedAnswers': [
            {'questionId': 101, 'selectedOptionIds': [1002], 'score': 2.5, 'teacherNote': null},
            {'questionId': 102, 'selectedOptionIds': [1005, 1006, 1008], 'score': 2.5, 'teacherNote': null},
            {'questionId': 103, 'selectedOptionIds': [1010], 'score': 2.0, 'teacherNote': null},
            {
              'questionId': 104,
              'answerText': 'Cửa hàng có số kg gạo là:\n12 x 5 = 60 kg\nĐáp số: 60 kg.',
              'score': 2.5,
              'teacherNote': 'Lời giải đúng và ngắn gọn, chú ý ghi đầy đủ đơn vị phép tính.',
            },
          ],
        };
    }
  }
}
