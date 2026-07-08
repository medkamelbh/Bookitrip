import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/navigation/app_router.dart';
import 'package:BookiTrip/providers/activity_provider.dart';
import 'package:BookiTrip/providers/availability_provider.dart';
import 'package:BookiTrip/providers/circuit_form_provider.dart';
import 'package:BookiTrip/providers/artisanat_provider.dart';
import 'package:BookiTrip/providers/destination_provider.dart';
import 'package:BookiTrip/providers/event_provider.dart';
import 'package:BookiTrip/providers/festival_provider.dart';
import 'package:BookiTrip/providers/guestHouse_provider.dart';
import 'package:BookiTrip/providers/hotel_provider.dart';
import 'package:BookiTrip/providers/monument_provider.dart';
import 'package:BookiTrip/providers/musee_provider.dart';
import 'package:BookiTrip/providers/restaurant_provider.dart';
import 'package:BookiTrip/providers/story_provider.dart';
import 'package:BookiTrip/providers/voyage_provider.dart';
import 'package:BookiTrip/repositories/activity_repository.dart';
import 'package:BookiTrip/repositories/availability_repository.dart';
import 'package:BookiTrip/repositories/circuit_repository.dart';
import 'package:BookiTrip/repositories/artisanat_repository.dart';
import 'package:BookiTrip/repositories/destination_repository.dart';
import 'package:BookiTrip/repositories/event_repository.dart';
import 'package:BookiTrip/repositories/festival_repository.dart';
import 'package:BookiTrip/repositories/guest_house_repository.dart';
import 'package:BookiTrip/repositories/hotel_repository.dart';
import 'package:BookiTrip/repositories/monument_repository.dart';
import 'package:BookiTrip/repositories/musee_repository.dart';
import 'package:BookiTrip/repositories/restaurant_repository.dart';
import 'package:BookiTrip/repositories/story_repository.dart';
import 'package:BookiTrip/repositories/voyage_repository.dart';
import 'package:BookiTrip/repositories/reservation_repository.dart';
import 'package:BookiTrip/repositories/auth_repository.dart';
import 'package:BookiTrip/repositories/vehicle_repository.dart';
import 'package:BookiTrip/providers/auth_provider.dart';
import 'package:BookiTrip/providers/user_provider.dart';
import 'package:BookiTrip/providers/reservation_history_provider.dart';
import 'package:BookiTrip/providers/vehicle_provider.dart';
import 'package:BookiTrip/providers/transfer_provider.dart';
import 'package:BookiTrip/repositories/transfer_repository.dart';
import 'package:BookiTrip/services/api_client.dart';
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

  final apiClient = ApiClient();
  final authRepository = AuthRepository();

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
        Provider<ReservationRepository>(create: (_) => ReservationRepository(apiClient)),
          Provider<AuthRepository>(create: (_) => authRepository),
          ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider(authRepository)..checkSession()),
          ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
            create: (ctx) => UserProvider(authRepository, ctx.read<AuthProvider>()),
            update: (ctx, auth, prev) => prev ?? UserProvider(authRepository, auth),
          ),
          ChangeNotifierProvider<ReservationHistoryProvider>(
            create: (_) => ReservationHistoryProvider(authRepository),
          ),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AvailabilityProvider(AvailabilityRepository(HotelRepository(apiClient)))),
          ChangeNotifierProvider(create: (_) => DestinationProvider(DestinationRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => HotelProvider(HotelRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => GuestHouseProvider(GuestHouseRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => RestaurantProvider(RestaurantRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => ActivityProvider(ActivityRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => EventProvider(EventRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => VoyageProvider(VoyageRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => MuseeProvider(MuseeRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => MonumentProvider(MonumentRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => FestivalProvider(FestivalRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => ArtisanatProvider(ArtisanatRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => StoryProvider(StoryRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => CircuitFormProvider(CircuitRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => VehicleProvider(VehicleRepository(apiClient))),
          ChangeNotifierProvider(create: (_) => TransferProvider(TransferRepository(apiClient))),
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
        title: 'Bookitrip',
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
