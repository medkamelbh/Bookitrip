import 'package:flutter/material.dart';
import '../utils/localized_field.dart';

class Event {
  final String id;
  final String title;
  final String? titleEn;
  final String? titleAr;
  final String? titleRu;
  final String? titleZh;
  final String? titleKo;
  final String? titleJa;
  final String? description;
  final String? descriptionEn;
  final String? descriptionAr;
  final String? descriptionRu;
  final String? descriptionZh;
  final String? descriptionKo;
  final String? descriptionJa;
  final String? cover;
  final String? image;
  final String? categoryId;
  final String? destinationId;
  final String? price;
  final String? address;
  final String? addressEn;
  final String? addressAr;
  final String? addressZh;
  final String? addressKo;
  final String? addressRu;
  final String? addressJa;
  final String? lat;
  final String? lng;
  final bool? reservable;
  final String? slug;
  final String? startDate;
  final String? endDate;

  Event({
    required this.id,
    required this.title,
    this.titleEn,
    this.titleAr,
    this.titleRu,
    this.titleZh,
    this.titleKo,
    this.titleJa,
    this.description,
    this.descriptionEn,
    this.descriptionAr,
    this.descriptionRu,
    this.descriptionZh,
    this.descriptionKo,
    this.descriptionJa,
    this.cover,
    this.image,
    this.categoryId,
    this.destinationId,
    this.price,
    this.address,
    this.addressEn,
    this.addressAr,
    this.addressZh,
    this.addressRu,
    this.addressKo,
    this.addressJa,
    this.lat,
    this.lng,
    this.reservable,
    this.slug,
    this.startDate,
    this.endDate,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value == "1" || value.toLowerCase() == "true";
      return false;
    }

    return Event(
      id: json['id'],
      title: json['title'] ?? '',
      titleEn: json['title_en'],
      titleAr: json['title_ar'],
      titleRu: json['title_ru'],
      titleZh: json['title_zh'],
      titleKo: json['title_ko'],
      titleJa: json['title_ja'],
      description: json['description'],
      descriptionEn: json['description_en'],
      descriptionAr: json['description_ar'],
      descriptionRu: json['description_ru'],
      descriptionZh: json['description_zh'],
      descriptionKo: json['description_ko'],
      descriptionJa: json['description_ja'],
      cover: json['cover'],
      image: json['image'],
      categoryId: json['category_id'],
      destinationId: json['destination_id'],
      price: json['price'],
      address: json['address'],
      addressEn: json['address_en'],
      addressAr: json['address_ar'],
      addressZh: json['address_zh'],
      addressRu: json['address_ru'],
      addressKo: json['address_ko'],
      addressJa: json['address_ja'],
      lat: json['lat'],
      lng: json['lng'],
      reservable: parseBool(json['reservable']),
      slug: json['slug'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
  String getName(Locale locale) => localizedValue(locale, title, {
        'en': titleEn, 'ar': titleAr, 'ru': titleRu,
        'zh': titleZh, 'ko': titleKo, 'ja': titleJa,
      });

  String getDescription(Locale locale) => localizedValue(locale, description ?? '', {
        'en': descriptionEn, 'ar': descriptionAr, 'ru': descriptionRu,
        'zh': descriptionZh, 'ko': descriptionKo, 'ja': descriptionJa,
      });

  String getAddress(Locale locale) => localizedValue(locale, address ?? '', {
        'en': addressEn, 'ar': addressAr, 'ru': addressRu,
        'zh': addressZh, 'ko': addressKo, 'ja': addressJa,
      });
}
