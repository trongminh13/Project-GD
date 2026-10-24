import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/utils/constants.dart' show ApiConstants;
import 'package:ashadeep/core/page_flip/page_flip_view.dart';
import 'package:ashadeep/core/page_flip/material_pdf_page_image_source.dart';
import 'package:ashadeep/core/page_flip/book_mock_content_provider.dart';

class StudentBookReaderScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final int initialPage;

  const StudentBookReaderScreen({
    super.key,
    required this.data,
    this.initialPage = 1,
  });

  @override
  State<StudentBookReaderScreen> createState() =>
      _StudentBookReaderScreenState();
}

class _StudentBookReaderScreenState extends State<StudentBookReaderScreen> {
  late PageController _pageController;
  late PageFlipController _flipController;
  late MaterialPdfPageImageSource _pageSource;
  late int _currentPage;
  late int _totalPages;
  bool _isDarkMode = false;
  bool _isBookmarked = false;
  bool _isZoomMode = false;
  String? _jwtToken;

  List<Map<String, dynamic>> get _chapters =>
      BookMockContentProvider.getChapters(widget.data);

  String get _currentChapterTitle =>
      BookMockContentProvider.resolve(widget.data, _currentPage).chapterTitle;

  @override
  void initState() {
    super.initState();
    final total = widget.data['pageCount'] as int? ?? 110;
    _totalPages = total > 0 ? total : 110;
    _currentPage = widget.initialPage.clamp(1, _totalPages);
    _pageController = PageController(initialPage: _currentPage - 1);
    _flipController = PageFlipController();
    _initPageSource();
    _loadToken();
  }

  void _initPageSource() {
    _pageSource = MaterialPdfPageImageSource(
      fileId: widget.data['fileId'] ?? (widget.data['id'] == 101 ? 1 : null),
      jwtToken: _jwtToken,
      bookData: widget.data,
      isDarkMode: _isDarkMode,
    );
  }

