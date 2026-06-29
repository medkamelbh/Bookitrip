import 'package:BookiTrip/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CircuitBody extends StatelessWidget {
  const CircuitBody({
    super.key,
    required this.theme,
    required this.onManualTap,
    required this.onAutoTap,
  });

  final AppTheme theme;
  final VoidCallback onManualTap;
  final VoidCallback onAutoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        Text(
          'search.choose_circuit_type'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: theme.isDark ? Colors.white54 : Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CircuitButton(
                theme: theme,
                label: 'search.manual_circuit'.tr(),
                icon: Icons.edit_road_rounded,
                onTap: onManualTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CircuitButton(
                theme: theme,
                label: 'search.auto_circuit'.tr(),
                icon: Icons.auto_awesome_rounded,
                isPrimary: true,
                onTap: onAutoTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _CircuitButton extends StatelessWidget {
  const _CircuitButton({
    required this.theme,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final AppTheme theme;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final Color bg = isPrimary
        ? theme.primary
        : (theme.isDark ? theme.surface : const Color(0xFFF0F0F0));
    final Color fg = isPrimary
        ? Colors.white
        : (theme.isDark ? Colors.white70 : theme.primary);
    final Color borderColor =
    isPrimary ? Colors.transparent : theme.primary.withOpacity(0.3);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}