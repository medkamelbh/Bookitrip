import 'package:BookiTrip/models/hotel.dart';
import 'package:BookiTrip/models/restaurant.dart';
import 'package:BookiTrip/providers/restaurant_provider.dart';
import 'package:BookiTrip/widgets/hotels/hotel_card.dart';
import 'package:BookiTrip/widgets/restaurant_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/widgets/section_title.dart';
import 'package:BookiTrip/providers/hotel_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DestinationDetailsScreen extends StatefulWidget {
  final String? title;
  final String? description;
  final List<String>? gallery;
  final String? destinationId;
  final VoidCallback? onNavigateToHotels;
  final VoidCallback? onNavigateToRestaurants;

  const DestinationDetailsScreen({
    super.key,
    this.title,
    this.description,
    this.gallery,
    this.destinationId,
    this.onNavigateToHotels,
    this.onNavigateToRestaurants,
  });

  @override
  State<DestinationDetailsScreen> createState() =>
      _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  bool _isDescriptionExpanded = false;
  static const int _maxDescriptionLength = 225;
  List<Hotel> _destinationHotels = [];
  List<Restaurant> _destinationRestaurants = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);

      setState(() {
        _destinationHotels = hotelProvider.allHotels
            .where((hotel) => hotel.destinationId == widget.destinationId)
            .toList();

        print("Filtering hotels for destination: ${widget.destinationId}");
        print("Found ${_destinationHotels.length} hotels");

        _destinationRestaurants = restaurantProvider.allRestaurants
            .where((resto) => resto.destinationId == widget.destinationId)
            .toList();

        print("Filtering restaurants for destination: ${widget.destinationId}");
        print("Found ${_destinationRestaurants.length} restaurants");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    final bool _isDescriptionTooLong =
        (widget.description?.length ?? 0) > _maxDescriptionLength;

    final String displayedDescription = _isDescriptionExpanded || !_isDescriptionTooLong
        ? (widget.description ?? '')
        : (widget.description?.substring(0, _maxDescriptionLength) ?? '') + '...';

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.text),
        title: Text(
          widget.title ?? "",
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider.builder(
              itemCount: widget.gallery?.length ?? 0,
              itemBuilder: (context, index, realIndex) {
                final imgUrl = widget.gallery?[index] ?? '';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: imgUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, size: 50),
                  ),
                );
              },
              options: CarouselOptions(
                height: 250.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'details.destination_details'.tr(),
              style: TextStyle(
                color: theme.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 10),
            Text(
              displayedDescription,
              style: TextStyle(
                color: theme.text.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            if (_isDescriptionTooLong)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isDescriptionExpanded = !_isDescriptionExpanded;
                  });
                },
                child: Text(
                  _isDescriptionExpanded ? 'details.show_less'.tr() : 'details.show_more'.tr(),
                  style: TextStyle(
                    color: theme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Hotels Section
            SectionTitleWidget(
              title: 'hotels.title'.tr(),
              theme: theme,
              showMore: true,
              onTap: () {
                final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
                hotelProvider.filterByDestination(widget.destinationId!);
                context.go('/hotels');
              },
            ),
            const SizedBox(height: 15),

            if (_destinationHotels.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.hotel_outlined,
                        color: theme.primary.withValues(alpha: 0.5),
                        size: 60,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'details.no_hotels'.tr(),
                        style: TextStyle(
                          color: theme.text.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _destinationHotels.take(5).length,
                  itemBuilder: (context, index) {
                    final hotel = _destinationHotels.take(5).toList()[index];
                    return Container(
                      width: 240,
                      margin: const EdgeInsets.only(right: 15),
                      child: HotelCardWidget(
                        theme: theme,
                        title: hotel.getName(context.locale),
                        destination: hotel.getDestinationName(context.locale) ?? 'Unknown',
                        imgUrl: hotel.vignette ?? hotel.cover,
                        rating: hotel.categoryCode?.toDouble() ?? 4.0,
                        isHotel: true,
                        onTap: () {
                          context.pushNamed('hotelDetails', extra: hotel);
                        },
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),


            //resto section
            SectionTitleWidget(
              title: 'restaurants.title'.tr(),
              theme: theme,
              showMore: true,
              onTap: () {
                final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
                restaurantProvider.filterByDestination(widget.destinationId!);
                context.go('/restaurants');
              },
            ),
            const SizedBox(height: 15),

            if (_destinationRestaurants.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_outlined,
                        color: theme.primary.withValues(alpha: 0.5),
                        size: 60,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'details.no_restaurants'.tr(),
                        style: TextStyle(
                          color: theme.text.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _destinationRestaurants.take(5).length,
                  itemBuilder: (context, index) {
                    final restaurant = _destinationRestaurants.take(5).toList()[index];
                    return Container(
                      width: 240,
                      margin: const EdgeInsets.only(right: 15),
                      child: RestaurantCardWidget(
                        title: restaurant.getName(context.locale),
                        location: restaurant.getDestinationName(context.locale) ?? 'Unknown',
                        imgUrl: restaurant.vignette!,
                        rating: restaurant.rate?.toDouble() ?? 4.0,
                        onTap: () {
                          context.pushNamed('restaurantDetails', extra: restaurant);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}