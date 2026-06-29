# 🌍 Translation Guide - BookiTrip App

## Overview
All static text in the app has been made multilingual. This guide shows you how to replace hardcoded French text with translation keys.

## ✅ Completed Translation Files

All 7 language files have been updated with comprehensive translations:
- ✅ `assets/translations/en-US.json` (English)
- ✅ `assets/translations/fr-FR.json` (French)
- ✅ `assets/translations/ar-TN.json` (Arabic)
- ✅ `assets/translations/ru-RU.json` (Russian)
- ✅ `assets/translations/ja-JA.json` (Japanese)
- ✅ `assets/translations/ko-KO.json` (Korean)
- ✅ `assets/translations/zh-CN.json` (Chinese)

## 📝 How to Use Translations

### Basic Usage

```dart
import 'package:easy_localization/easy_localization.dart';

// Simple text
Text('auth.email'.tr())

// Text with parameters
Text('reservation.coming_soon'.tr(namedArgs: {'type': 'hotels'}))

// Plurals (if needed)
Text('circuits.days'.plural(5))
```

## 🔄 Files That Need Updates

### 1. **Authentication Screens** (HIGH PRIORITY)

#### `lib/screens/auth/login_screen.dart`

**Replace:**
```dart
// Line 48
Text('Bon retour !', ...)
// WITH:
Text('auth.welcome_back'.tr(), ...)

// Line 54
Text('Connectez-vous à votre compte Bookitrip', ...)
// WITH:
Text('auth.login_subtitle'.tr(), ...)

// Line 73
_buildLabel('Email', theme),
// WITH:
_buildLabel('auth.email'.tr(), theme),

// Line 78
hintText: 'votre@email.com',
// WITH:
hintText: 'auth.email_placeholder'.tr(),

// Line 84
if (v == null || v.trim().isEmpty) return 'Email requis';
if (!v.contains('@')) return 'Email invalide';
// WITH:
if (v == null || v.trim().isEmpty) return 'auth.email_required'.tr();
if (!v.contains('@')) return 'auth.email_invalid'.tr();

// Line 92
_buildLabel('Mot de passe', theme),
// WITH:
_buildLabel('auth.password'.tr(), theme),

// Line 97
hintText: '••••••••',
// WITH:
hintText: 'auth.password_placeholder'.tr(),

// Line 108
if (v == null || v.isEmpty) return 'Mot de passe requis';
if (v.length < 6) return 'Au moins 6 caractères';
// WITH:
if (v == null || v.isEmpty) return 'auth.password_required'.tr();
if (v.length < 6) return 'auth.password_min_length'.tr();

// Line 117
'Mot de passe oublié ?',
// WITH:
'auth.forgot_password'.tr(),

// Line 139
'Se connecter',
// WITH:
'auth.login'.tr(),

// Line 157
'ou',
// WITH:
'auth.or'.tr(),

// Line 173
'Pas encore de compte ? ',
// WITH:
'auth.no_account'.tr(),

// Line 181
'Créer un compte',
// WITH:
'auth.create_account'.tr(),
```

#### `lib/screens/auth/register_screen.dart`

