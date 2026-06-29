import 'package:flutter/material.dart';
import '../utils/localized_field.dart';

class StateApp {
  final String id;
  final String name;
  final String description;
  final String lat;
  final String lng;
  final String slug;
  final String cover;
  final String videoId;
  final List<String> images;
  final List<String> destinationServices;
  final List<String> destinations;

  // Multilingue
  final String nameAr;
  final String descriptionAr;
  final String nameEn;
  final String descriptionEn;
  final String nameRu;
  final String descriptionRu;
  final String nameJa;
  final String descriptionJa;
  final String nameKo;
  final String descriptionKo;
  final String nameZh;
  final String descriptionZh;

  StateApp({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.slug,
    required this.cover,
    required this.videoId,
    required this.images,
    required this.destinationServices,
    required this.destinations,
    required this.nameAr,
    required this.descriptionAr,
    required this.nameEn,
    required this.descriptionEn,
    required this.nameRu,
    required this.descriptionRu,
    required this.nameJa,
    required this.descriptionJa,
    required this.nameKo,
    required this.descriptionKo,
    required this.nameZh,
    required this.descriptionZh,
  });

  factory StateApp.fromJson(Map<String, dynamic> json) {
    return StateApp(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      lat: json['lat'] ?? '',
      lng: json['lng'] ?? '',
      slug: json['slug'] ?? '',
      cover: json['cover'] ?? '',
      videoId: json['video_id'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      destinationServices: List<String>.from(json['destinationservices'] ?? []),
      destinations: List<String>.from(json['destinations'] ?? []),
      nameAr: json['name_ar'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      nameRu: json['name_ru'] ?? '',
      descriptionRu: json['description_ru'] ?? '',
      nameJa: json['name_ja'] ?? '',
      descriptionJa: json['description_ja'] ?? '',
      nameKo: json['name_ko'] ?? '',
      descriptionKo: json['description_ko'] ?? '',
      nameZh: json['name_zh'] ?? '',
      descriptionZh: json['description_zh'] ?? '',
    );
  }

  String getName(Locale locale) => localizedValue(locale, name, {
        'en': nameEn, 'ar': nameAr, 'ru': nameRu,
        'zh': nameZh, 'ko': nameKo, 'ja': nameJa,
      });

  String? getDescription(Locale locale) => localizedValueNullable(locale, description, {
        'en': descriptionEn, 'ar': descriptionAr, 'ru': descriptionRu,
        'zh': descriptionZh, 'ko': descriptionKo, 'ja': descriptionJa,
      });
}
