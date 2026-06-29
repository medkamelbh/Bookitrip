import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/destination.dart';
import 'package:flutter/material.dart';

/// City dropdown that works with [Destination] objects instead of raw strings.
///
/// This captures both the destination ID (needed for API calls) and the
/// display name, avoiding the need for a separate lookup step.
class AcCityDropdown extends StatelessWidget {
  final String hint;
  final Destination? selectedCity;
  final List<Destination> cities;
  final ValueChanged<Destination?> onChanged;
  final AppTheme theme;
  final IconData icon;

  const AcCityDropdown({
    super.key,
    required this.hint,
    required this.cities,
    required this.onChanged,
    required this.theme,
    this.selectedCity,
    this.icon = Icons.location_on_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final Color fieldBg = theme.isDark
        ? theme.surface
        : Colors.white;
    final Color borderColor = theme.isDark
        ? Colors.white12
        : Colors.black.withOpacity(0.08);
    final Color hintColor = theme.text.withOpacity(0.35);

    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: (theme.shadow ?? Colors.black).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<Destination>(
            value: selectedCity,
            hint: Row(
              children: [
                Icon(icon, size: 20, color: theme.primary),
                const SizedBox(width: 12),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 15,
                    color: hintColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.text.withOpacity(0.4),
            ),
            dropdownColor: theme.isDark ? theme.surface : Colors.white,
            borderRadius: BorderRadius.circular(14),
            style: TextStyle(
              color: theme.text,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            isExpanded: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            items: cities.map((dest) {
              return DropdownMenuItem<Destination>(
                value: dest,
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: theme.primary),
                    const SizedBox(width: 12),
                    Flexible(child: Text(dest.name, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}