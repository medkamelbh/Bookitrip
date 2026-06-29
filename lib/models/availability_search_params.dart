import 'circuit_form_data.dart';

/// Normalized parameters for hotel availability search.
///
/// Used by all three entry points:
///   1. Hotel Details Screen (hotel-specific search)
///   2. Circuit Day View hotel cards (hotel-specific search)
///   3. Reservation Search Bar (destination-wide search)
///
/// Business rules:
///   - Dates are mandatory
///   - [rooms] defaults to 1 room / 2 adults if not provided
///   - If [hotelId] is set, [destinationId] is ignored (hotel-specific)
class AvailabilitySearchParams {
  /// Destination ID for destination-wide search. Ignored when [hotelId] is set.
  final String? destinationId;

  /// Hotel ID for single-hotel availability lookup.
  final String? hotelId;

  /// Hotel slug (needed to fetch detail for client-side computation fallback).
  final String? hotelSlug;

  /// Check-in date (mandatory).
  final DateTime checkIn;

  /// Check-out date (mandatory, must be after [checkIn]).
  final DateTime checkOut;

  /// Room configurations with guest breakdown.
  final List<RoomConfig> rooms;

  const AvailabilitySearchParams({
    this.destinationId,
    this.hotelId,
    this.hotelSlug,
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
  });

  /// Default guest configuration: 1 room, 2 adults, 0 children.
  static List<RoomConfig> get defaultRooms =>
      [const RoomConfig(adults: 2, childAges: [])];

  // ── Computed helpers ──────────────────────────────────────────────────────

  int get totalRooms => rooms.length;

  int get totalAdults => rooms.fold(0, (sum, r) => sum + r.adults);

  int get totalChildren => rooms.fold(0, (sum, r) => sum + r.children);

  int get nights => checkOut.difference(checkIn).inDays;

  bool get isHotelSpecific => hotelId != null && hotelId!.isNotEmpty;

  // ── Validation ────────────────────────────────────────────────────────────

  /// Returns a validation error message, or `null` if valid.
  String? validate() {
    if (checkOut.isBefore(checkIn) || checkOut.isAtSameMomentAs(checkIn)) {
      return 'La date de départ doit être après la date d\'arrivée';
    }
    if (rooms.isEmpty) {
      return 'Au moins une chambre est requise';
    }
    if (!isHotelSpecific &&
        (destinationId == null || destinationId!.isEmpty)) {
      return 'Veuillez sélectionner une destination';
    }
    return null;
  }

  // ── Equality (for dedup) ──────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailabilitySearchParams &&
          destinationId == other.destinationId &&
          hotelId == other.hotelId &&
          checkIn == other.checkIn &&
          checkOut == other.checkOut &&
          rooms.length == other.rooms.length;

  @override
  int get hashCode => Object.hash(destinationId, hotelId, checkIn, checkOut);

  // ── Serialization for API ─────────────────────────────────────────────────

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        if (destinationId != null) 'destination_id': destinationId,
        if (hotelId != null) 'hotel_id': hotelId,
        'check_in': _fmtDate(checkIn),
        'check_out': _fmtDate(checkOut),
        'rooms': rooms.map((r) => r.toJson()).toList(),
      };

  // ── Disponibility API payload ─────────────────────────────────────────

  /// Formats date as dd-MM-yyyy (required by hoteldisponiblepontion endpoint).
  String _fmtDateDdMmYyyy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  /// Builds the payload for POST /utilisateur/hoteldisponiblepontion.
  ///
  /// This endpoint expects dd-MM-yyyy dates and rooms as a list of objects
  /// with adults, children, and childAges.
  Map<String, dynamic> toDisponibilityPayload() => {
        if (destinationId != null) 'destination_id': destinationId,
        'date_start': _fmtDateDdMmYyyy(checkIn),
        'date_end': _fmtDateDdMmYyyy(checkOut),
        'rooms': rooms
            .map((r) => {
                  'adults': r.adults,
                  'children': r.children,
                  'childAges': r.childAges,
                })
            .toList(),
      };

  /// Builds the payload for POST /utilisateur/Mouradi/showdisponibility.
  ///
  /// Mouradi uses yyyy-MM-dd dates and a different payload shape.
  Map<String, dynamic> toMouradiPayload({
    required String hotelMouradiId,
    required String cityMouradiId,
  }) =>
      {
        'Hotel': hotelMouradiId,
        'City': cityMouradiId,
        'CheckIn': _fmtDate(checkIn),
        'CheckOut': _fmtDate(checkOut),
        'Rooms': rooms
            .map((r) => {
                  'Adult': r.adults,
                  'Child': r.childAges,
                })
            .toList(),
      };
}
