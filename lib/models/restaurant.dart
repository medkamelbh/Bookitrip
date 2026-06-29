import 'package:flutter/material.dart';
import '../utils/localized_field.dart';

class Restaurant {
  final String id;
  final String name;
  final String? slug;
  final String? crtDescription;
  final String? address;
  final String? destinationId;
  final String? destinationName;
  final String? destinationNameEn;
  final String? destinationNameRu;
  final String? destinationNameZh;
  final String? destinationNameKo;
  final String? destinationNameJa;
  final String? destinationNameAr;
  final String? cityId;
  final String? ville;
  final String? villeAr;
  final String? villeEn;
  final String? villeRu;
  final String? villeZh;
  final String? villeKo;
  final String? villeJa;
  final String? cover;
  final String? vignette;
  final List<String> images;
  final String lat;
  final String lng;
  final dynamic rate;
  final dynamic startingPrice;
  final Map<String, String?> openingHours;
  final Map<String, String?> openingHours_en;
  final Map<String, String?> openingHours_ar;
  final Map<String, String?> openingHours_ru;
  final Map<String, String?> openingHours_zh;
  final Map<String, String?> openingHours_ko;
  final String? phone;
  final String? email;
  final String? website;
  final String? videoLink;
  final bool isSpecial;
  final bool reservable;
  final String? status;
  final String? nameEn;
  final String? crtDescriptionEn;
  final String? addressEn;
  final String? nameAr;
  final String? crtDescriptionAr;
  final String? addressAr;
  final String? nameRu;
  final String? crtDescriptionRu;
  final String? addressRu;
  final String? nameJa;
  final String? crtDescriptionJa;
  final String? addressJa;
  final String? nameKo;
  final String? crtDescriptionKo;
  final String? addressKo;
  final String? nameZh;
  final String? crtDescriptionZh;
  final String? addressZh;


