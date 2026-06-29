import 'package:BookiTrip/models/activity.dart';
import 'package:BookiTrip/models/artisanat.dart';
import 'package:BookiTrip/models/availability_result.dart';
import 'package:BookiTrip/screens/availability_results_screen.dart';
import 'package:BookiTrip/screens/restaurant_availability_results_screen.dart';
import 'package:BookiTrip/models/festival.dart';
import 'package:BookiTrip/models/guestHouse.dart';
import 'package:BookiTrip/models/hotel.dart';
import 'package:BookiTrip/models/hotel_details.dart';
import 'package:BookiTrip/models/monument.dart';
import 'package:BookiTrip/models/musee.dart';
import 'package:BookiTrip/models/restaurant.dart';
import 'package:BookiTrip/models/voyage.dart';
import 'package:BookiTrip/models/event.dart';
import 'package:BookiTrip/screens/activities_screen.dart';
import 'package:BookiTrip/screens/activityDetails_screen.dart';
import 'package:BookiTrip/screens/artisanatDetails_screen.dart';
import 'package:BookiTrip/screens/artisanat_screen.dart';
import 'package:BookiTrip/screens/circuit_form_screen.dart';
import 'package:BookiTrip/screens/circuit_day_view_screen.dart';
import 'package:BookiTrip/screens/manual_destination_selection_screen.dart';
import 'package:BookiTrip/models/circuit_form_data.dart';
import 'package:BookiTrip/providers/circuit_form_provider.dart';
import 'package:BookiTrip/screens/chatbot_screen.dart';
import 'package:BookiTrip/screens/circuitDetails_screen.dart';
import 'package:BookiTrip/screens/circuits_screen.dart';
// [DISABLED] import 'package:BookiTrip/screens/cultures_screen.dart'; // Temporarily disabled — replaced by Musée
import 'package:BookiTrip/screens/destinationDetails_screen.dart';
import 'package:BookiTrip/screens/destinations_screen.dart';
import 'package:BookiTrip/screens/eventDetails_screen.dart';
import 'package:BookiTrip/screens/events_screen.dart';
import 'package:BookiTrip/screens/festivalDetails_screen.dart';
import 'package:BookiTrip/screens/festival_screen.dart';
import 'package:BookiTrip/screens/guestHouseDetails_screen.dart';
import 'package:BookiTrip/screens/guestHouse_screen.dart';
import 'package:BookiTrip/screens/home_screen.dart';
import 'package:BookiTrip/screens/hotelDetails_screen.dart';
import 'package:BookiTrip/screens/hotels_screen.dart';
import 'package:BookiTrip/screens/mainScreen_container.dart';
import 'package:BookiTrip/screens/monumentDetails_screen.dart';
import 'package:BookiTrip/screens/monument_screen.dart';
import 'package:BookiTrip/screens/museeDetails_screen.dart';
import 'package:BookiTrip/screens/musee_screen.dart';
import 'package:BookiTrip/screens/restaurantDetails_screen.dart';
import 'package:BookiTrip/screens/restaurants_screen.dart';
import 'package:BookiTrip/screens/reservation_screen.dart';
import 'package:BookiTrip/providers/reservation_provider.dart';
import 'package:BookiTrip/repositories/reservation_repository.dart';
import 'package:BookiTrip/models/availability_search_params.dart';
import 'package:provider/provider.dart';
import 'package:BookiTrip/screens/reservation_form_screen.dart';
import 'package:BookiTrip/screens/payment_webview_screen.dart';
import 'package:BookiTrip/screens/confirmation_screen.dart';
import 'package:BookiTrip/screens/sponsor_screen.dart';
import 'package:BookiTrip/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:BookiTrip/screens/auth/login_screen.dart';
import 'package:BookiTrip/screens/auth/register_screen.dart';
import 'package:BookiTrip/screens/auth/forgot_password_screen.dart';
import 'package:BookiTrip/screens/profile/profile_screen.dart';
import 'package:BookiTrip/screens/circuit_reservation_form_screen.dart';
import 'package:BookiTrip/screens/circuit_reservation_success_screen.dart';
import 'package:BookiTrip/screens/restaurant_reservation_form_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth & App Routes (all inside ShellRoute for drawer access) ──
      ShellRoute(
        builder: (context, state, child) {
          return MainScreenContainer(child: child);
        },
        routes: [
          // ── Auth screens (wrapped by shell for drawer access) ──
          /*GoRoute(
            path: '/login',
            name: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            name: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/forgot-password',
            name: 'forgotPassword',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),*/

          // Home Screen
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Destinations Screen
          GoRoute(
            path: '/destinations',
            name: 'destinations',
            builder: (context, state) => const DestinationScreen(),
          ), 

          // Hotels Screen
          GoRoute(
            path: '/hotels',
            name: 'hotels',
            builder: (context, state) => const HotelsScreen(),
          ),

          // Guest Houses Screen
          GoRoute(
            path: '/guest-houses',
            name: 'guestHouses',
            builder: (context, state) => const GuestHouseScreen(),
          ),

          // Restaurants Screen
          GoRoute(
            path: '/restaurants',
            name: 'restaurants',
            builder: (context, state) => const RestaurantScreen(),
          ),

          // Activities Screen
          GoRoute(
            path: '/activities',
            name: 'activities',
            builder: (context, state) => const ActivitiesScreen(),
          ),

          // Events Screen
          GoRoute(
            path: '/events',
            name: 'events',
            builder: (context, state) => const EventsScreen(),
          ),

          // [DISABLED] Cultures Screen — temporarily disabled, replaced by Musée (drawer.musee → /museums).
          // Kept for future reactivation if needed.
          // GoRoute(
          //   path: '/cultures',
          //   name: 'cultures',
          //   builder: (context, state) => const CulturesScreen(),
          // ),

          // Circuits Screen
          GoRoute(
            path: '/circuits',
            name: 'circuits',
            builder: (context, state) => const CircuitScreen(),
          ),

          GoRoute(
              path: '/auto-circuit',
              name: 'auto-circuit',
              builder: (context, state) => const CircuitFormScreen(mode: CircuitMode.auto)),

          GoRoute(
              path: '/manual-circuit',
              name: 'manual-circuit',
              builder: (context, state) => const CircuitFormScreen(mode: CircuitMode.manual)),

          GoRoute(
              path: '/circuit-day-view',
              name: 'circuit-day-view',
              builder: (context, state) {
                final extra = state.extra as Map;
                return CircuitDayViewScreen(
                  mode: extra['mode'] as CircuitMode,
                  circuitData: extra['circuitData'] as Map<String, dynamic>,
                  formData: extra['formData'] as CircuitFormData,
                );
              }),

          GoRoute(
              path: '/manual-destination-selection',
              name: 'manual-destination-selection',
              builder: (context, state) {
                final extra = state.extra as Map;
                return ManualDestinationSelectionScreen(
                  formData: extra['formData'] as CircuitFormData,
                );
              }),

          // Sponsors Screen
          GoRoute(
            path: '/sponsors',
            name: 'sponsors',
            builder: (context, state) => const SponsorScreen(),
          ),

          // Chatbot Screen
          GoRoute(
            path: '/chatbot',
            name: 'chatbot',
            builder: (context, state) => const ChatBotScreen(),
          ),

          // Availability Results Screen
          GoRoute(
            path: '/availability-results',
            name: 'availabilityResults',
            builder: (context, state) => const AvailabilityResultsScreen(),
          ),

          // Restaurant Availability Results Screen
          GoRoute(
            path: '/resto-availability-results',
            name: 'restoAvailabilityResults',
            builder: (context, state) => const RestaurantAvailabilityResultsScreen(),
          ),

          // Reservation Screen
          GoRoute(
            path: '/reservation',
            name: 'reservation',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              final result = extra['result'] as AvailabilityResult;
              final params = extra['params'] as AvailabilitySearchParams;
              final hotelDetails = extra['hotelDetails'] as HotelDetail?;
              
              return ChangeNotifierProvider(
                create: (context) => ReservationProvider(
                  repository: context.read<ReservationRepository>(),
                  searchParams: params,
                  hotel: result,
                  hotelDetails: hotelDetails,
                ),
                child: Builder(
                  builder: (context) {
                    final provider = context.watch<ReservationProvider>();
                    Widget currentScreen;
                    
                    if (provider.currentStep == ReservationStep.confirmation) {
                       currentScreen = const ConfirmationScreen(key: ValueKey('confirmation'));
                    } else if (provider.currentStep == ReservationStep.formFill) {
                       currentScreen = const ReservationFormScreen(key: ValueKey('formFill'));
                    } else if (provider.currentStep == ReservationStep.payment && provider.paymentUrl != null) {
                       currentScreen = PaymentWebViewScreen(key: const ValueKey('payment'), url: provider.paymentUrl!);
                    } else {
                       currentScreen = ReservationScreen(key: const ValueKey('selection'), result: result);
                    }
                    
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: currentScreen,
                    );
                  }
                ),
              );
            },
          ),

          // ==========================================
          // Detail Screens
          // ==========================================

          // Hotel Details
          GoRoute(
            path: '/hotel-details',
            name: 'hotelDetails',
            builder: (context, state) {
              final hotel = state.extra as Hotel;
              return HotelDetailsScreen(hotel: hotel);
            },
          ),

          // Restaurant Details
          GoRoute(
            path: '/restaurant-details',
            name: 'restaurantDetails',
            builder: (context, state) {
              final restaurant = state.extra as Restaurant;
              return RestaurantDetailsScreen(restaurant: restaurant);
            },
          ),

          // Guest House Details
          GoRoute(
            path: '/guest-house-details',
            name: 'guestHouseDetails',
            builder: (context, state) {
              final guestHouse = state.extra as GuestHouse;
              return GuestHouseDetailsScreen(guestHouse: guestHouse);
            },
          ),

          // Destination Details
          GoRoute(
            path: '/destination-details',
            name: 'destinationDetails',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return DestinationDetailsScreen(
                title: extra['title'] as String?,
                description: extra['description'] as String?,
                gallery: extra['gallery'] as List<String>?,
                destinationId: extra['destinationId'] as String?,
              );
            },
          ),

          // Activity Details
          GoRoute(
            path: '/activity-details',
            name: 'activityDetails',
            builder: (context, state) {
              final activity = state.extra as Activity;
              return ActivityDetailsScreen(activity: activity);
            },
          ),

          // Event Details
          GoRoute(
            path: '/event-details',
            name: 'eventDetails',
            builder: (context, state) {
              final event = state.extra as Event;
              return EventDetailsScreen(event: event);
            },
          ),

          // Circuit Details
          GoRoute(
            path: '/circuit-details',
            name: 'circuitDetails',
            builder: (context, state) {
              final circuit = state.extra as Voyage;
              return CircuitDetailsScreen(circuit: circuit);
            },
          ),

          // Monument Details
          GoRoute(
            path: '/monument-details',
            name: 'monumentDetails',
            builder: (context, state) {
              final monument = state.extra as Monument;
              return MonumentDetailsScreen(monument: monument);
            },
          ),

          // Museum Details
          GoRoute(
            path: '/musee-details',
            name: 'museeDetails',
            builder: (context, state) {
              final musee = state.extra as Musees;
              return MuseeDetailsScreen(musee: musee);
            },
          ),

          // Festival Details
          GoRoute(
            path: '/festival-details',
            name: 'festivalDetails',
            builder: (context, state) {
              final festival = state.extra as Festival;
              return FestivalDetailsScreen(festival: festival);
            },
          ),

          // Artisanat Details
          GoRoute(
            path: '/artisanat-details',
            name: 'artisanatDetails',
            builder: (context, state) {
              final artisanat = state.extra as Artisanat;
              return ArtisanatDetailsScreen(artisanat: artisanat);
            },
          ),

          // Sub-category screens (Monuments, Museums, Festivals, Artisanat)
          GoRoute(
            path: '/monuments',
            name: 'monuments',
            builder: (context, state) => const MonumentScreen(),
          ),
          GoRoute(
            path: '/museums',
            name: 'museums',
            builder: (context, state) => const MuseeScreen(),
          ),
          GoRoute(
            path: '/festivals',
            name: 'festivals',
            builder: (context, state) => const FestivalScreen(),
           ),
          GoRoute(
            path: '/artisanat',
            name: 'artisanat',
            builder: (context, state) => const ArtisanatScreen(),
          ),
        ],
      ),
      GoRoute(
        name: 'circuit-reservation',
        path: '/circuit-reservation',
        builder: (context, state) {
          final extras = state.extra as Map;
          return CircuitReservationFormScreen(
            circuitData: extras['circuitData'] as Map<String, dynamic>,
            formData: extras['formData'] as CircuitFormData,
          );
        },
      ),
      GoRoute(
        name: 'circuit-reservation-success',
        path: '/circuit-reservation-success',
        builder: (context, state) => const CircuitReservationSuccessScreen(),
      ),
      GoRoute(
        name: 'restaurant-reservation',
        path: '/restaurant-reservation',
        builder: (context, state) {
          final extras = state.extra as Map;
          return RestaurantReservationFormScreen(
            restaurant: extras['restaurant'] as Restaurant,
            initialDate: extras['initialDate'] as String?,
            initialGuests: extras['initialGuests'] as int?,
          );
        },
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
}