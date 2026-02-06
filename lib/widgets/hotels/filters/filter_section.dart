import 'package:TunisiaBook/providers/destination_provider.dart';
import 'package:TunisiaBook/providers/hotel_provider.dart';
import 'package:TunisiaBook/providers/guestHouse_provider.dart';
import 'package:TunisiaBook/providers/restaurant_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TunisiaBook/constants/theme.dart';
import 'custom_filter_dropdown.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';

enum FilterType { hotel, restaurant, guestHouse, basic }

class FilterSection extends StatelessWidget {
  final AppTheme theme;
  final FilterType type;

  const FilterSection({
    super.key,
    required this.theme,
    required this.type,
  });

  static const List<int> ratingFilters = [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    final bool isHotel = type == FilterType.hotel;
    final bool isRestaurant = type == FilterType.restaurant;
    final bool isGuestHouse = type == FilterType.guestHouse;

    if (isHotel) {
      return Consumer<HotelProvider>(
        builder: (context, provider, child) =>
            _buildFilterRow(context, provider, isHotel: true),
      );
    } else if (isGuestHouse) {
      return Consumer<GuestHouseProvider>(
        builder: (context, provider, child) =>
            _buildFilterRow(context, provider, isGuestHouse: true),
      );
    } else if (isRestaurant) {
      return Consumer<RestaurantProvider>(
        builder: (context, provider, child) =>
            _buildFilterRow(context, provider, isRestaurant: true),
      );
    } else {
      return _buildFilterRow(context, null);
    }
  }

  // Helper methods remain the same to keep your logic intact
  Map<String, dynamic> _getProviderFilters(dynamic provider) {
    if (provider is HotelProvider) {
      return {'stars': provider.selectedStars, 'destination': provider.selectedDestination, 'clear': provider.clearFilters};
    } else if (provider is GuestHouseProvider) {
      return {'stars': provider.selectedStars, 'destination': provider.selectedDestination, 'clear': provider.clearFilters};
    } else if (provider is RestaurantProvider) {
      return {'forks': provider.minRating?.toInt(), 'destination': provider.currentState, 'clear': provider.clearFilters};
    }
    return {'stars': null, 'destination': null, 'clear': null};
  }

  void _setProviderStars(dynamic provider, int stars) => provider is HotelProvider ? provider.setStars(stars) : provider is GuestHouseProvider ? provider.setStars(stars) : provider is RestaurantProvider ? provider.setMinRating(stars.toDouble()) : null;
  void _setProviderDestination(dynamic provider, String destination) => provider is HotelProvider ? provider.setDestination(destination) : provider is GuestHouseProvider ? provider.setDestination(destination) : provider is RestaurantProvider ? provider.setStateFilter(destination) : null;

  Widget _buildFilterRow(
      BuildContext context,
      dynamic provider, {
        bool isHotel = false,
        bool isRestaurant = false,
        bool isGuestHouse = false,
      }) {
    final destinationProvider = Provider.of<DestinationProvider>(context, listen: false);
    final destinations = destinationProvider.destinations;
    final filters = _getProviderFilters(provider);

    final currentStarsOrForks = provider is HotelProvider ? provider.selectedStars : provider is GuestHouseProvider ? provider.selectedStars : provider is RestaurantProvider ? provider.minRating?.toInt() : null;

    String? currentDestination;
    if (provider is HotelProvider) {
      currentDestination = provider.selectedDestination ?? destinations.firstWhereOrNull((d) => d.id == provider.selectedDestinationId)?.getName(context.locale);
    } else if (provider is GuestHouseProvider) {
      currentDestination = provider.selectedDestination;
    } else if (provider is RestaurantProvider) {
      currentDestination = provider.currentDestinationId != null ? destinations.firstWhereOrNull((d) => d.id == provider.currentDestinationId)?.getName(context.locale) : provider.currentState;
    }

    final VoidCallback? clearFilters = filters['clear'] as VoidCallback?;

    // Label Logic
    final String primaryLabel = isHotel
        ? (currentStarsOrForks != null ? "$currentStarsOrForks ${currentStarsOrForks > 1 ? 'filters.stars'.tr() : 'filters.star'.tr()}" : 'filters.stars'.tr())
        : (isRestaurant ? (currentStarsOrForks != null ? "$currentStarsOrForks ${currentStarsOrForks > 1 ? 'filters.forks'.tr() : 'filters.fork'.tr()}" : 'filters.forks'.tr()) : 'filters.filter'.tr());

    final IconData visualRatingIcon = isHotel ? Icons.star : (isRestaurant ? Icons.restaurant_menu : Icons.filter_list);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use Wrap for responsiveness
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12.0, // Horizontal space between items
            runSpacing: 12.0, // Vertical space when items wrap
            children: [
              if (isHotel || isRestaurant)
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 120, maxWidth: constraints.maxWidth * 0.45),
                  child: CustomFilterDropdown(
                    theme: theme,
                    label: primaryLabel,
                    icon: isHotel ? Icons.star_border : Icons.restaurant_menu,
                    options: ratingFilters.map((count) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(count, (_) => Icon(visualRatingIcon, color: Colors.amber, size: 16)),
                    )).toList(),
                    onSelectedIndex: (index) => _setProviderStars(provider, ratingFilters[index]),
                  ),
                ),

              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 140, maxWidth: constraints.maxWidth * 0.45),
                child: CustomFilterDropdown(
                  theme: theme,
                  label: currentDestination ?? 'filters.destination'.tr(),
                  icon: Icons.location_on_outlined,
                  options: destinations.map((d) => Text(d.getName(context.locale), style: TextStyle(color: theme.text), overflow: TextOverflow.ellipsis)).toList(),
                  onSelectedIndex: (index) => _setProviderDestination(provider, destinations[index].name),
                ),
              ),

              if (clearFilters != null && (currentStarsOrForks != null || currentDestination != null))
                GestureDetector(
                  onTap: clearFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA30000),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

