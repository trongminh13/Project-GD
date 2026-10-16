import 'package:flutter/material.dart';
import 'package:ashadeep/core/theme/app_colors.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? linkLabel;
  final VoidCallback? onLink;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.linkLabel,
    this.onLink,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        if (linkLabel != null && onLink != null)
          InkWell(
            onTap: onLink,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Text(
                linkLabel!,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
