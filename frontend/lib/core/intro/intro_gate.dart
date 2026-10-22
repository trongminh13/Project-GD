import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ashadeep/core/intro/book_mascot_painter.dart';
import 'package:ashadeep/core/intro/intro_policy.dart';

/// Bọc màn đầu tiên của app. Hiện intro "sách đi bộ" nếu quy tắc cho phép,
/// xong thì dựng `builder`.
///
/// Cách dùng:
/// ```dart
/// home: IntroGate(
///   ready: bootstrapFuture,
///   appName: 'Giáo Dục Đại Việt',
///   tagline: 'Cổng thông tin nhà trường',
///   semanticsLabel: 'Ứng dụng nhà trường. Chạm để bỏ qua phần giới thiệu',
///   skipHint: 'Chạm để bỏ qua',
///   builder: (context) => resolvedScreen,
/// )
/// ```
class IntroGate extends StatefulWidget {
  IntroGate({
    super.key,
    required this.ready,
    required this.builder,
    required this.appName,
    required this.semanticsLabel,
    this.tagline,
    this.skipHint,
    IntroPolicy? policy,
    Duration? duration,
    this.palette,
    this.holdLimit = const Duration(seconds: 1),
    this.reducedMotionDuration = const Duration(milliseconds: 700),
  })  : policy = policy ?? SharedPrefsIntroPolicy(),
        duration = duration ?? const Duration(milliseconds: 2000);

  /// Hoàn thành khi việc khởi động thật xong. Lỗi cũng được coi là xong
  /// (màn kế tiếp tự xử lý lỗi của nó).
  final Future<void> ready;

  /// Màn kế tiếp. Chỉ được dựng sau khi intro kết thúc hoặc không hiện.
  final WidgetBuilder builder;

  final String appName;
  final String? tagline;
  final String semanticsLabel;

  /// Dòng nhắc nhỏ ở đáy, ví dụ "Chạm để bỏ qua". Bỏ trống thì không hiện.
  final String? skipHint;

  final IntroPolicy policy;

  /// Tổng thời lượng. Mặc định 2 giây (2000ms) đồng bộ cho cả Web và App.
  final Duration duration;

  /// Bảng màu của intro. Bỏ trống (null) thì tự động nhận diện theo Dark/Light Mode.
  final IntroPalette? palette;

  /// Thời gian chờ thêm tối đa khi animation vẫy xong mà `ready` chưa xong.
  final Duration holdLimit;

  /// Thời gian hiện hình tĩnh khi người dùng bật "giảm chuyển động".
  final Duration reducedMotionDuration;

  @override
  State<IntroGate> createState() => _IntroGateState();
}

class _IntroGateState extends State<IntroGate>
    with SingleTickerProviderStateMixin {
  static const double _poseAtRest = BookMascotPainter.tEnter; // sách đứng giữa, tay thả xuống
  static const double _poseBeforeExit = BookMascotPainter.tWave;

  late final AnimationController _controller;
  late final Animation<double> _titleOpacity;
  Timer? _timer;

  bool _deciding = true;
  bool _finished = false;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    // Chữ hiện ở 0.38 – 0.46, giữ đến 0.72, mờ dần đến 0.92.
    _titleOpacity = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: ConstantTween<double>(0), weight: 38),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 0, end: 1), weight: 8),
      TweenSequenceItem<double>(tween: ConstantTween<double>(1), weight: 26),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1, end: 0), weight: 20),
      TweenSequenceItem<double>(tween: ConstantTween<double>(0), weight: 8),
    ]).animate(_controller);
    _start();
  }

  Future<void> _start() async {
    final show = await widget.policy.shouldShow();
    if (!mounted) return;
    if (!show) {
      setState(() {
        _deciding = false;
        _finished = true;
      });
      return;
    }

    _reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    unawaited(widget.policy.markShown());
    if (_reduced) _controller.value = _poseAtRest;
    setState(() => _deciding = false);

    // Giai đoạn 1: đi vào và vẫy tay (hoặc hiện hình tĩnh nếu giảm chuyển động).
    if (_reduced) {
      await _wait(widget.reducedMotionDuration);
    } else {
      await _controller.animateTo(
        _poseBeforeExit,
        duration: widget.duration * _poseBeforeExit,
        curve: Curves.linear,
      );
    }
    if (!mounted || _finished) return;

    // Giữ tư thế cho đến khi khởi động xong (tối đa holdLimit).
    await _holdUntilReady();
    if (!mounted || _finished) return;

    // Giai đoạn 2: đi ra.
    if (!_reduced) {
      await _controller.animateTo(
        1.0,
        duration: widget.duration * (1 - _poseBeforeExit),
        curve: Curves.linear,
      );
    }
    _finish();
  }

  Future<void> _wait(Duration d) {
    final done = Completer<void>();
    _timer = Timer(d, () {
      if (!done.isCompleted) done.complete();
    });
    return done.future;
  }

  Future<void> _holdUntilReady() {
    final done = Completer<void>();
    void complete() {
      if (!done.isCompleted) done.complete();
    }

    widget.ready.then<void>((_) => complete(), onError: (Object _) => complete());
    _timer?.cancel();
    _timer = Timer(widget.holdLimit, complete);
    return done.future.whenComplete(() => _timer?.cancel());
  }

  /// Chỉ chạy một lần dù bị gọi từ chạm bỏ qua hay từ hết giờ.
  void _finish() {
    if (_finished || !mounted) return;
    _timer?.cancel();
    _controller.stop();
    setState(() => _finished = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  IntroPalette _resolvePalette(BuildContext context) {
    if (widget.palette != null) return widget.palette!;
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        MediaQuery.maybeOf(context)?.platformBrightness == Brightness.dark;
    return isDark ? IntroPalette.dark : IntroPalette.standard;
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return widget.builder(context);

    final p = _resolvePalette(context);
    if (_deciding) return ColoredBox(color: p.background);

    final media = MediaQuery.maybeOf(context);
    final bottomInset = media?.padding.bottom ?? 0;

    return Semantics(
      container: true,
      button: true,
      label: widget.semanticsLabel,
      onTap: _finish,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _finish,
          child: Material(
            color: p.background,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final s = BookMascotPainter.scaleFor(constraints.maxWidth);
                return Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: BookMascotPainter(
                            progress: _controller,
                            palette: p,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: constraints.maxHeight / 2 + 44 * s,
                      child: FadeTransition(
                        opacity: _reduced
                            ? const AlwaysStoppedAnimation<double>(1)
                            : _titleOpacity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              widget.appName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                                color: p.ink,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (widget.tagline != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  widget.tagline!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: p.muted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.skipHint != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 24 + bottomInset,
                        child: Text(
                          widget.skipHint!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: p.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
