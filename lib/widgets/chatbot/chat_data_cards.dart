import 'package:flutter/material.dart';
import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/hotel.dart';
import 'package:BookiTrip/models/restaurant.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatDataCards extends StatelessWidget {
  final Map<String, dynamic> data;
  final AppTheme theme;

  const ChatDataCards({
    super.key,
    required this.data,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> sections = [];

    if (data.containsKey('hotels') && (data['hotels'] as List).isNotEmpty) {
      sections.add(_buildSectionTitle('Hôtels recommandés'));
      sections.add(_buildHotelsList(context, data['hotels'] as List));
    }

    if (data.containsKey('restaurants') && (data['restaurants'] as List).isNotEmpty) {
      sections.add(_buildSectionTitle('Restaurants recommandés'));
      sections.add(_buildRestaurantsList(context, data['restaurants'] as List));
    }

    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: sections,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: theme.primary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildHotelsList(BuildContext context, List hotelsData) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hotelsData.length,
        itemBuilder: (context, index) {
          final rawJson = hotelsData[index] as Map<String, dynamic>;
          // Map _id to id if necessary for parsing
          if (!rawJson.containsKey('id') && rawJson.containsKey('_id')) {
            rawJson['id'] = rawJson['_id'];
          }
          final hotel = Hotel.fromJson(rawJson);

          return _buildHotelCard(context, hotel);
        },
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, Hotel hotel) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('hotelDetails', extra: hotel);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        decoration: BoxDecoration(
          color: theme.isDark ? theme.background : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.isDark 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _buildImage(hotel.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${hotel.categoryCode ?? 3} Étoiles',
                        style: TextStyle(
                          color: theme.text.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, 
                          color: theme.primary.withOpacity(0.7), size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.text.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantsList(BuildContext context, List restaurantsData) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: restaurantsData.length,
        itemBuilder: (context, index) {
          final rawJson = restaurantsData[index] as Map<String, dynamic>;
          // Map _id to id if necessary for parsing
          if (!rawJson.containsKey('id') && rawJson.containsKey('_id')) {
            rawJson['id'] = rawJson['_id'];
          }
          final restaurant = Restaurant.fromJson(rawJson);

          return _buildRestaurantCard(context, restaurant);
        },
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant restaurant) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('restaurantDetails', extra: restaurant);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        decoration: BoxDecoration(
          color: theme.isDark ? theme.background : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.isDark 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _buildImage(restaurant.cover ?? restaurant.vignette ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, 
                          color: theme.primary.withOpacity(0.7), size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address ?? restaurant.destinationName ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.text.withOpacity(0.6),
                            fontSize: 11,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    const String baseUrl = 'https://backend.BookiTrip.com/storage/';
    final String fullUrl = imageUrl.startsWith('http') ? imageUrl : baseUrl + imageUrl;
    
    return CachedNetworkImage(
      imageUrl: fullUrl,
      height: 100,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 100,
        width: double.infinity,
        color: theme.primary.withOpacity(0.1),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.primary,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 100,
        width: double.infinity,
        color: theme.primary.withOpacity(0.1),
        child: Icon(Icons.image_not_supported, color: theme.primary.withOpacity(0.5)),
      ),
    );
  }
}
