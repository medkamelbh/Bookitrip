import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/destination.dart';
import 'package:BookiTrip/widgets/search_reservation/shared/search_button.dart';
import 'package:BookiTrip/widgets/search_reservation/shared/stepper_field.dart';
import 'package:BookiTrip/widgets/search_reservation/shared/tappable_field.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class VolsForm extends StatelessWidget {
  const VolsForm({
    super.key,
    required this.theme,
    required this.fieldBg,
    required this.iconInactive,
    required this.hintColor,
    // state
    required this.departAirport,
    required this.arrivalAirport,
    required this.departDate,
    required this.arrivalDate,
    required this.passengers,
    // callbacks
    required this.onDepartAirportTap,
    required this.onArrivalAirportTap,
    required this.onDepartDateChanged,
    required this.onArrivalDateChanged,
    required this.onPassengersChanged,
    required this.onSearch,
  });

  final AppTheme theme;
  final Color fieldBg;
  final Color iconInactive;
  final Color hintColor;

  final Destination? departAirport;
  final Destination? arrivalAirport;
  final DateTime? departDate;
  final DateTime? arrivalDate;
  final int passengers;

  final VoidCallback onDepartAirportTap;
  final VoidCallback onArrivalAirportTap;
  final ValueChanged<DateTime> onDepartDateChanged;
  final ValueChanged<DateTime> onArrivalDateChanged;
  final ValueChanged<int> onPassengersChanged;
  final VoidCallback onSearch;

  bool get _canSearch =>
      departAirport != null && arrivalAirport != null && departDate != null;

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDepartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: departDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) onDepartDateChanged(picked);
  }

  Future<void> _pickArrivalDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: arrivalDate ?? (departDate ?? DateTime.now()),
      firstDate: departDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) onArrivalDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Airports
        Row(
          children: [
            Expanded(
              child: TappableField(
                icon: Icons.flight_takeoff_outlined,
                hint: 'Aéroport de départ',
                value: departAirport?.name,
                fieldBg: fieldBg,
                iconColor:
                departAirport != null ? theme.primary : iconInactive,
                hintColor: hintColor,
                valueColor: theme.text,
                onTap: onDepartAirportTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TappableField(
                icon: Icons.flight_land_outlined,
                hint: "Aéroport d'arrivée",
                value: arrivalAirport?.name,
                fieldBg: fieldBg,
                iconColor:
                arrivalAirport != null ? theme.primary : iconInactive,
                hintColor: hintColor,
                valueColor: theme.text,
                onTap: onArrivalAirportTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Dates
        Row(
          children: [
            Expanded(
              child: TappableField(
                icon: Icons.calendar_today_outlined,
                hint: 'Date de départ',
                value: departDate != null ? _fmtDate(departDate!) : null,
                fieldBg: fieldBg,
                iconColor:
                departDate != null ? theme.primary : iconInactive,
                hintColor: hintColor,
                valueColor: theme.text,
                onTap: () => _pickDepartDate(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TappableField(
                icon: Icons.calendar_today_outlined,
                hint: "Date d'arrivée",
                value: arrivalDate != null ? _fmtDate(arrivalDate!) : null,
                fieldBg: fieldBg,
                iconColor:
                arrivalDate != null ? theme.primary : iconInactive,
                hintColor: hintColor,
                valueColor: theme.text,
                onTap: () => _pickArrivalDate(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StepperField(
          icon: Icons.airline_seat_recline_normal_outlined,
          label: 'search.passengers'.tr(),
          value: passengers,
          min: 1,
          max: 9,
          fieldBg: fieldBg,
          iconColor: iconInactive,
          primaryColor: theme.primary,
          textColor: theme.text,
          onChanged: onPassengersChanged,
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