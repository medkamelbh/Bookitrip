import 'package:BookiTrip/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/destination_provider.dart';
import '../models/destination.dart';

class ActivityCardWidget extends StatelessWidget {
  final AppTheme theme;
  final String title;
  final String destId;
  final String category;
  final String imgUrl;
  final double rating;
  final VoidCallback onTap;

  const ActivityCardWidget({
    super.key,
    required this.theme,
    required this.title,
    required this.destId,
    required this.category,
    required this.imgUrl,
    this.rating = 0.0,
    required this.onTap,
  });

  String _getDestinationName(BuildContext context, DestinationProvider provider) {
    final Locale currentLocale = Localizations.localeOf(context);
    final Destination? destination = provider.getDestinationById(destId);
    return destination?.getName(currentLocale) ?? "Unknown Location";
  }

  @override
  Widget build(BuildContext context) {
    final destinationProvider = Provider.of<DestinationProvider>(context);
    final destinationName = _getDestinationName(context, destinationProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // --- RESPONSIVE DIMENSIONS ---
        // Instead of hardcoded 180, we use a ratio of the available width (approx 0.5 to 0.6)
        // We clamp it to ensure it stays within a beautiful range (160 to 240)
        final double responsiveHeight = (constraints.maxWidth * 0.55).clamp(160.0, 240.0);
        final double borderRadius = 16;
        final double padding = 16;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: responsiveHeight,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 1. Background Image with Gradient
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade300,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                // 2. The UI Gradients (Preserving your exact Look)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.primary.withValues(alpha: 0.7),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. Category Badge (Top Right)
                Positioned(
                  top: padding,
                  right: padding,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // 4. Activity Title
                Positioned(
                  left: padding,
                  bottom: 40,
                  right: padding,
                  child: Text(
                    title,
                    style: TextStyle(
                      // Scale font slightly based on card size
                      fontSize: (responsiveHeight * 0.1).clamp(15.0, 19.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 5. Location Row (RTL/LTR Compatible)
                Positioned(
                  bottom: padding,
                  left: padding,
                  right: padding,
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red.withValues(alpha: 0.8), size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destinationName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}