/// Detailed pension data for the reservation screen.
///
/// Contains all rooms under this pension with their full pricing info.
class PensionDetail {
  final String id;
  final String name;
  final String? nameEn;
  final String? nameAr;
  final String? description;
  final String? descriptionEn;
  final String currency;
  final int nightCount;
  final List<RoomDetail> rooms;

  const PensionDetail({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameAr,
    this.description,
    this.descriptionEn,
    this.currency = 'TND',
    this.nightCount = 1,
    this.rooms = const [],
  });

  /// Cheapest room price under this pension.
  double get cheapestPrice {
    if (rooms.isEmpty) return 0;
    return rooms
        .map((r) => r.sellingPrice)
        .reduce((a, b) => a < b ? a : b);
  }

  factory PensionDetail.fromDisponibility(
    Map<String, dynamic> json, {
    required int nbOfPersons,
  }) {
    final roomsJson = json['rooms'] as List<dynamic>? ?? [];
    final rooms = <RoomDetail>[];

    for (final roomJson in roomsJson) {
      final room = roomJson as Map<String, dynamic>;
      final priceList = room['purchase_price'] as List<dynamic>? ?? [];
      if (priceList.isEmpty) continue;

      // SUM all purchase_price entries
      double totalPurchasePrice = 0;
      for (final entry in priceList) {
        final pp = ((entry as Map<String, dynamic>)['purchase_price'] as num?)
                ?.toDouble() ??
            0;
        totalPurchasePrice += pp;
      }

      if (totalPurchasePrice <= 0) continue;

      // Selling price: SUM × 1.12 × nbOfPersons
      final sellingPrice =
          (totalPurchasePrice + (totalPurchasePrice * 12) / 100) * nbOfPersons;

      // Parse capacity
      final capacityList = room['capacity'] as List<dynamic>? ?? [];
      int maxAdults = 2;
      int maxChildren = 0;
      if (capacityList.isNotEmpty) {
        final first = capacityList.first as Map<String, dynamic>;
        maxAdults = (first['adults'] as num?)?.toInt() ?? 2;
        maxChildren = (first['children'] as num?)?.toInt() ?? 0;
      }

      // Get commission from room if available
      final double commission = (room['commission'] as num?)?.toDouble() ?? 12.0;

      rooms.add(RoomDetail(
        id: room['id']?.toString() ?? '',
        pensionId: json['id']?.toString() ?? '',
        title: room['title']?.toString() ?? 'Chambre',
        purchasePrice: totalPurchasePrice,
        sellingPrice: sellingPrice,
        stillAvailable: (room['still_available'] as num?)?.toInt() ?? 0,
        maxAdults: maxAdults,
        maxChildren: maxChildren,
        currency: (priceList.first as Map<String, dynamic>)['currency']
                ?.toString() ??
            'TND',
      ));
    }

    final diffInDays =
        json[' \$diffInDays'] ?? json['\$diffInDays'];
    final nights = diffInDays != null
        ? (diffInDays is int ? diffInDays : int.tryParse(diffInDays.toString()) ?? 1)
        : 1;

    return PensionDetail(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString(),
      nameAr: json['name_ar']?.toString(),
      description: json['description']?.toString(),
      descriptionEn: json['description_en']?.toString(),
      currency: json['devise']?.toString() ?? 'TND',
      nightCount: nights,
      rooms: rooms,
    );
  }
}

class RoomDetail {
  final String id;
  final String pensionId;
  final String title;

  /// Sum of all purchase_price entries (raw cost, no commission).
  final double purchasePrice;
  
  /// The commission percentage.
  final double commission;

  /// Final selling price: purchasePrice × 1.12 × nbOfPersons.
  final double sellingPrice;

  final int stillAvailable;
  final int maxAdults;
  final int maxChildren;
  final String currency;

  const RoomDetail({
    required this.id,
    required this.pensionId,
    required this.title,
    required this.purchasePrice,
    required this.sellingPrice,
    this.commission = 12.0,
    this.stillAvailable = 0,
    this.maxAdults = 2,
    this.maxChildren = 0,
    this.currency = 'TND',
  });
}
