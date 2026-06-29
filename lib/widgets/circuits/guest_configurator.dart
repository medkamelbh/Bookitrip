import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/circuit_form_data.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AcGuestConfigurator extends StatelessWidget {
  final List<RoomConfig> rooms;
  final ValueChanged<List<RoomConfig>> onChanged;
  final AppTheme theme;

  static const int _maxRooms = 5;
  static const int _maxAdultsPerRoom = 6;
  static const int _maxChildrenPerRoom = 4;
  static const int _maxChildAge = 12;

  const AcGuestConfigurator({
    super.key,
    required this.rooms,
    required this.onChanged,
    required this.theme,
  });

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<RoomConfig> _clone() =>
      rooms.map((r) => r.copyWith(childAges: List<int>.from(r.childAges))).toList();

  void _updateRoom(int index, RoomConfig updated) {
    final list = _clone();
    list[index] = updated;
    onChanged(list);
  }

  void _addRoom() {
    if (rooms.length >= _maxRooms) return;
    final list = _clone();
    list.add(const RoomConfig(adults: 1, childAges: []));
    onChanged(list);
  }

  void _removeRoom(int index) {
    if (rooms.length <= 1) return;
    final list = _clone();
    list.removeAt(index);
    onChanged(list);
  }

  // ── Computed summary ────────────────────────────────────────────────────

  String _buildSummary() {
    final r = rooms.length;
    final a = rooms.fold<int>(0, (s, rm) => s + rm.adults);
    final c = rooms.fold<int>(0, (s, rm) => s + rm.children);

    final parts = <String>[
      'circuit.room_count'.tr(namedArgs: {'count': '$r'}),
      'circuit.adult_count'.tr(namedArgs: {'count': '$a'}),
    ];
    if (c > 0) parts.add('circuit.child_count'.tr(namedArgs: {'count': '$c'}));

    return parts.join(' · ');
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final Color fieldBg = theme.isDark ? theme.surface : Colors.white;
    final Color borderColor =
        theme.isDark ? Colors.white12 : Colors.black.withOpacity(0.08);

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary header ──────────────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: theme.text.withOpacity(0.4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _buildSummary(),
                  style: TextStyle(
                    color: theme.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Room cards ───────────────────────────────────────────────────
          ...List.generate(rooms.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i < rooms.length - 1 ? 12 : 0),
              child: _RoomCard(
                index: i,
                config: rooms[i],
                theme: theme,
                canRemove: rooms.length > 1,
                onUpdate: (updated) => _updateRoom(i, updated),
                onRemove: () => _removeRoom(i),
                maxAdults: _maxAdultsPerRoom,
                maxChildren: _maxChildrenPerRoom,
                maxChildAge: _maxChildAge,
              ),
            );
          }),

          // ── Add room button ──────────────────────────────────────────────
          if (rooms.length < _maxRooms) ...[
            const SizedBox(height: 12),
            _AddRoomButton(theme: theme, onTap: _addRoom),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROOM CARD
// ═══════════════════════════════════════════════════════════════════════════════

class _RoomCard extends StatelessWidget {
  final int index;
  final RoomConfig config;
  final AppTheme theme;
  final bool canRemove;
  final ValueChanged<RoomConfig> onUpdate;
  final VoidCallback onRemove;
  final int maxAdults;
  final int maxChildren;
  final int maxChildAge;

  const _RoomCard({
    required this.index,
    required this.config,
    required this.theme,
    required this.canRemove,
    required this.onUpdate,
    required this.onRemove,
    required this.maxAdults,
    required this.maxChildren,
    required this.maxChildAge,
  });

  void _setAdults(int value) {
    onUpdate(config.copyWith(adults: value.clamp(1, maxAdults)));
  }

  void _setChildren(int value) {
    final clamped = value.clamp(0, maxChildren);
    final ages = List<int>.from(config.childAges);

    if (clamped > ages.length) {
      // Add new children with default age 5
      while (ages.length < clamped) {
        ages.add(6);
      }
    } else if (clamped < ages.length) {
      // Remove last children
      while (ages.length > clamped) {
        ages.removeLast();
      }
    }

    onUpdate(config.copyWith(childAges: ages));
  }

  void _setChildAge(int childIndex, int age) {
    final ages = List<int>.from(config.childAges);
    ages[childIndex] = age;
    onUpdate(config.copyWith(childAges: ages));
  }

  @override
  Widget build(BuildContext context) {
    final Color cardBg = theme.isDark
        ? theme.primary.withOpacity(0.06)
        : theme.primary.withOpacity(0.03);
    final Color cardBorder = theme.primary.withOpacity(0.12);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Room header ────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.hotel_rounded, size: 16, color: theme.primary),
              const SizedBox(width: 8),
              Text(
                'circuit.room_number'.tr(namedArgs: {'number': '${index + 1}'}),
                style: TextStyle(
                  color: theme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (canRemove)
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.red.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Adults counter ────────────────────────────────────────────
          _CounterRow(
            label: 'circuit.adults'.tr(),
            value: config.adults,
            min: 1,
            max: maxAdults,
            theme: theme,
            onChanged: _setAdults,
          ),
          const SizedBox(height: 8),

          // ── Children counter ──────────────────────────────────────────
          _CounterRow(
            label: 'circuit.children'.tr(),
            value: config.children,
            min: 0,
            max: maxChildren,
            theme: theme,
            onChanged: _setChildren,
          ),

          // ── Child age selectors ───────────────────────────────────────
          if (config.children > 0) ...[
            const SizedBox(height: 10),
            ...List.generate(config.children, (ci) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _ChildAgeRow(
                  childIndex: ci,
                  age: config.childAges[ci],
                  maxAge: maxChildAge,
                  theme: theme,
                  onAgeChanged: (age) => _setChildAge(ci, age),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CHILD AGE ROW
// ═══════════════════════════════════════════════════════════════════════════════

class _ChildAgeRow extends StatelessWidget {
  final int childIndex;
  final int age;
  final int maxAge;
  final AppTheme theme;
  final ValueChanged<int> onAgeChanged;

  const _ChildAgeRow({
    required this.childIndex,
    required this.age,
    required this.maxAge,
    required this.theme,
    required this.onAgeChanged,
  });

  String _ageLabel(int a) => a < 2 ? 'circuit.age_under_2'.tr() : 'circuit.age_years'.tr(namedArgs: {'years': '$a'});

  @override
  Widget build(BuildContext context) {
    final Color dropBg = theme.isDark
        ? theme.surface
        : Colors.white;

    return Row(
      children: [
        const SizedBox(width: 8),
        Icon(Icons.child_care_rounded, size: 14, color: theme.primary.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          'circuit.child_number'.tr(namedArgs: {'number': '${childIndex + 1}'}),
          style: TextStyle(
            color: theme.text.withOpacity(0.55),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: dropBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.primary.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: age,
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: theme.text.withOpacity(0.4),
              ),
              dropdownColor: theme.isDark ? theme.surface : Colors.white,
              borderRadius: BorderRadius.circular(10),
              style: TextStyle(
                color: theme.text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              items: List.generate(maxAge + 1, (a) {
                return DropdownMenuItem<int>(
                  value: a,
                  child: Text(
                    _ageLabel(a),
                    style: TextStyle(
                      color: theme.text.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                );
              }),
              onChanged: (v) {
                if (v != null) onAgeChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COUNTER ROW (reused for adults + children)
// ═══════════════════════════════════════════════════════════════════════════════

class _CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final AppTheme theme;
  final ValueChanged<int> onChanged;

  const _CounterRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.theme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: theme.text.withOpacity(0.55),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        _CounterBtn(
          icon: Icons.remove,
          enabled: value > min,
          theme: theme,
          onTap: () => onChanged(value - 1),
        ),
        SizedBox(
          width: 32,
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                color: theme.text,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
        _CounterBtn(
          icon: Icons.add,
          enabled: value < max,
          theme: theme,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COUNTER BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final AppTheme theme;
  final VoidCallback onTap;

  const _CounterBtn({
    required this.icon,
    required this.enabled,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled
              ? theme.primary.withOpacity(0.12)
              : theme.text.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? theme.primary : theme.text.withOpacity(0.2),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ADD ROOM BUTTON
// ═══════════════════════════════════════════════════════════════════════════════

class _AddRoomButton extends StatelessWidget {
  final AppTheme theme;
  final VoidCallback onTap;

  const _AddRoomButton({required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: theme.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.primary.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: theme.primary),
            const SizedBox(width: 6),
            Text(
              'circuit.add_room'.tr(),
              style: TextStyle(
                color: theme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
