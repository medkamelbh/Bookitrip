import 'package:TunisiaBook/screens/activities_screen.dart';
import 'package:TunisiaBook/screens/chatbot_screen.dart';
import 'package:TunisiaBook/screens/circuits_screen.dart';
import 'package:TunisiaBook/screens/cultures_screen.dart';
import 'package:TunisiaBook/screens/destinations_screen.dart';
import 'package:TunisiaBook/screens/eventDetails_screen.dart';
import 'package:TunisiaBook/screens/events_screen.dart';
import 'package:TunisiaBook/screens/guestHouse_screen.dart';
import 'package:TunisiaBook/screens/home_screen.dart';
import 'package:TunisiaBook/screens/hotels_screen.dart';
import 'package:TunisiaBook/screens/mainScreen_container.dart';
import 'package:TunisiaBook/screens/restaurants_screen.dart';
import 'package:TunisiaBook/screens/sponsor_screen.dart';
import 'package:TunisiaBook/screens/splash_screen.dart';
import 'package:TunisiaBook/screens/circuitDetails_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return MainScreenContainer(child: child);
        },
        routes: [
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

          // Cultures Screen
          GoRoute(
            path: '/cultures',
            name: 'cultures',
            builder: (context, state) => const CulturesScreen(),
          ),

          // Circuits Screen
          GoRoute(
            path: '/circuits',
            name: 'circuits',
            builder: (context, state) => const CircuitScreen(),
          ),

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

          // Circuit Details Screen
          GoRoute(
            path: '/circuit-details/:id',
            name: 'circuitDetails',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return CircuitDetailsScreen(
                circuit: extra?['circuit'],
              );
            },
          ),
          // event Details Screen
          GoRoute(
            path: '/event-details/:id',
            name: 'eventDetails',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return EventDetailsScreen(
                event: extra?['event'],
              );
            },
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
}