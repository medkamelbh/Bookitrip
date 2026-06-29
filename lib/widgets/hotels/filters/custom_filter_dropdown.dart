import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:BookiTrip/constants/theme.dart';

class CustomFilterDropdown extends StatelessWidget {
  final AppTheme theme;
  final String label;
  final IconData icon;
  final List<Widget> options;
  final void Function(int)? onSelectedIndex;

  // NEW: Dark-mode aware colors
  final Color? backgroundColor;
  final Color? optionBackgroundColor;

  const CustomFilterDropdown({
    super.key,
    required this.theme,
    required this.label,
    required this.icon,
    required this.options,
    this.onSelectedIndex,
    this.backgroundColor,
    this.optionBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = theme.isDark;
    final locale = context.locale;

    final Color defaultBgColor =
        backgroundColor ??
            (isDark ? theme.primary.withValues(alpha: 0.7) : theme.primary.withValues(alpha: 0.8));

    final Color defaultOptionColor =
        optionBackgroundColor ?? (isDark ? Colors.black : Colors.white);

    return PopupMenuButton<int>(
      color: defaultOptionColor,
      onSelected: (index) {
        if (onSelectedIndex != null) onSelectedIndex!(index);
      },

      itemBuilder: (context) {
        return List.generate(
          options.length,
              (index) => PopupMenuItem<int>(
            value: index,
            child: DefaultTextStyle(
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
              child: options[index],
            ),
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: defaultBgColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? theme.primary.withValues(alpha: 0.4)
                  : theme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white : Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
