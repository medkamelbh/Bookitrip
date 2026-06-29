import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:BookiTrip/constants/theme.dart';

class CircuitCard extends StatelessWidget {
  final AppTheme theme;
  final String title;
  final String duration;
  final String startDestination;
  final String endDestination;
  final String imgUrl;
  final double progress;
  final VoidCallback? onTap;

  const CircuitCard({
    super.key,
    required this.theme,
    required this.title,
    required this.duration,
    required this.startDestination,
    required this.endDestination,
    required this.imgUrl,
    this.progress = 0.7,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 700;

    double f(double size) => size * (width / 390);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: isTablet ? 1.4 : 0.85,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(f(22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.15),
                  blurRadius: 4,
                  spreadRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(f(22)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildOptimizedImage(),
                  ),

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.6),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(f(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildSimpleTag(duration, f),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: f(16),
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(color: Colors.black54, blurRadius: 4)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedImage() {
    final isNetworkImage = imgUrl.startsWith('http://') || imgUrl.startsWith('https://');

    if (isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: imgUrl,
        fit: BoxFit.cover,
        memCacheHeight: 400,
        maxHeightDiskCache: 400,
        placeholder: (context, url) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white54,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[800],
          child: const Icon(Icons.image_not_supported, color: Colors.white54),
        ),
      );
    } else {
      // Asset image
      return Image.asset(
        imgUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[800],
          child: const Icon(Icons.image_not_supported, color: Colors.white54),
        ),
      );
    }
  }

  Widget _buildSimpleTag(String text, double Function(double) f) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: f(12), vertical: f(6)),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(f(12)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: f(13),
        ),
      ),
    );
  }
}

class CircuitCardWithGlass extends StatelessWidget {
  final AppTheme theme;
  final String title;
  final String duration;
  final String startDestination;
  final String endDestination;
  final String imgUrl;
  final double progress;
  final VoidCallback? onTap;

  const CircuitCardWithGlass({
    super.key,
    required this.theme,
    required this.title,
    required this.duration,
    required this.startDestination,
    required this.endDestination,
    required this.imgUrl,
    this.progress = 0.7,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 700;

    double f(double size) => size * (width / 390);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: isTablet ? 1.4 : 0.85,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(f(22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  spreadRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(f(22)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      memCacheHeight: 400,
                      maxHeightDiskCache: 400,
                    ),
                  ),

                  // Single blur layer
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.2),
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(f(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _glassTag(duration, f),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: f(16),
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(color: Colors.black54, blurRadius: 4)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassTag(String text, double Function(double) f) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(f(12)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: f(10), vertical: f(5)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(f(12)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: f(13),
            ),
          ),
        ),
      ),
    );
  }
}