  void _loadToken() async {
    try {
      final token = await AuthService().getToken();
      if (mounted) {
        setState(() {
          _jwtToken = token;
          _initPageSource();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      if (_isZoomMode) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
        );
      } else {
        _flipController.next();
      }
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      if (_isZoomMode) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
        );
      } else {
        _flipController.previous();
      }
    }
  }

  void _showTableOfContents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Colors.white,
      builder: (ctx) => Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 420),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.list_alt, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Mục lục sách điện tử',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            Expanded(
              child: ListView.separated(
                itemCount: _chapters.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (_, idx) {
                  final ch = _chapters[idx];
                  final isCurrent =
                      _currentPage >= ch['startPage'] &&
                      _currentPage <= ch['endPage'];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isCurrent ? Icons.bookmark : Icons.bookmark_border,
                      color: isCurrent ? AppColors.primary : AppColors.textSub,
                    ),
                    title: Text(
                      ch['title'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textMain,
                      ),
                    ),
                    trailing: Text(
                      'Tr. ${ch['startPage']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSub,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      final targetPage = ch['startPage'] as int;
                      setState(() {
                        _currentPage = targetPage;
                      });
                      _flipController.jumpTo(targetPage - 1);
                      if (_isZoomMode && _pageController.hasClients) {
                        _pageController.jumpToPage(targetPage - 1);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitizedCanvas(int pageNum) {
    final paperText = _isDarkMode
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF2C2C2C);
    final paperBorder = _isDarkMode
        ? const Color(0xFF333333)
        : const Color(0xFFE8E5DD);

    final lesson = BookMockContentProvider.resolve(widget.data, pageNum);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                lesson.chapterTitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: _isDarkMode ? Colors.grey[400] : AppColors.textSub,
                ),
              ),
            ),
            Text(
              'TRANG $pageNum',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: paperBorder),
        const SizedBox(height: 16),
        Text(
          lesson.lessonTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: paperText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isDarkMode
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.06),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_stories,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    lesson.tipTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                lesson.tipText,
                style: TextStyle(fontSize: 12, height: 1.5, color: paperText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          lesson.exTitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: paperText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isDarkMode ? const Color(0xFF252525) : Colors.white,
            border: Border.all(color: paperBorder),
          ),
          child: Text(
            lesson.exContent,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              height: 1.6,
              color: paperText,
            ),
          ),
        ),
        if (lesson.exTitle2.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            lesson.exTitle2,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: paperText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lesson.exContent2,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: paperText,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Divider(height: 1, color: paperBorder),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${lesson.footerBookName} - Đại Việt EdTech',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: _isDarkMode ? Colors.grey[500] : AppColors.textSub,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '- $pageNum -',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.grey[400] : AppColors.textMain,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageItem(int pageNum) {
    final fileId =
        widget.data['fileId'] ?? (widget.data['id'] == 101 ? 1 : null);
    final pageUrl = fileId != null
        ? '${ApiConstants.baseUrl}/materials/files/$fileId/pages/$pageNum?dpi=115'
        : null;

    final paperBg = _isDarkMode
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFCFBF7);
    final paperBorder = _isDarkMode
        ? const Color(0xFF333333)
        : const Color(0xFFE8E5DD);

    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 3.5,
      clipBehavior: Clip.none,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 520),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: paperBg,
              border: Border.all(color: paperBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: _isDarkMode ? 0.35 : 0.08,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: pageUrl != null
                ? Image.network(
                    pageUrl,
                    headers: _jwtToken != null
                        ? {'Authorization': 'Bearer $_jwtToken'}
                        : null,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        height: 480,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                    : null,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Đang truyền trực tiếp trang $pageNum...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isDarkMode
                                      ? Colors.grey[400]
                                      : AppColors.textSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDigitizedCanvas(pageNum);
                    },
                  )
                : _buildDigitizedCanvas(pageNum),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.data['title'] ?? 'Sách học';
    final subject = widget.data['subjectName'] ?? 'Toán';

    final scaffold = Scaffold(
      backgroundColor: _isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF0EFEB),
      appBar: AppBar(
        backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _isDarkMode ? Colors.white : AppColors.textMain,
          ),
          onPressed: () => Navigator.of(context).pop(_currentPage),
          tooltip: 'Thoát trình đọc',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : AppColors.textMain,
              ),
            ),
            Text(
              '$subject · Đang đọc trang $_currentPage / $_totalPages',
              style: TextStyle(
                fontSize: 11,
                color: _isDarkMode ? Colors.grey[400] : AppColors.textSub,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked
                  ? AppColors.primary
                  : (_isDarkMode ? Colors.white : AppColors.textMain),
            ),
            tooltip: 'Đánh dấu trang',
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isBookmarked
                        ? 'Đã đánh dấu trang $_currentPage'
                        : 'Đã bỏ đánh dấu trang $_currentPage',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: _isDarkMode ? Colors.amber : AppColors.textMain,
            ),
            tooltip: _isDarkMode ? 'Chế độ ban ngày' : 'Chế độ ban đêm',
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
                _initPageSource();
              });
            },
          ),
          IconButton(
            icon: Icon(
              _isZoomMode ? Icons.auto_stories : Icons.zoom_in,
              color: _isZoomMode
                  ? AppColors.primary
                  : (_isDarkMode ? Colors.white : AppColors.textMain),
            ),
            tooltip: _isZoomMode
                ? 'Chuyển sang chế độ lật sách 3D'
                : 'Chuyển sang chế độ phóng to chi tiết',
            onPressed: () {
              setState(() {
                _isZoomMode = !_isZoomMode;
              });
              if (_isZoomMode) {
                _pageController = PageController(initialPage: _currentPage - 1);
              } else {
                _flipController.jumpTo(_currentPage - 1);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isZoomMode
                        ? 'Chế độ Phóng to: Dùng 2 ngón tay hoặc con lăn để zoom'
                        : 'Chế độ Lật sách 3D: Vuốt góc hoặc chạm mép để lật trang',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.menu_book_outlined,
              color: _isDarkMode ? Colors.white : AppColors.textMain,
            ),
            tooltip: 'Mục lục',
            onPressed: _showTableOfContents,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: _isDarkMode ? const Color(0xFF333333) : AppColors.border,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            child: Row(
              children: [
                Icon(
                  Icons.menu_book,
                  size: 14,
                  color: _isDarkMode ? Colors.grey[400] : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentChapterTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: _isDarkMode ? Colors.grey[400] : AppColors.textSub,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _isZoomMode ? 'Chế độ Phóng to' : 'Chế độ Lật 3D',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: _isDarkMode ? const Color(0xFF333333) : AppColors.border,
          ),
          Expanded(
            child: _isZoomMode
                ? PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _totalPages,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index + 1;
                      });
                      _flipController.jumpTo(index);
                    },
                    itemBuilder: (context, index) {
                      return _buildPageItem(index + 1);
                    },
                  )
                : PageFlipView(
                    pageCount: _totalPages,
                    source: _pageSource,
                    initialPage: _currentPage - 1,
                    controller: _flipController,
                    aspectRatio: 1 / 1.4142,
                    paperColor: _isDarkMode
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFFCFBF7),
                    backColor: _isDarkMode
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF8F9FA),
                    shadow: true,
                    hintOnOpen: true,
                    onPageChanged: (pageIndex) {
                      setState(() {
                        _currentPage = pageIndex + 1;
                      });
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(pageIndex);
                      }
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          border: Border(
            top: BorderSide(
              color: _isDarkMode ? const Color(0xFF333333) : AppColors.border,
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: _currentPage > 1
                      ? (_isDarkMode ? Colors.white : AppColors.textMain)
                      : Colors.grey[400],
                  onPressed: _currentPage > 1 ? _prevPage : null,
                  tooltip: 'Trang trước',
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: _isDarkMode
                          ? Colors.grey[800]
                          : AppColors.border,
                      thumbColor: AppColors.primary,
                      trackHeight: 3.0,
                    ),
                    child: Slider(
                      min: 1.0,
                      max: _totalPages.toDouble(),
                      value: _currentPage.toDouble(),
                      divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                      onChanged: (val) {
                        final target = val.toInt();
                        if (target != _currentPage) {
                          setState(() {
                            _currentPage = target;
                          });
                          _flipController.jumpTo(target - 1);
                          if (_isZoomMode && _pageController.hasClients) {
                            _pageController.jumpToPage(target - 1);
                          }
                        }
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: _currentPage < _totalPages
                      ? (_isDarkMode ? Colors.white : AppColors.textMain)
                      : Colors.grey[400],
                  onPressed: _currentPage < _totalPages ? _nextPage : null,
                  tooltip: 'Trang sau',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiến độ: ${((_currentPage / _totalPages) * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _isDarkMode ? Colors.grey[400] : AppColors.textSub,
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 12,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Đã tự động lưu trang $_currentPage',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
            child: ClipRect(child: scaffold),
          ),
        ),
      ),
    );
  }
}
