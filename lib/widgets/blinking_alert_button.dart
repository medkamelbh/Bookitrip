import 'package:flutter/material.dart';

class BlinkingAlertButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color baseColor;
  final Color alertColor;

  const BlinkingAlertButton({
    super.key,
    required this.onPressed,
    required this.baseColor,
    this.alertColor = Colors.grey,
  });

  @override
  State<BlinkingAlertButton> createState() => _BlinkingAlertButtonState();
}

class _BlinkingAlertButtonState extends State<BlinkingAlertButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: widget.baseColor.withValues(alpha: 0.1),
      end: widget.alertColor.withValues(alpha: 0.3),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.onPressed,
      icon: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return CircleAvatar(
            backgroundColor: _colorAnimation.value,
            child: child,
          );
        },
        child: Icon(
          Icons.smart_toy_outlined,
          color: widget.baseColor,
          size: 30,
        ),
      ),
    );
  }
}