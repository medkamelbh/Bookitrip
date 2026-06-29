import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/circuit_form_data.dart';
import 'package:BookiTrip/models/destination.dart';
import 'package:BookiTrip/providers/circuit_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Manual circuit Step 2: Destination selection & day allocation.
///
/// The provider already contains `destinations` (fetched in Step 1).
/// The user selects a start city, allocates days per destination,
/// then taps "Créer" → calls POST /utilisateur/createcircuit →
/// navigates to the day-view screen.
class ManualDestinationSelectionScreen extends StatefulWidget {
  final CircuitFormData formData;

  const ManualDestinationSelectionScreen({
    super.key,
    required this.formData,
  });

  @override
  State<ManualDestinationSelectionScreen> createState() =>
      _ManualDestinationSelectionScreenState();
}

class _ManualDestinationSelectionScreenState
    extends State<ManualDestinationSelectionScreen> {

  // ── Submit ──────────────────────────────────────────────────────────────

  Future<void> _onCreateCircuit() async {
    final provider = context.read<CircuitFormProvider>();

    // Validate
    final validationError =
        provider.validateDestinationSelection(widget.formData.duration);
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    debugPrint('──────────────────────────────────────────');
    debugPrint('ManualDestinationSelectionScreen._onCreateCircuit');
    debugPrint('Selected destinations:');
    for (final d in provider.destinations.where((d) => d.days > 0)) {
      debugPrint('  - ${d.name}: ${d.days} days (start: ${d.isStart})');
    }
    debugPrint('──────────────────────────────────────────');

    await provider.createManualCircuit(widget.formData);

    if (!mounted) return;

    if (provider.error != null) {
      _showError(provider.error!);
    } else if (provider.circuitResult != null) {
      final result = provider.circuitResult!;
      final listparjours = result['listparjours'];
      final dayCount = (listparjours is Map) ? listparjours.length : ((listparjours is List) ? listparjours.length : 0);

      debugPrint('✅ Manual circuit created: $dayCount days');

      context.pushNamed('circuit-day-view', extra: {
        'mode': CircuitMode.manual,
        'circuitData': result,  
        'formData': widget.formData,
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final provider = context.watch<CircuitFormProvider>();
    final destinations = provider.destinations;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.background,
          appBar: _buildAppBar(theme),
          body: Column(
            children: [
              // ── Summary header ─────────────────────────────────────────
              _SummaryHeader(
                formData: widget.formData,
                destinations: destinations,
                theme: theme,
              ),

              // ── Destination list ───────────────────────────────────────
              Expanded(
                child: destinations.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: destinations.length,
                        itemBuilder: (context, index) {
                          return _DestinationCard(
                            destination: destinations[index],
                            index: index,
                            theme: theme,
                            maxDays: widget.formData.duration,
                            onDaysChanged: (days) {
                              provider.updateDestinationDays(index, days);
                            },
                            onStartToggled: () {
                              provider.setStartDestination(index);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          bottomNavigationBar:
              _buildCreateButton(theme, provider.isLoading, destinations),
        ),

        // ── Loading overlay ──────────────────────────────────────────────
        if (provider.isLoading)
          Container(
            color: Colors.black.withOpacity(0.35),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (theme.shadow ?? Colors.black).withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: theme.primary,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Création du circuit...',
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AppTheme theme) {
    return AppBar(
      backgroundColor: theme.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.text),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Sélection des destinations',
        style: TextStyle(
          color: theme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── EMPTY STATE ─────────────────────────────────────────────────────────

  Widget _buildEmptyState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_rounded,
              size: 64, color: theme.text.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text(
            'Aucune destination disponible',
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

  // ── CREATE BUTTON ───────────────────────────────────────────────────────

  Widget _buildCreateButton(
    AppTheme theme,
    bool isLoading,
    List<DestinationSelection> destinations,
  ) {
    final selected = destinations.where((d) => d.days > 0).length;
    final totalDays = destinations.fold<int>(0, (sum, d) => sum + d.days);
    final hasStart = destinations.any((d) => d.isStart);
    final canSubmit =
        selected > 0 && hasStart && totalDays <= widget.formData.duration && !isLoading;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Days used indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 14, color: theme.text.withOpacity(0.4)),
                const SizedBox(width: 6),
                Text(
                  '$totalDays / ${widget.formData.duration} jours alloués',
                  style: TextStyle(
                    color: totalDays > widget.formData.duration
                        ? Colors.red.shade600
                        : theme.text.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!hasStart && selected > 0) ...[
                  const SizedBox(width: 12),
                  Text(
                    '⚠ Choisir ville de départ',
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: canSubmit ? 1.0 : 0.45,
            child: ElevatedButton.icon(
              onPressed: canSubmit ? _onCreateCircuit : null,
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
              label: const Text(
                'Créer mon circuit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: theme.primary,
                disabledForegroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

/// Summary header showing trip info and progress.
class _SummaryHeader extends StatelessWidget {
  final CircuitFormData formData;
  final List<DestinationSelection> destinations;
  final AppTheme theme;

  const _SummaryHeader({
    required this.formData,
    required this.destinations,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final selected = destinations.where((d) => d.days > 0).length;
    final totalDays = destinations.fold<int>(0, (sum, d) => sum + d.days);
    final remaining = formData.duration - totalDays;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary.withOpacity(0.10),
            theme.primary.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _MiniStat(
                icon: Icons.place_rounded,
                value: '$selected',
                label: 'sélectionnées',
                theme: theme,
              ),
              const SizedBox(width: 12),
              _MiniStat(
                icon: Icons.calendar_today_rounded,
                value: '$totalDays/${formData.duration}',
                label: 'jours',
                theme: theme,
                isWarning: totalDays > formData.duration,
              ),
              const SizedBox(width: 12),
              _MiniStat(
                icon: Icons.timelapse_rounded,
                value: '${remaining.clamp(0, 999)}',
                label: 'restants',
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: formData.duration > 0
                  ? (totalDays / formData.duration).clamp(0.0, 1.0)
                  : 0,
              backgroundColor: theme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                totalDays > formData.duration
                    ? Colors.red.shade400
                    : theme.primary,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final AppTheme theme;
  final bool isWarning;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? Colors.red.shade600 : theme.primary;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color.withOpacity(0.6)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: theme.text.withOpacity(0.4),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual destination card with day allocation and start-city toggle.
class _DestinationCard extends StatelessWidget {
  final DestinationSelection destination;
  final int index;
  final AppTheme theme;
  final int maxDays;
  final ValueChanged<int> onDaysChanged;
  final VoidCallback onStartToggled;

  const _DestinationCard({
    required this.destination,
    required this.index,
    required this.theme,
    required this.maxDays,
    required this.onDaysChanged,
    required this.onStartToggled,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = destination.days > 0;
    final isStart = destination.isStart;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.isDark ? theme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isStart
              ? theme.primary.withOpacity(0.5)
              : isActive
                  ? theme.primary.withOpacity(0.2)
                  : theme.isDark
                      ? Colors.white10
                      : Colors.black.withOpacity(0.06),
          width: isStart ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (theme.shadow ?? Colors.black).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // ── Top row: name + start toggle ──────────────────────────
            Row(
              children: [
                // Index badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.primary.withOpacity(0.12)
                        : theme.text.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive
                            ? theme.primary
                            : theme.text.withOpacity(0.3),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Name
                Expanded(
                  child: Text(
                    destination.name,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Start city toggle
                GestureDetector(
                  onTap: onStartToggled,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isStart
                          ? theme.primary
                          : theme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isStart
                            ? theme.primary
                            : theme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isStart
                              ? Icons.flag_rounded
                              : Icons.flag_outlined,
                          size: 14,
                          color: isStart ? Colors.white : theme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Départ',
                          style: TextStyle(
                            color: isStart ? Colors.white : theme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Day allocation row ───────────────────────────────────
            Row(
              children: [
                Text(
                  'Jours :',
                  style: TextStyle(
                    color: theme.text.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Minus button
                _DayButton(
                  icon: Icons.remove_rounded,
                  theme: theme,
                  enabled: destination.days > 0,
                  onTap: () => onDaysChanged(destination.days - 1),
                ),
                // Day count
                Container(
                  width: 44,
                  alignment: Alignment.center,
                  child: Text(
                    '${destination.days}',
                    style: TextStyle(
                      color: isActive ? theme.primary : theme.text.withOpacity(0.3),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                // Plus button
                _DayButton(
                  icon: Icons.add_rounded,
                  theme: theme,
                  enabled: destination.days < maxDays,
                  onTap: () => onDaysChanged(destination.days + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small circular increment/decrement button for day allocation.
class _DayButton extends StatelessWidget {
  final IconData icon;
  final AppTheme theme;
  final bool enabled;
  final VoidCallback onTap;

  const _DayButton({
    required this.icon,
    required this.theme,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled
              ? theme.primary.withOpacity(0.10)
              : theme.text.withOpacity(0.04),
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? theme.primary.withOpacity(0.25)
                : theme.text.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? theme.primary : theme.text.withOpacity(0.2),
        ),
      ),
    );
  }
}
