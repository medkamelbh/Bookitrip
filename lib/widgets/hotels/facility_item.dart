import 'package:BookiTrip/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FacilityItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const FacilityItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: theme.primary, size: 20),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(color: theme.text, fontSize: 13),
        ),
      ],
    );
  }
}