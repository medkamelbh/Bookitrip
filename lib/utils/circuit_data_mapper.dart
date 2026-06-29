// /utils/voyage_data_mapper.dart

import 'package:flutter/material.dart';
import 'package:BookiTrip/models/voyage.dart';

// Helper function to convert Voyage model to circuit card data for presentation
Map<String, dynamic> voyageToCircuitCardData(Voyage voyage, Locale locale) {
  // Get the localized name
  final name = voyage.getName(locale);

  // Get duration text
  final duration = voyage.number.isNotEmpty
      ? '${voyage.number} ${_localizedDays(locale)}'
      : '3 ${_localizedDays(locale)}';

  // Extract destinations from the name (localized fallback)
  String startDest = _localizedStartDestination(locale);
  String endDest = _localizedEndDestination(name, locale);

  final subtitle = '$duration | $startDest, $endDest';

  return {
    'id': voyage.id,
    'title': name,
    'subtitle': subtitle,
    'image': voyage.images.length > 1
        ? voyage.images[1]
        : (voyage.images.isNotEmpty
              ? voyage.images[0]
              : 'assets/images/circuit1.jpg'),
  };
}

/// Returns the localized word for "days"
String _localizedDays(Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      return 'أيام';
    case 'en':
      return 'days';
    case 'ru':
      return 'дней';
    case 'zh':
      return '天';
    case 'ko':
      return '일';
    case 'ja':
      return '日';
    default:
      return 'jours';
  }
}

/// Returns localized start destination
String _localizedStartDestination(Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      return 'تونس';
    case 'en':
      return 'Tunis';
    case 'ru':
      return 'Тунис';
    case 'zh':
      return '突尼斯';
    case 'ko':
      return '튀니스';
    case 'ja':
      return 'チュニス';
    default:
      return 'Tunis';
  }
}

/// Returns localized end destination based on voyage name
String _localizedEndDestination(String name, Locale locale) {
  String endDest = '';

  final lowerName = name.toLowerCase();

  if (lowerName.contains('djerba')) {
    endDest = _localizedText('Djerba', locale);
  } else if (lowerName.contains('douz')) {
    endDest = _localizedText('Douz', locale);
  } else if (lowerName.contains('tozeur')) {
    endDest = _localizedText('Tozeur', locale);
  } else if (lowerName.contains('tabarka')) {
    endDest = _localizedText('Tabarka', locale);
  } else {
    endDest = _localizedText('Various', locale);
  }

  return endDest;
}

/// Returns a localized version of a given text
String _localizedText(String text, Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      switch (text.toLowerCase()) {
        case 'djerba':
          return 'جربة';
        case 'douz':
          return 'دوز';
        case 'tozeur':
          return 'توزر';
        case 'tabarka':
          return 'طبرقة';
        case 'various':
          return 'عدة وجهات';
      }
      break;
    case 'en':
      return text;
    case 'ru':
      switch (text.toLowerCase()) {
        case 'djerba':
          return 'Джерба';
        case 'douz':
          return 'Дуз';
        case 'tozeur':
          return 'Тозер';
        case 'tabarka':
          return 'Табарка';
        case 'various':
          return 'Разное';
      }
      break;
    case 'zh':
      switch (text.toLowerCase()) {
        case 'djerba':
          return '杰尔巴';
        case 'douz':
          return '杜兹';
        case 'tozeur':
          return '托泽尔';
        case 'tabarka':
          return '塔巴尔卡';
        case 'various':
          return '各地';
      }
      break;
    case 'ko':
      switch (text.toLowerCase()) {
        case 'djerba':
          return '제르바';
        case 'douz':
          return '두즈';
        case 'tozeur':
          return '토제르';
        case 'tabarka':
          return '타바르카';
        case 'various':
          return '여러 곳';
      }
      break;
    case 'ja':
      switch (text.toLowerCase()) {
        case 'djerba':
          return 'ジェルバ';
        case 'douz':
          return 'ドゥーズ';
        case 'tozeur':
          return 'トズール';
        case 'tabarka':
          return 'タバルカ';
        case 'various':
          return 'その他';
      }
      break;
  }

  return text;
}
