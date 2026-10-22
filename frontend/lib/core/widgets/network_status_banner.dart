import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

/// Thanh thông báo trạng thái kết nối mạng và đồng bộ nền (SWR Resilient Banner)
class NetworkStatusBanner extends StatelessWidget {
  final bool isSyncing;
  final bool isOffline;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const NetworkStatusBanner({
    super.key,
    this.isSyncing = false,
    this.isOffline = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSyncing && !isOffline && (errorMessage == null || errorMessage!.isEmpty)) {
      return const SizedBox.shrink();
    }

    if (isSyncing) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          border: Border(
            bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Đang kiểm tra cập nhật mới...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    // Trạng thái mất mạng hoặc lỗi kết nối
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        border: Border.all(color: const Color(0xFFF8B4B4)),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_outlined,
            size: 16,
            color: AppColors.dangerRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage ?? 'Mất kết nối mạng. Đang hiển thị bản lưu gần nhất.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9B1C1C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.dangerRed,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: const Size(40, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
