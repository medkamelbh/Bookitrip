import 'package:flutter/material.dart';
import '../utils/localized_field.dart';

class Musees {
  final String id;
  final String name;
  final String description;
  final String situation;
  final List<String> aVoir;
  final String droitsEntree;
  final String? droitsEntreeAr;
  final String? droitsEntreeRu;
  final String? droitsEntreeJa;
  final String? droitsEntreeZh;
  final String? droitsEntreeKo;
  final String? droitsEntreeEn;
  final List<String> horairesOuverture;
  final double? lat;
  final double? lng;
  final List<String> commodites;
  final List<String> images;
  final String vignette;
  final String cover;
  final String destinationId;
  final String slug;
  final String observations;

  // Champs en différentes langues
  final String nameEn;
  final String descriptionEn;
  final String situationEn;
  final List<String> aVoirEn;
  final List<String> horairesOuvertureEn;
  final String observationsEn;

  final String nameAr;
  final String descriptionAr;
  final String situationAr;
  final List<String> aVoirAr;
  final List<String> horairesOuvertureAr;
  final String observationsAr;

  final String nameRu;
  final String descriptionRu;
  final String situationRu;
  final List<String> aVoirRu;
  final List<String> horairesOuvertureRu;
  final String observationsRu;

  final String nameJa;
  final String descriptionJa;
  final String situationJa;
  final List<String> aVoirJa;
  final List<String> horairesOuvertureJa;
  final String observationsJa;

  final String nameZh;
  final String descriptionZh;
  final String situationZh;
  final List<String> aVoirZh;
  final List<String> horairesOuvertureZh;
  final String observationsZh;

  final String nameKo;
  final String descriptionKo;
  final String situationKo;
  final List<String> aVoirKo;
  final List<String> horairesOuvertureKo;
  final String observationsKo;





  // Constructor
  Musees({
    required this.id,
    required this.name,
    required this.description,
    required this.situation,
    required this.aVoir,
    required this.droitsEntree,
    required this.horairesOuverture,
    required this.lat,
    required this.lng,
    required this.commodites,
    required this.images,
    required this.vignette,
    required this.cover,
    required this.destinationId,
    required this.slug,
    required this.observations,
    required this.nameEn,
    required this.descriptionEn,
    required this.situationEn,
    required this.aVoirEn,
    required this.horairesOuvertureEn,
    required this.observationsEn,
    required this.nameAr,
    required this.descriptionAr,
    required this.situationAr,
    required this.aVoirAr,
    required this.horairesOuvertureAr,
    required this.observationsAr,
    required this.nameRu,
    required this.descriptionRu,
    required this.situationRu,
    required this.aVoirRu,
    required this.horairesOuvertureRu,
    required this.observationsRu,
    required this.nameJa,
    required this.descriptionJa,
    required this.situationJa,
    required this.aVoirJa,
    required this.horairesOuvertureJa,
    required this.observationsJa,
    required this.nameZh,
    required this.descriptionZh,
    required this.situationZh,
    required this.aVoirZh,
    required this.horairesOuvertureZh,
    required this.observationsZh,
    required this.nameKo,
    required this.descriptionKo,
    required this.situationKo,
    required this.aVoirKo,
    required this.horairesOuvertureKo,
    required this.observationsKo,
    this.droitsEntreeAr,
    this.droitsEntreeRu,
    this.droitsEntreeJa,
    this.droitsEntreeZh,
    this.droitsEntreeKo,
    this.droitsEntreeEn,

  });

