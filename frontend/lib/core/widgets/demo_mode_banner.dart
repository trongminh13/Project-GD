import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';

/// Banner cảnh báo hiển thị trên đầu ứng dụng khi chạy ở chế độ Demo
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!ApiConstants.isDemoMode) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF3CD),
        border: Border(
          bottom: BorderSide(color: Color(0xFFFFEEBA), width: 1.0),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 16, color: Color(0xFF856404)),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'CHẾ ĐỘ TRÌNH CHIẾU DEMO: Đang sử dụng dữ liệu mẫu độc lập, không kết nối cơ sở dữ liệu thật.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF856404),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
