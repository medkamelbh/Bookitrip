import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/circuit_form_data.dart';
import 'package:BookiTrip/models/destination.dart';
import 'package:BookiTrip/providers/circuit_form_provider.dart';
import 'package:BookiTrip/providers/destination_provider.dart';
import 'package:BookiTrip/widgets/circuits/budget_field.dart';
import 'package:BookiTrip/widgets/circuits/calendar_picker.dart';
import 'package:BookiTrip/widgets/circuits/city_dropdown.dart';
import 'package:BookiTrip/widgets/circuits/guest_configurator.dart';
import 'package:BookiTrip/widgets/circuits/section_label.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// MODE CONFIGURATION
// ═══════════════════════════════════════════════════════════════════════════════

/// Encapsulates all mode-specific strings and icons so the form screen
/// needs zero if/else branching.
class _ModeConfig {
  final String title;
  final String bannerTitle;
  final String bannerDescription;
  final String buttonLabel;
  final IconData appBarIcon;
  final IconData bannerIcon;
  final IconData buttonIcon;

  const _ModeConfig({
    required this.title,
    required this.bannerTitle,
    required this.bannerDescription,
    required this.buttonLabel,
    required this.appBarIcon,
    required this.bannerIcon,
    required this.buttonIcon,
  });

  static _ModeConfig forMode(CircuitMode mode) => switch (mode) {
    CircuitMode.auto => const _ModeConfig(
      title: 'Circuit Automatique',
      bannerTitle: 'Planification intelligente',
      bannerDescription:
          'Renseignez vos préférences et laissez notre IA créer '
          'le circuit idéal pour vous.',
      buttonLabel: 'Générer mon circuit',
      appBarIcon: Icons.auto_awesome_rounded,
      bannerIcon: Icons.auto_awesome_rounded,
      buttonIcon: Icons.auto_awesome_rounded,
    ),
    CircuitMode.manual => const _ModeConfig(
      title: 'Circuit Manuel',
      bannerTitle: 'Planification personnalisée',
      bannerDescription:
          'Composez votre circuit étape par étape en choisissant '
          'vos destinations et hébergements.',
      buttonLabel: 'Créer mon circuit',
      appBarIcon: Icons.edit_road_rounded,
      bannerIcon: Icons.edit_road_rounded,
      buttonIcon: Icons.route_rounded,
    ),
  };
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

/// Unified circuit form screen for both Auto and Manual modes.
///
/// The only visual differences (title, banner text, button label, icons) are
/// driven by [_ModeConfig] — no duplicated widget trees.
class CircuitFormScreen extends StatefulWidget {
  final CircuitMode mode;

  const CircuitFormScreen({required this.mode, super.key});

  @override
  State<CircuitFormScreen> createState() => _CircuitFormScreenState();
}

class _CircuitFormScreenState extends State<CircuitFormScreen> {
  late final _ModeConfig _config;

  // ── Form state ──────────────────────────────────────────────────────────
  DateTime? _startDate;
  DateTime? _endDate;
  Destination? _departureCity;
  Destination? _arrivalCity;
  final TextEditingController _budgetController = TextEditingController();
  List<RoomConfig> _rooms = [const RoomConfig(adults: 1, childAges: [])];

