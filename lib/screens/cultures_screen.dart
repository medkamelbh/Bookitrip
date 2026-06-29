import 'dart:async';
import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/screens/mainScreen_container.dart';
import 'package:BookiTrip/widgets/cultures/historyTimelineSection.dart';
import 'package:BookiTrip/widgets/experiences_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math' as math;

class CulturesScreen extends StatefulWidget {
  const CulturesScreen({super.key});

  @override
  State<CulturesScreen> createState() => _CulturesScreenState();
}

class _CulturesScreenState extends State<CulturesScreen> {
  void _toggleDrawer() {
    final containerState = context.findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final locale = context.locale;



    final categories = [
      {"title": 'cultures.monuments'.tr(), "key": "Monuments", "image": "assets/images/monuments.png"},
      {"title": 'cultures.museums'.tr(), "key": "Musées", "image": "assets/images/museums.png"},
      {"title": 'cultures.festival'.tr(), "key": "Festival", "image": "assets/images/festival.png"},
      {"title": 'cultures.artisanat'.tr(), "key": "Artisanat", "image": "assets/images/artisanat.png"},
    ];

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
          'cultures.title'.tr(),
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*Padding(
              padding: const EdgeInsets.all(15.0),
              child: ExperiencesReelSection(theme: theme),
            ),
*/
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'cultures.discover'.tr(),
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
              ),
            ),
            Circular3DCarousel(
              categories: categories,
              theme: theme,
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.only(top:0.0, bottom:20.0, left: 16.0,right: 16.0),
              child: TunisiaHistoryTimeline(
                theme: theme,
              ),
            ),
            SizedBox(height: 40)
          ],
        ),
      ),
    );
  }
}

class Circular3DCarousel extends StatefulWidget {
  final List<Map<String, String>> categories;
  final dynamic theme;

  const Circular3DCarousel({
    Key? key,
    required this.categories,
    required this.theme,
  }) : super(key: key);

  @override
  State<Circular3DCarousel> createState() => _Circular3DCarouselState();
}

