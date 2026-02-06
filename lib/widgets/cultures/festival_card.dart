import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:TunisiaBook/constants/theme.dart';

class FestivalCardWidget extends StatelessWidget {
  final AppTheme theme;
  final String title;
  final String destination;
  final String imgUrl;
  final VoidCallback onTap;

  const FestivalCardWidget({
    super.key,
    required this.theme,
    required this.title,
    required this.destination,
    required this.imgUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine screen scale factor
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Proportional sizing
          final double borderRadius = isTablet ? 24 : 20;
          final double titleFontSize = (constraints.maxWidth * 0.04).clamp(16.0, 24.0);
          final double subTitleFontSize = (constraints.maxWidth * 0.04).clamp(12.0, 16.0);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: AspectRatio(
                // Maintains a cinematic 16:9 or similar ratio across all sizes
                aspectRatio: isTablet ? 2.0 : 1.8,
                child: Stack(
                  children: [
                    // Image - Now fills the AspectRatio
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: imgUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.primary.withOpacity(0.05),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.primary.withOpacity(0.05),
                          child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),

                    // Gradient overlay - Positioned.fill ensures it matches the AspectRatio
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.2), // Darkens top for visibility
                              theme.primary.withOpacity(0.85),
                            ],
                            stops: const [0.4, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Positioned(
                      bottom: isTablet ? 20 : 15,
                      left: isTablet ? 20 : 15,
                      right: isTablet ? 20 : 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.redAccent,
                                size: subTitleFontSize * 1.1,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  destination,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: subTitleFontSize,
                                    fontWeight: FontWeight.w500,
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
            ),
          );
        },
      ),
    );
  }
}