**Replace:**
```dart
// Line 71
Text('Créer un compte', ...)
// WITH:
Text('auth.register_title'.tr(), ...)

// Line 81
_field(_prenomCtrl, 'Prénom', ...)
// WITH:
_field(_prenomCtrl, 'auth.first_name'.tr(), ...)

// Line 83
_field(_nomCtrl, 'Nom', ...)
// WITH:
_field(_nomCtrl, 'auth.last_name'.tr(), ...)

// Line 88
_field(_emailCtrl, 'Email', ...)
// WITH:
_field(_emailCtrl, 'auth.email'.tr(), ...)

// Line 92
if (v == null || v.trim().isEmpty) return 'Requis';
if (!v.contains('@')) return 'Email invalide';
// WITH:
if (v == null || v.trim().isEmpty) return 'auth.field_required'.tr();
if (!v.contains('@')) return 'auth.email_invalid'.tr();

// Line 97
_field(_telCtrl, 'Téléphone', ...)
// WITH:
_field(_telCtrl, 'auth.phone'.tr(), ...)

// Line 99
_field(_villeCtrl, 'Ville', ...)
// WITH:
_field(_villeCtrl, 'auth.city'.tr(), ...)

// Line 103
_field(_passwordCtrl, 'Mot de passe', ...)
// WITH:
_field(_passwordCtrl, 'auth.password'.tr(), ...)

// Line 107
if (v == null || v.isEmpty) return 'Requis';
if (v.length < 6) return 'Au moins 6 caractères';
// WITH:
if (v == null || v.isEmpty) return 'auth.field_required'.tr();
if (v.length < 6) return 'auth.password_min_length'.tr();

// Line 112
_field(_confirmCtrl, 'Confirmer mot de passe', ...)
// WITH:
_field(_confirmCtrl, 'auth.confirm_password'.tr(), ...)

// Line 116
if (v != _passwordCtrl.text) return 'Les mots de passe ne correspondent pas';
// WITH:
if (v != _passwordCtrl.text) return 'auth.passwords_dont_match'.tr();

// Line 127
"J'accepte les conditions d'utilisation",
// WITH:
'auth.accept_terms'.tr(),

// Line 148
'Créer mon compte',
// WITH:
'auth.register'.tr(),

// Line 157
'Déjà un compte ? ',
// WITH:
'auth.already_have_account'.tr(),

// Line 163
'Se connecter',
// WITH:
'auth.sign_in'.tr(),

// Line 56
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text("Veuillez accepter les conditions d'utilisation.")),
);
// WITH:
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('auth.accept_terms_required'.tr())),
);

// Line 75
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Compte créé ! Veuillez vous connecter.'), ...),
);
// WITH:
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('auth.account_created'.tr()), ...),
);
```

#### `lib/screens/auth/forgot_password_screen.dart`

**Replace:**
```dart
// Line 68
Text('Mot de passe oublié ?', ...)
// WITH:
Text('auth.forgot_password_title'.tr(), ...)

// Line 71
Text('Entrez votre email pour recevoir un lien de réinitialisation.', ...)
// WITH:
Text('auth.forgot_password_subtitle'.tr(), ...)

// Line 79
labelText: 'Email',
// WITH:
labelText: 'auth.email'.tr(),

// Line 91
if (v == null || v.trim().isEmpty) return 'Email requis';
if (!v.contains('@')) return 'Email invalide';
// WITH:
if (v == null || v.trim().isEmpty) return 'auth.email_required'.tr();
if (!v.contains('@')) return 'auth.email_invalid'.tr();

// Line 105
'Envoyer le lien',
// WITH:
'auth.send_link'.tr(),

// Line 127
Text('Email envoyé !', ...)
// WITH:
Text('auth.email_sent'.tr(), ...)

// Line 131
Text('Un lien de réinitialisation a été envoyé à\n${_emailCtrl.text.trim()}', ...)
// WITH:
Text('${'auth.reset_link_sent'.tr()}\n${_emailCtrl.text.trim()}', ...)

// Line 140
'Retour à la connexion',
// WITH:
'auth.back_to_login'.tr(),
```

---

### 2. **Reservation Screens** (HIGH PRIORITY)

#### `lib/screens/reservation_form_screen.dart`