  @override
  void initState() {
    super.initState();
    _config = _ModeConfig.forMode(widget.mode);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  // ── Validation ──────────────────────────────────────────────────────────

  bool get _isFormValid =>
      _startDate != null &&
      _endDate != null &&
      _departureCity != null &&
      _arrivalCity != null &&
      _budgetController.text.trim().isNotEmpty;

  /// Builds a [CircuitFormData] from current state, or returns null and shows
  /// a snackbar if validation fails.
  CircuitFormData? _buildFormData() {
    if (!_isFormValid) return null;

    // Same-city check (both modes)
    if (_departureCity!.id == _arrivalCity!.id) {
      _showError('La ville de départ et d\'arrivée doivent être différentes.');
      return null;
    }

    final budgetText = _budgetController.text.trim();
    final budget = double.tryParse(budgetText);
    if (budget == null || budget < 1000) {
      _showError('Le budget minimum est de 1000 TND.');
      return null;
    }
    if (budget > 50000) {
      _showError('Le budget maximum est de 50 000 TND.');
      return null;
    }

    final duration = _endDate!.difference(_startDate!).inDays + 1;
    if (duration < 1) {
      _showError('La durée du séjour doit être d\'au moins 1 jour.');
      return null;
    }

    return CircuitFormData(
      startDate: _startDate!,
      endDate: _endDate!,
      departureCityId: _departureCity!.id,
      departureCityName: _departureCity!.name,
      arrivalCityId: _arrivalCity!.id,
      arrivalCityName: _arrivalCity!.name,
      budget: budget,
      rooms: _rooms,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  // ── Submit ──────────────────────────────────────────────────────────────

  Future<void> _onSubmit() async {
    final formData = _buildFormData();
    if (formData == null) return;

    final provider = context.read<CircuitFormProvider>();

    debugPrint('──────────────────────────────────────────');
    debugPrint('CircuitFormScreen._onSubmit');
    debugPrint('Mode: ${widget.mode.name}');
    debugPrint('Payload: ${formData.toFetchPayload()}');
    debugPrint('Rooms: ${_rooms.map((r) => r.toJson()).toList()}');
    debugPrint('──────────────────────────────────────────');

    if (widget.mode == CircuitMode.auto) {
      // ── Auto: POST /utilisateur/circuitsmobile ──────────────────────────
      await provider.generateAutoCircuit(formData);

      if (!mounted) return;

      if (provider.error != null) {
        _showError(provider.error!);
      } else if (provider.circuitResult != null) {
        final result = provider.circuitResult!;
        final listparjours = result['listparjours'];
        final dayCount = (listparjours is Map) ? listparjours.length : ((listparjours is List) ? listparjours.length : 0);

        debugPrint('✅ Auto circuit generated: $dayCount days');
        debugPrint('Response keys: ${result.keys.toList()}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Circuit généré avec succès — $dayCount jours',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
        // Navigate to day view screen
        context.pushNamed('circuit-day-view', extra: {
          'mode': widget.mode,
          'circuitData': result,
          'formData': formData,
        });
      }
    } else {
      // ── Manual: POST /utilisateur/newcircuit ────────────────────────────
      await provider.fetchDestinations(formData);

      if (!mounted) return;

      if (provider.error != null) {
        _showError(provider.error!);
      } else if (provider.destinations.isNotEmpty) {
        debugPrint('✅ Manual destinations fetched: ${provider.destinations.length}');
        for (final d in provider.destinations) {
          debugPrint('  - ${d.name} (${d.id})');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${provider.destinations.length} destinations disponibles',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to destination selection screen
        context.pushNamed('manual-destination-selection', extra: {
          'formData': formData,
        });
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final destinations = context.watch<DestinationProvider>().destinations;
    final circuitProvider = context.watch<CircuitFormProvider>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.background,
          appBar: _buildAppBar(theme),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Intro banner ──────────────────────────────────────────────
            _buildIntroBanner(theme),
            const SizedBox(height: 24),

            // ── Dates ─────────────────────────────────────────────────────
            AcSectionLabel(label: 'Dates du séjour', theme: theme),
            AcCalendarPicker(
              startDate: _startDate,
              endDate: _endDate,
              theme: theme,
              onStartDateSelected: (d) => setState(() {
                _startDate = d;
                _endDate = null; // reset end when new start is picked
              }),
              onEndDateSelected: (d) => setState(() => _endDate = d),
            ),
            const SizedBox(height: 20),

            // ── Cities ────────────────────────────────────────────────────
            AcSectionLabel(label: 'Ville de départ', theme: theme),
            AcCityDropdown(
              hint: 'Ville de départ',
              cities: destinations,
              selectedCity: _departureCity,
              theme: theme,
              icon: Icons.flight_takeoff_rounded,
              onChanged: (v) => setState(() => _departureCity = v),
            ),
            const SizedBox(height: 12),

            AcSectionLabel(label: "Ville d'arrivée", theme: theme),
            AcCityDropdown(
              hint: "Ville d'arrivée",
              cities: destinations,
              selectedCity: _arrivalCity,
              theme: theme,
              icon: Icons.flight_land_rounded,
              onChanged: (v) => setState(() => _arrivalCity = v),
            ),
            const SizedBox(height: 20),

            // ── Budget ────────────────────────────────────────────────────
            AcSectionLabel(label: 'Budget total', theme: theme),
            AcBudgetField(
              controller: _budgetController,
              theme: theme,
              currency: 'TND',
            ),
            const SizedBox(height: 20),

            // ── Guests ────────────────────────────────────────────────────
            AcSectionLabel(label: 'Hébergement', theme: theme),
            AcGuestConfigurator(
              rooms: _rooms,
              theme: theme,
              onChanged: (updated) => setState(() => _rooms = updated),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),

      // ── Sticky submit button ──────────────────────────────────────────────
      bottomNavigationBar: _buildSubmitButton(theme, circuitProvider.isLoading),
    ),

    // ── Loading overlay ──────────────────────────────────────────────────
    if (circuitProvider.isLoading)
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
                  widget.mode == CircuitMode.auto
                      ? 'Génération en cours...'
                      : 'Chargement des destinations...',
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

  // ── APP BAR ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AppTheme theme) {
    return AppBar(
      backgroundColor: theme.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.text),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        _config.title,
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
            _config.appBarIcon,
            color: theme.primary,
            size: 22,
          ),
        ),
      ],
    );
  }

  // ── INTRO BANNER ────────────────────────────────────────────────────────────

  Widget _buildIntroBanner(AppTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primary.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _config.bannerIcon,
              color: theme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _config.bannerTitle,
                  style: TextStyle(
                    color: theme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _config.bannerDescription,
                  style: TextStyle(
                    color: theme.text.withOpacity(0.60),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SUBMIT BUTTON ───────────────────────────────────────────────────────────

  Widget _buildSubmitButton(AppTheme theme, bool isLoading) {
    final bool canSubmit = _isFormValid && !isLoading;

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
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: canSubmit ? 1.0 : 0.45,
        child: ElevatedButton.icon(
          onPressed: canSubmit ? _onSubmit : null,
          icon: Icon(_config.buttonIcon, size: 20),
          label: Text(
            _config.buttonLabel,
            style: const TextStyle(
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
    );
  }
}
