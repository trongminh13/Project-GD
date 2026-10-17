import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Button chuẩn hoá tích hợp trạng thái Loading (Spinner), chống double-click,
/// chuyển đổi hiệu ứng mượt mà và hỗ trợ đa dạng kiểu dáng (Primary, Outlined, Danger, Success).
class AppLoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;
  final IconData? icon;
  final double height;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? loadingIndicatorColor;
  final BorderRadius? borderRadius;
  final bool isOutlined;
  final Color? borderColor;
  final double elevation;
  final TextStyle? textStyle;

  const AppLoadingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.loadingText,
    this.icon,
    this.height = 48.0,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.loadingIndicatorColor,
    this.borderRadius,
    this.isOutlined = false,
    this.borderColor,
    this.elevation = 0,
    this.textStyle,
  });

  /// Factory cho nút chính (Primary Blue #2457C5)
  factory AppLoadingButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    String? loadingText,
    IconData? icon,
    double height = 48.0,
    double? width,
    BorderRadius? borderRadius,
    double elevation = 0,
    TextStyle? textStyle,
  }) {
    return AppLoadingButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      loadingText: loadingText,
      icon: icon,
      height: height,
      width: width,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      loadingIndicatorColor: Colors.white,
      borderRadius: borderRadius,
      isOutlined: false,
      elevation: elevation,
      textStyle: textStyle,
    );
  }

  /// Factory cho nút phụ dạng viền (Outlined)
  factory AppLoadingButton.outlined({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    String? loadingText,
    IconData? icon,
    double height = 48.0,
    double? width,
    BorderRadius? borderRadius,
    Color? borderColor,
    Color? textColor,
    TextStyle? textStyle,
  }) {
    return AppLoadingButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      loadingText: loadingText,
      icon: icon,
      height: height,
      width: width,
      backgroundColor: Colors.white,
      textColor: textColor ?? AppColors.textMain,
      loadingIndicatorColor: textColor ?? AppColors.primary,
      borderRadius: borderRadius,
      isOutlined: true,
      borderColor: borderColor ?? AppColors.border,
      elevation: 0,
      textStyle: textStyle,
    );
  }

  /// Factory cho nút cảnh báo / nguy hiểm (Đỏ - Danger)
  factory AppLoadingButton.danger({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    String? loadingText,
    IconData? icon,
    double height = 48.0,
    double? width,
    BorderRadius? borderRadius,
    double elevation = 0,
    TextStyle? textStyle,
  }) {
    return AppLoadingButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      loadingText: loadingText,
      icon: icon,
      height: height,
      width: width,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      loadingIndicatorColor: Colors.white,
      borderRadius: borderRadius,
      isOutlined: false,
      elevation: elevation,
      textStyle: textStyle,
    );
  }

  /// Factory cho nút thành công (Xanh lá - Success)
  factory AppLoadingButton.success({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    String? loadingText,
    IconData? icon,
    double height = 48.0,
    double? width,
    BorderRadius? borderRadius,
    double elevation = 0,
    TextStyle? textStyle,
  }) {
    return AppLoadingButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      loadingText: loadingText,
      icon: icon,
      height: height,
      width: width,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      loadingIndicatorColor: Colors.white,
      borderRadius: borderRadius,
      isOutlined: false,
      elevation: elevation,
      textStyle: textStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(8.0);
    final effectiveBg = backgroundColor ?? AppColors.primary;
    final effectiveFg = textColor ?? (isOutlined ? AppColors.textMain : Colors.white);
    final effectiveIndicatorColor = loadingIndicatorColor ?? (isOutlined ? AppColors.primary : Colors.white);
    final effectiveBorderColor = borderColor ?? AppColors.border;

    final effectiveTextStyle = textStyle ??
        TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w600,
          color: effectiveFg,
          letterSpacing: 0.1,
        );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: effectiveBg,
      foregroundColor: effectiveFg,
      disabledBackgroundColor: isOutlined
          ? Colors.white.withValues(alpha: 0.8)
          : effectiveBg.withValues(alpha: 0.65),
      disabledForegroundColor: effectiveFg.withValues(alpha: 0.8),
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveRadius,
        side: isOutlined ? BorderSide(color: effectiveBorderColor, width: 1.0) : BorderSide.none,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
    );

    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? Row(
              key: const ValueKey('button_loading_state'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveIndicatorColor),
                  ),
                ),
                if (loadingText != null && loadingText!.isNotEmpty) ...[
                  const SizedBox(width: 10.0),
                  Text(
                    loadingText!,
                    style: effectiveTextStyle.copyWith(color: effectiveFg),
                  ),
                ],
              ],
            )
          : Row(
              key: const ValueKey('button_idle_state'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18.0, color: effectiveFg),
                  const SizedBox(width: 8.0),
                ],
                Text(
                  text,
                  style: effectiveTextStyle,
                ),
              ],
            ),
    );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: content,
    );

    if (width != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return SizedBox(
      height: height,
      child: button,
    );
  }
}