**Replace:**
```dart
// Line 163
'Détails de Réservation',
// WITH:
'reservation.title'.tr(),

// Line 181
_buildSectionTitle('Informations de Contact', theme),
// WITH:
_buildSectionTitle('reservation.contact_info'.tr(), theme),

// Line 186
_buildSectionTitle('Détails des Passagers', theme),
// WITH:
_buildSectionTitle('reservation.traveler_details'.tr(), theme),

// Line 207
'${provider.searchParams.totalAdults} adulte(s), ${provider.searchParams.totalChildren} enfant(s)',
// WITH:
'${provider.searchParams.totalAdults} ${'reservation.adults'.tr()}, ${provider.searchParams.totalChildren} ${'reservation.children'.tr()}',

// Line 211
'${provider.totalSelectedRooms} chambre(s) · ${provider.searchParams.nights} nuit(s)',
// WITH:
'${provider.totalSelectedRooms} ${'reservation.rooms'.tr()} · ${provider.searchParams.nights} ${'reservation.nights'.tr()}',

// Line 227
_buildTextField(_firstNameCtrl, 'Prénom', theme),
// WITH:
_buildTextField(_firstNameCtrl, 'reservation.first_name'.tr(), theme),

// Line 229
_buildTextField(_lastNameCtrl, 'Nom', theme),
// WITH:
_buildTextField(_lastNameCtrl, 'reservation.last_name'.tr(), theme),

// Line 234
_buildTextField(_emailCtrl, 'Email', theme, ...),
// WITH:
_buildTextField(_emailCtrl, 'reservation.email'.tr(), theme, ...),

// Line 237
_buildTextField(_phoneCtrl, 'Téléphone', theme, ...),
// WITH:
_buildTextField(_phoneCtrl, 'reservation.phone'.tr(), theme, ...),

// Line 241
_buildTextField(_cityCtrl, 'Ville', theme),
// WITH:
_buildTextField(_cityCtrl, 'reservation.city'.tr(), theme),

// Line 243
_buildTextField(_cinCtrl, 'CIN / Passeport', theme),
// WITH:
_buildTextField(_cinCtrl, 'reservation.cin_passport'.tr(), theme),

// Line 261
'Chambre ${i + 1} - ${rt.room.title}',
// WITH:
'${'reservation.room'.tr()} ${i + 1} - ${rt.room.title}',

// Line 267
'Adulte ${index + 1} ${rt.adults[index].isHolder ? "(Titulaire)" : ""}'
// WITH:
'${'reservation.adult'.tr()} ${index + 1} ${rt.adults[index].isHolder ? 'reservation.holder'.tr() : ""}'

// Line 274
'Enfant ${index + 1}'
// WITH:
'${'reservation.child'.tr()} ${index + 1}'

// Line 291
items: ['Mr', 'Mme', 'Mlle', 'Enfant'].map(...)
// WITH:
items: [
  'reservation.mr'.tr(),
  'reservation.mrs'.tr(),
  'reservation.miss'.tr(),
  'reservation.child'.tr()
].map(...)

// Line 310
_inputDecoration('Prénom', theme),
// WITH:
_inputDecoration('reservation.first_name'.tr(), theme),

// Line 318
_inputDecoration('Nom', theme),
// WITH:
_inputDecoration('reservation.last_name'.tr(), theme),

// Line 345
validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
// WITH:
validator: (value) => value == null || value.trim().isEmpty ? 'auth.field_required'.tr() : null,

// Line 387
'Total',
// WITH:
'reservation.total'.tr(),

// Line 421
'Payer',
// WITH:
'reservation.pay'.tr(),
```

#### `lib/screens/payment_webview_screen.dart`

**Replace:**
```dart
// Line 50
title: const Text('Annuler le paiement ?'),
content: const Text('Si vous quittez cette page, votre réservation ne sera pas confirmée.'),
// WITH:
title: Text('reservation.cancel_payment'.tr()),
content: Text('reservation.cancel_payment_message'.tr()),

// Line 54
child: const Text('Non'),
// WITH:
child: Text('reservation.no'.tr()),

// Line 58
child: const Text('Oui, annuler'),
// WITH:
child: Text('reservation.yes_cancel'.tr()),

// Line 82
'Paiement Sécurisé',
// WITH:
'reservation.payment_secure'.tr(),
```

---

### 3. **Search & Availability Widgets** (MEDIUM PRIORITY)

#### `lib/widgets/reservation_searchbar.dart` & `lib/widgets/search_reservation/reservation_search_widget.dart`

**Replace:**
```dart
// Line 71-75
static const _categories = [
  CategoryItem(label: 'Hôtels', icon: Icons.hotel),
  CategoryItem(label: 'Restaurants', icon: Icons.restaurant),
  CategoryItem(label: 'Transports', icon: Icons.directions_bus),
];
// WITH:
final _categories = [
  CategoryItem(label: 'search.hotels'.tr(), icon: Icons.hotel),
  CategoryItem(label: 'search.restaurants'.tr(), icon: Icons.restaurant),
  CategoryItem(label: 'search.transports'.tr(), icon: Icons.directions_bus),
];

// Line 108
content: Text('Veuillez sélectionner une destination et une date'),
// WITH:
content: Text('reservation.select_destination'.tr()),

// Line 141
content: Text('Lien pour ${type.name} bientôt disponible'),
// WITH:
content: Text('reservation.coming_soon'.tr(namedArgs: {'type': type.name})),
```

