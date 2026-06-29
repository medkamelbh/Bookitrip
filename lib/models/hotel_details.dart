import 'package:BookiTrip/models/destination.dart';
import 'package:flutter/material.dart';
import '../utils/localized_field.dart';

class HotelDetail {
  final String type;
  final bool auto;
  final String childMinage;
  final String childMaxage;
  final String idCityBbx;
  final String idHotelBbx;
  final String arabicCrtDescription;
  final String name;
  final String address;
  final String ville;
  final String? villeAr;
  final String? villeEn;
  final String? villeRu;
  final String? villeZh;
  final String? villeKo;
  final String? villeJa;
  final String phone;
  final String fax;
  final String email;
  final String website;
  final double lat;
  final double lng;
  final String cover;
  final String description;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? descriptionRu;
  final String? descriptionZh;
  final String? descriptionKo;
  final String? descriptionJa;

  final bool isSpecial;
  final Links links;
  final List<dynamic> options;
  final bool reservable;
  final List<Bio> bios;
  final List<dynamic> cancellations;
  final List<ReleaseHotel> releaseHotels;
  final List<FlashSale> flashSales;
  final List<MinimumStay> minimumstay;
  final List<Spo> spo;
  final List<Discount> discounts;
  final String? slug;
  final String? videoLink;
  final String? vignette;
  final String? destinationId;
  final String? categoryCode;
  final String? nameEn;
  final String? addressEn;
  final String? nameAr;
  final String? addressAr;
  final String? nameRu;
  final String? addressRu;
  final String? nameZh;
  final String? addressZh;
  final String? nameKo;
  final String? addressKo;
  final String? nameJa;
  final String? addressJa;
  final String? id;
  final Destination? destination;
  final List<String>? gallery;
  final List<String>? images;
  final String? idCityMouradi;
  final String? idHotelMouradi;
  final String? idHotelBhr;

  HotelDetail({
    required this.type,
    required this.auto,
    required this.childMinage,
    required this.childMaxage,
    required this.idCityBbx,
    required this.idHotelBbx,
    required this.arabicCrtDescription,
    required this.name,
    required this.address,
    required this.ville,
    required this.phone,
    required this.fax,
    required this.email,
    required this.website,
    required this.lat,
    required this.lng,
    required this.cover,
    required this.description,
    required this.isSpecial,
    required this.links,
    required this.options,
    required this.reservable,
    required this.bios,
    required this.cancellations,
    required this.releaseHotels,
    required this.flashSales,
    required this.minimumstay,
    required this.spo,
    required this.discounts,
    this.slug,
    this.videoLink,
    this.vignette,
    this.destinationId,
    this.categoryCode,
    this.nameEn,
    this.addressEn,
    this.descriptionEn,
    this.nameAr,
    this.addressAr,
    this.descriptionAr,
    this.nameRu,
    this.addressRu,
    this.descriptionRu,
    this.nameZh,
    this.addressZh,
    this.descriptionZh,
    this.nameKo,
    this.addressKo,
    this.descriptionKo,
    this.nameJa,
    this.addressJa,
    this.descriptionJa,
    this.id,
    this.destination,
    this.gallery,
    this.images,
    this.idCityMouradi,
    this.idHotelMouradi,
    this.idHotelBhr,
    this.villeAr,
    this.villeEn,
    this.villeRu,
    this.villeZh,
    this.villeKo,
    this.villeJa

  });

