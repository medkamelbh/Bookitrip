// /widgets/circuit_card_skeleton.dart

import 'package:flutter/material.dart';
import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/widgets/skeleton_box.dart';

class CircuitCardSkeleton extends StatelessWidget {
  final AppTheme theme;

  const CircuitCardSkeleton({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SkeletonBox(
        theme: theme,
        width: double.infinity,
        height: double.infinity,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(theme: theme, width: 150, height: 18, radius: 4),
              const SizedBox(height: 8),
              SkeletonBox(theme: theme, width: 100, height: 14, radius: 4),
            ],
          ),
        ),
      ),
    );
  }
}