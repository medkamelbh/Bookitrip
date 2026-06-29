import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/destination.dart';
import 'package:BookiTrip/providers/destination_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Bottom sheet showing a searchable list of destinations.
///
/// Uses [DestinationProvider] for data. Returns the selected [Destination]
/// object (ID-based, not name-based) via [onSelected].
class DestinationPickerSheet extends StatefulWidget {
  final ValueChanged<Destination> onSelected;
  final AppTheme theme;

  const DestinationPickerSheet({
    super.key,
    required this.onSelected,
    required this.theme,
  });

  static Future<void> show({
    required BuildContext context,
    required AppTheme theme,
    required ValueChanged<Destination> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DestinationPickerSheet(
        onSelected: onSelected,
        theme: theme,
      ),
    );
  }

  @override
  State<DestinationPickerSheet> createState() => _DestinationPickerSheetState();
}

class _DestinationPickerSheetState extends State<DestinationPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final destinations = context.watch<DestinationProvider>().destinations;
    final filtered = _query.isEmpty
        ? destinations
        : destinations.where((d) {
            final name = d.name.toLowerCase();
            final state = d.state.toLowerCase();
            return name.contains(_query) || state.contains(_query);
          }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
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
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: theme.text.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Choisir une destination',
              style: TextStyle(
                color: theme.text,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: theme.isDark ? theme.surface : const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
                style: TextStyle(color: theme.text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(color: theme.text.withOpacity(0.35)),
                  prefixIcon: Icon(Icons.search, size: 20, color: theme.text.withOpacity(0.35)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List
          Flexible(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Aucune destination trouvée',
                      style: TextStyle(color: theme.text.withOpacity(0.4), fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final dest = filtered[index];
                      return _DestinationTile(
                        destination: dest,
                        theme: theme,
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onSelected(dest);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DestinationTile extends StatelessWidget {
  final Destination destination;
  final AppTheme theme;
  final VoidCallback onTap;

  const _DestinationTile({
    required this.destination,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.isDark ? theme.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on_outlined, size: 18, color: theme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: TextStyle(color: theme.text, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  if (destination.state.isNotEmpty)
                    Text(
                      destination.state,
                      style: TextStyle(color: theme.text.withOpacity(0.4), fontSize: 11),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: theme.text.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}
