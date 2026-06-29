import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/guestHouse.dart';
import 'package:BookiTrip/utils/open_googlemaps.dart';
import 'package:BookiTrip/widgets/contact_section.dart';
import 'package:BookiTrip/widgets/hotels/gallery_section_details.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class GuestHouseDetailsScreen extends StatefulWidget {
  final GuestHouse guestHouse;

  const GuestHouseDetailsScreen({
    super.key,
    required this.guestHouse,
  });

  @override
  State<GuestHouseDetailsScreen> createState() => _GuestHouseDetailsScreenState();
}

class _GuestHouseDetailsScreenState extends State<GuestHouseDetailsScreen> {
  int _selectedImageIndex = 0;
  bool _showVideo = true;
  PageController? _imagePageController;
  int _currentImageIndex = 0;
  VideoPlayerController? _videoController;



  void _onGalleryImageTap(int imageIndex, List<String> images) {
    setState(() {
      _showVideo = false;
      _currentImageIndex = imageIndex;

      if (_videoController?.value.isInitialized == true &&
          _videoController!.value.isPlaying) {
        _videoController?.pause();
      }

      if (_imagePageController == null) {
        _imagePageController = PageController(initialPage: imageIndex);
      } else {
        _imagePageController!.jumpToPage(imageIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final size = MediaQuery.of(context).size;
    final images = widget.guestHouse.images ?? [];

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          Container(
            height: size.height * 0.45,
            color: Colors.black,
            child: widget.guestHouse.images.isNotEmpty
                ? Stack(
              children: [
                PageView.builder(
                  itemCount: widget.guestHouse.images.length,
                  onPageChanged: (index) {
                    setState(() => _selectedImageIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: widget.guestHouse.images[index],
                      width: double.infinity,
                      height: size.height * 0.45,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.broken_image, size: 60, color: Colors.white54),
                      ),
                    );
                  },
                ),
                // Image Counter
                /*Positioned(
                  bottom: 60,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${_currentImageIndex + 1} / ${images.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),*/
              ],
            )
                : const Center(
              child: Icon(Icons.home_outlined, size: 80, color: Colors.white54),
            ),
          ),

          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: _DetailActionButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),

          // Content Section
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.guestHouse.getName(context.locale),
                            style: TextStyle(
                              color: theme.text,
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: theme.primary, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.guestHouse.getVille(context.locale),
                            style: TextStyle(
                              color: theme.text.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.map_outlined, color: theme.text.withValues(alpha: 0.5), size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.guestHouse.getAddress(context.locale),
                            style: TextStyle(
                              color: theme.text.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (widget.guestHouse.lat != null && widget.guestHouse.lng != null)
                          IconButton(
                            icon: Icon(Icons.map, color: theme.primary),
                            onPressed: () {
                              double? lng = double.tryParse(widget.guestHouse.lng.toString());
                              double? lat = double.tryParse(widget.guestHouse.lat.toString());openMap(context, lng, lat);
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    GallerySection(
                      theme: theme,
                      galleryImages: images,
                      onImageTap: (index) => _onGalleryImageTap(index, images),
                    ),
                    const SizedBox(height: 30),

                    // Amenities Section
                    Text(
                      'details.amenities'.tr(),
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _AmenityItem(icon: Icons.wifi, label: 'details.wifi'.tr()),
                        _AmenityItem(icon: Icons.restaurant_outlined, label: 'details.breakfast'.tr()),
                        _AmenityItem(icon: FontAwesomeIcons.snowflake, label: 'details.ac'.tr()),
                        _AmenityItem(icon: Icons.local_parking_outlined, label: 'details.parking'.tr()),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Description
                    if (widget.guestHouse.description.isNotEmpty) ...[
                      Text(
                        'details.about'.tr(),
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.guestHouse.getDescription(context.locale),
                        style: TextStyle(
                          color: theme.text.withValues(alpha: 0.8),
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Contact Section
                    _ContactSection(theme: theme, guestHouse: widget.guestHouse),
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

class _AmenityItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AmenityItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: theme.primary, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: theme.text.withValues(alpha: 0.8),
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  final AppTheme theme;
  final GuestHouse guestHouse;

  const _ContactSection({required this.theme, required this.guestHouse});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.contact'.tr(),
          style: TextStyle(
            color: theme.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),

        // Phone
        if (guestHouse.phone.isNotEmpty)
          ContactDetailRow(
            theme: theme,
            icon: Icons.phone_outlined,
            text: guestHouse.phone,
            isLink: true,
          ),

        // Email
        if (guestHouse.email.isNotEmpty)
          ContactDetailRow(
            theme: theme,
            icon: Icons.email_outlined,
            text: guestHouse.email,
            isLink: true,
          ),

        // Address
        ContactDetailRow(
          theme: theme,
          icon: Icons.location_on_outlined,
          text: guestHouse.getAddress(context.locale),
          isLink: false,
        ),
      ],
    );
  }
}

