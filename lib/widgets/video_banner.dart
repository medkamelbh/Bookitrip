import 'package:TunisiaBook/constants/theme.dart';
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

class _VideoBannerState extends State<VideoBanner> {
  late VideoPlayerController _controller;

  static const double _videoAspectRatio = 1920 / 600; // 3.2

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        "https://cdn.tunisiabook.com/videos/home/tunisiabook_web.mp4",
      ),
    )
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
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
    final theme = widget.theme;

    final bool isRTL = context.locale.languageCode == 'ar';

    final double screenWidth = MediaQuery.of(context).size.width;
    final double bannerHeight =
    (screenWidth / _videoAspectRatio).clamp(150, 200);

    return Stack(
      children: [
        // ================= VIDEO =================
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: bannerHeight,
            width: double.infinity,
            color: Colors.black,
            child: _controller.value.isInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
                : Container(
              color: Colors.black12,
            ),
          ),
        ),

        // ================= GRADIENT =================
        Container(
          height: bannerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.65),
                Colors.transparent,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),

        // ================= TEXT CONTENT =================
        Positioned(
          bottom: 20,
          left: isRTL ? null : 20,
          right: isRTL ? 20 : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FEATURED BADGE
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

              // TITLE
              Text(
                "video.discover_tunisia".tr(),
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
