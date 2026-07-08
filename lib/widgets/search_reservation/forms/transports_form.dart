import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/widgets/search_reservation/transport_type.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'transfer_form_dialog.dart';

class _TransportItem {
  final TransportType type;
  final String labelKey;
  final IconData icon;
  const _TransportItem({
    required this.type,
    required this.labelKey,
    required this.icon,
  });
}

class TransportsForm extends StatelessWidget {
  const TransportsForm({
    super.key,
    required this.theme,
    required this.selectedTransport,
    required this.onTransportSelected,
    required this.onSearch,
  });

  final AppTheme theme;
  final TransportType? selectedTransport;
  final ValueChanged<TransportType> onTransportSelected;
  final VoidCallback onSearch;

  static const _items = [
    _TransportItem(
        type: TransportType.bateaux,
        labelKey: 'search.boats',
        icon: Icons.directions_boat_rounded),
    _TransportItem(
        type: TransportType.transfert,
        labelKey: 'search.transfert',
        icon: Icons.directions_bus_rounded),
    _TransportItem(
        type: TransportType.taxi,
        labelKey: 'search.taxi',
        icon: Icons.local_taxi_rounded),
    _TransportItem(
        type: TransportType.locationVoiture,
        labelKey: 'search.car_rental',
        icon: Icons.car_rental_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    // Derive card colors from the current theme
    final Color cardBg = theme.CardBG ?? theme.surface;
    final Color accent = theme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: _items.map((item) {
            final bool isSelected = selectedTransport == item.type;
            final bool isLast = item == _items.last;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTransportSelected(item.type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: isLast ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent.withOpacity(0.15)
                        : cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? accent
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (theme.shadow ?? Colors.black)
                            .withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.labelKey.tr(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? accent
                              : theme.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: selectedTransport != null ? 1.0 : 0.55,
          child: ElevatedButton(
            onPressed: selectedTransport != null 
                ? () {
                    if (selectedTransport == TransportType.transfert) {
                      showDialog(
                        context: context,
                        builder: (context) => TransferFormDialog(theme: theme),
                      );
                    } else if (selectedTransport == TransportType.locationVoiture) {
                      context.push('/vehicles');
                    } else {
                      onSearch();
                    }
                  } 
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: theme.primary,
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_forward_rounded, size: 18),
                const SizedBox(width: 6),
                Text(
                  'search.continue_btn'.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}