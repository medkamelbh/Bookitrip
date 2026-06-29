import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:BookiTrip/constants/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RestaurantCardWidget extends StatelessWidget {
  final String title;
  final String location;
  final String imgUrl;
  final double rating;
  final VoidCallback onTap;

  const RestaurantCardWidget({
    super.key,
    required this.title,
    required this.location,
    required this.imgUrl,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of<ThemeProvider>(context).currentTheme;
    final Size screenSize = MediaQuery.of(context).size;

    // Determine responsive constants
    final bool isTablet = screenSize.width > 600;
    final double borderRadius = isTablet ? 20 : 16;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AspectRatio(
          // 16:9 ratio looks good on most devices.
          // On tablets, you might prefer 2.0 (wider) if showing in a grid.
          aspectRatio: isTablet ? 2.1 : 1.8,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Use constraints to scale text and icons
                final double width = constraints.maxWidth;
                final double titleSize = width * 0.045; // Scales font to ~5.5% of width
                final double padding = width * 0.04;

                return Stack(
                  children: [
                    // Image Layer
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                        ),
                      ),
                    ),

                    // Multi-layer Gradient for readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.transparent,
                              theme.primary.withValues(alpha: 0.8),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Top Right Badge (Location)
                    Positioned(
                      top: padding,
                      right: padding,
                      left: padding,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.03,
                            vertical: width * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(30),
                            //blurStyle: BlurStyle.outer,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.red.shade400,
                                size: width * 0.04,
                              ),
                              SizedBox(width: width * 0.01),
                              Flexible(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: width * 0.032,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom Content (Title & Rating)
                    Positioned(
                      left: padding,
                      bottom: padding,
                      right: padding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: titleSize > 22 ? 22 : titleSize, // Cap max font size
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}