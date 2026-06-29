import 'package:BookiTrip/constants/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A single item card for a hotel, restaurant, activity, museum, or monument.
///
/// Shows: cover image, name, address/subtitle, and an optional star rating.
/// Tapping the card is a no-op for now (detail screens are future work).
class DayItemCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? imageUrl;
  final double? rating;
  final AppTheme theme;
  final VoidCallback? onTap;
  final bool showAvailabilityButton;
  final String? hotelId;
  final String? hotelSlug;
  final VoidCallback? onAvailabilityTap;

  const DayItemCard({
    super.key,
    required this.name,
    required this.theme,
    this.subtitle,
    this.imageUrl,
    this.rating,
    this.onTap,
    this.showAvailabilityButton = false,
    this.hotelId,
    this.hotelSlug,
    this.onAvailabilityTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: theme.isDark ? theme.surface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (theme.shadow ?? Colors.black).withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Image ──────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: SizedBox(
                width: 80,
                height: 80,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: theme.primary.withOpacity(0.08),
                          child: Icon(
                            Icons.image_outlined,
                            size: 24,
                            color: theme.primary.withOpacity(0.3),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: theme.primary.withOpacity(0.08),
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 24,
                            color: theme.primary.withOpacity(0.3),
                          ),
                        ),
                      )
                    : Container(
                        color: theme.primary.withOpacity(0.08),
                        child: Icon(
                          Icons.place_outlined,
                          size: 24,
                          color: theme.primary.withOpacity(0.3),
                        ),
                      ),
              ),
            ),

            // ── Content ────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.text.withOpacity(0.45),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    if (rating != null && rating! > 0) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: TextStyle(
                              color: theme.text.withOpacity(0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Availability button or Chevron ─────────────────────────
            if (showAvailabilityButton && onAvailabilityTap != null)
              GestureDetector(
                onTap: onAvailabilityTap,
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.primary.withOpacity(0.20),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 12,
                        color: theme.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Dispo',
                        style: TextStyle(
                          color: theme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.text.withOpacity(0.2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
