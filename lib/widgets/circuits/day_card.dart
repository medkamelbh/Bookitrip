import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/widgets/circuits/day_section.dart';
import 'package:flutter/material.dart';

class DayCard extends StatefulWidget {
  final int dayNumber;
  final Map<String, dynamic> dayData;
  final AppTheme theme;
  final bool initiallyExpanded;

  const DayCard({
    super.key,
    required this.dayNumber,
    required this.dayData,
    required this.theme,
    this.initiallyExpanded = false,
  });

  @override
  State<DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<DayCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _controller;
  late final Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: _expanded ? 1.0 : 0.0,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      _expanded ? _controller.forward() : _controller.reverse();
    });
  }

  // ── Parse items from raw day data ───────────────────────────────────────

  List<Map<String, dynamic>> _parseItems(String key) {
    final raw = widget.dayData[key];
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  int get _totalItems {
    return _parseItems('hotel').length +
        _parseItems('Restaurant').length +
        _parseItems('Activity').length +
        _parseItems('musees').length +
        _parseItems('monuments').length;
  }

  @override
  Widget build(BuildContext context) {
    final hotels = _parseItems('hotel');
    final restaurants = _parseItems('Restaurant');
    final activities = _parseItems('Activity');
    final musees = _parseItems('musees');
    final monuments = _parseItems('monuments');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: widget.theme.isDark ? widget.theme.surface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.theme.isDark
              ? Colors.white10
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.theme.shadow ?? Colors.black).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Day header ──────────────────────────────────────────────
          GestureDetector(
            onTap: _toggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: _expanded
                    ? widget.theme.primary.withOpacity(0.06)
                    : Colors.transparent,
                borderRadius: _expanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      )
                    : BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.theme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.dayNumber}',
                        style: TextStyle(
                          color: widget.theme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jour ${widget.dayNumber}',
                          style: TextStyle(
                            color: widget.theme.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_totalItems éléments',
                          style: TextStyle(
                            color: widget.theme.text.withOpacity(0.4),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 24,
                      color: widget.theme.text.withOpacity(0.35),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded content ─────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOutCubic,
            crossFadeState:
                _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: Column(
                children: [
                  if (hotels.isNotEmpty) ...[
                    DaySection(
                      config: DaySectionConfigs.hotel(context),
                      items: hotels,
                      theme: widget.theme,
                      categoryKey: 'hotel',
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (restaurants.isNotEmpty) ...[
                    DaySection(
                      config: DaySectionConfigs.restaurant(context),
                      items: restaurants,
                      theme: widget.theme,
                      categoryKey: 'Restaurant',
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (activities.isNotEmpty) ...[
                    DaySection(
                      config: DaySectionConfigs.activity(context),
                      items: activities,
                      theme: widget.theme,
                      categoryKey: 'Activity',
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (musees.isNotEmpty) ...[
                    DaySection(
                      config: DaySectionConfigs.musee(context),
                      items: musees,
                      theme: widget.theme,
                      categoryKey: 'musees',
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (monuments.isNotEmpty)
                    DaySection(
                      config: DaySectionConfigs.monument(context),
                      items: monuments,
                      theme: widget.theme,
                      categoryKey: 'monuments',
                    ),
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
