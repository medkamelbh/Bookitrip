class RoomConfig {
  final int adults;
  final List<int> childAges;

  const RoomConfig({
    this.adults = 1,
    this.childAges = const [],
  });

  int get children => childAges.length;

  RoomConfig copyWith({
    int? adults,
    List<int>? childAges,
  }) {
    return RoomConfig(
      adults: adults ?? this.adults,
      childAges: childAges ?? this.childAges,
    );
  }

  Map<String, dynamic> toJson() => {
    'adults': adults,
    'children': childAges.length,
    'childAges': childAges,
  };
}

class CircuitFormData {
  final DateTime startDate;
  final DateTime endDate;
  final String departureCityId;
  final String departureCityName;
  final String arrivalCityId;
  final String arrivalCityName;
  final double budget;
  final List<RoomConfig> rooms;

  const CircuitFormData({
    required this.startDate,
    required this.endDate,
    required this.departureCityId,
    required this.departureCityName,
    required this.arrivalCityId,
    required this.arrivalCityName,
    required this.budget,
    required this.rooms,
  });

  // ── Computed properties ──────────────────────────────────────────────────

  int get duration => endDate.difference(startDate).inDays + 1;

  int get totalRooms => rooms.length;

  int get totalAdults =>
      rooms.fold(0, (sum, r) => sum + r.adults);

  int get totalChildren =>
      rooms.fold(0, (sum, r) => sum + r.children);

  /// Babies = children under 2 years old.
  int get totalBabies =>
      rooms.fold(0, (sum, r) =>
          sum + r.childAges.where((age) => age < 2).length);

  // ── Date formatting ──────────────────────────────────────────────────────

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── API payloads ─────────────────────────────────────────────────────────

  /// Payload for POST /utilisateur/newcircuit (Manual Step 1)
  /// and POST /utilisateur/circuitsmobile (Auto).
  Map<String, dynamic> toFetchPayload() => {
    'budget': budget.toStringAsFixed(0),
    'startDate': _fmtDate(startDate),
    'endDate': _fmtDate(endDate),
    'Vile_depart': departureCityId,
    'Vile_arrive': arrivalCityId,
    'adults': totalAdults.toString(),
    'children': totalChildren.toString(),
    'rooms': totalRooms.toString(),
    'duree': duration,
  };

  /// Payload for POST /utilisateur/createcircuit (Manual Step 2).
  ///
  /// Requires the user's destination selections to be passed separately.
  Map<String, dynamic> toCreatePayload(
      List<Map<String, dynamic>> destinationSelections,
      ) => {
    'dateStart': _fmtDate(startDate),
    'dateEnd': _fmtDate(endDate),
    'destinations': destinationSelections,
    'adults': totalAdults,
    'children': totalChildren,
    'rooms': totalRooms,
    'babies': totalBabies,
    'total': budget,
  };

  /// Reservation sub-payload used inside POST /utilisateur/newreservationcircuit.
  Map<String, dynamic> toReservationMeta() => {
    'departureCity': {'id': departureCityId, 'name': departureCityName},
    'arrivalCity': {'id': arrivalCityId, 'name': arrivalCityName},
    'adults': totalAdults,
    'children': totalChildren,
    'rooms': totalRooms,
    'babies': totalBabies,
    'budget': budget,
    'departureDate': _fmtDate(startDate),
    'arrivalDate': _fmtDate(endDate),
  };
}
