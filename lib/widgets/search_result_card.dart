import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/hotel.dart';
import 'package:BookiTrip/models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchResultCard extends StatelessWidget {
  final Hotel? hotel;
  final Restaurant? restaurant;
  final AppTheme theme;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    this.hotel,
    this.restaurant,
    required this.theme,
    required this.onTap,
  }) : assert(hotel != null || restaurant != null,
  'Either hotel or restaurant must be provided');

  // Helper getters
  String get imageUrl {
    if (hotel != null) {
      return hotel!.vignette ?? hotel!.cover ?? '';
    }
    return restaurant!.vignette ?? restaurant!.cover ?? '';
  }

  String get name {
    if (hotel != null) {
      return hotel!.name ?? 'Unknown Hotel';
    }
    return restaurant!.name ?? 'Unknown Restaurant';
  }

  String get address {
    if (hotel != null) {
      return hotel!.address ?? 'No address';
    }
    return restaurant!.address ?? 'No address';
  }

  IconData get icon {
    return hotel != null ? Icons.hotel : Icons.restaurant;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.CardBG,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Icon(
                          icon,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                errorWidget: (_, __, ___) =>
                    Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        icon,
                        color: Colors.grey.shade400,
                      ),
                    ),
              ),
            ),

            const SizedBox(width: 12),

            /// INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: theme.text.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.text.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}