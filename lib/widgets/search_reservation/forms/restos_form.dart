import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/destination.dart';
import 'package:BookiTrip/widgets/search_reservation/shared/search_button.dart';
import 'package:BookiTrip/widgets/search_reservation/shared/stepper_field.dart';
import 'package:BookiTrip/widgets/search_reservation/shared/tappable_field.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class RestosForm extends StatelessWidget {
  const RestosForm({
    super.key,
    required this.theme,
    required this.fieldBg,
    required this.iconInactive,
    required this.hintColor,
    // state
    required this.destination,
    required this.date,
    required this.time,
    required this.persons,
    // callbacks
    required this.onDestinationTap,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onPersonsChanged,
    required this.onSearch,
  });

  final AppTheme theme;
  final Color fieldBg;
  final Color iconInactive;
  final Color hintColor;

  final Destination? destination;
  final DateTime? date;
  final TimeOfDay? time;
  final int persons;

  final VoidCallback onDestinationTap;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<int> onPersonsChanged;
  final VoidCallback onSearch;

  bool get _canSearch =>
      destination != null && date != null && time != null;

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) onDateChanged(picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: time ?? TimeOfDay.now(),
    );
    if (picked != null) onTimeChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TappableField(
          icon: Icons.location_on_outlined,
          hint: 'Votre destination',
          value: destination?.name,
          fieldBg: fieldBg,
          iconColor: destination != null ? theme.primary : iconInactive,
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
                hint: 'Date de réservation',
                value: date != null ? _fmtDate(date!) : null,
                fieldBg: fieldBg,
                iconColor: date != null ? theme.primary : iconInactive,
                hintColor: hintColor,
                valueColor: theme.text,
                onTap: () => _pickDate(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TappableField(
                icon: Icons.access_time_outlined,
                hint: 'Heure',
                value: time != null ? _fmtTime(time!) : null,
                fieldBg: fieldBg,
                iconColor: time != null ? theme.primary : iconInactive,
                hintColor: hintColor,
                valueColor: theme.text,
                onTap: () => _pickTime(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StepperField(
          icon: Icons.group_outlined,
          label: 'search.persons'.tr(),
          value: persons,
          min: 1,
          max: 20,
          fieldBg: fieldBg,
          iconColor: iconInactive,
          primaryColor: theme.primary,
          textColor: theme.text,
          onChanged: onPersonsChanged,
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