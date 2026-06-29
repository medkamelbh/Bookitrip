import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/activity.dart';
import 'package:BookiTrip/widgets/contact_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Activity activity;

  const ActivityDetailsScreen({super.key, required this.activity});

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  bool _isDescriptionExpanded = false;

  String _stripHtmlTags(String htmlText) {
    if (htmlText.isEmpty) return '';
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true);
    String plainText = htmlText.replaceAll(exp, '');
    plainText = plainText
        .replaceAll(RegExp(r'&[a-z]+;'), ' ')
        .replaceAll('\r\n', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('\t', ' ')
        .replaceAll(' ', ' ')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
    return plainText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final size = MediaQuery.of(context).size;

    // Prepare gallery
    final gallery = <String>[
      if (widget.activity.images != null && widget.activity.images!.isNotEmpty)
        ...widget.activity.images!
      else if (widget.activity.vignette != null)
        widget.activity.vignette!,
      if (widget.activity.cover != null) widget.activity.cover!,
    ];


    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          Container(
            height: size.height * 0.45,
            color: Colors.black,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: CachedNetworkImage(
                imageUrl: gallery[1]??gallery[0],
                fit: BoxFit.cover,
                width: double.infinity,
                height: size.height * 0.45,
                placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator(color: Colors.white)),
                errorWidget: (_, __, ___) =>
                const Center(child: Icon(Icons.broken_image, size: 40)),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  _DetailActionButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),

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
                padding:
                const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.activity.getName(Localizations.localeOf(context)),
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
                    const SizedBox(height: 10),

                    // LOCATION
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: theme.primary, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.activity.getAddress(context.locale) ?? 'details.location_unavailable'.tr(),
                            style: TextStyle(
                              color: theme.text.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // GALLERY
                    _GallerySection(theme: theme, galleryImages: gallery),
                    const SizedBox(height: 30),

                    // DESCRIPTION
                    Text(
                      'details.about'.tr(),
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Builder(builder: (context) {
                      final fullText =
                      _stripHtmlTags(widget.activity.getDescription(context.locale) ?? "");
                      final truncatedText =
                      fullText.length > 220 ? fullText.substring(0, 220) : fullText;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isDescriptionExpanded ? fullText : truncatedText + (fullText.length > 220 ? "..." : ""),
                            style: TextStyle(
                              color: theme.text,
                              fontSize: 15,
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
                                  _isDescriptionExpanded
                                      ? 'details.show_less'.tr()
                                      : 'details.show_more'.tr(),
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
                    }),
                    const SizedBox(height: 30),

                    // CONTACT
                    _ContactSection(theme: theme, activity: widget.activity),
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

// DETAIL BUTTON
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

// GALLERY SECTION
class _GallerySection extends StatelessWidget {
  final AppTheme theme;
  final List<String> galleryImages;

  const _GallerySection({required this.theme, required this.galleryImages});

  @override
  Widget build(BuildContext context) {
    if (galleryImages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.gallery'.tr(),
          style: TextStyle(
            color: theme.text,
            fontSize: 18,
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
                margin: EdgeInsets.only(
                    right: index < galleryImages.length - 1 ? 15 : 0),
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: galleryImages[index],
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 40),
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

// CONTACT SECTION
class _ContactSection extends StatelessWidget {
  final AppTheme theme;
  final Activity activity;

  const _ContactSection({required this.theme, required this.activity});

  @override
  Widget build(BuildContext context) {
    if ((activity.phone == null || activity.phone!.isEmpty) &&
        (activity.links == null ||
            activity.links!['external_link'] == null)) {
      return const SizedBox.shrink();
    }

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
        const SizedBox(height: 20),
        if (activity.phone != null && activity.phone!.isNotEmpty)
          ContactDetailRow(
              theme: theme,
              icon: Icons.phone_outlined,
              text: activity.phone!,
              isLink: false
          ),
        if (activity.links != null && activity.links!['external_link'] != null)
          ContactDetailRow(
              theme: theme,
              icon: Icons.public,
              text: activity.links!['external_link'],
              isLink: true
          ),
      ],
    );
  }
}
