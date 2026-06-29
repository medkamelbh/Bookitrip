import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/circuit_form_data.dart';
import 'package:BookiTrip/providers/circuit_form_provider.dart';
import 'package:BookiTrip/widgets/circuits/day_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Displays the generated circuit itinerary as a list of expandable day cards.
///
/// Used for both Auto and Manual circuit results — the data structure is
/// identical (`listparjours`).
class CircuitDayViewScreen extends StatelessWidget {
  final CircuitMode mode;
  final Map<String, dynamic> circuitData;
  final CircuitFormData formData;

  const CircuitDayViewScreen({
    super.key,
    required this.mode,
    required this.circuitData,
    required this.formData,
  });

  // ── Parse days ──────────────────────────────────────────────────────────

  List<MapEntry<int, Map<String, dynamic>>> get _sortedDays {
    final listparjours = circuitData['listparjours'];
    if (listparjours is! Map) return [];

    final entries = <MapEntry<int, Map<String, dynamic>>>[];
    listparjours.forEach((key, value) {
      final dayNum = int.tryParse(key.toString());
      if (dayNum != null && value is Map<String, dynamic>) {
        entries.add(MapEntry(dayNum, value));
      }
    });

    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  String get _titleText =>
      mode == CircuitMode.auto ? 'Circuit Automatique' : 'Circuit Manuel';

  String get _subtitleText {
    final days = _sortedDays.length;
    return '$days jour${days > 1 ? 's' : ''} · ${formData.totalAdults} adulte${formData.totalAdults > 1 ? 's' : ''}'
        '${formData.totalChildren > 0 ? ' · ${formData.totalChildren} enfant${formData.totalChildren > 1 ? 's' : ''}' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final days = _sortedDays;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: _buildAppBar(context, theme),
      body: days.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: days.length + 1, // +1 for the header
              itemBuilder: (context, index) {
                if (index == 0) return _buildHeader(theme);
                final entry = days[index - 1];
                return DayCard(
                  dayNumber: entry.key,
                  dayData: entry.value,
                  theme: theme,
                  initiallyExpanded: entry.key == 1, // First day expanded
                );
              },
            ),
      bottomNavigationBar: _buildReserveButton(context, theme),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, AppTheme theme) {
    return AppBar(
      backgroundColor: theme.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.text),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Votre itinéraire',
        style: TextStyle(
          color: theme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Icon(
            mode == CircuitMode.auto
                ? Icons.auto_awesome_rounded
                : Icons.edit_road_rounded,
            color: theme.primary,
            size: 22,
          ),
        ),
      ],
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────

  Widget _buildHeader(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primary.withOpacity(0.10),
              theme.primary.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.primary.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.map_rounded,
                  color: theme.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _titleText,
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _subtitleText,
              style: TextStyle(
                color: theme.text.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            // Quick stats
            Row(
              children: [
                _StatChip(
                  icon: Icons.calendar_today_rounded,
                  label:
                      '${formData.startDate.day}/${formData.startDate.month} → ${formData.endDate.day}/${formData.endDate.month}',
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.payments_rounded,
                  label: '${formData.budget.toStringAsFixed(0)} TND',
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.hotel_rounded,
                  label: '${formData.totalRooms} ch.',
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── EMPTY STATE ─────────────────────────────────────────────────────────

  Widget _buildEmptyState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: theme.text.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun itinéraire trouvé',
            style: TextStyle(
              color: theme.text.withOpacity(0.4),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── RESERVE BUTTON ──────────────────────────────────────────────────────

  Widget _buildReserveButton(BuildContext context, AppTheme theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: theme.background,
        boxShadow: [
          BoxShadow(
            color: (theme.shadow ?? Colors.black).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          context.pushNamed(
            'circuit-reservation',
            extra: {
              'circuitData': circuitData,
              'formData': formData,
            },
          );
        },
        icon: const Icon(Icons.bookmark_add_rounded, size: 20),
        label: const Text(
          'Réserver ce circuit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppTheme theme;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.primary.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.text.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
