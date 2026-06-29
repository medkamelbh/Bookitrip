import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/availability_search_params.dart';
import 'package:BookiTrip/models/circuit_form_data.dart';
import 'package:BookiTrip/widgets/circuits/calendar_picker.dart';
import 'package:BookiTrip/widgets/circuits/guest_configurator.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Bottom-sheet modal that collects availability search parameters.
///
/// Opens when the user taps "Check Availability" and dates/guests are missing.
/// Reuses [AcCalendarPicker] and [AcGuestConfigurator] from the circuits feature.
///
/// Returns [AvailabilitySearchParams] via the [onSearch] callback.
class AvailabilitySearchModal extends StatefulWidget {
  /// Pre-filled hotel ID (for hotel-specific search).
  final String? hotelId;

  /// Pre-filled hotel slug.
  final String? hotelSlug;

  /// Pre-filled destination ID (for destination-wide search).
  final String? destinationId;

  /// Pre-filled check-in date.
  final DateTime? initialCheckIn;

  /// Pre-filled check-out date.
  final DateTime? initialCheckOut;

  /// Pre-filled rooms config.
  final List<RoomConfig>? initialRooms;

  /// Callback fired when the user submits the search.
  final ValueChanged<AvailabilitySearchParams> onSearch;

  final AppTheme theme;

  const AvailabilitySearchModal({
    super.key,
    this.hotelId,
    this.hotelSlug,
    this.destinationId,
    this.initialCheckIn,
    this.initialCheckOut,
    this.initialRooms,
    required this.onSearch,
    required this.theme,
  });

  /// Shows this modal as a draggable bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required AppTheme theme,
    required ValueChanged<AvailabilitySearchParams> onSearch,
    String? hotelId,
    String? hotelSlug,
    String? destinationId,
    DateTime? initialCheckIn,
    DateTime? initialCheckOut,
    List<RoomConfig>? initialRooms,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AvailabilitySearchModal(
        hotelId: hotelId,
        hotelSlug: hotelSlug,
        destinationId: destinationId,
        initialCheckIn: initialCheckIn,
        initialCheckOut: initialCheckOut,
        initialRooms: initialRooms,
        onSearch: onSearch,
        theme: theme,
      ),
    );
  }

  @override
  State<AvailabilitySearchModal> createState() =>
      _AvailabilitySearchModalState();
}

class _AvailabilitySearchModalState extends State<AvailabilitySearchModal> {
  late DateTime? _checkIn;
  late DateTime? _checkOut;
  late List<RoomConfig> _rooms;

  @override
  void initState() {
    super.initState();
    _checkIn = widget.initialCheckIn;
    _checkOut = widget.initialCheckOut;
    _rooms = widget.initialRooms ?? AvailabilitySearchParams.defaultRooms;
  }

  bool get _canSearch => _checkIn != null && _checkOut != null;

  void _onSubmit() {
    if (!_canSearch) return;

    final params = AvailabilitySearchParams(
      hotelId: widget.hotelId,
      hotelSlug: widget.hotelSlug,
      destinationId: widget.destinationId,
      checkIn: _checkIn!,
      checkOut: _checkOut!,
      rooms: _rooms,
    );

    Navigator.of(context).pop();
    widget.onSearch(params);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.text.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Title ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: theme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'availability.search_title'.tr(),
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'availability.search_subtitle'.tr(),
                        style: TextStyle(
                          color: theme.text.withOpacity(0.45),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.text.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: theme.text.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Scrollable content ────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Calendar ────────────────────────────────────────────
                  _SectionLabel(
                    icon: Icons.calendar_today_rounded,
                    label: 'availability.stay_dates'.tr(),
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  AcCalendarPicker(
                    startDate: _checkIn,
                    endDate: _checkOut,
                    onStartDateSelected: (date) {
                      setState(() {
                        _checkIn = date;
                        _checkOut = null; // Reset end date when start changes
                      });
                    },
                    onEndDateSelected: (date) {
                      setState(() => _checkOut = date);
                    },
                    theme: theme,
                  ),
                  const SizedBox(height: 20),

                  // ── Guest configurator ──────────────────────────────────
                  _SectionLabel(
                    icon: Icons.group_outlined,
                    label: 'availability.accommodations'.tr(),
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  AcGuestConfigurator(
                    rooms: _rooms,
                    onChanged: (updated) => setState(() => _rooms = updated),
                    theme: theme,
                  ),
                  const SizedBox(height: 24),

                  // ── Search button ───────────────────────────────────────
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _canSearch ? 1.0 : 0.45,
                    child: ElevatedButton.icon(
                      onPressed: _canSearch ? _onSubmit : null,
                      icon: const Icon(Icons.search_rounded, size: 20),
                      label: Text(
                        'availability.search_button'.tr(),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small section label with icon, matching the circuit form style.
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppTheme theme;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: theme.text,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
