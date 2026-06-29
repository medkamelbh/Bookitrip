import 'dart:ui';

/// Resolves a localized field value based on the current [Locale].
///
/// Given a default value and a map of language-code → translated value,
/// returns the best match for the given locale. Falls back to [defaultValue]
/// when the translation is null, empty, or the locale is not in the map.
///
/// Usage:
/// ```dart
/// String getName(Locale locale) =>
///     localizedValue(locale, name, {'en': nameEn, 'ar': nameAr, ...});
/// ```
String localizedValue(
  Locale locale,
  String defaultValue,
  Map<String, String?> translations,
) {
  final translated = translations[locale.languageCode];
  if (translated != null && translated.isNotEmpty) {
    return translated;
  }
  return defaultValue;
}

/// Same as [localizedValue], but for nullable default values.
/// Returns null only when [defaultValue] is null AND no translation exists.
String? localizedValueNullable(
  Locale locale,
  String? defaultValue,
  Map<String, String?> translations,
) {
  final translated = translations[locale.languageCode];
  if (translated != null && translated.isNotEmpty) {
    return translated;
  }
  return defaultValue;
}
