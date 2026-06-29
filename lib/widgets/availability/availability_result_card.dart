import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/availability_result.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Card widget displaying a single hotel's availability result.
///
/// Shows: hotel image, name, stars, destination, availability badge,
/// offer badges (flash sales, SPOs), pension chips with prices,
/// starting price, minimum stay notice, and CTA.
class AvailabilityResultCard extends StatelessWidget {
  final AvailabilityResult result;
  final AppTheme theme;
  final VoidCallback? onTap;
  final VoidCallback? onReserve;

  const AvailabilityResultCard({
    super.key,
    required this.result,
    required this.theme,
    this.onTap,
    this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: theme.isDark ? theme.surface : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.isDark
                ? Colors.white10
                : Colors.black.withOpacity(0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (theme.shadow ?? Colors.black).withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + badges ──────────────────────────────────────────
            _buildImageSection(),

            // ── Content ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel name
                  Text(
                    result.hotelName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Destination + stars
                  Row(
                    children: [
                      if (result.destinationName != null &&
                          result.destinationName!.isNotEmpty) ...[
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: theme.text.withOpacity(0.4),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            result.destinationName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.text.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                      if (result.stars != null && result.stars! > 0) ...[
                        const SizedBox(width: 10),
                        ..._buildStars(result.stars!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Price display ──────────────────────────────────────
                  if (result.hasPrice) ...[
                    _buildPriceSection(),
                    const SizedBox(height: 8),
                  ],

                  // ── Pension chips ──────────────────────────────────────


                  // Available rooms (only if no pension data)
                  if (result.isAvailable &&
                      result.rooms.isNotEmpty &&
                      result.pensions.isEmpty) ...[
                    ...result.rooms.take(3).map((room) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                room.available
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.cancel_outlined,
                                size: 14,
                                color: room.available
                                    ? const Color(0xFF2E7D32)
                                    : Colors.red.shade400,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  room.name,
                                  style: TextStyle(
                                    color: theme.text.withOpacity(0.65),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],

                  // Minimum stay notice
                  if (result.minimumStayNights != null &&
                      result.minimumStayNights! > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Séjour minimum : ${result.minimumStayNights} nuit${result.minimumStayNights! > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ── Action buttons ─────────────────────────────────
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // View Details button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onTap,
                          icon: Icon(Icons.visibility_outlined,
                              size: 16, color: theme.primary),
                          label: Text(
                            'Détails',
                            style: TextStyle(
                              color: theme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: theme.primary.withOpacity(0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Reserve button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: result.isAvailable ? onReserve : null,
                          icon: const Icon(Icons.bookmark_add_outlined,
                              size: 16, color: Colors.white),
                          label: const Text(
                            'Réserver',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            disabledBackgroundColor:
                                theme.primary.withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  // ── Price section ─────────────────────────────────────────────────────────

  Widget _buildPriceSection() {
    final price = result.startingPrice!;
    final suffix = result.nightCount != null && result.nightCount! > 0
        ? ' / ${result.nightCount} nuit${result.nightCount! > 1 ? 's' : ''}'
        : ' total';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.payments_outlined,
            size: 18,
            color: theme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'À partir de ',
            style: TextStyle(
              color: theme.text.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${price.toStringAsFixed(0)} ${result.currency}',
            style: TextStyle(
              color: theme.primary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            suffix,
            style: TextStyle(
              color: theme.text.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Pension chips ─────────────────────────────────────────────────────────




  // ── Image section ───────────────────────────────────────────────────────

  Widget _buildImageSection() {
    final imageUrl = result.cover ?? result.vignette;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(18),
        topRight: Radius.circular(18),
      ),
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            imageUrl != null && imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: theme.primary.withOpacity(0.08),
                      child: Center(
                        child: Icon(
                          Icons.hotel_rounded,
                          size: 32,
                          color: theme.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: theme.primary.withOpacity(0.08),
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 32,
                        color: theme.primary.withOpacity(0.3),
                      ),
                    ),
                  )
                : Container(
                    color: theme.primary.withOpacity(0.08),
                    child: Icon(
                      Icons.hotel_rounded,
                      size: 40,
                      color: theme.primary.withOpacity(0.3),
                    ),
                  ),

            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.15),
                    ],
                  ),
                ),
              ),
            ),

            // Availability badge (top-left)
            Positioned(
              top: 10,
              left: 10,
              child: _buildAvailabilityBadge(),
            ),

            // Offer badges (top-right)
            if (result.offers.isNotEmpty)
              Positioned(
                top: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: result.offers
                      .take(2)
                      .map((offer) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: _buildOfferBadge(offer),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge() {
    final bool available = result.isAvailable;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: available
            ? const Color(0xFF2E7D32).withOpacity(0.90)
            : Colors.red.shade600.withOpacity(0.90),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            available
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            available ? 'Disponible' : 'Non disponible',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferBadge(OfferBadge offer) {
    Color badgeColor;
    IconData badgeIcon;

    switch (offer.type) {
      case 'flash_sale':
        badgeColor = Colors.deepOrange;
        badgeIcon = Icons.flash_on_rounded;
        break;
      case 'spo':
        badgeColor = const Color(0xFF7B1FA2);
        badgeIcon = Icons.local_offer_rounded;
        break;
      default:
        badgeColor = theme.primary;
        badgeIcon = Icons.discount_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.90),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            offer.percentage > 0
                ? '-${offer.percentage}%'
                : offer.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars(int count) {
    final clamped = count.clamp(0, 5);
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          return Icon(
            i < clamped ? Icons.star_rounded : Icons.star_border_rounded,
            size: 14,
            color: i < clamped
                ? Colors.amber.shade600
                : theme.text.withOpacity(0.2),
          );
        }),
      ),
    ];
  }
}