#### `lib/widgets/search_reservation/forms/transports_form.dart`

**Replace:**
```dart
// Lines 35-50
_TransportItem(type: TransportType.bateaux, label: 'Bateaux', ...),
_TransportItem(type: TransportType.train, label: 'Train', ...),
_TransportItem(type: TransportType.bus, label: 'Bus', ...),
_TransportItem(type: TransportType.taxi, label: 'Taxi', ...),
// WITH:
_TransportItem(type: TransportType.bateaux, label: 'search.boats'.tr(), ...),
_TransportItem(type: TransportType.train, label: 'search.train'.tr(), ...),
_TransportItem(type: TransportType.bus, label: 'search.bus'.tr(), ...),
_TransportItem(type: TransportType.taxi, label: 'search.taxi'.tr(), ...),
```

#### `lib/widgets/search_reservation/forms/restos_form.dart`

**Replace:**
```dart
// Line 120
label: 'Nombre de personnes',
// WITH:
label: 'search.persons'.tr(),
```

#### `lib/widgets/search_reservation/forms/vols_form.dart`

**Replace:**
```dart
// Line 148
label: 'Passagers',
// WITH:
label: 'search.passengers'.tr(),
```

#### `lib/widgets/search_reservation/circuit_body.dart`

**Replace:**
```dart
// Line 38
label: 'Circuit\nManuel',
// WITH:
label: 'search.manual_circuit'.tr(),

// Line 47
label: 'Circuit\nAutomatique',
// WITH:
label: 'search.auto_circuit'.tr(),
```

#### `lib/widgets/availability/availability_status_widget.dart`

**Replace:**
```dart
// Line 62
Text('Recherche en cours...', ...)
// WITH:
Text('availability.searching'.tr(), ...)

// Line 87
label: const Text('Réessayer', ...),
// WITH:
label: Text('availability.retry'.tr(), ...),

// Line 110
Text('Aucune disponibilité', ...)
// WITH:
Text('availability.no_availability'.tr(), ...)

// Line 112
Text('Essayez de modifier vos dates ou votre destination.', ...)
// WITH:
Text('availability.try_modify'.tr(), ...)
```

#### `lib/widgets/availability/availability_search_modal.dart`

**Replace:**
```dart
// Line 221
label: 'Dates du séjour',
// WITH:
label: 'availability.stay_dates'.tr(),

// Line 244
label: 'Hébergements',
// WITH:
label: 'availability.accommodations'.tr(),
```

---

### 4. **Circuit & Day Section Widgets** (MEDIUM PRIORITY)

#### `lib/widgets/circuits/guest_configurator.dart`

**Replace:**
```dart
// Line 249
label: 'Adultes',
// WITH:
label: 'circuit.adults'.tr(),

// Line 260
label: 'Enfants',
// WITH:
label: 'circuit.children'.tr(),
```

#### `lib/widgets/circuits/day_section.dart`

**Replace:**
```dart
// Lines 243-270
static const hotel = DaySectionConfig(title: 'Hôtels', ...);
static const restaurant = DaySectionConfig(title: 'Restaurants', ...);
static const activity = DaySectionConfig(title: 'Activités', ...);
static const musee = DaySectionConfig(title: 'Musées', ...);
static const monument = DaySectionConfig(title: 'Monuments', ...);
// WITH:
static DaySectionConfig hotel(BuildContext context) => DaySectionConfig(
  title: 'circuit.hotels'.tr(),
  icon: Icons.hotel_rounded,
  color: Color(0xFF5C6BC0),
);
static DaySectionConfig restaurant(BuildContext context) => DaySectionConfig(
  title: 'circuit.restaurants'.tr(),
  icon: Icons.restaurant_rounded,
  color: Color(0xFFEF6C00),
);
static DaySectionConfig activity(BuildContext context) => DaySectionConfig(
  title: 'circuit.activities'.tr(),
  icon: Icons.directions_run_rounded,
  color: Color(0xFF2E7D32),
);
static DaySectionConfig musee(BuildContext context) => DaySectionConfig(
  title: 'circuit.museums'.tr(),
  icon: Icons.museum_rounded,
  color: Color(0xFF8E24AA),
);
static DaySectionConfig monument(BuildContext context) => DaySectionConfig(
  title: 'circuit.monuments'.tr(),
  icon: Icons.account_balance_rounded,
  color: Color(0xFF00838F),
);
```

