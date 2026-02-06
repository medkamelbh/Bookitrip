import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:TunisiaBook/constants/theme.dart';

class HotelCardWidget extends StatelessWidget {
  final AppTheme theme;
  final String title;
  final String destination;
  final String imgUrl;
  final double rating;
  final bool? isHotel;
  final VoidCallback onTap;

  const HotelCardWidget({
    super.key,
    required this.theme,
    required this.title,
    required this.destination,
    required this.imgUrl,
    required this.rating,
    required this.onTap,
    this.isHotel,
  });

  int get starCount => rating.round().clamp(1, 5);

  @override
  Widget build(BuildContext context) {
    // Determine screen type
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double dynamicHeight = isTablet ? 250 : constraints.maxWidth * 0.58;
        final double borderRadius = isTablet ? 20 : 16;
        final double padding = isTablet ? 20 : 16;

        // Responsive font sizes
        final double titleFontSize = (constraints.maxWidth * 0.042).clamp(14.0, 20.0);
        final double detailFontSize = (constraints.maxWidth * 0.035).clamp(11.0, 15.0);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: dynamicHeight,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 1. Image Background
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                // 2. Multi-layer Gradient Overlay for readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                          theme.primary.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. Stars rating (Top Right)
                if (isHotel != false)
                  Positioned(
                    top: padding,
                    right: padding,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                        //backdropFilter: const ColorFilter.mode(Colors.black12, BlendMode.blur),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < starCount ? Icons.star : Icons.star_border,
                            color: index < starCount ? Colors.amber : Colors.white60,
                            size: isTablet ? 16 : 13,
                          );
                        }),
                      ),
                    ),
                  ),

                // 4. Text Content (Title and Destination)
                Positioned(
                  left: padding,
                  bottom: padding,
                  right: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white.withOpacity(0.9),
                            size: detailFontSize,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              destination,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: detailFontSize,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
      },
    );
  }
}