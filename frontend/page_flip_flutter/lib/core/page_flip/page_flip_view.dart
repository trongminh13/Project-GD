import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fold_geometry.dart';
import 'page_fold_painter.dart';
import 'page_image_window.dart';

/// Điều khiển [PageFlipView] từ bên ngoài (nút "Trang sau", "Trang trước"...).
class PageFlipController {
  _PageFlipViewState? _state;

  void next() => _state?._auto(true);
  void previous() => _state?._auto(false);

  /// Nhảy tới trang không có hoạt ảnh.
  void jumpTo(int page) => _state?._jumpTo(page);

  /// Chạy một lần gợi ý: nhấc góc trang lên rồi hạ xuống.
  void showHint() => _state?._peek();

  int get currentPage => _state?._front ?? 0;
}

/// Vùng đọc sách một mặt với hiệu ứng lật trang.
///
///  - Vuốt từ phải sang trái: trang sau. Vuốt từ trái sang phải: trang trước.
///  - Chạm vào 40% bên phải: trang sau. Chạm vào 40% bên trái: trang trước.
///  - Phím mũi tên trái và phải (web, máy tính).
///  - Hành động tăng/giảm của trợ năng (`Semantics`).
///  - Bật "giảm chuyển động" của hệ điều hành: mờ dần thay vì gập.
///
/// Chỉ lật khi ảnh của trang đích đã sẵn sàng, nên mạng chậm không gây nhấp nháy.
class PageFlipView extends StatefulWidget {
  const PageFlipView({
    super.key,
    required this.pageCount,
    required this.source,
    this.initialPage = 0,
    this.onPageChanged,
    this.controller,
    this.aspectRatio = 1 / 1.4142,
    this.flipDuration = const Duration(milliseconds: 340),
    this.liftFactor = 0.35,
    this.shadow = false,
    this.paperColor = const Color(0xFFFFFFFF),
    this.backColor = const Color(0xFFF1F3F4),
    this.maxDecodeWidth,
    this.thumbWidth = 360,
    this.enableHaptics = true,
    this.reducedMotion,
    this.hintOnOpen = false,
    this.semanticsLabel,
    this.loadingBuilder,
  }) : assert(pageCount > 0);

  final int pageCount;

  /// Nguồn ảnh trang, ví dụ [BytesPageImageSource] gọi API backend.
  final PageImageSource source;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;
  final PageFlipController? controller;

  /// Tỷ lệ rộng/cao của trang. Mặc định A4 dọc.
  final double aspectRatio;

  /// Thời gian hoàn tất lật khi kéo gần hết (rút ngắn khi đã kéo được nhiều).
  final Duration flipDuration;

  /// Ngón tay kéo lên cao thì góc nhấc lên bao nhiêu (0 đến khoảng 0,6).
  final double liftFactor;
  final bool shadow;
  final Color paperColor;
  final Color backColor;

  /// Chiều rộng giải mã tối đa (px). Mặc định 1080 trên app và 900 trên web.
  final int? maxDecodeWidth;
  final int thumbWidth;
  final bool enableHaptics;

  /// `null` nghĩa là theo cài đặt "giảm chuyển động" của hệ điều hành.
  final bool? reducedMotion;
  final bool hintOnOpen;

  /// Nhãn trợ năng, ví dụ `(page, total) => 'Trang $page trên $total'`.
  final String Function(int page, int total)? semanticsLabel;

  /// Hiện khi ảnh trang hiện tại chưa tải xong.
  final WidgetBuilder? loadingBuilder;

  @override
  State<PageFlipView> createState() => _PageFlipViewState();
}

enum _Mode { none, ignored, forward, back, fade }

enum _AnimMode { flip, fade, peek }

enum _FlipKind { forward, forwardCancel, back, backCancel }

class _Drag {
  _Drag(this.sx, this.sy);
  final double sx;
  final double sy;
  _Mode mode = _Mode.none;
  double extra = 0;
  double dx = 0;
}

