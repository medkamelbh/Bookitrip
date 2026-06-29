import 'package:flutter/material.dart';
import '../utils/localized_field.dart';

class Destination {
  final String id;
  final String name;
  final List<String> idCityBbx;
  final double lat;
  final double lng;
  final String country;
  final String state;
  final String status;

  final String? description;
  final String? descriptionEn;
  final String? descriptionMobile;
  final String? descriptionAr;
  final String? descriptionRu;
  final String? descriptionZh;
  final String? descriptionKo;
  final String? descriptionJa;

  final String? nameAr;
  final String? nameEn;
  final String? nameRu;
  final String? nameZh;
  final String? nameKo;
  final String? nameJa;


  final String? homeDescription;
  final String? homeDescriptionEn;
  final String? homeDescriptionAr;
  final String? homeDescriptionRu;
  final String? homeDescriptionZh;
  final String? homeDescriptionKo;
  final String? homeDescriptionJa;

  final String? shortDescription;
  final String? shortDescriptionEn;
  final String? shortDescriptionAr;
  final String? shortDescriptionRu;
  final String? shortDescriptionZh;
  final String? shortDescriptionKo;
  final String? shortDescriptionJa;

  final String? slug;
  final String? subtitle;
  final String? subtitleEn;
  final String? subtitleAr;
  final String? subtitleJa;

  final String? title;
  final String? titleEn;
  final String? titleAr;

  final String? mobileVideo;
  final String? thumbnail;

  final String? cover;
  final String? vignette;
  final List<String> gallery;

  final String? isSpecial;
  final List<String> destinationServices;

