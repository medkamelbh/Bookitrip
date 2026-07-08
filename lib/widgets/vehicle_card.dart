import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/vehicle.dart';
import 'package:BookiTrip/services/vehicle_pricing_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final AppTheme theme;
  final VoidCallback onReserve;
  final DateTime? searchFrom;
  final DateTime? searchTo;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.theme,
    required this.onReserve,
    this.searchFrom,
    this.searchTo,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the price to display
    VehiclePricingResult? exactPrice;
    if (searchFrom != null && searchTo != null) {
      exactPrice = VehiclePricingService.calculatePrice(
        vehicle: vehicle,
        from: searchFrom!,
        to: searchTo!,
      );
    }
    final double? lowest = vehicle.lowestPrice;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (theme.shadow ?? Colors.black).withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Vehicle Image ────────────────────────────────────────────
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                vehicle.photo != null && vehicle.photo!.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: vehicle.photo!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _imagePlaceholder(),
                  errorWidget: (_, __, ___) => _imagePlaceholder(),
                )
                    : _imagePlaceholder(),

                // Bottom gradient scrim so the plate & badges stay legible
                // over any photo.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 64,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0),
                          Colors.black.withOpacity(0.45),
                        ],
                      ),
                    ),
                  ),
                ),

                // Status badge — top right
                Positioned(
                  top: 12,
                  right: 12,
                  child: _statusBadge(),
                ),

                // Registration number — styled like a license plate,
                // anchored bottom-left of the image.
                if (vehicle.registrationNumber != null)
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: _plateBadge(vehicle.registrationNumber!),
                  ),
              ],
            ),
          ),

          // ── Info Section ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Brand
                Text(
                  vehicle.title ?? vehicle.model ?? '',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${vehicle.marque ?? ''} ${vehicle.model ?? ''}'.trim(),
                  style: TextStyle(
                    color: theme.text.withOpacity(0.55),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Info chips (registration number removed — now on the image)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (vehicle.startYear != null)
                      _infoChip(
                        Icons.calendar_today_rounded,
                        vehicle.startYear!,
                      ),
                    if (vehicle.kilometers != null)
                      _infoChip(
                        Icons.speed_rounded,
                        '${vehicle.kilometers} km',
                      ),
                    if (vehicle.guarantee != null)
                      _infoChip(
                        Icons.verified_rounded,
                        'vehicles.guarantee_years'
                            .tr(namedArgs: {'count': vehicle.guarantee!}),
                      ),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(height: 1, color: theme.text.withOpacity(0.08)),
                const SizedBox(height: 14),

                // Price + Reserve button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _priceBlock(exactPrice, lowest)),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: vehicle.isActive ? onReserve : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                        theme.primary.withOpacity(0.3),
                        disabledForegroundColor: Colors.white60,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'vehicles.reserve'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.3,
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

  // ── Sub-widgets ──────────────────────────────────────────────────────

  Widget _priceBlock(VehiclePricingResult? exactPrice, double? lowest) {
    if (exactPrice != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total pour ${exactPrice.rentalDays} jours',
            style: TextStyle(
              color: theme.text.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${exactPrice.total.toStringAsFixed(0)} TND',
            style: TextStyle(
              color: theme.primary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${exactPrice.pricePerDay.toStringAsFixed(0)} TND / jour',
            style: TextStyle(
              color: theme.text.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      );
    }

    if (lowest != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'vehicles.starting_from'.tr(),
            style: TextStyle(
              color: theme.text.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${lowest.toStringAsFixed(0)} TND',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2, left: 3),
                child: Text(
                  'vehicles.per_day'.tr(),
                  style: TextStyle(
                    color: theme.text.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (vehicle.isActive ? Colors.green.shade600 : Colors.red.shade600)
            .withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            vehicle.isActive
                ? 'vehicles.status_active'.tr()
                : 'vehicles.status_inactive'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _plateBadge(String registrationNumber) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_car_filled_rounded,
                size: 13,
                color: Colors.black.withOpacity(0.65),
              ),
              const SizedBox(width: 5),
              Text(
                registrationNumber,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.85),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: theme.text,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: theme.primary.withOpacity(0.08),
      child: Center(
        child: Icon(
          Icons.directions_car_rounded,
          size: 48,
          color: theme.primary.withOpacity(0.3),
        ),
      ),
    );
  }
}