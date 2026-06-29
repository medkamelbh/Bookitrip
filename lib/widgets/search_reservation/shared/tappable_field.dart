import 'package:flutter/material.dart';

class TappableField extends StatelessWidget {
  const TappableField({
    super.key,
    required this.icon,
    required this.hint,
    required this.fieldBg,
    required this.iconColor,
    required this.hintColor,
    required this.valueColor,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String hint;
  final Color fieldBg;
  final Color iconColor;
  final Color hintColor;
  final Color valueColor;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: fieldBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 14,
                  color: value != null ? valueColor : hintColor,
                  fontWeight:
                  value != null ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (value != null)
              Icon(Icons.check_circle_rounded, size: 16, color: iconColor),
          ],
        ),
      ),
    );
  }
}