class _PageFlipViewState extends State<PageFlipView> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final ValueNotifier<PageFrame> _frame = ValueNotifier<PageFrame>(const PageFrame(front: 0));
  PageImageWindow? _window;

  int _front = 0;
  int _settled = 0;
  Size _size = Size.zero;
  _Drag? _drag;

  _AnimMode? _animMode;
  _FlipKind _kind = _FlipKind.forward;
  double _from = 0;
  double _to = 0;
  double _extra0 = 0;
  int _fadeTo = 0;
  bool _hinted = false;

  bool get _reduced =>
      widget.reducedMotion ?? (MediaQuery.maybeOf(context)?.disableAnimations ?? false);

  @override
  void initState() {
    super.initState();
    _front = widget.initialPage.clamp(0, widget.pageCount - 1).toInt();
    _settled = _front;
    _frame.value = PageFrame(front: _front);
    _anim = AnimationController(vsync: this)
      ..addListener(_onTick)
      ..addStatusListener(_onStatus);
    widget.controller?._state = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureWindow();
  }

  @override
  void didUpdateWidget(PageFlipView old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?._state = null;
      widget.controller?._state = this;
    }
    if (old.source != widget.source || old.pageCount != widget.pageCount) {
      _front = _front.clamp(0, widget.pageCount - 1).toInt();
      _settled = _front;
      _frame.value = PageFrame(front: _front);
      _ensureWindow(force: true);
    }
  }

  void _ensureWindow({bool force = false}) {
    final mq = MediaQuery.of(context);
    final cap = widget.maxDecodeWidth ?? (kIsWeb ? 900 : 1080);
    final target = (mq.size.width * mq.devicePixelRatio).round().clamp(320, cap).toInt();
    final w = _window;
    if (!force && w != null && (w.targetWidth - target).abs() <= w.targetWidth * 0.25) return;
    _window?.dispose();
    _window = PageImageWindow(
      source: widget.source,
      pageCount: widget.pageCount,
      targetWidth: target,
      thumbWidth: widget.thumbWidth,
    )..setCenter(_front);
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    _anim.dispose();
    _frame.dispose();
    _window?.dispose();
    super.dispose();
  }

  // ---------- Hoạt ảnh ----------

  void _onTick() {
    switch (_animMode) {
      case _AnimMode.flip:
        final s = Curves.easeOutCubic.transform(_anim.value);
        final px = _from + (_to - _from) * s;
        _frame.value = PageFrame(
          front: _front,
          corner: FoldGeometry.cornerFor(_size, px, _extra0 * (1 - s)),
        );
        break;
      case _AnimMode.fade:
        _frame.value = PageFrame(front: _front, fadeTo: _fadeTo, fadeAlpha: _anim.value);
        break;
      case _AnimMode.peek:
        final k = math.sin(math.pi * _anim.value);
        _frame.value = PageFrame(
          front: _front,
          corner: FoldGeometry.cornerFor(_size, _size.width - 46 * k, 22 * k),
        );
        break;
      case null:
        break;
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final mode = _animMode;
    _animMode = null;
    switch (mode) {
      case _AnimMode.flip:
        if (_kind == _FlipKind.forward || _kind == _FlipKind.backCancel) _front += 1;
        _settle();
        break;
      case _AnimMode.fade:
        _front = _fadeTo;
        _settle();
        break;
      case _AnimMode.peek:
        _frame.value = PageFrame(front: _front);
        break;
      case null:
        break;
    }
  }

  /// Chạy phần còn lại của một lần lật từ hoành độ góc [from].
  void _runFlip(_FlipKind kind, double from, double extra0) {
    final w = _size.width;
    final target = (kind == _FlipKind.forward || kind == _FlipKind.backCancel) ? -w : w;
    final dist = (target - from).abs() / (2 * w);
    final ms = (widget.flipDuration.inMilliseconds * (0.45 + 0.55 * dist)).clamp(140, 700).round();
    _animMode = _AnimMode.flip;
    _kind = kind;
    _from = from;
    _to = target;
    _extra0 = extra0;
    _frame.value = PageFrame(front: _front, corner: FoldGeometry.cornerFor(_size, from, extra0));
    _anim.duration = Duration(milliseconds: ms);
    _anim.forward(from: 0);
  }

  void _startFade(int to) {
    _animMode = _AnimMode.fade;
    _fadeTo = to;
    _anim.duration = const Duration(milliseconds: 140);
    _anim.forward(from: 0);
  }

  void _peek() {
    if (_reduced || _anim.isAnimating || _drag != null) return;
    if (_front + 1 >= widget.pageCount) return;
    _animMode = _AnimMode.peek;
    _anim.duration = const Duration(milliseconds: 1000);
    _anim.forward(from: 0);
  }

  void _cancelPeek() {
    if (_animMode == _AnimMode.peek) {
      _anim.stop();
      _animMode = null;
      _frame.value = PageFrame(front: _front);
    }
  }

  void _settle() {
    _frame.value = PageFrame(front: _front);
    _window?.setCenter(_front);
    if (_front != _settled) {
      _settled = _front;
      if (widget.enableHaptics) HapticFeedback.selectionClick();
      widget.onPageChanged?.call(_front);
    }
    if (mounted) setState(() {});
  }

  void _jumpTo(int page) {
    if (_anim.isAnimating) {
      _anim.stop();
      _animMode = null;
    }
    _drag = null;
    _front = page.clamp(0, widget.pageCount - 1).toInt();
    _settle();
  }

  bool _ready(int index) => _window?.imageOf(index) != null;

  /// Lật bằng chạm, nút, phím hoặc trợ năng.
  void _auto(bool forward) {
    if (_anim.isAnimating || _drag != null) return;
    final target = forward ? _front + 1 : _front - 1;
    if (target < 0 || target >= widget.pageCount) return;
    if (!_ready(target) || !_ready(_front)) return;
    if (_reduced) {
      _startFade(target);
      return;
    }
    if (forward) {
      _runFlip(_FlipKind.forward, _size.width - 1, 0);
    } else {
      _front -= 1;
      _runFlip(_FlipKind.back, -_size.width + 1, 0);
    }
  }

  // ---------- Cử chỉ ----------

  void _onDown(DragDownDetails d) => _cancelPeek();

  void _onDragStart(DragStartDetails d) {
    if (_anim.isAnimating) {
      _drag = null;
      return;
    }
    _drag = _Drag(d.localPosition.dx, d.localPosition.dy);
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final drag = _drag;
    if (drag == null) return;
    final w = _size.width;
    final p = d.localPosition;
    drag.dx = p.dx - drag.sx;

    if (drag.mode == _Mode.none) {
      if (drag.dx.abs() < 1) return;
      if (drag.dx < 0 && drag.sx > 0.3 * w && _front < widget.pageCount - 1 && _ready(_front + 1)) {
        drag.mode = _reduced ? _Mode.fade : _Mode.forward;
      } else if (drag.dx > 0 && drag.sx < 0.7 * w && _front > 0 && _ready(_front - 1)) {
        drag.mode = _reduced ? _Mode.fade : _Mode.back;
        if (drag.mode == _Mode.back) _front -= 1;
      } else {
        drag.mode = _Mode.ignored;
        return;
      }
    }
    if (drag.mode == _Mode.fade || drag.mode == _Mode.ignored) return;

    drag.extra = math.max(0.0, drag.sy - p.dy) * widget.liftFactor;
    final px = drag.mode == _Mode.forward
        ? (w + drag.dx).clamp(-w, w).toDouble()
        : (-w + 2 * drag.dx).clamp(-w, w).toDouble();
    _frame.value = PageFrame(front: _front, corner: FoldGeometry.cornerFor(_size, px, drag.extra));
  }

  void _onDragEnd(DragEndDetails e) => _finishDrag(cancelled: false, velocity: (e.primaryVelocity ?? 0) / 1000);

  void _onDragCancel() => _finishDrag(cancelled: true, velocity: 0);

  void _finishDrag({required bool cancelled, required double velocity}) {
    final drag = _drag;
    _drag = null;
    if (drag == null) return;
    final w = _size.width;
    final px = _frame.value.corner?.dx ?? w;
    final vx = velocity; // px/ms, âm là đang vuốt sang trái

    switch (drag.mode) {
      case _Mode.forward:
        final go = !cancelled && (px < 0.55 * w || vx < -0.7) && vx < 0.7;
        _runFlip(go ? _FlipKind.forward : _FlipKind.forwardCancel, px, drag.extra);
        break;
      case _Mode.back:
        final go = !cancelled && (px > -0.4 * w || vx > 0.7) && vx > -0.7;
        _runFlip(go ? _FlipKind.back : _FlipKind.backCancel, px, drag.extra);
        break;
      case _Mode.fade:
        if (!cancelled && drag.dx < -40 && _front < widget.pageCount - 1 && _ready(_front + 1)) {
          _startFade(_front + 1);
        } else if (!cancelled && drag.dx > 40 && _front > 0 && _ready(_front - 1)) {
          _startFade(_front - 1);
        }
        break;
      case _Mode.none:
      case _Mode.ignored:
        break;
    }
  }

  void _onTapUp(TapUpDetails d) {
    if (_anim.isAnimating || _drag != null) return;
    final x = d.localPosition.dx;
    if (x > 0.6 * _size.width) {
      _auto(true);
    } else if (x < 0.4 * _size.width) {
      _auto(false);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _auto(true);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _auto(false);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ---------- Giao diện ----------

  @override
  Widget build(BuildContext context) {
    final window = _window!;
    final total = widget.pageCount;
    final label = widget.semanticsLabel ?? (int p, int t) => 'Trang $p trên $t';

    return LayoutBuilder(
      builder: (context, c) {
        var w = c.maxWidth;
        var h = w / widget.aspectRatio;
        if (c.hasBoundedHeight && h > c.maxHeight) {
          h = c.maxHeight;
          w = h * widget.aspectRatio;
        }
        _size = Size(w, h);

        if (widget.hintOnOpen && !_hinted) {
          _hinted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _ready(_front)) _peek();
          });
        }

        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: Focus(
              onKeyEvent: _onKey,
              child: Semantics(
                container: true,
                value: label(_front + 1, total),
                increasedValue: _front + 1 < total ? label(_front + 2, total) : null,
                decreasedValue: _front > 0 ? label(_front, total) : null,
                onIncrease: _front + 1 < total ? () => _auto(true) : null,
                onDecrease: _front > 0 ? () => _auto(false) : null,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragDown: _onDown,
                  onHorizontalDragStart: _onDragStart,
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  onHorizontalDragCancel: _onDragCancel,
                  onTapUp: _onTapUp,
                  child: RepaintBoundary(
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        CustomPaint(
                          painter: PageFoldPainter(
                            frame: _frame,
                            window: window,
                            pageCount: total,
                            shadow: widget.shadow,
                            paperColor: widget.paperColor,
                            backColor: widget.backColor,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: window,
                          builder: (context, _) {
                            if (window.imageOf(_front) != null) return const SizedBox.shrink();
                            return widget.loadingBuilder?.call(context) ??
                                const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
