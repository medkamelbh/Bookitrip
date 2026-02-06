import 'package:TunisiaBook/constants/theme.dart';
import 'package:TunisiaBook/models/musee.dart';
import 'package:TunisiaBook/utils/open_googlemaps.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class MuseeDetailsScreen extends StatefulWidget {
  final Musees musee;

  const MuseeDetailsScreen({
    super.key,
    required this.musee,
  });

  @override
  State<MuseeDetailsScreen> createState() => _MuseeDetailsScreenState();
}

class _MuseeDetailsScreenState extends State<MuseeDetailsScreen> {
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
          Container(
            height: size.height * 0.45,
            color: Colors.black,
            child: widget.musee.cover.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: CachedNetworkImage(
                imageUrl: widget.musee.cover,
                width: double.infinity,
                height: size.height * 0.45,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.white)),
                placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            )
                : const SizedBox.shrink(),
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
                    // Musee Name
                    Text(
                      widget.musee.getName(locale),
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Situation with map button
                    if (widget.musee.getSituation(locale).isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.location_on, color: theme.text, size: 18),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.musee.getSituation(locale),
                              style: TextStyle(
                                color: theme.text,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (widget.musee.lat != null && widget.musee.lng != null)
                            IconButton(
                              icon: Icon(Icons.map, color: theme.primary),
                              onPressed: () {
                                openMap(context, widget.musee.lng, widget.musee.lat);
                              },
                            ),
                        ],
                      ),

                    const SizedBox(height: 30),

                    // Gallery Section
                    if (widget.musee.images.isNotEmpty)
                      _GallerySection(theme: theme, galleryImages: widget.musee.images),

                    const SizedBox(height: 30),

                    // Entry Fee
                    if (widget.musee.getEntryFee(locale).isNotEmpty)
                      _InfoSection(
                        theme: theme,
                        title: 'details.entry_fee'.tr(),
                        content: widget.musee.getEntryFee(locale),
                        icon: Icons.local_atm,
                      ),

                    const SizedBox(height: 20),

                    // Opening Hours
                    if (widget.musee.horairesOuverture.isNotEmpty)
                      _InfoSection(
                        theme: theme,
                        title: 'details.opening_hours'.tr(),
                        content: widget.musee.horairesOuverture.join('\n'),
                        icon: Icons.access_time,
                      ),

                    const SizedBox(height: 20),

                   /* // Things to See
                    if (widget.musee.getAVoir(locale).isNotEmpty)
                      _ListSection(
                        theme: theme,
                        title: 'details.things_to_see'.tr(),
                        items: widget.musee.getAVoir(locale),
                      ),

                    const SizedBox(height: 30),*/

                    // Description
                    Text(
                      'details.description'.tr(),
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Builder(
                      builder: (context) {
                        final fullText = _stripHtmlTags(widget.musee.getDescription(locale));
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
                                fontSize: 14,
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
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 30),


                    /*// Observations
                    if (widget.musee.getObservations(locale).isNotEmpty) ...[
                      const SizedBox(height: 30),
                      Text(
                        'details.observations'.tr(),
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _stripHtmlTags(widget.musee.getObservations(locale)),
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],*/
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
          color: Colors.black.withOpacity(0.4),
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
            fontSize: 17,
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

class _InfoSection extends StatelessWidget {
  final AppTheme theme;
  final String title;
  final String content;
  final IconData icon;

  const _InfoSection({
    required this.theme,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: theme.text,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: theme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            content,
            style: TextStyle(
              color: theme.text,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ListSection extends StatelessWidget {
  final AppTheme theme;
  final String title;
  final List<String> items;

  const _ListSection({
    required this.theme,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: theme.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}