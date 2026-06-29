import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class AppTheme {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color drawerbg;
  final Color surface;
  final Color? shadow;
  final Color? CardBG;
  final Color text;
  final bool isDark;
  final bool isSpec;

  AppTheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.drawerbg,
    required this.surface,
    this.shadow,
    this.CardBG,
    required this.text,
    required this.isDark,
    required this.isSpec,

  });
}

class ThemeProvider with ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  final List<AppTheme> _themes = [
    // Theme 0 : Default Theme
    AppTheme(
        primary: const Color(0xFF237A5E),
        secondary: const Color(0xFFF97316),
        background: const Color(0xFFF9FAFB),
        drawerbg: const Color(0xFF1A3C29),
        surface: const Color(0xFFFFFFFF),
        shadow: const Color(0xFF000000),
        CardBG: const Color(0xFFEDFCF6),
        text: const Color(0xFF1A3C29),
        isDark: false,
        isSpec: false
    ),
    // Theme 1 : Blue Theme
    AppTheme(
      primary: const Color(0xFF2B7EA8),
      secondary: const Color(0xFF122034),
      background: const Color(0xFFF4F7FA),
      drawerbg: const Color(0xFF122034),
      surface: const Color(0xFFFFFFFF),
      text: const Color(0xFF122034),
      shadow: const Color(0xFF000000),
      CardBG: const Color(0xFFDFEFF6),
      isDark: false,
      isSpec: false
    ),
    // Theme 2: Desert
    AppTheme(
      primary: const Color(0xFFC17A3A),
      secondary: const Color(0xFFFAF6F1),
      background: const Color(0xFFFAF6F1),
      drawerbg: const Color(0xFFFAF6F1),
      surface: const Color(0xFFFFFFFF),
      shadow: const Color(0xFF000000),
      CardBG: const Color(0xFFFAF6F1),
      text: const Color(0xFF4A3B32),
      isDark: false,
      isSpec: true,

    ),
    // Theme 3: Dark
    AppTheme(
      primary: const Color(0xFF8B5CF6),
      secondary: const Color(0xFF201826),
      background: const Color(0xFF201826),
      drawerbg: const Color(0xFF201826),
      surface: const Color(0xFF2D2438),
      shadow: const Color(0xFF000000),
      CardBG: const Color(0xFF201826),
      text: const Color(0xFFFFFFFF),
      isDark: true,
      isSpec: false,

    ),

  ];

  AppTheme get currentTheme => _themes[_currentIndex];

  void switchTheme(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}