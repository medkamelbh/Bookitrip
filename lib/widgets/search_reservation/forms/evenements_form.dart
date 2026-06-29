import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/destination.dart';
import 'package:BookiTrip/widgets/search_reservation/shared/search_button.dart';
import 'package:BookiTrip/widgets/search_reservation/shared/tappable_field.dart';
import 'package:flutter/material.dart';

class EvenementsForm extends StatelessWidget {
  const EvenementsForm({
    super.key,
    required this.theme,
    required this.fieldBg,
    required this.iconInactive,
    required this.hintColor,
    // state
    required this.destination,
    required this.date,
    // callbacks
    required this.onDestinationTap,
    required this.onDateChanged,
    required this.onSearch,
  });

  final AppTheme theme;
  final Color fieldBg;
  final Color iconInactive;
  final Color hintColor;

  final Destination? destination;
  final DateTime? date;

  final VoidCallback onDestinationTap;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onSearch;

  bool get _canSearch => destination != null && date != null;

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) onDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TappableField(
                icon: Icons.location_on_outlined,
                hint: 'Votre destination',
                value: destination?.name,
                fieldBg: fieldBg,
                iconColor:
                destination != null ? theme.primary : iconInactive,
                hintColor: hintColor,
                valueColor: theme.text,
                onTap: onDestinationTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TappableField(
                icon: Icons.event_outlined,
                hint: 'Date de réservation',
                value: date != null ? _fmtDate(date!) : null,
                fieldBg: fieldBg,
                iconColor: date != null ? theme.primary : iconInactive,
                hintColor: hintColor,
                valueColor: theme.text,
                onTap: () => _pickDate(context),
              ),
            ),
          ],
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