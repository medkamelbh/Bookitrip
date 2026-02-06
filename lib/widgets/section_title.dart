import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:TunisiaBook/constants/theme.dart';

class SectionTitleWidget extends StatelessWidget {
  final String title;
  final AppTheme theme;
  final bool showMore;
  final VoidCallback? onTap;

  const SectionTitleWidget({
    super.key,
    required this.title,
    required this.theme,
    this.showMore = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculate responsive scale factor
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scale = screenWidth / 375; // Normalized against standard mobile width

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 2. Wrap Title in Flexible to prevent overflow on small screens
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              color: theme.text,
              // Scaling font size: clamps between 16 and 24 to prevent extreme sizes
              fontSize: (16 * scale).clamp(16.0, 24.0),
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        if (showMore) ...[
          const SizedBox(width: 10), // Minimal spacing
          GestureDetector(
            onTap: onTap,
            child: Text(
              'common.see_more'.tr(),
              style: TextStyle(
                color: theme.primary,
                fontWeight: FontWeight.w600,
                fontSize: (13 * scale).clamp(12.0, 16.0),
              ),
            ),
          ),
        ],
      ],
    );
  }
}