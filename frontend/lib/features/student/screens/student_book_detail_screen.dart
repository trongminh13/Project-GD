import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ashadeep/core/theme/app_colors.dart';
import 'package:ashadeep/features/student/screens/student_book_reader_screen.dart';

class StudentBookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const StudentBookDetailScreen({super.key, required this.data});

  @override
  State<StudentBookDetailScreen> createState() => _StudentBookDetailScreenState();
}

class _StudentBookDetailScreenState extends State<StudentBookDetailScreen> {
  late bool _isDownloaded;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  Timer? _downloadTimer;
  late int _lastReadPage;

  List<Map<String, dynamic>> get _tableOfContents {
    final title = (widget.data['title'] ?? '').toString().toLowerCase();
    if (title.contains('toán 1') || title.contains('toan 1')) {
      return [
        {
          'title': 'Chủ đề 1: Làm quen với một số hình (Trang 4 - 23)',
          'startPage': 4,
        },
        {
          'title': 'Chủ đề 2: Làm quen với chữ số và phép so sánh (Trang 24 - 49)',
          'startPage': 24,
        },
        {
          'title': 'Chủ đề 3: Phép cộng và phép trừ trong phạm vi 10 (Trang 50 - 81)',
          'startPage': 50,
        },
        {
          'title': 'Chủ đề 4: Làm quen với hình khối và thời gian (Trang 82 - 99)',
          'startPage': 82,
        },
        {
          'title': 'Chủ đề 5: Ôn tập học kì 1 và ứng dụng thực hành (Trang 100 - 118)',
          'startPage': 100,
        },
      ];
    }
    return [
      {
        'title': 'Chương 1: Ôn tập và bổ sung kiến thức đầu năm (Trang 4 - 28)',
        'startPage': 4,
      },
      {
        'title': 'Chương 2: Bảng nhân và bảng chia cơ bản (Trang 29 - 56)',
        'startPage': 29,
      },
      {
        'title': 'Chương 3: Làm quen với hình phẳng và hình khối (Trang 57 - 82)',
        'startPage': 57,
      },
      {
        'title': 'Chương 4: Phép tính có nhớ trong phạm vi 1000 (Trang 83 - 110)',
        'startPage': 83,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _isDownloaded = widget.data['isDownloaded'] ?? true;
    final isToan1 = (widget.data['title'] ?? '').toString().toLowerCase().contains('toán 1') ||
        (widget.data['title'] ?? '').toString().toLowerCase().contains('toan 1');
    _lastReadPage = widget.data['lastReadPage'] ?? (isToan1 ? 1 : 18);
  }

  @override
  void dispose() {
    _downloadTimer?.cancel();
    super.dispose();
  }

  void _startDownload() {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.05;
    });

    _downloadTimer?.cancel();
    _downloadTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _downloadProgress += 0.2;
        if (_downloadProgress >= 1.0) {
          _downloadProgress = 1.0;
          _isDownloading = false;
          _isDownloaded = true;
          timer.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã tải xong sách: ${widget.data['title'] ?? 'Sách học'}! Sẵn sàng đọc offline.'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    });
  }

  void _cancelDownload() {
    _downloadTimer?.cancel();
    setState(() {
      _isDownloading = false;
      _downloadProgress = 0.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã hủy tải sách.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _confirmDeleteDownload(String fileSize) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: AppColors.error),
            SizedBox(width: 8),
            Text(
              'Giải phóng bộ nhớ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Bạn có muốn xóa bản tải ngoại tuyến của cuốn sách này để giải phóng $fileSize dung lượng bộ nhớ? Bạn có thể tải lại bất kỳ lúc nào khi có kết nối mạng.',
          style: const TextStyle(fontSize: 14, color: AppColors.textMain, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Giữ lại', style: TextStyle(color: AppColors.textSub)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isDownloaded = false;
                _downloadProgress = 0.0;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa bản tải và giải phóng $fileSize bộ nhớ thiết bị!'),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }

  void _openReader({int? page}) async {
    final targetPage = page ?? _lastReadPage;
    final returnedPage = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => StudentBookReaderScreen(
          data: widget.data,
          initialPage: targetPage,
        ),
      ),
    );

    if (returnedPage != null && mounted) {
      setState(() {
        _lastReadPage = returnedPage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.data['title'] ?? 'Sách học điện tử';
    final subject = widget.data['subjectName'] ?? 'Toán';
    final teacher = widget.data['teacherName'] ?? 'Cô Lê Thu Hà';
    final fileType = (widget.data['fileType'] ?? 'PDF').toString().toUpperCase();
    final fileSize = widget.data['fileSize'] ?? '4.8 MB';
    final safeFileName = title.toString().replaceAll(RegExp(r'[^\w\s\.-]'), '').replaceAll(' ', '_');
    final filePath = widget.data['filePath']?.toString() ?? 'file:///storage/emulated/0/Download/$safeFileName.pdf';
    final date = widget.data['createdAt'] != null ? widget.data['createdAt'].toString().split('T')[0] : '12/10/2026';
    final description = widget.data['description']?.toString() ??
        'Sách giáo khoa và tài liệu học tập điện tử phục vụ chương trình lớp 3. Học sinh có thể tải về theo nhu cầu để tra cứu, làm bài tập và đọc ngoại tuyến không cần kết nối mạng.';

    final scaffold = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Quay lại',
        ),
        title: const Text(
          'Chi tiết sách đọc',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
        ),
        actions: [
          if (_isDownloaded)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.textSub, size: 22),
              tooltip: 'Giải phóng bộ nhớ',
              onPressed: () => _confirmDeleteDownload(fileSize),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, thickness: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thẻ thông tin tổng quan bìa sách
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              color: AppColors.cardBg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 36),
                      SizedBox(height: 4),
                      Text(
                        'PDF',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Giáo viên: $teacher',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSub),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Định dạng: $fileType ($fileSize) · $date',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSub),
                      ),
                      if (_isDownloaded) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.auto_stories, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Tiến độ: Đang đọc trang $_lastReadPage / 110',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // KHỐI QUẢN LÝ TẢI THEO NHU CẦU & KIỂM SOÁT BỘ NHỚ
          if (_isDownloaded)
            // Trạng thái 1: ĐÃ TẢI VỀ MÁY (Sẵn sàng đọc offline & Quản lý bộ nhớ)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.folder_open_outlined, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đường dẫn tệp PDF trên thiết bị:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMain),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            filePath,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: AppColors.textMain,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.copy, size: 18, color: AppColors.primary),
                          tooltip: 'Sao chép đường dẫn',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: filePath));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã sao chép đường dẫn file PDF vào bộ nhớ tạm!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Đã lưu trong bộ nhớ máy · Sẵn sàng đọc offline',
                          style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(height: 1, color: AppColors.border.withValues(alpha: 0.6)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Bộ nhớ: $fileSize',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                        ),
                      ),
                      InkWell(
                        onTap: () => _confirmDeleteDownload(fileSize),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline, size: 15, color: AppColors.error),
                            SizedBox(width: 4),
                            Text(
                              'Giải phóng bộ nhớ',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else if (_isDownloading)
            // Trạng thái 2: ĐANG TẢI VỀ MÁY (Hiển thị tiến trình On-Demand Download)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Đang tải sách về máy...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _cancelDownload,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Hủy', style: TextStyle(color: AppColors.error, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: LinearProgressIndicator(
                      value: _downloadProgress,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiến độ: ${(_downloadProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Dung lượng tệp: $fileSize',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            // Trạng thái 3: CHƯA TẢI VỀ MÁY (Khuyến khích tải theo nhu cầu, tiết kiệm bộ nhớ)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cloud_download_outlined, size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sách chưa lưu trong bộ nhớ máy',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMain),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tài liệu được lưu trên máy chủ giáo dục. Hãy tải về khi có mạng để học và đọc ngoại tuyến không tiêu hao 4G.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSub, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: _startDownload,
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      label: Text('Tải về máy ngay ($fileSize)'),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Mô tả sách
          const Text(
            'Giới thiệu nội dung',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              color: Colors.white,
            ),
            child: Text(
              description,
              style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textMain),
            ),
          ),
          const SizedBox(height: 20),

          // Mục lục bài học
          const Text(
            'Mục lục bài học',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              color: Colors.white,
            ),
            child: Column(
              children: _tableOfContents.asMap().entries.map((entry) {
                final idx = entry.key;
                final chapter = entry.value;
                return InkWell(
                  onTap: () {
                    if (_isDownloaded) {
                      _openReader(page: chapter['startPage'] as int);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng tải sách về máy để mở đọc chương này!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: idx < _tableOfContents.length - 1
                          ? const Border(bottom: BorderSide(color: AppColors.border))
                          : null,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bookmark_outline, size: 16, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            chapter['title'] as String,
                            style: const TextStyle(fontSize: 13, color: AppColors.textMain, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.textSub),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: _isDownloaded
              ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  onPressed: () => _openReader(),
                  icon: const Icon(Icons.chrome_reader_mode_outlined, size: 20),
                  label: const Text(
                    'Đọc sách ngay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              : (_isDownloading
                  ? ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: null,
                      icon: const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      label: Text(
                        'Đang tải... ${(_downloadProgress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: _startDownload,
                      icon: const Icon(Icons.file_download_outlined, size: 20),
                      label: Text(
                        'Tải sách để đọc ($fileSize)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )),
        ),
      ),
    );

    // Bọc toàn bộ trong khung giả lập điện thoại di động (Mobile Viewport Shell)
    return Container(
      color: const Color(0xFFF5F6F7),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.symmetric(
                vertical: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.8),
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRect(
              child: scaffold,
            ),
          ),
        ),
      ),
    );
  }
}
