 import 'package:BookiTrip/constants/theme.dart';
import 'package:flutter/material.dart';

class AcCalendarPicker extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onStartDateSelected;
  final ValueChanged<DateTime>? onEndDateSelected;
  final AppTheme theme;

  const AcCalendarPicker({
    super.key,
    required this.startDate,
    this.endDate,
    required this.onStartDateSelected,
    this.onEndDateSelected,
    required this.theme,
  });

  @override
  State<AcCalendarPicker> createState() => _AcCalendarPickerState();
}

class _AcCalendarPickerState extends State<AcCalendarPicker> {
  late DateTime _focusedMonth;

  static const List<String> _weekDays = [
    'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'
  ];

  static const List<String> _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = widget.startDate ?? DateTime.now();
  }

  void _prevMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
  });

  void _nextMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
  });

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    // Monday = 1, so offset = weekday - 1
    final startOffset = firstDay.weekday - 1;
    final daysInMonth =
    DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);

    final List<DateTime?> days = List.filled(startOffset, null, growable: true);
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }
    // Pad to full rows
    while (days.length % 7 != 0) {
      days.add(null);
    }
    return days;
  }

  /// Handle tap: first tap = start, second tap = end (swap if before start),
  /// third tap = reset and start over.
  void _onDayTapped(DateTime day) {
    final start = widget.startDate;
    final end = widget.endDate;

    if (start == null || (start != null && end != null)) {
      // No selection yet OR both already chosen → begin a new selection
      widget.onStartDateSelected(day);
      // Clear the end date by sending the same day as start
      // The parent handles null-ing end when start changes
    } else {
      // Start is set, end is not → set end date
      if (day.isBefore(start)) {
        // Tapped before the start → swap: tapped day becomes start, old start becomes end
        widget.onStartDateSelected(day);
        widget.onEndDateSelected?.call(start);
      } else if (DateUtils.isSameDay(day, start)) {
        // Same day tapped → treat as single-day range
        widget.onEndDateSelected?.call(day);
      } else {
        widget.onEndDateSelected?.call(day);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final days = _buildCalendarDays();
    final today = DateTime.now();

    final Color bgCard = theme.isDark
        ? theme.surface
        : const Color(0xFFF0F5F3);
    final Color textMuted = theme.text.withOpacity(0.35);
    final Color textNormal = theme.text.withOpacity(0.85);

    final DateTime? start = widget.startDate;
    final DateTime? end = widget.endDate;

    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (theme.shadow ?? Colors.black).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(
                icon: Icons.chevron_left_rounded,
                theme: theme,
                onTap: _prevMonth,
              ),
              Text(
                '${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                style: TextStyle(
                  color: theme.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                theme: theme,
                onTap: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Weekday headers
          Row(
            children: _weekDays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),

          // Days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 0,
              childAspectRatio: 1.4,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == null) return const SizedBox();

              final bool isToday = DateUtils.isSameDay(day, today);
              final bool isPast =
              day.isBefore(DateTime(today.year, today.month, today.day));

              // Range logic
              final bool isStart = start != null && DateUtils.isSameDay(day, start);
              final bool isEnd = end != null && DateUtils.isSameDay(day, end);
              final bool isEndpoint = isStart || isEnd;
              final bool isInRange = start != null &&
                  end != null &&
                  !day.isBefore(start) &&
                  !day.isAfter(end) &&
                  !isEndpoint;

              // Determine shape for the range strip
              // Start of range: round left corners, flat right
              // End of range: flat left, round right corners
              // Middle of range: no rounding
              BorderRadius borderRadius;
              if (isStart && isEnd) {
                borderRadius = BorderRadius.circular(10);
              } else if (isStart) {
                borderRadius = const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                );
              } else if (isEnd) {
                borderRadius = const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  bottomLeft: Radius.circular(3),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                );
              } else if (isInRange) {
                borderRadius = BorderRadius.circular(3);
              } else {
                borderRadius = BorderRadius.circular(10);
              }

              Color bgColor;
              if (isEndpoint) {
                bgColor = theme.primary;
              } else if (isInRange) {
                bgColor = theme.primary.withOpacity(0.13);
              } else {
                bgColor = Colors.transparent;
              }

              Color textColor;
              if (isEndpoint) {
                textColor = Colors.white;
              } else if (isPast) {
                textColor = textMuted;
              } else if (isInRange) {
                textColor = theme.primary;
              } else if (isToday) {
                textColor = theme.primary;
              } else {
                textColor = textNormal;
              }

              return GestureDetector(
                onTap: isPast ? null : () => _onDayTapped(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: borderRadius,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isEndpoint || isToday || isInRange
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Selected range label
          if (start != null) ...[
            const SizedBox(height: 10),
            _RangeLabel(start: start, end: end, theme: theme),
          ],
        ],
      ),
    );
  }
}

/// Small label at the bottom showing the selected range.
class _RangeLabel extends StatelessWidget {
  final DateTime start;
  final DateTime? end;
  final AppTheme theme;

  const _RangeLabel({required this.start, this.end, required this.theme});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final text = end != null && !DateUtils.isSameDay(start, end)
        ? '${_fmt(start)}  →  ${_fmt(end!)}'
        : _fmt(start);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.date_range_rounded, size: 16, color: theme.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: theme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final AppTheme theme;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.primary.withOpacity(0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.primary, size: 22),
      ),
    );
  }
}