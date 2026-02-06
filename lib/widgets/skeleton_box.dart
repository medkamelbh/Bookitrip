import 'package:flutter/material.dart';
import 'package:TunisiaBook/constants/theme.dart';

// --- REUSABLE ANIMATED SKELETON WIDGET (Shimmer Effect) ---
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final AppTheme theme;
  final Widget? child;

  const SkeletonBox({
    Key? key,
    required this.width,
    required this.height,
    required this.theme,
    this.radius = 8.0,
    this.child,
  }) : super(key: key);

  @override
  _SkeletonBoxState createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Define the color range for the pulsing effect
    final Color startColor = widget.theme.text.withOpacity(0.2);
    final Color endColor = widget.theme.text.withOpacity(0.08);

    _animation = ColorTween(
      begin: startColor,
      end: endColor,
    ).animate(_controller);
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _animation.value,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          child: widget.child,
        );
      },
    );
  }
}