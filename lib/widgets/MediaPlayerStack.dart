import 'package:TunisiaBook/widgets/ImageCounterBadge.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

class MediaPlayerStack extends StatelessWidget {
  final Size screenSize;
  final bool showVideo;
  final VideoPlayerController? videoController;
  final bool isVideoInitializing;
  final List<String> images;
  final PageController? imagePageController;
  final int currentImageIndex;
  final Function(int)? onPageChanged;
  final double heightRatio;
  final bool showImageIcon;

  const MediaPlayerStack({
    super.key,
    required this.screenSize,
    required this.showVideo,
    this.videoController,
    this.isVideoInitializing = false,
    required this.images,
    this.imagePageController,
    required this.currentImageIndex,
    this.onPageChanged,
    this.heightRatio = 0.45,
    this.showImageIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenSize.height * heightRatio,
      color: Colors.black,
      child: showVideo && videoController != null
          ? _buildVideoPlayer()
          : _buildImageGallery(),
    );
  }

  Widget _buildVideoPlayer() {
    if (videoController != null && videoController!.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: videoController!.value.size.width,
          height: videoController!.value.size.height,
          child: VideoPlayer(videoController!),
        ),
      );
    }
    return Center(
      child: isVideoInitializing
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(
        Icons.video_library,
        size: 60,
        color: Colors.white54,
      ),
    );
  }

  Widget _buildImageGallery() {
    if (images.isEmpty) {
      return const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 60,
          color: Colors.white54,
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: imagePageController,
          onPageChanged: onPageChanged,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 60,
            right: 20,
            child: ImageCounterBadge(
              currentIndex: currentImageIndex,
              totalImages: images.length,
              showIcon: showImageIcon,
            ),
          ),
      ],
    );
  }
}

