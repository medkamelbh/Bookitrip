import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/artisanat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArtisanatDetailsScreen extends StatefulWidget {
  final Artisanat artisanat;

  const ArtisanatDetailsScreen({
    super.key,
    required this.artisanat,
  });

  @override
  State<ArtisanatDetailsScreen> createState() => _ArtisanatDetailsScreenState();
}

class _ArtisanatDetailsScreenState extends State<ArtisanatDetailsScreen> {
  late VideoPlayerController _videoController;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.artisanat.videoLink.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.artisanat.videoLink))
        ..initialize().then((_) {
          setState(() {});
          _videoController.play();
          _videoController.setLooping(true);
          _videoController.setVolume(0.0);
        }).catchError((e) {
          debugPrint("Error initializing network video: $e");
        });
    }
  }

  @override
  void dispose() {
    if (widget.artisanat.videoLink.isNotEmpty) {
      _videoController.dispose();
    }
    super.dispose();
  }

  String _stripHtmlTags(String htmlText) {
    if (htmlText.isEmpty) return '';
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true);
    String plainText = htmlText.replaceAll(exp, '');
    plainText = plainText
        .replaceAll(RegExp(r'&[a-z]+;'), ' ')
        .replaceAll('\r\n', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('\t', ' ')
        .replaceAll('Â ', ' ')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
    return plainText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final size = MediaQuery.of(context).size;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          // Hero section with video or image
          Container(
            height: size.height * 0.45,
            color: Colors.black,
            child: (widget.artisanat.videoLink.isNotEmpty)
                ? (_videoController.value.isInitialized
                ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
                : const Center(child: CircularProgressIndicator(color: Colors.white)))
                : (widget.artisanat.cover.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: CachedNetworkImage(
                imageUrl: widget.artisanat.cover,
                width: double.infinity,
                height: size.height * 0.45,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.broken_image, size: 40)),
                placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            )
                : const SizedBox.shrink()),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DetailActionButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),

          // Details card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.60,
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Artisanat Name
                    Text(
                      widget.artisanat.getName(locale),
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Gallery Section
                    if (widget.artisanat.images.isNotEmpty)
                      _GallerySection(theme: theme, galleryImages: widget.artisanat.images),

                    const SizedBox(height: 30),

                    // Description
                    Text(
                      'details.description'.tr(),
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Builder(
                      builder: (context) {
                        final fullText = _stripHtmlTags(widget.artisanat.getDescription(locale));
                        final truncatedText = fullText.length > 220
                            ? fullText.substring(0, 220) + "..."
                            : fullText;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isDescriptionExpanded ? fullText : truncatedText,
                              style: TextStyle(
                                color: theme.text,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            if (fullText.length > 220)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isDescriptionExpanded = !_isDescriptionExpanded;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    _isDescriptionExpanded ? 'details.show_less'.tr() : 'details.show_more'.tr(),
                                    style: TextStyle(
                                      color: theme.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DetailActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  final AppTheme theme;
  final List<String> galleryImages;

  const _GallerySection({required this.theme, required this.galleryImages});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.gallery'.tr(),
          style: TextStyle(
            color: theme.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: galleryImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(right: index < galleryImages.length - 1 ? 15 : 0),
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: galleryImages[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 40),
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