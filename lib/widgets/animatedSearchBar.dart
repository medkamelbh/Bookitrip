import 'package:BookiTrip/constants/theme.dart';
import 'package:flutter/material.dart';

class AnimatedSearchBar extends StatefulWidget {
  final AppTheme theme;
  final String hint;
  final ValueChanged<String> onChanged;

  const AnimatedSearchBar({
    Key? key,
    required this.theme,
    required this.hint,
    required this.onChanged,
  }) : super(key: key);

  @override
  _AnimatedSearchBarState createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: widget.theme.CardBG,
          borderRadius: BorderRadius.circular(15),
          boxShadow: _isFocused
              ? [
            BoxShadow(
              color: widget.theme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: widget.onChanged,
          onTap: () {
            setState(() => _isFocused = true);
            _controller.forward();
          },
          onTapOutside: (_) {
            setState(() => _isFocused = false);
            _controller.reverse();
          },
          style: TextStyle(color: widget.theme.text),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: widget.theme.text.withValues(alpha: 0.4)),
            prefixIcon: Icon(
              Icons.search,
              color: _isFocused
                  ? widget.theme.primary
                  : widget.theme.text.withValues(alpha: 0.4),
            ),
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }
}