  Destination({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.nameRu,
    this.nameZh,
    this.nameKo,
    this.nameJa,
    required this.idCityBbx,
    required this.lat,
    required this.lng,
    required this.country,
    required this.state,
    required this.status,
    this.description,
    this.descriptionEn,
    this.descriptionMobile,
    this.descriptionAr,
    this.descriptionRu,
    this.descriptionZh,
    this.descriptionKo,
    this.descriptionJa,
    this.homeDescription,
    this.homeDescriptionEn,
    this.homeDescriptionAr,
    this.homeDescriptionRu,
    this.homeDescriptionZh,
    this.homeDescriptionKo,
    this.homeDescriptionJa,
    this.shortDescription,
    this.shortDescriptionEn,
    this.shortDescriptionAr,
    this.shortDescriptionRu,
    this.shortDescriptionZh,
    this.shortDescriptionKo,
    this.shortDescriptionJa,
    this.slug,
    this.subtitle,
    this.subtitleEn,
    this.subtitleAr,
    this.subtitleJa,
    this.title,
    this.titleEn,
    this.titleAr,
    this.mobileVideo,
    this.thumbnail,
    this.cover,
    required this.gallery,
    this.vignette,
    this.isSpecial,
    required this.destinationServices,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      nameAr: json["name_ar"],
      nameEn: json["name_en"],
      nameRu: json["name_ru"],
      nameZh: json["name_zh"],
      nameKo: json["name_ko"],
      nameJa: json["name_ja"],
      idCityBbx: List<String>.from(json["id_city_bbx"] ?? []),
      lat: (json["lat"] as num?)?.toDouble() ?? 0.0,
      lng: (json["lng"] as num?)?.toDouble() ?? 0.0,
      country: json["country"] ?? "",
      state: json["state"] ?? "",
      status: json["status"] ?? "",
      description: json["description"],
      descriptionEn: json["description_en"],
      descriptionMobile: json["description_mobile"],
      descriptionAr: json["description_mobile_ar"],
      descriptionRu: json["description_mobile_ru"],
      descriptionZh: json["description_mobile_zh"],
      descriptionKo: json["description_mobile_ko"],
      descriptionJa: json["description_mobile_ja"],
      homeDescription: json["home_description"],
      homeDescriptionEn: json["home_description_en"],
      homeDescriptionAr: json["home_description_ar"],
      homeDescriptionRu: json["home_description_ru"],
      homeDescriptionZh: json["home_description_zh"],
      homeDescriptionKo: json["home_description_ko"],
      homeDescriptionJa: json["home_description_ja"],
      shortDescription: json["short_description"],
      shortDescriptionEn: json["short_description_en"],
      shortDescriptionAr: json["short_description_ar"],
      shortDescriptionRu: json["short_description_ru"],
      shortDescriptionZh: json["short_description_zh"],
      shortDescriptionKo: json["short_description_ko"],
      shortDescriptionJa: json["short_description_ja"],
      slug: json["slug"],
      subtitle: json["subtitle"],
      subtitleEn: json["subtitle_en"],
      subtitleAr: json["subtitle_ar"],
      subtitleJa: json["subtitle_ja"],
      title: json["title"],
      titleEn: json["title_en"],
      titleAr: json["title_ar"],
      mobileVideo: json["mobile_video"],
      thumbnail: json["thumbnail"],
      cover: json["cover"],
      vignette: json["vignette"],
      gallery: List<String>.from(json["gallery"] ?? []),
      isSpecial: json["is_special"],
      destinationServices: List<String>.from(json["destinationservices"] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "name_ar": nameAr,
    "name_en": nameEn,
    "name_ru": nameRu,
    "name_zh": nameZh,
    "name_ko": nameKo,
    "name_ja": nameJa,
    "id_city_bbx": idCityBbx,
    "lat": lat,
    "lng": lng,
    "country": country,
    "state": state,
    "status": status,
    "description": description,
    "description_en": descriptionEn,
    "description_mobile": descriptionMobile,
    "description_mobile_ar": descriptionAr,
    "description_mobile_ru": descriptionRu,
    "description_mobile_zh": descriptionZh,
    "description_mobile_ko": descriptionKo,
    "description_mobile_ja": descriptionJa,
    "home_description": homeDescription,
    "home_description_en": homeDescriptionEn,
    "home_description_ar": homeDescriptionAr,
    "home_description_ru": homeDescriptionRu,
    "home_description_zh": homeDescriptionZh,
    "home_description_ko": homeDescriptionKo,
    "home_description_ja": homeDescriptionJa,
    "short_description": shortDescription,
    "short_description_en": shortDescriptionEn,
    "short_description_ar": shortDescriptionAr,
    "short_description_ru": shortDescriptionRu,
    "short_description_zh": shortDescriptionZh,
    "short_description_ko": shortDescriptionKo,
    "short_description_ja": shortDescriptionJa,
    "slug": slug,
    "subtitle": subtitle,
    "subtitle_en": subtitleEn,
    "subtitle_ar": subtitleAr,
    "subtitle_ja": subtitleJa,
    "title": title,
    "title_en": titleEn,
    "title_ar": titleAr,
    "mobile_video": mobileVideo,
    "thumbnail": thumbnail,
    "cover": cover,
    "vignette": vignette,
    "gallery": gallery,
    "is_special": isSpecial,
    "destinationservices": destinationServices,
  };


  String getName(Locale locale) => localizedValue(locale, name, {
        'en': nameEn, 'ar': nameAr, 'ru': nameRu,
        'zh': nameZh, 'ko': nameKo, 'ja': nameJa,
      });

  String? getDescription(Locale locale) => localizedValueNullable(locale, descriptionMobile, {
        'en': descriptionEn, 'ar': descriptionAr, 'ru': descriptionRu,
        'zh': descriptionZh, 'ko': descriptionKo, 'ja': descriptionJa,
      });

  String? getTitle(Locale locale) => localizedValueNullable(locale, title, {
        'en': titleEn, 'ar': titleAr,
      });

  String? getSubtitle(Locale locale) => localizedValueNullable(locale, subtitle, {
        'en': subtitleEn, 'ar': subtitleAr, 'ja': subtitleJa,
      });
}

class DestinationSelection {
  final String id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final String? nameRu;
  final String? nameZh;
  final String? nameKo;
  final String? nameJa;
  bool isStart;
  int days;

  DestinationSelection({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.nameRu,
    this.nameZh,
    this.nameKo,
    this.nameJa,
    this.isStart = false,
    this.days = 0,
  });

  factory DestinationSelection.fromDestination(Destination destination) {
    return DestinationSelection(
      id: destination.id,
      name: destination.name,
      nameAr: destination.nameAr,
      nameEn: destination.nameEn,
      nameRu: destination.nameRu,
      nameZh: destination.nameZh,
      nameKo: destination.nameKo,
      nameJa: destination.nameJa,
      isStart: false,
      days: 0,
    );
  }

  String getName(Locale locale) => localizedValue(locale, name, {
        'en': nameEn, 'ar': nameAr, 'ru': nameRu,
        'zh': nameZh, 'ko': nameKo, 'ja': nameJa,
      });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "nameAr": nameAr,
    "nameEn": nameEn,
    "nameRu": nameRu,
    "nameZh": nameZh,
    "nameKo": nameKo,
    "nameJa": nameJa,
    "isStart": isStart,
    "days": days,
  };


}
