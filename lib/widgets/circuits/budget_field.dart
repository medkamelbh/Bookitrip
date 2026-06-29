import 'package:BookiTrip/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AcBudgetField extends StatefulWidget {
  final TextEditingController controller;
  final AppTheme theme;
  final String? currency;

  const AcBudgetField({
    super.key,
    required this.controller,
    required this.theme,
    this.currency = 'TND',
  });

  @override
  State<AcBudgetField> createState() => _AcBudgetFieldState();
}

class _AcBudgetFieldState extends State<AcBudgetField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final Color fieldBg = theme.isDark ? theme.surface : Colors.white;
    final Color borderColor = _isFocused
        ? theme.primary
        : (theme.isDark ? Colors.white12 : Colors.black.withOpacity(0.08));
    final Color hintColor = theme.text.withOpacity(0.35);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? theme.primary.withOpacity(0.08)
                : (theme.shadow ?? Colors.black).withOpacity(0.04),
            blurRadius: _isFocused ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 20,
            color: _isFocused ? theme.primary : theme.text.withOpacity(0.4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Focus(
              onFocusChange: (v) => setState(() => _isFocused = v),
              child: TextField(
                controller: widget.controller,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: TextStyle(
                  color: theme.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Budget',
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          // Currency badge
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.currency ?? 'TND',
              style: TextStyle(
                color: theme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}