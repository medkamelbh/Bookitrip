import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/screens/mainScreen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;

final List<Map<String, String>> allSponsors = [
  {"name": "Ministère du Tourisme", "logo": "assets/images/logo_mintourisme1.png"},
  {"name": "Agil", "logo": "assets/images/logo_agil.png"},
  {"name": "Tunisie Telecom", "logo": "assets/images/logo_tt.png"},
  {"name": "OLEA", "logo": "assets/images/logo_olea.png"},
  {"name": "GAT Assurance", "logo": "assets/images/logo_gat.png"},
  {"name": "Tunisia Inspiring", "logo": "assets/images/logo_tunisiainspiring.png"},
];

class AnimatedSponsorCard extends StatefulWidget {
  final AppTheme theme;
  final String logoPath;
  final String name;
  final int index;

  const AnimatedSponsorCard({
    super.key,
    required this.theme,
    required this.logoPath,
    required this.name,
    required this.index,
  });

  @override
  State<AnimatedSponsorCard> createState() => _AnimatedSponsorCardState();
}

class _AnimatedSponsorCardState extends State<AnimatedSponsorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (widget.index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        },
        onTapUp: (_) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        },
        onTapCancel: () {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        },
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            final scale = 1.0 + (_hoverController.value * 0.05);
            final elevation = 5.0 + (_hoverController.value * 15.0);

            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.theme.secondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isHovered
                        ? widget.theme.primary.withValues(alpha: 0.3)
                        : widget.theme.text.withValues(alpha: 0.1),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.theme.primary.withValues(alpha: 0.1 * _hoverController.value),
                      blurRadius: elevation,
                      offset: Offset(0, elevation / 2),
                      spreadRadius: _hoverController.value * 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Center(
                          child: Image.asset(
                            widget.logoPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.theme.primary.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                        ),
                        child: Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.theme.primary == const Color(0xFF2B7EA8)
                                ? Colors.white
                                : widget.theme.text.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

class FloatingParticle extends StatefulWidget {
  final AppTheme theme;

  const FloatingParticle({super.key, required this.theme});

  @override
  State<FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _startX;
  late double _startY;
  late double _endX;
  late double _endY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 3000 + math.Random().nextInt(2000)),
      vsync: this,
    )..repeat();

    _startX = math.Random().nextDouble();
    _startY = math.Random().nextDouble();
    _endX = math.Random().nextDouble();
    _endY = math.Random().nextDouble();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final x = _startX + (_endX - _startX) * _controller.value;
        final y = _startY + (_endY - _startY) * math.sin(_controller.value * math.pi);

        return Positioned(
          left: x * MediaQuery.of(context).size.width,
          top: y * MediaQuery.of(context).size.height * 0.5,
          child: Opacity(
            opacity: 0.3,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.theme.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SponsorScreen extends StatefulWidget {
  const SponsorScreen({super.key});

  @override
  State<SponsorScreen> createState() => _SponsorScreenState();
}

class _SponsorScreenState extends State<SponsorScreen> {
  void _toggleDrawer() {
    final containerState = context.findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;
    double childAspectRatio = 0.85;

    if (screenWidth > 600) {
      crossAxisCount = 3;
      childAspectRatio = 0.9;
    }
    if (screenWidth > 900) {
      crossAxisCount = 4;
      childAspectRatio = 0.95;
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: theme.text),
          onPressed: _toggleDrawer,
        ),
        title: Text(
          'sponsors.title'.tr(),
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ...List.generate(
            30,
                (index) => FloatingParticle(theme: theme),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primary.withValues(alpha: 0.1),
                            theme.primary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.handshake_rounded,
                            size: 48,
                            color: theme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'sponsors.thanks'.tr(),
                            style: TextStyle(
                              color: theme.text,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'sponsors.support_message'.tr(),
                            style: TextStyle(
                              color: theme.text.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Grid of sponsors
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: allSponsors.length,
                    itemBuilder: (context, index) {
                      final sponsor = allSponsors[index];
                      return AnimatedSponsorCard(
                        theme: theme,
                        name: sponsor["name"]!,
                        logoPath: sponsor["logo"]!,
                        index: index,
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primary.withValues(alpha: 0.1),
                            theme.primary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            color: theme.primary,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'sponsors.become_partner'.tr(),
                            style: TextStyle(
                              color: theme.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'sponsors.contact_us'.tr(),
                            style: TextStyle(
                              color: theme.text.withValues(alpha: 0.75),                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}