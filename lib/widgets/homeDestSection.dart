import 'dart:async';
import 'dart:math' as math;
import 'package:BookiTrip/models/destination.dart';
import 'package:BookiTrip/widgets/homeDestCard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NearbyDestinationSection extends StatefulWidget {
  final List<Destination> destinations;
  final VoidCallback? onMenuTap;

  const NearbyDestinationSection({
    Key? key,
    required this.destinations,
    this.onMenuTap,
  }) : super(key: key);

  @override
  State<NearbyDestinationSection> createState() =>
      _NearbyDestinationSectionState();
}

class _NearbyDestinationSectionState extends State<NearbyDestinationSection>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  int? _previousIndex;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  double _dragOffset = 0.0;
  bool _isDragging = false;

  void _animateToIndex(int newIndex) {
    setState(() {
      _previousIndex = currentIndex;
      currentIndex = newIndex;
    });
    _fadeController.forward(from: 0);
    _animationController.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.value = 1.0;
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.value = 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToDetails(BuildContext context, Destination destination) {
    context.pushNamed(
      'destinationDetails',
      extra: {
        'title': destination.getName(context.locale),
        'description': destination.getDescription(context.locale) ?? "",
        'gallery': destination.gallery,
        'destinationId': destination.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.destinations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: Listenable.merge([_animation, _fadeAnimation]),
              builder: (context, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (_previousIndex != null && _fadeAnimation.value < 1.0)
                      _buildCard(
                        context,
                        widget.destinations[_previousIndex!],
                        0,
                        false,
                        fadeOpacity: 1.0 - _fadeAnimation.value,
                      ),

                    if (widget.destinations.length > 2)
                      _buildCard(
                        context,
                        widget.destinations[(currentIndex + 2) %
                            widget.destinations.length],
                        2,
                        false,
                      ),

                    if (widget.destinations.length > 1)
                      _buildCard(
                        context,
                        widget.destinations[(currentIndex + 1) %
                            widget.destinations.length],
                        1,
                        false,
                      ),

                    _buildCard(
                      context,
                      widget.destinations[currentIndex],
                      0,
                      true,
                      fadeOpacity: _fadeAnimation.value,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        if (widget.destinations.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.destinations.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 340),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == index ? 14 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? const Color(0xFF2D3142)
                        : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard(
      BuildContext context,
      Destination destination,
      int position,
      bool isInteractive, {
        double fadeOpacity = 1.0,
      }) {
    final double dragInfluence = _isDragging ? _dragOffset / 300 : 0.0;
    final double effectivePosition = position - dragInfluence;

    final double scale = 1.0 - (effectivePosition * 0.10).clamp(0.0, 0.3);
    final double translateX = effectivePosition * 60.0;
    final double translateY = effectivePosition * 8.0;
    final double rotateY = effectivePosition * 0.20;

    final double baseOpacity = effectivePosition <= 0
        ? 1.0
        : (1.0 - (effectivePosition * 0.25)).clamp(0.3, 1.0);

    final double finalOpacity = baseOpacity * fadeOpacity;

    final double cardTranslateX = isInteractive ? _dragOffset : 0.0;
    final double cardRotateZ = isInteractive ? (_dragOffset / 1000) : 0.0;

    return Positioned(
      left: 0,
      top: translateY,
      right: null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: _isDragging && isInteractive ? 1.0 : finalOpacity,
        child: Transform.translate(
          offset: Offset(cardTranslateX, 0),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..translate(translateX, 0.0, -effectivePosition * 75)
              ..rotateY(-rotateY)
              ..rotateZ(cardRotateZ)
              ..scale(scale),
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width - 90,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 
                        (0.25 - (effectivePosition * 0.08)).clamp(0.05, 0.25)
                    ),
                    blurRadius: (20 - (effectivePosition * 5)).clamp(5, 20),
                    offset: Offset(5, 8 - (effectivePosition * 2)),
                    spreadRadius: isInteractive && _isDragging ? 2 : 0,
                  ),
                ],
              ),
              child: isInteractive
                  ? GestureDetector(
                onHorizontalDragStart: (_) {
                  setState(() {
                    _isDragging = true;
                  });
                },
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragOffset += details.delta.dx;
                    _dragOffset = _dragOffset.clamp(-400.0, 400.0);
                  });
                },
                onHorizontalDragEnd: (details) {
                  setState(() {
                    _isDragging = false;
                  });

                  const double threshold = 80;

                  if (_dragOffset < -threshold) {
                    int newIndex =
                    currentIndex < widget.destinations.length - 1
                        ? currentIndex + 1
                        : 0;
                    _animateToIndex(newIndex);
                  } else if (_dragOffset > threshold) {
                    int newIndex = currentIndex > 0
                        ? currentIndex - 1
                        : widget.destinations.length - 1;
                    _animateToIndex(newIndex);
                  }

                  setState(() {
                    _dragOffset = 0.0;
                  });
                },
                onTap: () => _navigateToDetails(context, destination),
                child: HomeDestCard(
                  destination: destination,
                ),
              )
                  : HomeDestCard(
                destination: destination,
                showText: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}