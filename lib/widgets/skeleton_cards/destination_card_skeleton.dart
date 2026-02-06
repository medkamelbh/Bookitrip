import 'package:flutter/material.dart';
import 'package:TunisiaBook/constants/theme.dart';
import 'package:TunisiaBook/widgets/skeleton_box.dart';

class DestinationCardSkeleton extends StatelessWidget {
  final AppTheme theme;

  const DestinationCardSkeleton({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: SkeletonBox(
                theme: theme,
                width: double.infinity,
                height: double.infinity,
                radius: 0,
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 35,
              right: 35,
              top: 20,
              bottom: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SkeletonBox(theme: theme, width: 120, height: 20, radius: 8),
                  const SizedBox(height: 8),
                  SkeletonBox(theme: theme, width: 80, height: 16, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}