import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/availability_search_params.dart';
import 'package:BookiTrip/models/circuit_form_data.dart';
import 'package:BookiTrip/models/destination.dart';
import 'package:BookiTrip/widgets/search_reservation/shared/search_button.dart';
import 'package:BookiTrip/widgets/search_reservation/shared/tappable_field.dart';
import 'package:flutter/material.dart';

class HotelsForm extends StatelessWidget {
  const HotelsForm({
    super.key,
    required this.theme,
    required this.fieldBg,
    required this.iconInactive,
    required this.hintColor,
    // state
    required this.selectedDestination,
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
    // callbacks
    required this.onDestinationTap,
    required this.onDatesTap,
    required this.onGuestsTap,
    required this.onSearch,
  });

  final AppTheme theme;
  final Color fieldBg;
  final Color iconInactive;
  final Color hintColor;

  final Destination? selectedDestination;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final List<RoomConfig> rooms;

  final VoidCallback onDestinationTap;
  final VoidCallback onDatesTap;
  final VoidCallback onGuestsTap;
  final VoidCallback onSearch;

  bool get _canSearch =>
      selectedDestination != null && checkIn != null && checkOut != null;

  String get _guestSummary {
    final r = rooms.length;
    final a = rooms.fold<int>(0, (s, rm) => s + rm.adults);
    final c = rooms.fold<int>(0, (s, rm) => s + rm.children);
    final parts = ['$r ch.', '$a ad.'];
    if (c > 0) parts.add('$c enf.');
    return parts.join(' · ');
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TappableField(
          icon: Icons.location_on_outlined,
          hint: 'Destination',
          value: selectedDestination?.name,
          fieldBg: fieldBg,
          iconColor:
          selectedDestination != null ? theme.primary : iconInactive,
          hintColor: hintColor,
          valueColor: theme.text,
          onTap: onDestinationTap,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TappableField(
                icon: Icons.calendar_today_outlined,
                hint: 'Arrivée',
                value: checkIn != null ? _fmtDate(checkIn!) : null,
                fieldBg: fieldBg,
                iconColor: checkIn != null ? theme.primary : iconInactive,
                hintColor: hintColor,
                valueColor: theme.text,
                onTap: onDatesTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TappableField(
                icon: Icons.calendar_today_outlined,
                hint: 'Départ',
                value: checkOut != null ? _fmtDate(checkOut!) : null,
                fieldBg: fieldBg,
                iconColor: checkOut != null ? theme.primary : iconInactive,
                hintColor: hintColor,
                valueColor: theme.text,
                onTap: onDatesTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TappableField(
          icon: Icons.group_outlined,
          hint: 'Hébergements',
          value: _guestSummary,
          fieldBg: fieldBg,
          iconColor: iconInactive,
          hintColor: hintColor,
          valueColor: theme.text,
          onTap: onGuestsTap,
        ),
        const SizedBox(height: 16),
        SearchButton(
          canSearch: _canSearch,
          primaryColor: theme.primary,
          onPressed: onSearch,
        ),
      ],
    );
  }
}