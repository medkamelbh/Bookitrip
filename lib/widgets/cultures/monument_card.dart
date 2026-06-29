import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:BookiTrip/constants/theme.dart';

class MonumentCardWidget extends StatelessWidget {
  final AppTheme theme;
  final String title;
  final String destination;
  final String category;
  final String imgUrl;
  final VoidCallback onTap;

  const MonumentCardWidget({
    super.key,
    required this.theme,
    required this.title,
    required this.destination,
    required this.category,
    required this.imgUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width to calculate dynamic scaling factor
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scale = screenWidth / 375;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15 * scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20 * scale),
            child: Stack(
              children: [
                // Image
                CachedNetworkImage(
                  imageUrl: imgUrl,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.primary.withValues(alpha: 0.1),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.broken_image, size: 40 * scale),
                  ),
                ),

                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ),

                // Category badge
                if (category.isNotEmpty)
                  Positioned(
                    top: 12 * scale,
                    right: 12 * scale,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10 * scale,
                          vertical: 4 * scale
                      ),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20 * scale),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Content
                Positioned(
                  bottom: 12 * scale,
                  left: 15 * scale,
                  right: 15 * scale,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4 * scale),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.redAccent,
                            size: 14 * scale,
                          ),
                          SizedBox(width: 4 * scale),
                          Expanded(
                            child: Text(
                              destination,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13 * scale,
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
      ),
    );
  }
}