---

### 5. **Drawer Menu** (ALREADY DONE ✅)

The drawer menu in `lib/screens/mainScreen_container.dart` already uses translations correctly:
- `drawer.settings`
- `drawer.home`
- `drawer.destinations`
- etc.

---

### 6. **Common Widgets** (LOW PRIORITY)

#### `lib/widgets/dataFetch_status.dart`

**Replace:**
```dart
// Line 73
label: const Text("Réessayer"),
// WITH:
label: Text('common.retry'.tr()),
```

#### `lib/widgets/chatbot/ChatQuickSuggestion.dart`

**Replace:**
```dart
// Lines 34-55
ChatQuickChip(label: 'Hotels', ...),
ChatQuickChip(label: 'Restaurants', ...),
ChatQuickChip(label: 'Destinations', ...),
ChatQuickChip(label: 'Circuits', ...),
// WITH:
ChatQuickChip(label: 'home.categories.hotels'.tr(), ...),
ChatQuickChip(label: 'home.categories.restaurants'.tr(), ...),
ChatQuickChip(label: 'home.categories.destinations'.tr(), ...),
ChatQuickChip(label: 'home.categories.circuits'.tr(), ...),
```

---

## 🎯 Priority Order

### 🔴 **HIGH PRIORITY** (Do First)
1. ✅ Authentication screens (login, register, forgot password)
2. ✅ Reservation form screen
3. ✅ Payment webview screen

### 🟡 **MEDIUM PRIORITY** (Do Second)
4. ✅ Search widgets and forms
5. ✅ Availability widgets
6. ✅ Circuit widgets

### 🟢 **LOW PRIORITY** (Do Last)
7. ✅ Common widgets (retry buttons, etc.)
8. ✅ Chatbot quick suggestions

---

## 📋 Testing Checklist

After making changes, test each language:

```dart
// In your app, change language programmatically:
context.setLocale(Locale('fr', 'FR')); // French
context.setLocale(Locale('en', 'US')); // English
context.setLocale(Locale('ar', 'TN')); // Arabic
context.setLocale(Locale('ru', 'RU')); // Russian
context.setLocale(Locale('ja', 'JA')); // Japanese
context.setLocale(Locale('ko', 'KO')); // Korean
context.setLocale(Locale('zh', 'CN')); // Chinese
```

### Test Scenarios:
- [ ] Login screen displays correctly in all languages
- [ ] Registration form shows translated labels
- [ ] Reservation form has translated field names
- [ ] Error messages appear in correct language
- [ ] Search categories are translated
- [ ] Circuit sections show translated titles
- [ ] Arabic (RTL) displays correctly

---

## 🚀 Quick Start

1. **Start with authentication screens** - they're the most visible
2. **Use Find & Replace** in your IDE for common patterns
3. **Test after each file** to catch issues early
4. **Check Arabic (RTL)** separately as it has different layout

---

## 💡 Tips

1. **Always use `.tr()` method** from easy_localization
2. **For dynamic text with parameters**, use `namedArgs`:
   ```dart
   'reservation.coming_soon'.tr(namedArgs: {'type': 'hotels'})
   ```
3. **For plurals**, use `.plural()`:
   ```dart
   'circuits.days'.plural(numberOfDays)
   ```
4. **Remove `const` keyword** when using `.tr()`:
   ```dart
   // ❌ Wrong
   const Text('auth.email'.tr())
   
   // ✅ Correct
   Text('auth.email'.tr())
   ```

---

## 📞 Need Help?

If you encounter any issues:
1. Check the translation key exists in all 7 JSON files
2. Verify you're using `.tr()` method
3. Make sure `easy_localization` is properly initialized in `main.dart`
4. Test with `flutter run` to see real-time changes

---

**Good luck with the translations! 🌍**
