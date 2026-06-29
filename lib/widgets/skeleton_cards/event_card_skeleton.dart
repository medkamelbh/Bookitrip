// /widgets/event_card_skeleton.dart

import 'package:flutter/material.dart';
import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/widgets/skeleton_box.dart';

class EventCardSkeleton extends StatelessWidget {
  final AppTheme theme;

  const EventCardSkeleton({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.7,
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
              SkeletonBox(theme: theme, width: 100, height: 16, radius: 4),
              const SizedBox(height: 5),
              SkeletonBox(theme: theme, width: 60, height: 12, radius: 4),
            ],
          ),
        ),
      ),
    );
  }
}