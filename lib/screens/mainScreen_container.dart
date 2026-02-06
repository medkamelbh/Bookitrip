import 'package:TunisiaBook/constants/theme.dart';
import 'package:TunisiaBook/providers/guestHouse_provider.dart';
import 'package:TunisiaBook/providers/hotel_provider.dart';
import 'package:TunisiaBook/providers/restaurant_provider.dart';
import 'package:TunisiaBook/widgets/language_selector.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;

class MainScreenContainer extends StatefulWidget {
  final Widget child;

  const MainScreenContainer({super.key, required this.child});

  @override
  State<MainScreenContainer> createState() => MainScreenContainerState();
}

class MainScreenContainerState extends State<MainScreenContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Dynamic responsiveness based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.75; // Drawer takes 75% of screen

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _drawerController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: drawerWidth).animate(
      CurvedAnimation(parent: _drawerController, curve: Curves.easeOutCubic),
    );
  }

  void toggleDrawer() {
    if (!mounted) return;
    if (_drawerController.isDismissed) {
      _drawerController.forward();
      setState(() => isDrawerOpen = true);
    } else {
      _drawerController.reverse();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => isDrawerOpen = false);
      });
    }
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(BuildContext context, AppTheme theme) async {
    if (isDrawerOpen) {
      toggleDrawer();
      return false;
    }

    final currentLocation = GoRouterState.of(context).matchedLocation;
    if (currentLocation != '/home') {
      context.go('/home');
      return false;
    }

    if (Platform.isAndroid || Platform.isFuchsia) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.background,
          surfaceTintColor: theme.CardBG,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('drawer.exit_title'.tr(), style: TextStyle(color: theme.text, fontWeight: FontWeight.bold)),
          content: Text('drawer.exit_message'.tr(), style: TextStyle(color: theme.text)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('common.cancel'.tr(), style: TextStyle(color: theme.primary)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: theme.primary),
              onPressed: () {
                Navigator.of(context).pop(true);
                SystemNavigator.pop();
              },
              child: Text('drawer.exit_confirm'.tr()),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final isRTL = context.locale.languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () => _onWillPop(context, theme),
      child: Scaffold(
        backgroundColor: theme.secondary,
        body: Stack(
          children: [
            // Responsive Drawer Position
            Positioned(
              top: 0,
              bottom: 0,
              left: isRTL ? null : 0,
              right: isRTL ? 0 : null,
              width: screenWidth * 0.75,
              child: CustomDrawerMenu(
                onThemeSwitch: toggleDrawer,
                toggleDrawer: toggleDrawer,
                isRTL: isRTL,
              ),
            ),

            // Main Content with Animation
            AnimatedBuilder(
              animation: _drawerController,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..translate(isRTL ? -_slideAnimation.value : _slideAnimation.value)
                    ..scale(_scaleAnimation.value),
                  alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: isDrawerOpen ? toggleDrawer : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isDrawerOpen ? 30 : 0),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: isDrawerOpen
                              ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: Offset(isRTL ? 10 : -10, 10),
                            ),
                          ]
                              : [],
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDrawerMenu extends StatelessWidget {
  final VoidCallback? onThemeSwitch;
  final VoidCallback? toggleDrawer;
  final bool isRTL;

  const CustomDrawerMenu({
    super.key,
    this.onThemeSwitch,
    this.toggleDrawer,
    this.isRTL = false,
  });

  void _navigateAndClose(BuildContext context, String routeName) {
    toggleDrawer?.call();
    Future.delayed(const Duration(milliseconds: 100), () {
      context.go(routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    final textColor = theme.isSpec ? Colors.black : Colors.white;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: theme.secondary,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isRTL ? 20 : 25,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "drawer.settings".tr(),
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 30),

              // Nav Items
              _buildNavItems(context, textColor),

              // Spacer replacement for scrollable view
              SizedBox(height: screenHeight * 0.05),

              Row(
                children: [
                  LanguageSelector(
                    showInTopMenu: false,
                    onLanguageChanged: toggleDrawer,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                "drawer.choose_theme".tr(),
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              // Theme Selector
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      themeProvider.switchTheme(index);
                      onThemeSwitch?.call();
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getThemeColor(index),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItems(BuildContext context, Color textColor) {
    return Column(
      children: [
        DrawerItem(icon: Icons.home_outlined, label: "drawer.home".tr(), color: textColor, isRTL: isRTL, onTap: () => _navigateAndClose(context, '/home')),
        DrawerItem(icon: Icons.place_outlined, label: "drawer.destinations".tr(), color: textColor, isRTL: isRTL, onTap: () => _navigateAndClose(context, '/destinations')),
        DrawerItem(
          icon: Icons.hotel,
          label: "drawer.hotels".tr(),
          color: textColor,
          isRTL: isRTL,
          onTap: () {
            Provider.of<HotelProvider>(context, listen: false).clearFilters();
            _navigateAndClose(context, '/hotels');
          },
        ),
        DrawerItem(
          icon: Icons.apartment_outlined,
          label: "drawer.guest_houses".tr(),
          color: textColor,
          isRTL: isRTL,
          onTap: () {
            Provider.of<GuestHouseProvider>(context, listen: false).clearFilters();
            _navigateAndClose(context, '/guest-houses');
          },
        ),
        DrawerItem(
          icon: Icons.restaurant_menu,
          label: "drawer.restaurants".tr(),
          color: textColor,
          isRTL: isRTL,
          onTap: () {
            Provider.of<RestaurantProvider>(context, listen: false).clearFilters();
            _navigateAndClose(context, '/restaurants');
          },
        ),
        DrawerItem(icon: Icons.local_activity_outlined, label: "drawer.activities".tr(), color: textColor, isRTL: isRTL, onTap: () => _navigateAndClose(context, '/activities')),
        DrawerItem(icon: Icons.event_available_outlined, label: "drawer.events".tr(), color: textColor, isRTL: isRTL, onTap: () => _navigateAndClose(context, '/events')),
        DrawerItem(icon: Icons.account_balance_outlined, label: "drawer.cultures".tr(), color: textColor, isRTL: isRTL, onTap: () => _navigateAndClose(context, '/cultures')),
        DrawerItem(icon: Icons.route_outlined, label: "drawer.circuits".tr(), color: textColor, isRTL: isRTL, onTap: () => _navigateAndClose(context, '/circuits')),
        //DrawerItem(icon: Icons.star_border, label: "drawer.sponsors".tr(), color: textColor, isRTL: isRTL, onTap: () => _navigateAndClose(context, '/sponsors')),
      ],
    );
  }

  Color _getThemeColor(int index) {
    switch (index) {
      case 0: return const Color(0xFFdc2626);
      case 1: return const Color(0xFF2B7EA8);
      case 2: return const Color(0xFFC17A3A);
      case 3: return const Color(0xFF8B5CF6);
      case 4: return const Color(0xFF214E34);
      default: return Colors.transparent;
    }
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isRTL;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isRTL = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell( // Added InkWell for better touch feedback
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}