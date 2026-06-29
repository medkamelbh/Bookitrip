import 'package:flutter/material.dart';

class ImageCounterBadge extends StatelessWidget {
  final int currentIndex;
  final int totalImages;
  final bool showIcon;

  const ImageCounterBadge({
    super.key,
    required this.currentIndex,
    required this.totalImages,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            const Icon(
              Icons.photo_library_outlined,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            "${currentIndex + 1} / $totalImages",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}