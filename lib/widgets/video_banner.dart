import 'package:BookiTrip/constants/theme.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBanner extends StatefulWidget {
  final AppTheme theme;

  const VideoBanner({
    super.key,
    required this.theme,
  });

  @override
  State<VideoBanner> createState() => _VideoBannerState();
}

class _VideoBannerState extends State<VideoBanner>
    with AutomaticKeepAliveClientMixin {
  late final CachedVideoPlayerPlusController _controller;

  bool _isInitialized = false;

  static const double _videoAspectRatio = 1920 / 600;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(
          "https://cdn.bookitrip.com/videos/home/Bookitrip-Video.mp4",
        ),
        invalidateCacheIfOlderThan: const Duration(days: 7),
      );

      await _controller.initialize();

      await _controller.setLooping(true);

      await _controller.setVolume(0);

      await _controller.play();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint("Video Banner Error: $e");
    }
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = widget.theme;

    final bool isRTL = context.locale.languageCode == 'ar';

    final double screenWidth = MediaQuery.of(context).size.width;

    final double bannerHeight =
    (screenWidth / _videoAspectRatio).clamp(150.0, 200.0);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: bannerHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ================= VIDEO =================
              Container(
                color: Colors.black,
                child: _isInitialized
                    ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: CachedVideoPlayerPlus(_controller),
                  ),
                )
                    : _buildPlaceholder(),
              ),

              // ================= OVERLAY =================
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // ================= CONTENT =================
              Positioned(
                bottom: 20,
                left: isRTL ? null : 20,
                right: isRTL ? 20 : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "video.featured".tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "video.discover_tunisia".tr(),
                      textAlign:
                      isRTL ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              if (!_isInitialized)
                const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      "assets/images/video_thumbnail2.png",
      fit: BoxFit.cover,
    );
  }
}