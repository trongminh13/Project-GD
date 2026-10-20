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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textMainOf(context),
          ),
        ),
        if (linkLabel != null && onLink != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onLink,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  linkLabel!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
