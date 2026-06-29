import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:BookiTrip/constants/theme.dart';

class CategoryRowWidget extends StatefulWidget {
  final AppTheme theme;
  final VoidCallback? onDestinationsTap;
  final VoidCallback? onHotelsTap;
  final VoidCallback? onRestaurantsTap;
  final VoidCallback? onCircuitsTap;
  final VoidCallback? onChatBotTap;

  const CategoryRowWidget({
    super.key,
    required this.theme,
    this.onDestinationsTap,
    this.onHotelsTap,
    this.onRestaurantsTap,
    this.onCircuitsTap,
    this.onChatBotTap,
  });

  @override
  State<CategoryRowWidget> createState() => _CategoryRowWidgetState();
}

class _CategoryRowWidgetState extends State<CategoryRowWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _iconController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -10.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_bounceController);

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.05).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: -0.05).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_bounceController);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_pulseController);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_pulseController);

    _glowAnimation = Tween<double>(begin: 8.0, end: 16.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_glowController);

    _iconRotation = Tween<double>(begin: 0.0, end: 6.28319).animate(_iconController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.hotel, 'label': 'home.categories.hotels'.tr(), 'onTap': widget.onHotelsTap, 'isSpecial': false},
      {'icon': Icons.restaurant, 'label': 'home.categories.restaurants'.tr(), 'onTap': widget.onRestaurantsTap, 'isSpecial': false},
      {'icon': Icons.smart_toy_outlined, 'label': 'home.categories.chatbot'.tr(), 'onTap': widget.onChatBotTap, 'isSpecial': true},
      {'icon': Icons.map, 'label': 'home.categories.circuits'.tr(), 'onTap': widget.onCircuitsTap, 'isSpecial': false},
      {'icon': Icons.location_on, 'label': 'home.categories.destinations'.tr(), 'onTap': widget.onDestinationsTap, 'isSpecial': false},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate size based on available width
        // Divide width by 5 (number of items) and subtract padding
        double availableWidth = constraints.maxWidth;
        double itemWidth = availableWidth / 5;
        double iconSize = (itemWidth * 0.75).clamp(45.0, 65.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end, // Aligns labels even if AI icon bounces
          children: categories.map((cat) {
            bool isSpecial = cat['isSpecial'] as bool;

            return Expanded(
              child: GestureDetector(
                onTap: cat['onTap'] as VoidCallback?,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: iconSize + 15, // Space for the bounce animation
                      child: Center(
                        child: isSpecial
                            ? _buildSpecialIcon(iconSize, cat['icon'] as IconData)
                            : _buildStandardIcon(iconSize, cat['icon'] as IconData),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat['label'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSpecial ? widget.theme.primary : widget.theme.text.withValues(alpha: 0.7),
                        fontSize: (availableWidth * 0.028).clamp(10.0, 12.0),
                        fontWeight: isSpecial ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSpecialIcon(double size, IconData icon) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceController, _pulseController, _glowController, _iconController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.theme.primary, widget.theme.primary.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(size * 0.3),
                  boxShadow: [
                    BoxShadow(
                      color: widget.theme.primary.withValues(alpha: 0.4),
                      blurRadius: _glowAnimation.value,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Transform.rotate(
                        angle: _iconRotation.value,
                        child: Icon(icon, color: Colors.white, size: size * 0.5),
                      ),
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStandardIcon(double size, IconData icon) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: widget.theme.surface,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: widget.theme.primary, size: size * 0.45),
    );
  }
}