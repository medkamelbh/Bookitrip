import 'dart:async'; // Required for Timer
import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/voyage.dart';
import 'package:BookiTrip/widgets/contact_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class CircuitDetailsScreen extends StatefulWidget {
  final Voyage circuit;

  const CircuitDetailsScreen({
    super.key,
    required this.circuit,
  });

  @override
  State<CircuitDetailsScreen> createState() => _CircuitDetailsScreenState();
}

class _CircuitDetailsScreenState extends State<CircuitDetailsScreen> {
  bool _isDescriptionExpanded = false;
  int _selectedDayIndex = 0;
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _imagePageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    if (widget.circuit.images != null && widget.circuit.images!.length > 1) {
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (_imagePageController.hasClients) {
          int nextPage = _currentImageIndex + 1;

          // Loop back to the first image
          if (nextPage >= widget.circuit.images!.length) {
            nextPage = 0;
          }

          _imagePageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutQuad,
          );
        }
      });
    }
  }

  String _stripHtmlTags(String htmlText) {
    if (htmlText.isEmpty) return '';
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true);
    String plainText = htmlText.replaceAll(exp, '');
    plainText = plainText
        .replaceAll(RegExp(r'&[a-z]+;'), ' ')
        .replaceAll('\r\n', '\n')
        .replaceAll('\t', ' ')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
    return plainText;
  }

  String _formatPrice(String? price) {
    if (price == null || price.isEmpty) return '';
    return '${price} TND';
  }

  String _formatDateRange(List<Price> prices) {
    if (prices.isEmpty) return '';

    try {
      final p = prices.first;
      final start = DateTime.tryParse(p.dateStart);
      final end = DateTime.tryParse(p.dateEnd);

      if (start == null || end == null) return '';

      final formatter = DateFormat('dd MMM yyyy');
      return '${formatter.format(start)} - ${formatter.format(end)}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final size = MediaQuery.of(context).size;
    final images = widget.circuit.images ?? [];
    final localizedProgram = widget.circuit.getLocalizedProgram(context.locale);

    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        children: [
          // Header Image Slider
          Container(
            height: size.height * 0.45,
            color: Colors.black,
            child: images.isNotEmpty
                ? Stack(
              children: [
                PageView.builder(
                  controller: _imagePageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.broken_image, size: 40, color: Colors.white),
                      ),
                    );
                  },
                ),
                if (images.length > 1)
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentImageIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
                : const Center(
              child: Icon(Icons.image_not_supported, size: 60, color: Colors.white54),
            ),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: _DetailActionButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
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
                    Text(
                      widget.circuit.getName(context.locale),
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 15),

                    _QuickInfoSection(
                      theme: theme,
                      duration: widget.circuit.number ?? '0',
                      price: _formatPrice(
                        widget.circuit.price.isNotEmpty
                            ? widget.circuit.price.first.price
                            : null,
                      ),
                      dateRange: _formatDateRange(widget.circuit.price),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'details.about_circuit'.tr(),
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Builder(
                      builder: (context) {
                        final fullText = widget.circuit.getDescription(context.locale) ?? '';
                        final truncatedText = fullText.length > 200
                            ? "${fullText.substring(0, 200)}..."
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
                            if (fullText.length > 200)
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

                    const SizedBox(height: 30),

                    if (localizedProgram.isNotEmpty)
                      _ProgramSection(
                        theme: theme,
                        program: localizedProgram,
                        selectedIndex: _selectedDayIndex,
                        onDaySelected: (index) {
                          setState(() {
                            _selectedDayIndex = index;
                          });
                        },
                      ),

                    const SizedBox(height: 30),

                    _HighlightsSection(theme: theme),

                    const SizedBox(height: 30),

                    _ContactSection(theme: theme, circuit: widget.circuit),

                    const SizedBox(height: 20),
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

// Helper Widgets (Action Button, Info Card, etc.) remain largely the same
// but ensure they are provided in the same file to keep the code "Full".

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

class _QuickInfoSection extends StatelessWidget {
  final AppTheme theme;
  final String duration;
  final String price;
  final String dateRange;

  const _QuickInfoSection({
    required this.theme,
    required this.duration,
    required this.price,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            theme: theme,
            icon: Icons.calendar_today,
            label: 'details.duration'.tr(),
            value: '$duration ${'circuits.days'.tr()}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            theme: theme,
            icon: Icons.payments_outlined,
            label: 'details.price'.tr(),
            value: price,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final AppTheme theme;
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: theme.text.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: theme.text,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProgramSection extends StatelessWidget {
  final AppTheme theme;
  final List<Program> program;
  final int selectedIndex;
  final Function(int) onDaySelected;

  const _ProgramSection({
    required this.theme,
    required this.program,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  String _stripHtmlTags(String htmlText) {
    if (htmlText.isEmpty) return '';
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true);
    String plainText = htmlText.replaceAll(exp, '');
    plainText = plainText
        .replaceAll(RegExp(r'&[a-z]+;'), ' ')
        .replaceAll('\r\n', '\n')
        .replaceAll('\t', ' ')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
    return plainText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.circuit_program'.tr(),
          style: TextStyle(
            color: theme.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: program.length,
            itemBuilder: (context, index) {
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onDaySelected(index),
                child: Container(
                  margin: EdgeInsets.only(right: index < program.length - 1 ? 10 : 0),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primary : theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? theme.primary : theme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${'details.day'.tr()} ${index + 1}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.CardBG,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program[selectedIndex].title,
                style: TextStyle(
                  color: theme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _stripHtmlTags(program[selectedIndex].description),
                style: TextStyle(
                  color: theme.text.withValues(alpha: 0.8),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  final AppTheme theme;
  const _HighlightsSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    final highlights = [
      {'icon': Icons.hotel, 'text': 'details.accommodation_included'.tr()},
      {'icon': Icons.restaurant, 'text': 'details.meals_included'.tr()},
      {'icon': Icons.directions_bus, 'text': 'details.transport_organized'.tr()},
      {'icon': Icons.tour, 'text': 'details.professional_guide'.tr()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.whats_included'.tr(),
          style: TextStyle(
            color: theme.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: highlights.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item['icon'] as IconData, color: theme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    item['text'] as String,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  final AppTheme theme;
  final Voyage circuit;

  const _ContactSection({required this.theme, required this.circuit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.contact'.tr(),
          style: TextStyle(
            color: theme.text,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ContactDetailRow(
          theme: theme,
          icon: Icons.phone_outlined,
          text: circuit.phone ?? '',
          isLink: true,
        ),
      ],
    );
  }
}
