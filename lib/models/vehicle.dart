import 'dart:convert';

class VehiclePriceRange {
  final int dayFrom;
  final int? dayTo;
  final double priceAchat;
  final double priceVente;

  const VehiclePriceRange({
    required this.dayFrom,
    this.dayTo,
    required this.priceAchat,
    required this.priceVente,
  });

  factory VehiclePriceRange.fromJson(Map<String, dynamic> json) {
    return VehiclePriceRange(
      dayFrom: int.tryParse(json['day_from']?.toString() ?? '0') ?? 0,
      dayTo: json['day_to'] != null
          ? int.tryParse(json['day_to'].toString())
          : null,
      priceAchat:
          double.tryParse(json['price_achat']?.toString() ?? '0') ?? 0.0,
      priceVente:
          double.tryParse(json['price_vente']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'day_from': dayFrom.toString(),
        'day_to': dayTo?.toString(),
        'price_achat': priceAchat.toString(),
        'price_vente': priceVente.toString(),
      };
}

class VehiclePricePeriod {
  final String? from;
  final String? to;
  final List<VehiclePriceRange> prices;

  const VehiclePricePeriod({
    this.from,
    this.to,
    this.prices = const [],
  });

  factory VehiclePricePeriod.fromJson(Map<String, dynamic> json) {
    return VehiclePricePeriod(
      from: json['from'] as String?,
      to: json['to'] as String?,
      prices: (json['prices'] as List<dynamic>?)
              ?.map((e) =>
                  VehiclePriceRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'prices': prices.map((e) => e.toJson()).toList(),
      };
}

class Vehicle {
  final String id;
  final String? model;
  final String? marque;
  final String? startYear;
  final String? registrationNumber;
  final String? kilometers;
  final String? guarantee;
  final String? title;
  final String? status;
  final String? photo;
  final List<VehiclePricePeriod> price;
  final String? agency;
  final String? createdAt;
  final String? updatedAt;

  const Vehicle({
    required this.id,
    this.model,
    this.marque,
    this.startYear,
    this.registrationNumber,
    this.kilometers,
    this.guarantee,
    this.title,
    this.status,
    this.photo,
    this.price = const [],
    this.agency,
    this.createdAt,
    this.updatedAt,
  });

  /// Whether the vehicle is currently active/available.
  bool get isActive => status?.toLowerCase() == 'active';

  /// Returns the lowest `price_vente` across all pricing tiers, or null.
  double? get lowestPrice {
    double? lowest;
    for (final period in price) {
      for (final range in period.prices) {
        if (lowest == null || range.priceVente < lowest) {
          lowest = range.priceVente;
        }
      }
    }
    return lowest;
  }

  static List<VehiclePricePeriod> _parsePrices(dynamic rawPrices) {
    if (rawPrices == null || rawPrices is! List) return [];
    
    final List<VehiclePricePeriod> result = [];
    for (final item in rawPrices) {
      if (item is Map<String, dynamic>) {
        result.add(VehiclePricePeriod.fromJson(item));
      } else if (item is String) {
        try {
          final decoded = jsonDecode(item);
          if (decoded is Map<String, dynamic>) {
            result.add(VehiclePricePeriod.fromJson(decoded));
          }
        } catch (_) {}
      }
    }
    return result;
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      model: json['model'] as String?,
      marque: json['marque'] as String?,
      startYear: json['start_year'] as String?,
      registrationNumber: json['registration_number'] as String?,
      kilometers: json['kilometers'] as String?,
      guarantee: json['guarantee'] as String?,
      title: json['title'] as String?,
      status: json['status'] as String?,
      photo: json['photo'] as String?,
      price: _parsePrices(json['price']),
      agency: json['agency']?.toString(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'model': model,
        'marque': marque,
        'start_year': startYear,
        'registration_number': registrationNumber,
        'kilometers': kilometers,
        'guarantee': guarantee,
        'title': title,
        'status': status,
        'photo': photo,
        'price': price.map((e) => e.toJson()).toList(),
        'agency': agency,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
