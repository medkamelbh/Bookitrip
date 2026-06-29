import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:BookiTrip/constants/theme.dart';

class MuseeCardWidget extends StatelessWidget {
  final AppTheme theme;
  final String title;
  final String situation;
  final String imgUrl;
  final VoidCallback onTap;

  const MuseeCardWidget({
    super.key,
    required this.theme,
    required this.title,
    required this.situation,
    required this.imgUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the scale factor (based on a standard 375px wide screen)
    final double screenWidth = MediaQuery.of(context).size.width;
    final double scale = screenWidth / 375;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16 * scale),
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
          // 1.8 is a great sweet spot for "wide" cards in a list
          aspectRatio: 1.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20 * scale),
            child: Stack(
              children: [
                // Image - Set to fill the AspectRatio container
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

                // Gradient overlay using Positioned.fill to match the image size
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

                // Content
                Positioned(
                  bottom: 15 * scale,
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
                          fontSize: 15 * scale, // Scaled font size
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (situation.isNotEmpty) ...[
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
                                situation,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13 * scale,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
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