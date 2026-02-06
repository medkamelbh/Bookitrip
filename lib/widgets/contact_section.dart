import 'package:TunisiaBook/constants/theme.dart';
import 'package:flutter/material.dart';

class ContactDetailRow extends StatelessWidget {
  final AppTheme theme;
  final IconData icon;
  final String text;
  final bool isLink;

  const ContactDetailRow({
    super.key,
    required this.theme,
    required this.icon,
    required this.text,
    required this.isLink,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Icon(icon, color: theme.primary, size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isLink ? theme.primary : theme.text,
                fontSize: 14,
                fontWeight: isLink ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

