import 'dart:ui';
import '../utils/localized_field.dart';

class Hotel {
  final String id;
  final String id_hotel_bbx;
  final String email;
  final String phone;


  final String name;
  final String name_en;
  final String name_ar;
  final String name_ru;
  final String name_ja;
  final String name_ko;
  final String name_zh;

  final String address;
  final String? address_en;
  final String? address_ar;
  final String? address_ru;
  final String? address_ja;
  final String? address_ko;
  final String? address_zh;

  final String cover;
  final String vignette;
  final List<String>? images;
  final String video_link;
  final bool reservable;
  final String slug;
  final String lat;
  final String lng;
  final String destinationId;
  final int? categoryCode;
  final String? destinationName;
  final String? destinationNameEn;
  final String? destinationNameAR;
  final String? destinationNameJA;
  final String? destinationNameRU;
  final String? destinationNameKO;
  final String? destinationNameZH;
  final String? description;
  final String? description_en;
  final String? description_ar;
  final String? description_ja;
  final String? description_ru;
  final String? description_ko;
  final String? description_zh;

  final String? idCityMouradi;
  final String? idHotelMouradi;
  final String? idHotelBhr;


  Hotel({
    required this.id,
    required this.id_hotel_bbx,
    required this.email,
    required this.phone,
    required this.name,
    required this.name_en,
    required this.name_ar,
    required this.name_ru,
    required this.name_ja,
    required this.name_ko,
    required this.name_zh,
    required this.address,
    required this.cover,
    required this.vignette,
    required this.images,
    required this.video_link,
    required this.lat,
    required this.lng,
    required this.reservable,
    required this.slug,
    required this.destinationId,
    this.categoryCode,
    this.destinationName,
    this.destinationNameEn,
    this.destinationNameAR,
    this.destinationNameJA,
    this.destinationNameRU,
    this.destinationNameKO,
    this.destinationNameZH,
    this.description,
    this.description_ar,
    this.description_en,
    this.description_ja,
    this.description_ru,
    this.description_ko,
    this.description_zh,
    this.address_en,
    this.address_ar,
    this.address_ru,
    this.address_ja,
    this.address_ko,
    this.address_zh,


    this.idCityMouradi,
    this.idHotelMouradi,
    this.idHotelBhr
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    final dest = json['destination'] as Map<String, dynamic>?;

    return Hotel(
      id: json['id'] ?? '',
      id_hotel_bbx: json['id_hotel_bbx'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      name_en: json['name_en'] ?? '',
      name_ar: json['name_ar'] ?? '',
      name_ru: json['name_ru'] ?? '',
      name_ko: json['name_ko'] ?? '',
      name_ja: json['name_ja'] ?? '',
      name_zh: json['name_zh'] ?? '',
      address: json['address'] ?? '',
      address_en: json['address_en'] ?? '',
      address_ar: json['address_ar'] ?? '',
      address_ru: json['address_ru'] ?? '',
      address_ko: json['address_ko'] ?? '',
      address_ja: json['address_ja'] ?? '',
      address_zh: json['address_zh'] ?? '',
      cover: json['cover'] ?? '',
      vignette: json['vignette'] ?? '',
      images: json['gallery'] != null
          ? List<String>.from(json['gallery'])
          : [],

      video_link: json['video_link']??'',

      lat: dest != null ? dest['lat'].toString() : '',
      lng: dest != null ? dest['lng'].toString() : '',

      reservable: json['reservable'] ?? false,
      slug: json['slug'] ?? '',
      destinationId: json['destination_id'] ?? '',

      categoryCode: json['category_code'] != null
          ? int.tryParse(json['category_code'].toString())
          : null,

      destinationName: dest?['name'] ?? '',
      destinationNameEn: dest?['name_en'] ?? '',
      destinationNameAR: dest?['name_ar'] ?? '',
      destinationNameJA: dest?['name_ja'] ?? '',
      destinationNameRU: dest?['name_ru'] ?? '',
      destinationNameKO: dest?['name_ko'] ?? '',
      destinationNameZH: dest?['name_zh'] ?? '',

      description: json['description'] ?? '',
      description_en: json['description_en'] ?? '',
      description_ar: json['description_ar'] ?? '',
      description_ja: json['description_ja'] ?? '',
      description_ru: json['description_ru'] ?? '',
      description_ko: json['description_ko'] ?? '',
      description_zh: json['description_zh'] ?? '',

      idCityMouradi: json['id_city_mouradi'] ?? '',
      idHotelMouradi: json['id_hotel_mouradi'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_hotel_bbx': id_hotel_bbx,
      'email': email,
      'phone': phone,
      'name': name,
      'address': address,
      'cover': cover,
      'reservable': reservable,
      'slug': slug,
      'destination_id': destinationId,
      'category_code': categoryCode,
      'destination_name': destinationName,
      'short_description': description,
      'short_description_en': description_en,
      'short_description_ar': description_ar,
      'short_description_ja': description_ja,
      'short_description_ru': description_ru,
      'short_description_ko': description_ko,
      'short_description_zh': description_zh,

    };
  }
  String getName(Locale locale) => localizedValue(locale, name, {
        'en': name_en, 'ar': name_ar, 'ru': name_ru,
        'zh': name_zh, 'ko': name_ko, 'ja': name_ja,
      });

  String? getDescription(Locale locale) => localizedValueNullable(locale, description, {
        'en': description_en, 'ar': description_ar, 'ru': description_ru,
        'zh': description_zh, 'ko': description_ko, 'ja': description_ja,
      });

  String? getAddress(Locale locale) => localizedValueNullable(locale, address, {
        'en': address_en, 'ar': address_ar, 'ru': address_ru,
        'zh': address_zh, 'ko': address_ko, 'ja': address_ja,
      });

  String? getDestinationName(Locale locale) => localizedValueNullable(locale, destinationName, {
        'en': destinationNameEn, 'ar': destinationNameAR, 'ru': destinationNameRU,
        'zh': destinationNameZH, 'ko': destinationNameKO, 'ja': destinationNameJA,
      });
}