  Restaurant({
    required this.id,
    required this.name,
    this.slug,
    this.crtDescription,
    this.address,
    this.destinationId,
    this.destinationName,
    this.destinationNameAr,
    this.destinationNameEn,
    this.destinationNameRu,
    this.destinationNameZh,
    this.destinationNameKo,
    this.destinationNameJa,
    this.cityId,
    this.ville,
    this.cover,
    this.vignette,
    required this.images,
    required this.lat,
    required this.lng,
    this.rate,
    this.startingPrice,
    required this.openingHours,
    required this.openingHours_en,
    required this.openingHours_ar,
    required this.openingHours_ru,
    required this.openingHours_zh,
    required this.openingHours_ko,
    this.phone,
    this.email,
    this.website,
    this.videoLink,
    required this.isSpecial,
    required this.reservable,
    this.status,
    this.nameEn,
    this.crtDescriptionEn,
    this.addressEn,
    this.nameAr,
    this.crtDescriptionAr,
    this.addressAr,
    this.nameRu,
    this.crtDescriptionRu,
    this.addressRu,
    this.nameJa,
    this.crtDescriptionJa,
    this.addressJa,
    this.nameKo,
    this.crtDescriptionKo,
    this.addressKo,
    this.nameZh,
    this.crtDescriptionZh,
    this.addressZh,
    this.villeAr,
    this.villeEn,
    this.villeRu,
    this.villeZh,
    this.villeKo,
    this.villeJa,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    double? _parseDouble(dynamic value) {
      if (value is String) {
        return double.tryParse(value);
      } else if (value is num) {
        return value.toDouble();
      }
      return null;
    }

    Map<String, String?> _parseOpeningHours(dynamic openingHoursJson) {
      Map<String, String?> hours = {};
      if (openingHoursJson is Map) {
        openingHoursJson.forEach((key, value) {
          hours[key.toString()] = value?.toString();
        });
      }
      return hours;
    }

    // Parse all opening hours variants
    Map<String, String?> openingHours = _parseOpeningHours(json['opening_hours']);
    Map<String, String?> openingHours_en = _parseOpeningHours(json['opening_hours_en']);
    Map<String, String?> openingHours_ar = _parseOpeningHours(json['opening_hours_ar']);
    Map<String, String?> openingHours_ru = _parseOpeningHours(json['opening_hours_ru']);
    Map<String, String?> openingHours_zh = _parseOpeningHours(json['opening_hours_zh']);
    Map<String, String?> openingHours_ko = _parseOpeningHours(json['opening_hours_ko']);

    List<String> imageList = [];
    if (json['images'] is List) {
      imageList = List<String>.from(json['images'].map((img) => img.toString()));
    }

    String? destName;
    String? destNameAr;
    String? destNameEn;
    String? destNameRu;
    String? destNameJa;
    String? destNameKo;
    String? destNameZh;

    if (json['destination'] is Map) {
      destName = json['destination']['name'] as String?;
      destNameAr = json['destination']['name_ar'] as String?;
      destNameEn = json['destination']['name_en'] as String?;
      destNameRu = json['destination']['name_ru'] as String?;
      destNameJa = json['destination']['name_ja'] as String?;
      destNameKo = json['destination']['name_ko'] as String?;
      destNameZh = json['destination']['name_zh'] as String?;
    }

    return Restaurant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Restaurant',
      slug: json['slug'] as String?,
      crtDescription: json['crt_description'] as String?,
      address: json['address'] as String?,
      destinationId: json['destination_id'] as String?,
      destinationName: destName,
      destinationNameAr: destNameAr,
      destinationNameEn: destNameEn,
      destinationNameRu: destNameRu,
      destinationNameKo: destNameKo,
      destinationNameJa: destNameJa,
      destinationNameZh: destNameZh,
      cityId: json['city_id'] as String?,
      ville: json['ville'] as String?,
      villeAr: json['ville_ar'] as String?,
      villeEn: json['ville_en'] as String?,
      villeRu: json['ville_ru'] as String?,
      villeJa: json['ville_ja'] as String?,
      villeZh: json['ville_zh'] as String?,
      villeKo: json['ville_ko'] as String?,
      cover: json['cover'] as String?,
      vignette: json['vignette'] as String?,
      images: imageList,
      lat: json['lat'] ?? '',
      lng: json['lng'] ?? '',
      rate: json['rate'],
      startingPrice: json['starting_price'],
      openingHours: openingHours,
      openingHours_en: openingHours_en,
      openingHours_ar: openingHours_ar,
      openingHours_ru: openingHours_ru,
      openingHours_zh: openingHours_zh,
      openingHours_ko: openingHours_ko,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      videoLink: json['video_link'] as String?,
      isSpecial: (json['is_special'] == 'yes' || json['is_special'] == true),
      reservable: (json['reservable'] == 'yes' || json['reservable'] == true),
      status: json['status'] as String?,
      nameEn: json['name_en'] as String?,
      crtDescriptionEn: json['crt_description_en'] as String?,
      addressEn: json['address_en'] as String?,
      nameAr: json['name_ar'] as String?,
      crtDescriptionAr: json['crt_description_ar'] as String?,
      addressAr: json['address_ar'] as String?,
      nameRu: json['name_ru'] as String?,
      crtDescriptionRu: json['crt_description_ru'] as String?,
      addressRu: json['address_ru'] as String?,
      nameJa: json['name_ja'] as String?,
      crtDescriptionJa: json['crt_description_ja'] as String?,
      addressJa: json['address_ja'] as String?,
      nameKo: json['name_ko'] as String?,
      crtDescriptionKo: json['crt_description_ko'] as String?,
      addressKo: json['address_ko'] as String?,
      nameZh: json['name_zh'] as String?,
      crtDescriptionZh: json['crt_description_zh'] as String?,
      addressZh: json['address_zh'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'crt_description': crtDescription,
      'address': address,
      'destination_id': destinationId,
      'destination': {
        'name': destinationName,
        'name_ar': destinationNameAr,
        'name_en': destinationNameEn,
        'name_ru': destinationNameRu,
        'name_zh': destinationNameZh,
        'name_ko': destinationNameKo,
        'name_ja': destinationNameJa,
      },
      'city_id': cityId,
      'ville': ville,
      'ville_ar': villeAr,
      'ville_en': villeEn,
      'ville_ru': villeRu,
      'ville_zh': villeZh,
      'ville_ko': villeKo,
      'ville_ja': villeJa,
      'cover': cover,
      'vignette': vignette,
      'images': images,
      'lat': lat,
      'lng': lng,
      'rate': rate,
      'starting_price': startingPrice,
      'opening_hours': openingHours,
      'phone': phone,
      'email': email,
      'website': website,
      'video_link': videoLink,
      'is_special': isSpecial,
      'reservable': reservable,
      'status': status,
      'name_en': nameEn,
      'crt_description_en': crtDescriptionEn,
      'address_en': addressEn,
      'name_ar': nameAr,
      'crt_description_ar': crtDescriptionAr,
      'address_ar': addressAr,
      'name_ru': nameRu,
      'crt_description_ru': crtDescriptionRu,
      'address_ru': addressRu,
      'name_ja': nameJa,
      'crt_description_ja': crtDescriptionJa,
      'address_ja': addressJa,
      'name_ko': nameKo,
      'crt_description_ko': crtDescriptionKo,
      'address_ko': addressKo,
      'name_zh': nameZh,
      'crt_description_zh': crtDescriptionZh,
      'address_zh': addressZh,
    };
  }
  String getName(Locale locale) => localizedValue(locale, name, {
        'en': nameEn, 'ar': nameAr, 'ru': nameRu,
        'zh': nameZh, 'ko': nameKo, 'ja': nameJa,
      });

  String getAddress(Locale locale) => localizedValue(locale, address ?? '', {
        'en': addressEn, 'ar': addressAr, 'ru': addressRu,
        'zh': addressZh, 'ko': addressKo, 'ja': addressJa,
      });

  String getVille(Locale locale) => localizedValue(locale, ville ?? '', {
        'en': villeEn, 'ar': villeAr, 'ru': villeRu,
        'zh': villeZh, 'ko': villeKo, 'ja': villeJa,
      });

  String getDescription(Locale locale) => localizedValue(locale, crtDescription ?? '', {
        'en': crtDescriptionEn, 'ar': crtDescriptionAr, 'ru': crtDescriptionRu,
        'zh': crtDescriptionZh, 'ko': crtDescriptionKo, 'ja': crtDescriptionJa,
      });

  String getDestinationName(Locale locale) => localizedValue(locale, destinationName ?? '', {
        'en': destinationNameEn, 'ar': destinationNameAr, 'ru': destinationNameRu,
        'zh': destinationNameZh, 'ko': destinationNameKo, 'ja': destinationNameJa,
      });

  Map<String, String?> getOpeningHours(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return openingHours_ar.isNotEmpty ? openingHours_ar : openingHours;
      case 'en':
        return openingHours_en.isNotEmpty ? openingHours_en : openingHours;
      case 'ru':
        return openingHours_ru.isNotEmpty ? openingHours_ru : openingHours;
      case 'zh':
        return openingHours_zh.isNotEmpty ? openingHours_zh : openingHours;
      case 'ko':
        return openingHours_ko.isNotEmpty ? openingHours_ko : openingHours;
      default:
        return openingHours;
    }
  }


  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, destinationId: $destinationId)';
  }
}