  factory HotelDetail.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    return HotelDetail(
      type: json['type'] ?? '',
      auto: parseBool(json['auto']),
      childMinage: json['Child_minage'] ?? '0',
      childMaxage: json['Child_maxage'] ?? '12',
      idCityBbx: json['id_city_bbx'] ?? '',
      idHotelBbx: json['id_hotel_bbx'] ?? '',
      arabicCrtDescription: json['arabic_crt_description'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      ville: json['ville'] ?? '',
      phone: json['phone'] ?? '',
      fax: json['fax'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      lat: double.tryParse(json['lat'] ?? '0.0') ?? 0.0,
      lng: double.tryParse(json['lng'] ?? '0.0') ?? 0.0,
      cover: json['cover'] ?? '',
      description: json['description'] ?? '',
      isSpecial: parseBool(json['is_special']),
      links: Links.fromJson(json['links'] ?? {}),
      videoLink: json['video_link'],
      options: json['options'] ?? [],
      reservable: parseBool(json['reservable']),
      bios: (json['bios'] as List<dynamic>? ?? [])
          .map((e) => Bio.fromJson(e))
          .toList(),
      cancellations: json['cancellations'] ?? [],
      releaseHotels: (json['release_hotels'] as List<dynamic>? ?? [])
          .map((e) => ReleaseHotel.fromJson(e))
          .toList(),
      flashSales: (json['flash_sales'] as List<dynamic>? ?? [])
          .map((e) => FlashSale.fromJson(e))
          .toList(),
      minimumstay: (json['minimumstay'] as List<dynamic>? ?? [])
          .map((e) => MinimumStay.fromJson(e))
          .toList(),
      spo: (json['spo'] as List<dynamic>? ?? [])
          .map((e) => Spo.fromJson(e))
          .toList(),
      discounts: (json['discounts'] as List<dynamic>? ?? [])
          .map((e) => Discount.fromJson(e))
          .toList(),
      slug: json['slug'],
      vignette: json['vignette'],
      destinationId: json['destination_id'],
      categoryCode: json['category_code'],

      nameEn: json['name_en'],
      addressEn: json['address_en'],
      descriptionEn: json['description_en'],
      villeEn: json['ville_en'],

      nameAr: json['name_ar'],
      addressAr: json['address_ar'],
      villeAr: json['ville_ar'],
      descriptionAr: json['description_ar'],

      nameRu: json['name_ru'],
      addressRu: json['address_ru'],
      villeRu: json['ville_ru'],
      descriptionRu: json['description_ru'],

      nameZh: json['name_zh'],
      addressZh: json['address_zh'],
      villeZh: json['ville_zh'],
      descriptionZh: json['description_zh'],

      nameKo: json['name_ko'],
      addressKo: json['address_ko'],
      villeKo: json['ville_ko'],
      descriptionKo: json['description_ko'],

      nameJa: json['name_ja'],
      addressJa: json['address_ja'],
      villeJa: json['ville_ja'],
      descriptionJa: json['description_ja'],

      id: json['id'],
      destination: json['destination'] != null
          ? Destination.fromJson(json['destination'])
          : null,
      gallery: json['gallery'] != null
          ? List<String>.from(json['gallery'])
          : (json['destination']?['gallery'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      idCityMouradi: json['id_city_mouradi'] ?? '',
      idHotelMouradi: json['id_hotel_mouradi'] ?? '',
      idHotelBhr: json['id_hotel_bhr'] ?? '',

    );
  }


  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'auto': auto,
      'Child_minage': childMinage,
      'Child_maxage': childMaxage,
      'id_city_bbx': idCityBbx,
      'id_hotel_bbx': idHotelBbx,
      'arabic_crt_description': arabicCrtDescription,
      'name': name,
      'address': address,
      'ville': ville,
      'phone': phone,
      'fax': fax,
      'email': email,
      'website': website,
      'lat': lat,
      'lng': lng,
      'cover': cover,
      'description': description,
      'is_special': isSpecial,
      'links': links.toJson(),
      'options': options,
      'reservable': reservable,
      'bios': bios.map((e) => e.toJson()).toList(),
      'cancellations': cancellations,
      'release_hotels': releaseHotels.map((e) => e.toJson()).toList(),
      'flash_sales': flashSales.map((e) => e.toJson()).toList(),
      'minimumstay': minimumstay.map((e) => e.toJson()).toList(),
      'spo': spo.map((e) => e.toJson()).toList(),
      'discounts': discounts.map((e) => e.toJson()).toList(),
      'slug': slug,
      'vignette': vignette,
      'destination_id': destinationId,
      'category_code': categoryCode,
      'name_en': nameEn,
      'address_en': addressEn,
      'name_ar': nameAr,
      'address_ar': addressAr,
      'name_ru': nameRu,
      'address_ru': addressRu,
      'name_zh': nameZh,
      'address_zh': addressZh,
      'name_ko': nameKo,
      'address_ko': addressKo,
      'name_ja': nameJa,
      'address_ja': addressJa,
      'id': id,
      'destination': destination?.toJson(),
      'gallery': gallery,
      'images': images,

    };
  }
  String getName(Locale locale) => localizedValue(locale, name, {
        'en': nameEn, 'ar': nameAr, 'ru': nameRu,
        'zh': nameZh, 'ko': nameKo, 'ja': nameJa,
      });

  String getAddress(Locale locale) => localizedValue(locale, address, {
        'en': addressEn, 'ar': addressAr, 'ru': addressRu,
        'zh': addressZh, 'ko': addressKo, 'ja': addressJa,
      });

  String getVille(Locale locale) => localizedValue(locale, ville, {
        'en': villeEn, 'ar': villeAr, 'ru': villeRu,
        'zh': villeZh, 'ko': villeKo, 'ja': villeJa,
      });

  String getDescription(Locale locale) => localizedValue(locale, description, {
        'en': descriptionEn, 'ar': descriptionAr, 'ru': descriptionRu,
        'zh': descriptionZh, 'ko': descriptionKo, 'ja': descriptionJa,
      });




}

class Links {
  final String website;
  final String facebook;
  final String instagram;
  final String youtube;
  final String twitter;

