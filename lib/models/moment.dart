import 'package:flutter/material.dart';
import '../utils/localized_field.dart';

class Moment{
  final String id;
  final String name;
  final String? nameEn;
  final String? nameAr;
  final String? nameRu;
  final String? nameZh;
  final String? nameKo;
  final String? nameJa;
  final String? nameFr;
  final String vignette;
  final List<String>? images;

  Moment({
    required this.id,
    required this.name,
    required this.vignette,
    this.nameEn,
    this.nameAr,
    this.nameRu,
    this.nameZh,
    this.nameKo,
    this.nameJa,
    this.nameFr,
    this.images,
});

  factory Moment.fromJson(Map<String, dynamic> json) {
    return Moment(
      id: json['id'],
      name: json['name'],
      nameEn: json['name_en'],
      nameAr: json['name_ar'],
      nameRu: json['name_ru'],
      nameZh: json['name_zh'],
      nameKo: json['name_ko'],
      nameJa: json['name_ja'],
      nameFr: json['name'],
      vignette: json['vignette'],
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  String getName(Locale locale) => localizedValue(locale, name, {
        'en': nameEn, 'ar': nameAr, 'ru': nameRu,
        'zh': nameZh, 'ko': nameKo, 'ja': nameJa, 'fr': nameFr,
      });

}