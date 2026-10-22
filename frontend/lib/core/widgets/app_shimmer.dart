import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

/// Widget Shimmer / Skeleton Loader chuẩn Design System bo góc 4px phẳng
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE8EAED),
    this.highlightColor = const Color(0xFFF8F9FA),
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              stops: const [0.1, 0.5, 0.9],
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              transform: _SlidingGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double percent;
  const _SlidingGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (percent * 2 - 1), 0.0, 0.0);
  }
}

/// Thẻ Shimmer hình khối chữ nhật bo góc 4px chuẩn thiết kế phẳng
class AppShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAED),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Khung Skeleton giả lập thẻ nội dung (Card Shimmer)
class AppShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final EdgeInsetsGeometry margin;

  const AppShimmerCard({
    super.key,
    this.height = 96,
    this.width,
    this.margin = const EdgeInsets.symmetric(vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        height: height,
        width: width ?? double.infinity,
        margin: margin,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppShimmerBox(width: 80, height: 16),
                const Spacer(),
                const AppShimmerBox(width: 48, height: 16),
              ],
            ),
            const SizedBox(height: 12),
            const AppShimmerBox(width: 180, height: 14),
            const SizedBox(height: 8),
            const AppShimmerBox(width: 120, height: 12),
          ],
        ),
      ),
    );
  }
}
