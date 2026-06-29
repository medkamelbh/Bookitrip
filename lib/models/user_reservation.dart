class UserReservation {
  final String id;
  final String status;
  final String? statusPayment;
  final double total;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? hotelName;
  final String? hotelImage;
  final int? adults;
  final int? children;

  const UserReservation({
    required this.id,
    required this.status,
    this.statusPayment,
    required this.total,
    this.startAt,
    this.endAt,
    this.hotelName,
    this.hotelImage,
    this.adults,
    this.children,
  });

  factory UserReservation.fromJson(Map<String, dynamic> json) {
    // The hotel field may be eagerly loaded as a nested map
    final hotel = json['hotel'] as Map<String, dynamic>?;

    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      try { return DateTime.parse(raw.toString()); } catch (_) { return null; }
    }

    return UserReservation(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      statusPayment: json['statusPayment']?.toString(),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      startAt: parseDate(json['start_at']),
      endAt: parseDate(json['end_at']),
      hotelName: hotel?['name']?.toString() ?? hotel?['titre']?.toString(),
      hotelImage: hotel?['image']?.toString() ?? hotel?['photo']?.toString(),
      adults: (json['adultes'] as num?)?.toInt(),
      children: (json['children'] as num?)?.toInt(),
    );
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'confirmed': return 'Confirmée';
      case 'pending': return 'En attente';
      case 'cancelled': return 'Annulée';
      default: return status;
    }
  }
}
