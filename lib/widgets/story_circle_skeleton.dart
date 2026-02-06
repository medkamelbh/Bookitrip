import 'package:flutter/material.dart';
import 'package:TunisiaBook/constants/theme.dart';

class StoryCircleSkeleton extends StatefulWidget {
  final AppTheme theme;

  const StoryCircleSkeleton({
    super.key,
    required this.theme,
  });

  @override
  State<StoryCircleSkeleton> createState() => _StoryCircleSkeletonState();
}

class _StoryCircleSkeletonState extends State<StoryCircleSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: widget.theme.surface.withOpacity(_animation.value),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.theme.secondary.withOpacity(_animation.value),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: widget.theme.surface.withOpacity(_animation.value),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      },
    );
  }
}