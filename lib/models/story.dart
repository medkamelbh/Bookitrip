import 'package:flutter/material.dart';
import '../utils/localized_field.dart';

class Story {
  final bool status;
  final String name;
  final String nameAr;
  final String nameEn;
  final String nameJa;
  final String nameKo;
  final String nameRu;
  final String nameZh;
  final List<String> images;
  final String id;

  Story({
    required this.status,
    required this.name,
    required this.nameAr,
    required this.nameEn,
    required this.nameJa,
    required this.nameKo,
    required this.nameRu,
    required this.nameZh,
    required this.images,
    required this.id,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      status: json['status'] ?? false,
      name: json['name'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameJa: json['name_ja'] ?? '',
      nameKo: json['name_ko'] ?? '',
      nameRu: json['name_ru'] ?? '',
      nameZh: json['name_zh'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'name': name,
      'name_ar': nameAr,
      'name_en': nameEn,
      'name_ja': nameJa,
      'name_ko': nameKo,
      'name_ru': nameRu,
      'name_zh': nameZh,
      'images': images,
      'id': id,
    };
  }

  /// Get name based on locale
  String getName(Locale locale) => localizedValue(locale, name, {
        'en': nameEn, 'ar': nameAr, 'ru': nameRu,
        'zh': nameZh, 'ko': nameKo, 'ja': nameJa,
      });

  /// Convert to the format expected by StoryViewerScreen
  Map<String, dynamic> toReelFormat() {
    return {
      'title': name,
      'preview_image': images.isNotEmpty ? images.first : '',
      'segments': images
          .map((url) => {
        'type': 'image',
        'url': url,
      })
          .toList(),
    };
  }
}