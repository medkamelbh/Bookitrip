import 'package:flutter/material.dart';
import 'package:TunisiaBook/constants/theme.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final AppTheme theme;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: theme.primary, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: theme.text,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}