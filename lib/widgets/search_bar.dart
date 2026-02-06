import 'dart:async';
import 'package:TunisiaBook/constants/theme.dart';
import 'package:TunisiaBook/providers/hotel_provider.dart';
import 'package:TunisiaBook/providers/restaurant_provider.dart';
import 'package:TunisiaBook/screens/hotelDetails_screen.dart';
import 'package:TunisiaBook/screens/restaurantDetails_screen.dart';
import 'package:TunisiaBook/widgets/search_result_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchBarWidget extends StatefulWidget {
  final AppTheme theme;

  const SearchBarWidget({super.key, required this.theme});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelProvider>().clearSearch();
      context.read<RestaurantProvider>().clearSearch();
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      context.read<HotelProvider>().clearSearch();
      context.read<RestaurantProvider>().clearSearch();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<HotelProvider>().searchHotels(value);
      context.read<RestaurantProvider>().searchRestaurants(value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    context.read<HotelProvider>().clearSearch();
    context.read<RestaurantProvider>().clearSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotelProvider = context.watch<HotelProvider>();
    final restaurantProvider = context.watch<RestaurantProvider>();
    final hasQuery = _controller.text.trim().isNotEmpty;

    final isLoading =
        hotelProvider.isSearching || restaurantProvider.isSearching;
    final totalResults =
        hotelProvider.searchResults.length +
        restaurantProvider.searchResults.length;

    final noResults =
        !isLoading &&
        totalResults == 0 &&
        hasQuery &&
        hotelProvider.error == null &&
        restaurantProvider.error == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // SEARCH INPUT
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          decoration: BoxDecoration(
            color: widget.theme.surface,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: widget.theme.primary,size: 16,),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'common.search_placeholder'.tr(),
                    hintStyle: TextStyle(
                      color: widget.theme.text.withOpacity(0.5),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: widget.theme.text),
                ),
              ),
              if (hasQuery)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: widget.theme.text.withOpacity(0.5),
                  ),
                  onPressed: () {
                    _controller.clear();
                    context.read<HotelProvider>().clearSearch();
                    context.read<RestaurantProvider>().clearSearch();
                  },
                ),
            ],
          ),
        ),

        // SEARCH LOADING INDICATOR
        if (isLoading && hasQuery)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          ),

        // ERROR MESSAGES
        if (!isLoading &&
            hasQuery &&
            (hotelProvider.error != null || restaurantProvider.error != null))
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hotelProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Hotels: ${hotelProvider.error!}',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (restaurantProvider.error != null)
                  Text(
                    'Restaurants: ${restaurantProvider.error!}',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
              ],
            ),
          ),

        // NO RESULTS MESSAGE
        if (noResults)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Text(
              'common.no_data'.tr(),
              style: TextStyle(color: widget.theme.text.withOpacity(0.6)),
            ),
          ),

        // SEARCH RESULTS
        if (!isLoading && totalResults > 0 && hasQuery)
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
                children: [
                  // HOTELS SECTION
                  if (hotelProvider.searchResults.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.hotel,
                            color: widget.theme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'home.categories.hotels'.tr(),
                            style: TextStyle(
                              color: widget.theme.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.theme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${hotelProvider.searchResults.length}',
                              style: TextStyle(
                                color: widget.theme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...hotelProvider.searchResults.map((hotel) {
                      return SearchResultCard(
                        theme: widget.theme,
                        hotel: hotel,
                        onTap: () {
                          context.read<HotelProvider>().clearSearch();
                          context.read<RestaurantProvider>().clearSearch();
                          _controller.clear();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HotelDetailsScreen(hotel: hotel),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],

                  // RESTAURANTS SECTION
                  if (restaurantProvider.searchResults.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 12,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.restaurant,
                            color: widget.theme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'home.categories.restaurants'.tr(),
                            style: TextStyle(
                              color: widget.theme.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.theme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${restaurantProvider.searchResults.length}',
                              style: TextStyle(
                                color: widget.theme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...restaurantProvider.searchResults.map((restaurant) {
                      return SearchResultCard(
                        theme: widget.theme,
                        restaurant: restaurant,
                        onTap: () {
                          context.read<HotelProvider>().clearSearch();
                          context.read<RestaurantProvider>().clearSearch();
                          _controller.clear();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RestaurantDetailsScreen(
                                restaurant: restaurant,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
