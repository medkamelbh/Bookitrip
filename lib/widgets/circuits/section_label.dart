import 'package:BookiTrip/constants/theme.dart';
import 'package:flutter/material.dart';

class AcSectionLabel extends StatelessWidget {
  final String label;
  final AppTheme theme;
  final EdgeInsetsGeometry padding;

  const AcSectionLabel({
    super.key,
    required this.label,
    required this.theme,
    this.padding = const EdgeInsets.only(bottom: 10, top: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        label,
        style: TextStyle(
          color: theme.text.withOpacity(0.55),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}