import 'package:BookiTrip/models/pension_detail.dart';

/// Result of an availability search for a single hotel.
///
/// Contains availability status, room options, pricing data from the
/// disponibility/pension API, and active promotional offers (flash sales,
/// SPOs, discounts).
class AvailabilityResult {
  final String hotelId;
  final String hotelName;
  final String? hotelSlug;
  final String? cover;
  final String? vignette;
  final int? stars;
  final String? destinationName;
  final String? address;
  final bool isAvailable;
  final List<RoomAvailability> rooms;
  final List<OfferBadge> offers;
  final int? minimumStayNights;
  final bool reservable;

  // ── Pricing & pension fields (from disponibility API) ────────────────────

  /// Provider type: 'tgt', 'bhr', 'mouradi', or null for generic/unknown.
  final String? providerType;

  /// Lowest price across all pension/room combinations (commission applied).
  /// For TGT: `purchasePrice * (1 + commission/100)` per person per night.
  /// For BHR: `rate * 1.1` (total stay).
  /// For Mouradi: `price * 1.1` per room.
  final double? startingPrice;

  /// Currency code (defaults to 'TND').
  final String currency;

  /// Number of nights (for per-night price context).
  final int? nightCount;

  /// Summary of available pension/boarding options with cheapest prices.
  final List<PensionSummary> pensions;

  /// Full pension details with room breakdowns (for reservation screen).
  final List<PensionDetail> pensionDetails;

  const AvailabilityResult({
    required this.hotelId,
    required this.hotelName,
    this.hotelSlug,
    this.cover,
    this.vignette,
    this.stars,
    this.destinationName,
    this.address,
    required this.isAvailable,
    this.rooms = const [],
    this.offers = const [],
    this.minimumStayNights,
    this.reservable = true,
    this.providerType,
    this.startingPrice,
    this.currency = 'TND',
    this.nightCount,
    this.pensions = const [],
    this.pensionDetails = const [],
  });

  /// Whether this result has real pricing data from the disponibility API.
  bool get hasPrice => startingPrice != null && startingPrice! > 0;

  factory AvailabilityResult.fromJson(Map<String, dynamic> json) {
    return AvailabilityResult(
      hotelId: json['hotel_id']?.toString() ?? json['id']?.toString() ?? '',
      hotelName: json['hotel_name']?.toString() ?? json['name']?.toString() ?? '',
      hotelSlug: json['slug']?.toString(),
      cover: json['cover']?.toString(),
      vignette: json['vignette']?.toString(),
      stars: json['stars'] is int
          ? json['stars']
          : int.tryParse(json['stars']?.toString() ?? ''),
      destinationName: json['destination_name']?.toString() ??
          (json['destination'] is Map ? json['destination']['name']?.toString() : null),
      isAvailable: json['is_available'] == true ||
          json['available'] == true ||
          json['is_available'] == 1,
      rooms: (json['rooms'] as List<dynamic>? ?? [])
          .map((e) => RoomAvailability.fromJson(e as Map<String, dynamic>))
          .toList(),
      offers: (json['offers'] as List<dynamic>? ?? [])
          .map((e) => OfferBadge.fromJson(e as Map<String, dynamic>))
          .toList(),
      minimumStayNights: json['minimum_stay'] is int
          ? json['minimum_stay']
          : int.tryParse(json['minimum_stay']?.toString() ?? ''),
      reservable: json['reservable'] == true || json['reservable'] == 1,
      providerType: json['provider_type']?.toString(),
      startingPrice: (json['starting_price'] is num)
          ? (json['starting_price'] as num).toDouble()
          : double.tryParse(json['starting_price']?.toString() ?? ''),
      currency: json['currency']?.toString() ?? 'TND',
      nightCount: json['night_count'] is int
          ? json['night_count']
          : int.tryParse(json['night_count']?.toString() ?? ''),
      pensions: (json['pensions'] as List<dynamic>? ?? [])
          .map((e) => PensionSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'hotel_id': hotelId,
        'hotel_name': hotelName,
        'slug': hotelSlug,
        'cover': cover,
        'vignette': vignette,
        'stars': stars,
        'destination_name': destinationName,
        'is_available': isAvailable,
        'rooms': rooms.map((r) => r.toJson()).toList(),
        'offers': offers.map((o) => o.toJson()).toList(),
        'minimum_stay': minimumStayNights,
        'reservable': reservable,
        'provider_type': providerType,
        'starting_price': startingPrice,
        'currency': currency,
        'night_count': nightCount,
        'pensions': pensions.map((p) => p.toJson()).toList(),
      };
}

/// Summary of a single pension/boarding option for display.
class PensionSummary {
  final String id;
  final String name;

  /// Localized names for multi-language support.
  final String? nameEn;
  final String? nameAr;

  /// Cheapest room price under this pension (with commission applied).
  final double cheapestPrice;

  /// Number of room types available under this pension.
  final int roomCount;

  /// Currency code.
  final String currency;

  const PensionSummary({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameAr,
    required this.cheapestPrice,
    this.roomCount = 0,
    this.currency = 'TND',
  });

  factory PensionSummary.fromJson(Map<String, dynamic> json) {
    return PensionSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString(),
      nameAr: json['name_ar']?.toString(),
      cheapestPrice: (json['cheapest_price'] is num)
          ? (json['cheapest_price'] as num).toDouble()
          : double.tryParse(json['cheapest_price']?.toString() ?? '') ?? 0,
      roomCount: json['room_count'] is int
          ? json['room_count']
          : int.tryParse(json['room_count']?.toString() ?? '') ?? 0,
      currency: json['currency']?.toString() ?? 'TND',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_en': nameEn,
        'name_ar': nameAr,
        'cheapest_price': cheapestPrice,
        'room_count': roomCount,
        'currency': currency,
      };
}

/// A single room/accommodation option returned by the availability API.
class RoomAvailability {
  final String accommodationId;
  final String name;
  final int capacity;
  final bool available;

  const RoomAvailability({
    required this.accommodationId,
    required this.name,
    this.capacity = 2,
    this.available = true,
  });

  factory RoomAvailability.fromJson(Map<String, dynamic> json) {
    return RoomAvailability(
      accommodationId:
          json['accommodation_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Chambre',
      capacity: json['capacity'] is int
          ? json['capacity']
          : int.tryParse(json['capacity']?.toString() ?? '') ?? 2,
      available: json['available'] == true || json['available'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'accommodation_id': accommodationId,
        'name': name,
        'capacity': capacity,
        'available': available,
      };
}

/// A promotional offer badge (flash sale, SPO, or discount).
class OfferBadge {
  final String type; // 'flash_sale', 'spo', 'discount'
  final String label;
  final int percentage;
  final DateTime? validUntil;

  const OfferBadge({
    required this.type,
    required this.label,
    required this.percentage,
    this.validUntil,
  });

  factory OfferBadge.fromJson(Map<String, dynamic> json) {
    return OfferBadge(
      type: json['type']?.toString() ?? 'discount',
      label: json['label']?.toString() ?? '',
      percentage: json['percentage'] is int
          ? json['percentage']
          : int.tryParse(json['percentage']?.toString() ?? '') ?? 0,
      validUntil: json['valid_until'] != null
          ? DateTime.tryParse(json['valid_until'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'label': label,
        'percentage': percentage,
        'valid_until': validUntil?.toIso8601String(),
      };
}
