import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/destination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeDestCard extends StatefulWidget {
  final Destination destination;
  final bool showText;
  final VoidCallback? onTap;

  const HomeDestCard({
    Key? key,
    required this.destination,
    this.onTap,
    this.showText = true,
  }) : super(key: key);

  @override
  State<HomeDestCard> createState() => _HomeDestCardState();
}

class _HomeDestCardState extends State<HomeDestCard> {
  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of<ThemeProvider>(context).currentTheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: widget.destination.gallery.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: widget.showText ? 0.35 : 0.5),
                        Colors.black.withValues(alpha: widget.showText ? 0.6 : 0.7),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
              ),
              if (widget.showText)
                Positioned(
                  left: 35,
                  right: 35,
                  top: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '|',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primary,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4.0,
                                      color: Colors.white.withValues(alpha: 0.6),
                                      offset: Offset(1, 0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  widget.destination.getName(context.locale),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4.0,
                                        color: Colors.white.withValues(alpha: 0.2),
                                        offset: Offset(-5, -10),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10)
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
