import 'package:flutter/material.dart';
import '../utils/localized_field.dart';

import 'destination.dart';

class Festival {
  final String id;
  final String name;
  final String nameEn;
  final String nameAr;
  final String nameRu;
  final String nameZh;
  final String nameKo;
  final String nameJa;
  final String description;
  final String descriptionEn;
  final String descriptionAr;
  final String descriptionRu;
  final String descriptionZh;
  final String descriptionKo;
  final String descriptionJa;
  final String cover;
  final String vignette;
  final List<String> images;
  final String lat;
  final String lng;
  final String destinationId;
  final String slug;
  final Destination? destination;
  final Destination? destinationAr;
  final Destination? destinationRu;
  final Destination? destinationZh;
  final Destination? destinationKo;
  final Destination? destinationJa;
  final Destination? destinationEn;



  Festival({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameAr,
    required this.nameRu,
    required this.nameZh,
    required this.nameKo,
    required this.nameJa,
    required this.description,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.descriptionRu,
    required this.descriptionZh,
    required this.descriptionKo,
    required this.descriptionJa,
    required this.cover,
    required this.vignette,
    required this.images,
    required this.lat,
    required this.lng,
    required this.destinationId,
    required this.slug,
    this.destination,
    this.destinationAr,
    this.destinationRu,
    this.destinationZh,
    this.destinationKo,
    this.destinationJa,
    this.destinationEn,
  });

  factory Festival.fromJson(Map<String, dynamic> json) {
    return Festival(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameRu: json['name_ru']?.toString() ?? '',
      nameZh: json['name_zh']?.toString() ?? '',
      nameKo: json['name_ko']?.toString() ?? '',
      nameJa: json['name_ja']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      descriptionEn: json['description_en']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString() ?? '',
      descriptionRu: json['description_ru']?.toString() ?? '',
      descriptionZh: json['description_zh']?.toString() ?? '',
      descriptionKo: json['description_ko']?.toString() ?? '',
      descriptionJa: json['description_ja']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      vignette: json['vignette']?.toString() ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      lat: json['lat'] ,
      lng: json['lng'],
      destinationId: json['destination_id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      destination: json['destination'] != null ? Destination.fromJson(json['destination']) : null,
      destinationAr: json['destination_ar'] != null ? Destination.fromJson(json['destination_ar']) : null,
      destinationRu: json['destination_ru'] != null ? Destination.fromJson(json['destination_ru']) : null,
      destinationZh: json['destination_zh'] != null ? Destination.fromJson(json['destination_zh']) : null,
      destinationKo: json['destination_ko'] != null ? Destination.fromJson(json['destination_ko']) : null,
      destinationJa: json['destination_ja'] != null ? Destination.fromJson(json['destination_ja']) : null,
      destinationEn: json['destination_en'] != null ? Destination.fromJson(json['destination_en']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'name_ar': nameAr,
      'name_ru': nameRu,
      'name_zh': nameZh,
      'name_ko': nameKo,
      'name_ja': nameJa,
      'description': description,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'description_ru': descriptionRu,
      'description_zh': descriptionZh,
      'description_ko': descriptionKo,
      'description_ja': descriptionJa,
      'cover': cover,
      'vignette': vignette,
      'images': images,
      'lat': lat,
      'lng': lng,
      'destination_id': destinationId,
      'slug': slug,
      'destination': destination,
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

  String getDestinationName(Locale locale) => localizedValue(locale, destination?.name ?? '', {
        'en': destination?.nameEn, 'ar': destination?.nameAr, 'ru': destination?.nameRu,
        'zh': destination?.nameZh, 'ko': destination?.nameKo, 'ja': destination?.nameJa,
      });
}
