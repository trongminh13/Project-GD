import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

class AppEmptyCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;

  const AppEmptyCard({
    super.key,
    required this.title,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.cardBorder, width: AppColors.cardBorderWidth),
        borderRadius: AppColors.cardBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.textSub, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSub,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
