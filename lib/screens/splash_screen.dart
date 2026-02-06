import 'package:TunisiaBook/constants/theme.dart';
import 'package:TunisiaBook/providers/activity_provider.dart';
import 'package:TunisiaBook/providers/destination_provider.dart';
import 'package:TunisiaBook/providers/guestHouse_provider.dart';
import 'package:TunisiaBook/providers/hotel_provider.dart';
import 'package:TunisiaBook/providers/restaurant_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          context.go('/home');
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<DestinationProvider>(context, listen: false).fetchDestinations();

        final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
        hotelProvider.fetchAllHotels().then((_) {
          if (mounted) {
            hotelProvider.continueLoadingAllPages();
          }
        });

        final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
        restaurantProvider.fetchAllRestaurants().then((_) {
          if (mounted) {
            restaurantProvider.continueLoadingAllPages();
          }
        });

        Provider.of<GuestHouseProvider>(context, listen: false).fetchAllGuestHouses();
        Provider.of<ActivityProvider>(context, listen: false).fetchAllActivities();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Scaffold(
      backgroundColor: theme.secondary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/TunisiaBook.png',
                      fit: BoxFit.contain,
                      height: 130,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}