  Links({
    required this.website,
    required this.facebook,
    required this.instagram,
    required this.youtube,
    required this.twitter,
  });

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      website: json['website'] ?? '',
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
      youtube: json['youtube'] ?? '',
      twitter: json['twitter'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'website': website,
      'facebook': facebook,
      'instagram': instagram,
      'youtube': youtube,
      'twitter': twitter,
    };
  }
}



class Bio {
  final String name;
  final String nameRu;
  final String nameEn;
  final String nameAr;
  final String nameZh;
  final String nameKo;
  final String nameJa;
  final String description;
  final String descriptionRu;
  final String descriptionEn;
  final String descriptionAr;
  final String descriptionZh;
  final String descriptionKo;
  final String descriptionJa;
  final String icon;
  final String hotelIds; // Stored as JSON string in sample, but parsed as string for simplicity
  final String id;

  Bio({
    required this.name,
    required this.nameRu,
    required this.nameEn,
    required this.nameAr,
    required this.nameZh,
    required this.nameKo,
    required this.nameJa,
    required this.description,
    required this.descriptionRu,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.descriptionZh,
    required this.descriptionKo,
    required this.descriptionJa,
    required this.icon,
    required this.hotelIds,
    required this.id,
  });

  factory Bio.fromJson(Map<String, dynamic> json) {
    return Bio(
      name: json['name'] ?? '',
      nameRu: json['name_ru'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameZh: json['name_zh'] ?? '',
      nameKo: json['name_ko'] ?? '',
      nameJa: json['name_ja'] ?? '',
      description: json['description'] ?? '',
      descriptionRu: json['description_ru'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      descriptionZh: json['description_zh'] ?? '',
      descriptionKo: json['description_ko'] ?? '',
      descriptionJa: json['description_ja'] ?? '',
      icon: json['icon'] ?? '',
      hotelIds: json['hotel_ids'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'name_ru': nameRu,
      'name_en': nameEn,
      'name_ar': nameAr,
      'name_zh': nameZh,
      'name_ko': nameKo,
      'name_ja': nameJa,
      'description': description,
      'description_ru': descriptionRu,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'description_zh': descriptionZh,
      'description_ko': descriptionKo,
      'description_ja': descriptionJa,
      'icon': icon,
      'hotel_ids': hotelIds,
      'id': id,
    };
  }
  String getName(Locale locale) => localizedValue(locale, name, {
        'en': nameEn, 'ar': nameAr, 'ru': nameRu,
        'zh': nameZh, 'ko': nameKo, 'ja': nameJa,
      });

  String getDescription(Locale locale) => localizedValue(locale, description, {
        'en': descriptionEn, 'ar': descriptionAr, 'ru': descriptionRu,
        'zh': descriptionZh, 'ko': descriptionKo, 'ja': descriptionJa,
      });
}

class ReleaseHotel {
  final String hotelId;
  final String dateStart;
  final String dateEnd;
  final int dayNumber;
  final String marchiId;
  final String updatedAt;
  final String createdAt;
  final String id;

  ReleaseHotel({
    required this.hotelId,
    required this.dateStart,
    required this.dateEnd,
    required this.dayNumber,
    required this.marchiId,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory ReleaseHotel.fromJson(Map<String, dynamic> json) {
    return ReleaseHotel(
      hotelId: json['hotel_id'] ?? '',
      dateStart: json['date_start'] ?? '',
      dateEnd: json['date_end'] ?? '',
      dayNumber: json['day_number'] ?? 0,
      marchiId: json['marchi_id'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotel_id': hotelId,
      'date_start': dateStart,
      'date_end': dateEnd,
      'day_number': dayNumber,
      'marchi_id': marchiId,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}

class FlashSale {
  final String hotelId;
  final String dateStart;
  final String dateEnd;
  final int percentage;
  final String updatedAt;
  final String createdAt;
  final String id;

  FlashSale({
    required this.hotelId,
    required this.dateStart,
    required this.dateEnd,
    required this.percentage,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory FlashSale.fromJson(Map<String, dynamic> json) {
    return FlashSale(
      hotelId: json['hotel_id'] ?? '',
      dateStart: json['date_start'] ?? '',
      dateEnd: json['date_end'] ?? '',
      percentage: json['percentage'] ?? 0,
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotel_id': hotelId,
      'date_start': dateStart,
      'date_end': dateEnd,
      'percentage': percentage,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}

class MinimumStay {
  final String hotelId;
  final String dateStart;
  final String dateEnd;
  final int number;
  final String? marchiId;
  final String updatedAt;
  final String createdAt;
  final String id;

  MinimumStay({
    required this.hotelId,
    required this.dateStart,
    required this.dateEnd,
    required this.number,
    this.marchiId,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory MinimumStay.fromJson(Map<String, dynamic> json) {
    return MinimumStay(
      hotelId: json['hotel_id'] ?? '',
      dateStart: json['date_start'] ?? '',
      dateEnd: json['date_end'] ?? '',
      number: json['number'] ?? 0,
      marchiId: json['marchi_id'],
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotel_id': hotelId,
      'date_start': dateStart,
      'date_end': dateEnd,
      'number': number,
      'marchi_id': marchiId,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}

class Spo {
  final String hotelId;
  final String dateBefore;
  final String dateStartStay;
  final String dateEndStay;
  final List<Percentage> percentage;
  final String updatedAt;
  final String createdAt;
  final String id;

  Spo({
    required this.hotelId,
    required this.dateBefore,
    required this.dateStartStay,
    required this.dateEndStay,
    required this.percentage,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory Spo.fromJson(Map<String, dynamic> json) {
    return Spo(
      hotelId: json['hotel_id'] ?? '',
      dateBefore: json['date_before'] ?? '',
      dateStartStay: json['date_start_stay'] ?? '',
      dateEndStay: json['date_end_stay'] ?? '',
      percentage: (json['percentage'] as List<dynamic>? ?? [])
          .map((e) => Percentage.fromJson(e))
          .toList(),
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotel_id': hotelId,
      'date_before': dateBefore,
      'date_start_stay': dateStartStay,
      'date_end_stay': dateEndStay,
      'percentage': percentage.map((e) => e.toJson()).toList(),
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}

class Percentage {
  final String accommodationId;
  final String discountType;
  final int value;

  Percentage({
    required this.accommodationId,
    required this.discountType,
    required this.value,
  });

  factory Percentage.fromJson(Map<String, dynamic> json) {
    return Percentage(
      accommodationId: json['accommodation_id'] ?? '',
      discountType: json['discount_type'] ?? '',
      value: json['value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accommodation_id': accommodationId,
      'discount_type': discountType,
      'value': value,
    };
  }
}

class Discount {
  final String hotelId;
  final String dateStart;
  final String dateEnd;
  final List<DiscountDetail> discounts;
  final String updatedAt;
  final String createdAt;
  final String id;

  Discount({
    required this.hotelId,
    required this.dateStart,
    required this.dateEnd,
    required this.discounts,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      hotelId: json['hotel_id'] ?? '',
      dateStart: json['date_start'] ?? '',
      dateEnd: json['date_end'] ?? '',
      discounts: (json['discounts'] as List<dynamic>? ?? [])
          .map((e) => DiscountDetail.fromJson(e))
          .toList(),
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotel_id': hotelId,
      'date_start': dateStart,
      'date_end': dateEnd,
      'discounts': discounts.map((e) => e.toJson()).toList(),
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}

class DiscountDetail {
  final String type;
  final int ageMin;
  final int ageMax;
  final int percentage;
  final List<int> percentages;
  final int numberAdultes;
  final int numberChild;
  final String? lit;
  final int daysNumber;

  DiscountDetail({
    required this.type,
    required this.ageMin,
    required this.ageMax,
    required this.percentage,
    required this.percentages,
    required this.numberAdultes,
    required this.numberChild,
    this.lit,
    required this.daysNumber,
  });

  factory DiscountDetail.fromJson(Map<String, dynamic> json) {
    return DiscountDetail(
      type: json['type'] ?? '',
      ageMin: json['age_min'] ?? 0,
      ageMax: json['age_max'] ?? 0,
      percentage: json['percentage'] ?? 0,
      percentages: List<int>.from(json['percentages'] ?? []),
      numberAdultes: json['number_adultes'] ?? 0,
      numberChild: json['number_child'] ?? 0,
      lit: json['lit'],
      daysNumber: json['days_number'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'age_min': ageMin,
      'age_max': ageMax,
      'percentage': percentage,
      'percentages': percentages,
      'number_adultes': numberAdultes,
      'number_child': numberChild,
      'lit': lit,
      'days_number': daysNumber,
    };
  }
}
// Usage example: Parse from JSON string
// HotelDetail hotel = HotelDetail.fromJson(json.decode(jsonString)['hotels'][0]);