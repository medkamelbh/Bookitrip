import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/availability_provider.dart';
import 'package:BookiTrip/widgets/availability/availability_search_modal.dart';
import 'package:BookiTrip/widgets/circuits/day_item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/hotel.dart';
import '../../models/restaurant.dart';
import '../../models/activity.dart';
import '../../models/monument.dart';
import '../../models/musee.dart';

/// Configuration for a category section within a day card.
class DaySectionConfig {
  final String title;
  final IconData icon;
  final Color color;

  const DaySectionConfig({
    required this.title,
    required this.icon,
    required this.color,
  });
}

/// A collapsible category section within a day (e.g., Hotels, Restaurants).
///
/// Shows a header with an icon, title, and item count badge. Expands to
/// reveal [DayItemCard]s for each item in the category.
class DaySection extends StatefulWidget {
  final DaySectionConfig config;
  final List<Map<String, dynamic>> items;
  final AppTheme theme;
  final String categoryKey; // 'hotel', 'Restaurant', 'Activity', 'musees', 'monuments'

  const DaySection({
    super.key,
    required this.config,
    required this.items,
    required this.theme,
    required this.categoryKey,
  });

  @override
  State<DaySection> createState() => _DaySectionState();
}

class _DaySectionState extends State<DaySection>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  late final AnimationController _controller;
  late final Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      _expanded ? _controller.forward() : _controller.reverse();
    });
  }

  // ── Extract display data from raw JSON ────────────────────────────────

  String _getName(Map<String, dynamic> item) {
    switch (widget.categoryKey) {
      case 'hotel':
        return item['name']?.toString() ?? 'circuit.hotel_default'.tr();
      case 'Restaurant':
        return item['name']?.toString() ?? 'circuit.restaurant_default'.tr();
      case 'Activity':
        return item['title']?.toString() ?? 'circuit.activity_default'.tr();
      case 'musees':
        return item['Name']?.toString() ?? 'circuit.museum_default'.tr();
      case 'monuments':
        return item['name']?.toString() ?? 'circuit.monument_default'.tr();
      default:
        return item['name']?.toString() ?? item['title']?.toString() ?? '';
    }
  }

  String? _getSubtitle(Map<String, dynamic> item) {
    final address = item['address']?.toString();
    if (address != null && address.isNotEmpty) return address;
    final dest = item['destination'];
    if (dest is Map && dest['name'] != null) return dest['name'].toString();
    return null;
  }

  String? _getImageUrl(Map<String, dynamic> item) {
    return item['vignette']?.toString() ?? item['cover']?.toString();
  }

  double? _getRating(Map<String, dynamic> item) {
    final rate = item['rate'];
    if (rate is num) return rate.toDouble();
    if (rate is String) return double.tryParse(rate);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // ── Section header ─────────────────────────────────────────────
        GestureDetector(
          onTap: _toggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.config.color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.config.color.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.config.color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.config.icon,
                    size: 16,
                    color: widget.config.color,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.config.title,
                    style: TextStyle(
                      color: widget.theme.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.config.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.items.length}',
                    style: TextStyle(
                      color: widget.config.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                RotationTransition(
                  turns: _iconTurns,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: widget.theme.text.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Expanded items ─────────────────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState:
              _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: widget.items.map((item) {
                final isHotel = widget.categoryKey == 'hotel';
                return DayItemCard(
                  name: _getName(item),
                  subtitle: _getSubtitle(item),
                  imageUrl: _getImageUrl(item),
                  rating: _getRating(item),
                  theme: widget.theme,
                  showAvailabilityButton: isHotel,
                  hotelId: isHotel ? item['id']?.toString() : null,
                  hotelSlug: isHotel ? item['slug']?.toString() : null,
                  onAvailabilityTap: isHotel
                      ? () => _onHotelAvailability(context, item)
                      : null,
                  onTap: () => _onItemTap(context, item),
                );
              }).toList(),
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  void _onHotelAvailability(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    AvailabilitySearchModal.show(
      context: context,
      theme: widget.theme,
      hotelId: item['id']?.toString(),
      hotelSlug: item['slug']?.toString(),
      onSearch: (params) {
        final provider =
            Provider.of<AvailabilityProvider>(context, listen: false);
        provider.getHotelAvailability(params);
        context.pushNamed('availabilityResults');
      },
    );
  }

  void _onItemTap(BuildContext context, Map<String, dynamic> item) {
    switch (widget.categoryKey) {
      case 'hotel':
        context.pushNamed('hotelDetails', extra: Hotel.fromJson(item));
        break;
      case 'Restaurant':
        context.pushNamed('restaurantDetails', extra: Restaurant.fromJson(item));
        break;
      case 'Activity':
        context.pushNamed('activityDetails', extra: Activity.fromJson(item));
        break;
      case 'musees':
        context.pushNamed('museeDetails', extra: Musees.fromJson(item));
        break;
      case 'monuments':
        context.pushNamed('monumentDetails', extra: Monument.fromJson(item));
        break;
    }
  }
}

class DaySectionConfigs {
  static DaySectionConfig hotel(BuildContext context) => DaySectionConfig(
    title: 'circuit.hotels'.tr(),
    icon: Icons.hotel_rounded,
    color: const Color(0xFF5C6BC0), // Indigo
  );

  static DaySectionConfig restaurant(BuildContext context) => DaySectionConfig(
    title: 'circuit.restaurants'.tr(),
    icon: Icons.restaurant_rounded,
    color: const Color(0xFFEF6C00), // Deep Orange
  );

  static DaySectionConfig activity(BuildContext context) => DaySectionConfig(
    title: 'circuit.activities'.tr(),
    icon: Icons.directions_run_rounded,
    color: const Color(0xFF2E7D32), // Green
  );

  static DaySectionConfig musee(BuildContext context) => DaySectionConfig(
    title: 'circuit.museums'.tr(),
    icon: Icons.museum_rounded,
    color: const Color(0xFF8E24AA), // Purple
  );

  static DaySectionConfig monument(BuildContext context) => DaySectionConfig(
    title: 'circuit.monuments'.tr(),
    icon: Icons.account_balance_rounded,
    color: const Color(0xFF00838F), // Teal
  );
}
