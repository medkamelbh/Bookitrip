import 'package:TunisiaBook/constants/theme.dart';
import 'package:TunisiaBook/navigation/app_router.dart';
import 'package:TunisiaBook/providers/activity_provider.dart';
import 'package:TunisiaBook/providers/artisanat_provider.dart';
import 'package:TunisiaBook/providers/destination_provider.dart';
import 'package:TunisiaBook/providers/event_provider.dart';
import 'package:TunisiaBook/providers/festival_provider.dart';
import 'package:TunisiaBook/providers/guestHouse_provider.dart';
import 'package:TunisiaBook/providers/hotel_provider.dart';
import 'package:TunisiaBook/providers/monument_provider.dart';
import 'package:TunisiaBook/providers/musee_provider.dart';
import 'package:TunisiaBook/providers/restaurant_provider.dart';
import 'package:TunisiaBook/providers/story_provider.dart';
import 'package:TunisiaBook/providers/voyage_provider.dart';
import 'package:TunisiaBook/screens/splash_screen.dart';
import 'package:TunisiaBook/services/api_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
        Locale('ar', 'TN'),
        Locale('ru', 'RU'),
        Locale('ja', 'JA'),
        Locale('ko', 'KO'),
        Locale('zh', 'CN'),
      ],
      path: 'assets/translations',
      startLocale: null,

      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => DestinationProvider()),
          ChangeNotifierProvider(create: (_) => HotelProvider()),
          ChangeNotifierProvider(create: (_) => GuestHouseProvider()),
          ChangeNotifierProvider(create: (_) => RestaurantProvider()),
          ChangeNotifierProvider(create: (_) => ActivityProvider()),
          ChangeNotifierProvider(create: (_) => EventProvider()),
          ChangeNotifierProvider(create: (_) => VoyageProvider()),
          ChangeNotifierProvider(create: (_) => MuseeProvider()),
          ChangeNotifierProvider(create: (_) => MonumentProvider()),
          ChangeNotifierProvider(create: (_) => FestivalProvider()),
          ChangeNotifierProvider(create: (_) => ArtisanatProvider()),
          ChangeNotifierProvider(create: (_) => StoryProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        locale: context.locale,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        title: 'Tunisia Book',
        theme: ThemeData(
          primaryColor: theme.primary,
          scaffoldBackgroundColor: theme.background,
          textTheme: GoogleFonts.poppinsTextTheme().apply(
            bodyColor: theme.text,
            displayColor: theme.text,
          ),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      );
  }
}

