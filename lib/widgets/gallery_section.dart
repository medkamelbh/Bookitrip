import 'package:TunisiaBook/widgets/gallery_images.dart';
import 'package:TunisiaBook/widgets/section_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:TunisiaBook/constants/theme.dart';

class GallerySectionWidget extends StatefulWidget {
  final AppTheme theme;
  final List<String> galleryImages;

  const GallerySectionWidget({
    super.key,
    required this.theme,
    required this.galleryImages,
  });

  @override
  State<GallerySectionWidget> createState() => _GallerySectionWidgetState();
}

class _GallerySectionWidgetState extends State<GallerySectionWidget> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late ScrollController _scrollController;
  int _currentTopImageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize scroll controller
    _scrollController = ScrollController();

    // Start fade animation cycle
    _startFadeAnimation();

    // Start auto-scroll after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startFadeAnimation() {
    _fadeController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _fadeController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _currentTopImageIndex = (_currentTopImageIndex + 1) % widget.galleryImages.length;
              });
              _startFadeAnimation();
            }
          });
        }
      });
    });
  }

  void _startAutoScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final duration = Duration(seconds: (maxScroll / 50).round());

    _scrollController.animateTo(
      maxScroll,
      duration: duration,
      curve: Curves.linear,
    ).then((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600.0;

    if (widget.galleryImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionTitleWidget(title: "details.gallery".tr(), theme: widget.theme),
        const SizedBox(height: 15),

        // Top fading image
        FadeTransition(
          opacity: _fadeController,
          child: GalleryImageWidget(
            theme: widget.theme,
            imgUrl: widget.galleryImages[_currentTopImageIndex],
            aspectRatio: 2.0,
          ),
        ),

        const SizedBox(height: 15),

        if (widget.galleryImages.length > 1)
          SizedBox(
            height: isLargeScreen ? 200 : 150,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.galleryImages.length * 100,
              itemBuilder: (context, index) {
                final imageIndex = index % widget.galleryImages.length;
                return Padding(
                  padding: EdgeInsets.only(
                    right: 15,
                    left: index == 0 ? 0 : 0,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GalleryImageWidget(
                      theme: widget.theme,
                      imgUrl: widget.galleryImages[imageIndex],
                      aspectRatio: 1.0,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}