  factory Musees.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    return Musees(
      id: json['id']?.toString() ?? '',
      name: json['Name']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      situation: json['Situation']?.toString() ?? '',
      aVoir: parseList(json['A_voir']),
      droitsEntree: json['Droits_d_entre']?.toString() ?? '',
      horairesOuverture: parseList(json['Horaires_d_ouverture']),
      lat: double.tryParse(json['lat']?.toString() ?? ''),
      lng: double.tryParse(json['lng']?.toString() ?? ''),
      commodites: parseList(json['Commodites']),
      images: parseList(json['images']),
      vignette: json['vignette']?.toString() ?? '',
      cover: json['cover']?.toString() ?? '',
      destinationId: json['destination_id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      observations: json['Observations']?.toString() ?? '',

      nameEn: json['Name_en']?.toString() ?? '',
      descriptionEn: json['Description_en']?.toString() ?? '',
      situationEn: json['Situation_en']?.toString() ?? '',
      aVoirEn: parseList(json['A_voir_en']),
      horairesOuvertureEn: parseList(json['Horaires_d_ouverture_en']),
      observationsEn: json['Observations_en']?.toString() ?? '',

      nameAr: json['Name_ar']?.toString() ?? '',
      descriptionAr: json['Description_ar']?.toString() ?? '',
      situationAr: json['Situation_ar']?.toString() ?? '',
      aVoirAr: parseList(json['A_voir_ar']),
      horairesOuvertureAr: parseList(json['Horaires_d_ouverture_ar']),
      observationsAr: json['Observations_ar']?.toString() ?? '',

      nameRu: json['Name_ru']?.toString() ?? '',
      descriptionRu: json['Description_ru']?.toString() ?? '',
      situationRu: json['Situation_ru']?.toString() ?? '',
      aVoirRu: parseList(json['A_voir_ru']),
      horairesOuvertureRu: parseList(json['Horaires_d_ouverture_ru']),
      observationsRu: json['Observations_ru']?.toString() ?? '',

      nameJa: json['Name_ja']?.toString() ?? '',
      descriptionJa: json['Description_ja']?.toString() ?? '',
      situationJa: json['Situation_ja']?.toString() ?? '',
      aVoirJa: parseList(json['A_voir_ja']),
      horairesOuvertureJa: parseList(json['Horaires_d_ouverture_ja']),
      observationsJa: json['Observations_ja']?.toString() ?? '',

      nameZh: json['Name_zh']?.toString() ?? '',
      descriptionZh: json['Description_zh']?.toString() ?? '',
      situationZh: json['Situation_zh']?.toString() ?? '',
      aVoirZh: parseList(json['A_voir_zh']),
      horairesOuvertureZh: parseList(json['Horaires_d_ouverture_zh']),
      observationsZh: json['Observations_zh']?.toString() ?? '',

      nameKo: json['Name_ko']?.toString() ?? '',
      descriptionKo: json['Description_ko']?.toString() ?? '',
      situationKo: json['Situation_ko']?.toString() ?? '',
      aVoirKo: parseList(json['A_voir_ko']),
      horairesOuvertureKo: parseList(json['Horaires_d_ouverture_ko']),
      observationsKo: json['Observations_ko']?.toString() ?? '',
      droitsEntreeAr: json['Droits_d_entre_ar'],
      droitsEntreeRu: json['Droits_d_entre_ru'],
      droitsEntreeJa: json['Droits_d_entre_ja'],
      droitsEntreeZh: json['Droits_d_entre_zh'],
      droitsEntreeKo: json['Droits_d_entre_ko'],
      droitsEntreeEn: json['Droits_d_entre_en'],
    );
  }

  String getName(Locale locale) => localizedValue(locale, name, {
        'en': nameEn, 'ar': nameAr, 'ru': nameRu,
        'zh': nameZh, 'ko': nameKo, 'ja': nameJa,
      });

  String getDescription(Locale locale) => localizedValue(locale, description, {
        'en': descriptionEn, 'ar': descriptionAr, 'ru': descriptionRu,
        'zh': descriptionZh, 'ko': descriptionKo, 'ja': descriptionJa,
      });

  List<String> getAVoir(Locale Locale) {
    switch (Locale.languageCode) {
      case 'en':
        return aVoirEn.isNotEmpty ? aVoirEn : aVoir;
      case 'ar':
        return aVoirAr.isNotEmpty ? aVoirAr : aVoir;
      case 'ru':
        return aVoirRu.isNotEmpty ? aVoirRu : aVoir;
      case 'ja':
        return aVoirJa.isNotEmpty ? aVoirJa : aVoir;
      case 'zh':
        return aVoirZh.isNotEmpty ? aVoirZh : aVoir;
      case 'ko':
        return aVoirKo.isNotEmpty ? aVoirKo : aVoir;
      default:
        return aVoir;
    }
  }

  String getObservations(Locale locale) => localizedValue(locale, observations, {
        'en': observationsEn, 'ar': observationsAr, 'ru': observationsRu,
        'zh': observationsZh, 'ko': observationsKo, 'ja': observationsJa,
      });

  String getSituation(Locale locale) => localizedValue(locale, situation, {
        'en': situationEn, 'ar': situationAr, 'ru': situationRu,
        'zh': situationZh, 'ko': situationKo, 'ja': situationJa,
      });

  String getEntryFee(Locale locale) => localizedValue(locale, droitsEntree, {
        'en': droitsEntreeEn, 'ar': droitsEntreeAr, 'ru': droitsEntreeRu,
        'zh': droitsEntreeZh, 'ko': droitsEntreeKo, 'ja': droitsEntreeJa,
      });
}
