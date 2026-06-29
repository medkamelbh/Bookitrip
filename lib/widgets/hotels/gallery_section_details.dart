import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:BookiTrip/constants/theme.dart';

class GallerySection extends StatelessWidget {
  final AppTheme theme;
  final List<String> galleryImages;
  final Function(int) onImageTap;

  const GallerySection({
    super.key,
    required this.theme,
    required this.galleryImages,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (galleryImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.gallery'.tr(),
          style: TextStyle(
            color: theme.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: galleryImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onImageTap(index),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: galleryImages[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.primary.withValues(alpha: 0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.broken_image,
                          color: theme.text.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}