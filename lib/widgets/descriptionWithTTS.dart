import 'package:BookiTrip/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DescriptionWithTts extends StatefulWidget {
  final AppTheme theme;
  final String description;
  final bool isSpeaking;
  final VoidCallback onSpeakToggle;
  final int truncateLength;

  const DescriptionWithTts({
    super.key,
    required this.theme,
    required this.description,
    required this.isSpeaking,
    required this.onSpeakToggle,
    this.truncateLength = 220,
  });

  @override
  State<DescriptionWithTts> createState() => _DescriptionWithTtsState();
}

class _DescriptionWithTtsState extends State<DescriptionWithTts> {
  bool _isExpanded = false;

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

  @override
  Widget build(BuildContext context) {
    final fullText = _stripHtmlTags(widget.description);
    final truncatedText = fullText.length > widget.truncateLength
        ? fullText.substring(0, widget.truncateLength) + "..."
        : fullText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.description'.tr(),
          style: TextStyle(
            color: widget.theme.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _isExpanded ? fullText : truncatedText,
          style: TextStyle(
            color: widget.theme.text,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (fullText.length > widget.truncateLength)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded
                      ? 'details.show_less'.tr()
                      : 'details.show_more'.tr(),
                  style: TextStyle(
                    color: widget.theme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            GestureDetector(
              onTap: widget.onSpeakToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.theme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isSpeaking ? Icons.stop : Icons.volume_up,
                      color: widget.theme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isSpeaking ? 'stop'.tr() : 'read_aloud'.tr(),
                      style: TextStyle(
                        color: widget.theme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}