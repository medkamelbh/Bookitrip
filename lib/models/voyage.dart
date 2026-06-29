import 'package:flutter/material.dart';
import '../utils/localized_field.dart';

class Voyage {
  final String id;
  final String name;
  final String name_en;
  final String name_zh;
  final String name_ko;
  final String name_ja;
  final String name_ru;
  final String name_ar;

  final String description;
  final String description_en;
  final String description_zh;
  final String description_ko;
  final String description_ja;
  final String description_ru;
  final String description_ar;

  final List<Program> programe;
  final List<Program> programe_en;
  final List<Program> programe_zh;
  final List<Program> programe_ko;
  final List<Program> programe_ja;
  final List<Program> programe_ru;
  final List<Program> programe_ar;

  final List<String> images;
  final String slug;
  final String phone;
  final String number;
  final String destinationId;

  final List<Price> price;

  final String agencyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Voyage({
    required this.id,
    required this.name,
    required this.name_en,
    required this.name_zh,
    required this.name_ko,
    required this.name_ja,
    required this.name_ru,
    required this.name_ar,
    required this.description,
    required this.description_en,
    required this.description_zh,
    required this.description_ko,
    required this.description_ja,
    required this.description_ru,
    required this.description_ar,
    required this.programe,
    required this.programe_en,
    required this.programe_zh,
    required this.programe_ko,
    required this.programe_ja,
    required this.programe_ru,
    required this.programe_ar,
    required this.images,
    required this.slug,
    required this.phone,
    required this.number,
    required this.destinationId,
    required this.price,
    required this.agencyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Voyage.fromJson(Map<String, dynamic> json) {
    List<Program> _parsePrograms(dynamic data) {
      return (data as List<dynamic>?)
          ?.map((p) => Program.fromJson(p))
          .toList() ??
          [];
    }

    List<String> _parseImages(dynamic data) {
      return (data as List<dynamic>?)?.map((i) => i.toString()).toList() ?? [];
    }

    List<Price> _parsePrices(dynamic data) {
      return (data as List<dynamic>?)?.map((p) => Price.fromJson(p)).toList() ?? [];
    }

    return Voyage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      name_en: json['name_en'] ?? '',
      name_zh: json['name_zh'] ?? '',
      name_ko: json['name_ko'] ?? '',
      name_ja: json['name_ja'] ?? '',
      name_ru: json['name_ru'] ?? '',
      name_ar: json['name_ar'] ?? '',
      description: json['description'] ?? '',
      description_en: json['description_en'] ?? '',
      description_zh: json['description_zh'] ?? '',
      description_ko: json['description_ko'] ?? '',
      description_ja: json['description_ja'] ?? '',
      description_ru: json['description_ru'] ?? '',
      description_ar: json['description_ar'] ?? '',
      programe: _parsePrograms(json['programe']),
      programe_en: _parsePrograms(json['programe_en']),
      programe_zh: _parsePrograms(json['programe_zh']),
      programe_ko: _parsePrograms(json['programe_ko']),
      programe_ja: _parsePrograms(json['programe_ja']),
      programe_ru: _parsePrograms(json['programe_ru']),
      programe_ar: _parsePrograms(json['programe_ar']),
      images: _parseImages(json['images']),
      slug: json['slug'] ?? '',
      phone: json['phone'] ?? '',
      number: json['number'] ?? '',
      destinationId: json['destination_id'] ?? '',
      price: _parsePrices(json['price']),
      agencyId: json['agency_id'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'name_en': name_en,
    'name_zh': name_zh,
    'name_ko': name_ko,
    'name_ja': name_ja,
    'name_ru': name_ru,
    'name_ar': name_ar,
    'description': description,
    'description_en': description_en,
    'description_zh': description_zh,
    'description_ko': description_ko,
    'description_ja': description_ja,
    'description_ru': description_ru,
    'description_ar': description_ar,
    'programe': programe.map((p) => p.toJson()).toList(),
    'programe_en': programe_en.map((p) => p.toJson()).toList(),
    'programe_zh': programe_zh.map((p) => p.toJson()).toList(),
    'programe_ko': programe_ko.map((p) => p.toJson()).toList(),
    'programe_ja': programe_ja.map((p) => p.toJson()).toList(),
    'programe_ru': programe_ru.map((p) => p.toJson()).toList(),
    'programe_ar': programe_ar.map((p) => p.toJson()).toList(),
    'images': images,
    'slug': slug,
    'phone': phone,
    'number': number,
    'destination_id': destinationId,
    'price': price.map((p) => p.toJson()).toList(),
    'agency_id': agencyId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
  String getName(Locale locale) => localizedValue(locale, name, {
        'en': name_en, 'ar': name_ar, 'ru': name_ru,
        'zh': name_zh, 'ko': name_ko, 'ja': name_ja,
      });

  String getDescription(Locale locale) => localizedValue(locale, description, {
        'en': description_en, 'ar': description_ar, 'ru': description_ru,
        'zh': description_zh, 'ko': description_ko, 'ja': description_ja,
      });
  String getPrograme(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return programe_ar.map((p) => p.description).join('\n');
      case 'en':
        return programe_en.map((p) => p.description).join('\n');
      case 'ru':
        return programe_ru.map((p) => p.description).join('\n');
      case 'zh':
        return programe_zh.map((p) => p.description).join('\n');
      case 'ko':
        return programe_ko.map((p) => p.description).join('\n');
      case 'ja':
        return programe_ja.map((p) => p.description).join('\n');
      default:
        return programe.map((p) => p.description).join('\n');
    }
  }
  // Inside your Voyage class in voyage.dart

  List<Program> getLocalizedProgram(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return programe_ar.isNotEmpty ? programe_ar : programe;
      case 'en':
        return programe_en.isNotEmpty ? programe_en : programe;
      case 'ru':
        return programe_ru.isNotEmpty ? programe_ru : programe;
      case 'zh':
        return programe_zh.isNotEmpty ? programe_zh : programe;
      case 'ko':
        return programe_ko.isNotEmpty ? programe_ko : programe;
      case 'ja':
        return programe_ja.isNotEmpty ? programe_ja : programe;
      default:
        return programe;
    }
  }
}

class Program {
  final String title;
  final String description;

  Program({required this.title, required this.description});

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
  };
}

class Price {
  final String dateStart;
  final String dateEnd;
  final String price;
  final String number;

  Price({
    required this.dateStart,
    required this.dateEnd,
    required this.price,
    required this.number,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      dateStart: json['date_start'] ?? '',
      dateEnd: json['date_end'] ?? '',
      price: json['price'] ?? '',
      number: json['number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'date_start': dateStart,
    'date_end': dateEnd,
    'price': price,
    'number': number,
  };
}

