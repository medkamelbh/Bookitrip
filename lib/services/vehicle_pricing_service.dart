import 'package:BookiTrip/models/vehicle.dart';

/// Result of a vehicle rental price calculation.
class VehiclePricingResult {
  /// The matched price per day (price_vente).
  final double pricePerDay;

  /// Total cost: [pricePerDay] × [rentalDays].
  final double total;

  /// Number of rental days.
  final int rentalDays;

  const VehiclePricingResult({
    required this.pricePerDay,
    required this.total,
    required this.rentalDays,
  });
}

/// Isolated, reusable pricing logic for vehicle rentals.
///
/// The backend returns a nested structure: `price` array contains periods
/// (with `from` and `to` dates), and each period contains a `prices` array
/// (with `day_from` and `day_to` thresholds and `price_vente`).
class VehiclePricingService {
  /// Calculates the rental price for [vehicle] between [from] and [to].
  ///
  /// Returns `null` if no matching price entry is found or if the dates
  /// are invalid.
  static VehiclePricingResult? calculatePrice({
    required Vehicle vehicle,
    required DateTime from,
    required DateTime to,
  }) {
    final rentalDays = to.difference(from).inDays;
    if (rentalDays < 1) return null;

    final range = _findMatchingPriceRange(vehicle.price, from, rentalDays);
    if (range == null) return null;

    final pricePerDay = range.priceVente;
    return VehiclePricingResult(
      pricePerDay: pricePerDay,
      total: pricePerDay * rentalDays,
      rentalDays: rentalDays,
    );
  }

  /// Finds the [VehiclePriceRange] whose period matches [rentalStart]
  /// and whose duration thresholds match [rentalDays].
  static VehiclePriceRange? _findMatchingPriceRange(
    List<VehiclePricePeriod> periods,
    DateTime rentalStart,
    int rentalDays,
  ) {
    // 1. Find matching period based on rental start date
    VehiclePricePeriod? matchedPeriod;
    for (final period in periods) {
      final pFrom = period.from != null ? DateTime.tryParse(period.from!) : null;
      final pTo = period.to != null ? DateTime.tryParse(period.to!) : null;

      if (pFrom == null || pTo == null) continue;

      if (!rentalStart.isBefore(pFrom) && !rentalStart.isAfter(pTo)) {
        matchedPeriod = period;
        break;
      }
    }

    if (matchedPeriod == null) {
      if (periods.isEmpty) return null;
      // Fallback to first period if no date match
      matchedPeriod = periods.first;
    }

    // 2. Find matching duration range within the period
    for (final range in matchedPeriod.prices) {
      if (rentalDays >= range.dayFrom) {
        if (range.dayTo == null || rentalDays <= range.dayTo!) {
          return range;
        }
      }
    }

    if (matchedPeriod.prices.isNotEmpty) {
      return matchedPeriod.prices.last;
    }

    return null;
  }
}