class _Circular3DCarouselState extends State<Circular3DCarousel>
    with TickerProviderStateMixin {
  late AnimationController _snapController;
  late AnimationController _autoRotateController;

  double _currentRotation = 0.0;
  int _selectedIndex = 0;
  bool _isUserInteracting = false;
  Timer? _interactionTimer;

  final double _radius = 180.0;
  final double _itemWidth = 200.0;
  final double _itemHeight = 240.0;

  @override
  void initState() {
    super.initState();

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _autoRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
      if (!_isUserInteracting) {
        setState(() {
          // Continuous rotation
          _currentRotation -= 0.005;
          _updateSelectedIndex();
        });
      }
    });

    _startAutoRotation();
  }

  void _startAutoRotation() {
    if (!_autoRotateController.isAnimating) {
      _autoRotateController.repeat();
    }
  }

  void _stopAutoRotation() {
    _autoRotateController.stop();
  }

  @override
  void dispose() {
    _snapController.dispose();
    _autoRotateController.dispose();
    _interactionTimer?.cancel();
    super.dispose();
  }


  void _onPanStart(DragStartDetails details) {
    _stopAutoRotation();
    _interactionTimer?.cancel();
    _snapController.stop();
    setState(() {
      _isUserInteracting = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentRotation += details.delta.dx * 0.005;
      _updateSelectedIndex();
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final double itemAngle = (2 * math.pi) / widget.categories.length;

    final double estimatedEndRotation = _currentRotation + (velocity * 0.0005);


    final double rawIndex = estimatedEndRotation / itemAngle;
    final int targetIndex = rawIndex.round();
    final double targetRotation = targetIndex * itemAngle;

    final animation = Tween<double>(
      begin: _currentRotation,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutBack,
    ));

    animation.addListener(() {
      setState(() {
        _currentRotation = animation.value;
        _updateSelectedIndex();
      });
    });

    _snapController.forward(from: 0.0).then((_) {
      setState(() {
        _isUserInteracting = false;
      });
      _restartAutoRotationTimer();
    });
  }

  void _handleItemTap(int index) {
    if (_selectedIndex == index) {
      _navigateToScreen(index);
      return;
    }

    _stopAutoRotation();
    _interactionTimer?.cancel();
    setState(() {
      _isUserInteracting = true;
    });

    final itemAngle = (2 * math.pi) / widget.categories.length;

    double currentMod = _currentRotation % (2 * math.pi);
    if (currentMod < 0) currentMod += (2 * math.pi);

    double currentRawIndex = _currentRotation / itemAngle;
    int targetCycle = currentRawIndex.round();

    int diff = index - (targetCycle % widget.categories.length).abs();

    double targetRotation = -(index * itemAngle);
    while (targetRotation - _currentRotation > math.pi) targetRotation -= 2 * math.pi;
    while (targetRotation - _currentRotation < -math.pi) targetRotation += 2 * math.pi;

    final animation = Tween<double>(
      begin: _currentRotation,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutCubic,
    ));

    animation.addListener(() {
      setState(() {
        _currentRotation = animation.value;
        _updateSelectedIndex();
      });
    });

    _snapController.forward(from: 0.0).then((_) {
      setState(() {
        _isUserInteracting = false;
      });
      _restartAutoRotationTimer();
      _navigateToScreen(index);
    });
  }

  void _restartAutoRotationTimer() {
    _interactionTimer?.cancel();
    _interactionTimer = Timer(const Duration(seconds: 1), () {
      if (mounted && !_isUserInteracting) {
        _startAutoRotation();
      }
    });
  }

  void _navigateToScreen(int index) {
    final categoryKey = widget.categories[index]['key'];

    switch (categoryKey) {
      case 'Monuments':
        context.pushNamed('monuments');
        break;
      case 'Musées':
        context.pushNamed('museums');
        break;
      case 'Festival':
        context.pushNamed('festivals');
        break;
      case 'Artisanat':
        context.pushNamed('artisanat');
        break;
    }
  }

  void _updateSelectedIndex() {
    final itemAngle = (2 * math.pi) / widget.categories.length;

    double rawIndex = (-_currentRotation / itemAngle);
    int index = rawIndex.round() % widget.categories.length;
    if (index < 0) index += widget.categories.length;

    if (_selectedIndex != index) {
      _selectedIndex = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        height: 310,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ..._buildSortedChildren(),

            Positioned(
              bottom: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.categories.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _selectedIndex == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _selectedIndex == index
                          ? widget.theme.primary
                          : Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSortedChildren() {
    final itemAngle = (2 * math.pi) / widget.categories.length;

    List<_CarouselItemData> items = [];

    for (int i = 0; i < widget.categories.length; i++) {
      final angle = _currentRotation + (i * itemAngle);

      final x = math.sin(angle) * _radius;
      final z = math.cos(angle) * _radius;

      final scale = 0.5 + (0.5 * ((z + _radius) / (2 * _radius)));
      final clampedScale = scale.clamp(0.5, 1.0);
      final opacity = (z > 0.1 ? 1.0 : 0.6) * clampedScale;

      items.add(_CarouselItemData(
        index: i,
        x: x,
        z: z,
        scale: clampedScale,
        opacity: opacity,
      ));
    }

    items.sort((a, b) => a.z.compareTo(b.z));

    return items.map((item) {
      return AnimatedPositioned(
        key: ValueKey(item.index),
        duration: const Duration(milliseconds: 0),
        left: MediaQuery.of(context).size.width / 2 + item.x - (_itemWidth / 2),
        top: 120 - (item.scale * 100),
        child: Transform.scale(
          scale: item.scale,
          child: Opacity(
            opacity: item.opacity.clamp(0.0, 1.0),
            child: GestureDetector(
              onTap: () => _handleItemTap(item.index),
              child: _buildCardContent(item.index, item.opacity),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCardContent(int index, double opacity) {
    return Container(
      width: _itemWidth,
      height: _itemHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(widget.categories[index]['image']!),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5 * opacity.clamp(0.0, 1.0)),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.6),
              Colors.transparent,
            ],
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(12),
        child: Text(
          widget.categories[index]['title']!,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CarouselItemData {
  final int index;
  final double x;
  final double z;
  final double scale;
  final double opacity;

  _CarouselItemData({
    required this.index,
    required this.x,
    required this.z,
    required this.scale,
    required this.opacity,
  });
}