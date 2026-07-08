import 'dart:async';
import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/hotel.dart';
import 'package:BookiTrip/providers/availability_provider.dart';
import 'package:BookiTrip/providers/hotel_provider.dart';
import 'package:BookiTrip/utils/open_googlemaps.dart';
import 'package:BookiTrip/widgets/InfoRaw.dart';
import 'package:BookiTrip/widgets/MediaPlayerStack.dart';
import 'package:BookiTrip/widgets/availability/availability_search_modal.dart';
import 'package:BookiTrip/widgets/descriptionWithTTS.dart';
import 'package:BookiTrip/widgets/hotels/contact_section.dart';
import 'package:BookiTrip/widgets/hotels/reviews_section.dart';
import 'package:BookiTrip/widgets/hotels/detail_action_button.dart';
import 'package:BookiTrip/widgets/hotels/facility_item.dart';
import 'package:BookiTrip/widgets/hotels/gallery_section_details.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Responsive {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  static double scale(BuildContext context, double size) {
    double factor = screenWidth(context) / 375;
    return size * factor.clamp(0.85, 1.3);
  }
}

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailsScreen({super.key, required this.hotel});

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  VideoPlayerController? _videoController;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _showVideo = true;
  bool _isLoading = true;
  bool _isVideoInitializing = false;
  PageController? _imagePageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHotelDetails();

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });
  }

  Future<void> _loadHotelDetails() async {
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    await hotelProvider.fetchHotelDetail(widget.hotel.slug);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      final hotelDetail = hotelProvider.selectedHotel;
      final videoLink = hotelDetail?.videoLink;

      if (videoLink != null && videoLink.isNotEmpty) {
        _initializeVideo(videoLink);
      }
    }
  }

  void _initializeVideo(String videoUrl) {
    if (_videoController != null) {
      _videoController!.dispose();
    }

    setState(() {
      _isVideoInitializing = true;
    });

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize()
          .then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitializing = false;
          });
          _videoController?.play();
          _videoController?.setLooping(true);
          _videoController?.setVolume(0.0);
        }
      })
          .catchError((e) {
        debugPrint("Error initializing network video: $e");
        if (mounted) {
          setState(() {
            _isVideoInitializing = false;
          });
        }
      });
  }

  void _onCheckAvailability(AppTheme theme) {
    AvailabilitySearchModal.show(
      context: context,
      theme: theme,
      hotelId: widget.hotel.id,
      hotelSlug: widget.hotel.slug,
      onSearch: (params) async {
        BuildContext? loadingContext;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            loadingContext = ctx;
            return Center(
              child: CircularProgressIndicator(color: theme.primary),
            );
          },
        );
        
        final provider = Provider.of<AvailabilityProvider>(context, listen: false);
        await provider.getHotelAvailability(params);
        
        if (loadingContext != null && loadingContext!.mounted) {
          Navigator.pop(loadingContext!); // Close loading dialog safely
        }
        
        if (context.mounted) {
          if (provider.hasSingleResult) {
            final result = provider.singleResult!;
            if (result.isAvailable) {
              final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
              
              context.pushNamed('reservation', extra: {
                'result': result,
                'params': params,
                'hotelDetails': hotelProvider.selectedHotel,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("L'hôtel n'est pas disponible pour ces dates."),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } else if (provider.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.error!),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _imagePageController?.dispose();
    _flutterTts.stop();
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
        .replaceAll(' ', ' ')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
    return plainText;
  }

  String _buildStarRating(int rating) {
    int count = rating.clamp(1, 5);
    return List.generate(count, (_) => '★').join() +
        List.generate(5 - count, (_) => '☆').join();
  }

  String _getTtsLanguageCode(String localeCode) {
    switch (localeCode.toLowerCase()) {
      case 'ar': return 'ar-SA';
      case 'en': return 'en-US';
      case 'fr': return 'fr-FR';
      case 'ru': return 'ru-RU';
      case 'ko': return 'ko-KR';
      case 'zh': return 'zh-CN';
      case 'ja': return 'ja-JP';
      default: return 'en-US';
    }
  }

  Future<void> _speakDescription(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
    } else {
      setState(() {
        _isSpeaking = true;
      });

      final locale = context.locale;
      final ttsLanguageCode = _getTtsLanguageCode(locale.languageCode);

      try {
        await _flutterTts.setLanguage(ttsLanguageCode);
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setPitch(1.0);

        await _flutterTts.speak(text);
      } catch (e) {
        debugPrint("TTS Error: $e");
        if (mounted) {
          setState(() {
            _isSpeaking = false;
          });
        }
      }
    }
  }

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

  void _onPlayVideoTap() {
    setState(() {
      _showVideo = true;
      if (_videoController?.value.isInitialized == true) {
        _videoController?.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final size = MediaQuery.of(context).size;
    final locale = context.locale;

    return Scaffold(
      backgroundColor: theme.background,
      bottomNavigationBar: widget.hotel.reservable
          ? _buildAvailabilityButton(theme)
          : null,
      body: Consumer<HotelProvider>(
        builder: (context, hotelProvider, _) {
          if (_isLoading || hotelProvider.isLoadingDetail) {
            return Center(
              child: CircularProgressIndicator(color: theme.primary),
            );
          }
          if (hotelProvider.errorDetail != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: Responsive.scale(context, 60),
                    color: theme.text.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: Responsive.scale(context, 16)),
                  Text(
                    hotelProvider.errorDetail!,
                    style: TextStyle(
                        color: theme.text,
                        fontSize: Responsive.scale(context, 16)
                    ),
                  ),
                  SizedBox(height: Responsive.scale(context, 16)),
                  ElevatedButton(
                    onPressed: _loadHotelDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                    ),
                    child: Text('common.retry'.tr()),
                  ),
                ],
              ),
            );
          }

          final hotelDetail = hotelProvider.selectedHotel;
          final name = hotelDetail?.getName(locale) ?? widget.hotel.getName(locale);
          final description = hotelDetail?.getDescription(locale) ?? widget.hotel.getDescription(locale);
          final destinationName = widget.hotel.getDestinationName(locale);
          final address = hotelDetail?.getAddress(locale) ?? widget.hotel.getAddress(locale);
          final categoryCode = widget.hotel.categoryCode;
          final email = hotelDetail?.email ?? widget.hotel.email;
          final phone = hotelDetail?.phone ?? widget.hotel.phone;
          final images = hotelDetail?.images ?? widget.hotel.images ?? [];
          final videoLink = hotelDetail?.videoLink;

          return Stack(
            children: [
              MediaPlayerStack(
                screenSize: size,
                showVideo: _showVideo && videoLink != null && videoLink.isNotEmpty,
                videoController: _videoController,
                isVideoInitializing: _isVideoInitializing,
                images: images,
                imagePageController: _imagePageController,
                currentImageIndex: _currentImageIndex,
                onPageChanged: (index) => setState(() => _currentImageIndex = index),
                heightRatio: 0.45,
                showImageIcon: true,
              ),

              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.scale(context, 10),
                    vertical: Responsive.scale(context, 10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DetailActionButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () {
                          hotelProvider.clearSelectedHotel();
                          Navigator.pop(context);
                        },
                      ),
                      if (!_showVideo && videoLink != null && videoLink.isNotEmpty)
                        DetailActionButton(
                          icon: Icons.play_circle_outline,
                          onTap: _onPlayVideoTap,
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Responsive.scale(context, 40)),
                      topRight: Radius.circular(Responsive.scale(context, 40)),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: Responsive.scale(context, 30),
                      left: Responsive.scale(context, 20),
                      right: Responsive.scale(context, 20),
                      bottom: Responsive.scale(context, 20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: theme.text,
                            fontSize: Responsive.scale(context, 20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: Responsive.scale(context, 6)),

                        Text(
                          _buildStarRating(categoryCode?.toInt() ?? 0),
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: Responsive.scale(context, 22),
                            letterSpacing: 4.0,
                          ),
                        ),
                        SizedBox(height: Responsive.scale(context, 10)),

                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: theme.primary,
                                  size: Responsive.scale(context, 17),
                                ),
                                SizedBox(width: Responsive.scale(context, 5)),
                                Text(
                                  destinationName ?? "",
                                  style: TextStyle(
                                    color: theme.text,
                                    fontSize: Responsive.scale(context, 14),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Responsive.scale(context, 4)),
                            Row(
                              children: [
                                Expanded(
                                  child: InfoRow(
                                    icon: Icons.map_outlined,
                                    text: address ?? 'N/A',
                                    theme: theme,
                                  ),
                                ),
                                if (widget.hotel.lat != null)
                                  IconButton(
                                    icon: Icon(Icons.map, color: theme.primary),
                                    onPressed: () => openMap(
                                      context,
                                      double.tryParse(widget.hotel.lng?.toString() ?? ''),
                                      double.tryParse(widget.hotel.lat?.toString() ?? ''),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: Responsive.scale(context, 30)),

                        GallerySection(
                          theme: theme,
                          galleryImages: images,
                          onImageTap: (index) => _onGalleryImageTap(index, images),
                        ),

                        SizedBox(height: Responsive.scale(context, 30)),

                        Text(
                          'details.amenities'.tr(),
                          style: TextStyle(
                            color: theme.text,
                            fontSize: Responsive.scale(context, 16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: Responsive.scale(context, 15)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FacilityItem(
                              icon: Icons.wifi,
                              label: 'details.wifi'.tr(),
                            ),
                            FacilityItem(
                              icon: FontAwesomeIcons.bath,
                              label: 'details.spa'.tr(),
                            ),
                            FacilityItem(
                              icon: FontAwesomeIcons.utensils,
                              label: 'details.restaurant'.tr(),
                            ),
                            FacilityItem(
                              icon: Icons.pool,
                              label: 'details.pool'.tr(),
                            ),
                          ],
                        ),

                        SizedBox(height: Responsive.scale(context, 30)),

                        DescriptionWithTts(
                          theme: theme,
                          description: description ?? "",
                          isSpeaking: _isSpeaking,
                          onSpeakToggle: () => _speakDescription(
                            _stripHtmlTags(description ?? ""),
                          ),
                        ),

                        SizedBox(height: Responsive.scale(context, 30)),

                        ContactSection(
                          theme: theme,
                          email: email,
                          phone: phone,
                          address: address ?? "",
                        ),

                        SizedBox(height: Responsive.scale(context, 30)),

                        ReviewsSection(
                          theme: theme,
                          hotelId: widget.hotel.id,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvailabilityButton(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: theme.background,
        boxShadow: [
          BoxShadow(
            color: (theme.shadow ?? Colors.black).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _onCheckAvailability(theme),
        icon: const Icon(Icons.calendar_month_rounded, size: 20),
        label: Text(
          'Vérifier la disponibilité',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}