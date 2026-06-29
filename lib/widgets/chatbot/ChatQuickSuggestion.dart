import 'package:flutter/material.dart';
import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/widgets/chatbot/chat_quick_chip.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatQuickSuggestions extends StatelessWidget {
  final AppTheme theme;
  final Function(String) onChipTap;

  const ChatQuickSuggestions({
    super.key,
    required this.theme,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.secondary.withValues(alpha: 0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChatQuickChip(
              label: 'home.categories.hotels'.tr(),
              icon: Icons.hotel,
              onTap: () => onChipTap('Hotels'),
            ),
            const SizedBox(width: 8),
            ChatQuickChip(
              label: 'home.categories.restaurants'.tr(),
              icon: Icons.restaurant,
              onTap: () => onChipTap('🍽Restaurants'),
            ),
            const SizedBox(width: 8),
            ChatQuickChip(
              label: 'home.categories.destinations'.tr(),
              icon: Icons.location_on,
              onTap: () => onChipTap('Destinations'),
            ),
            const SizedBox(width: 8),
            ChatQuickChip(
              label: 'home.categories.circuits'.tr(),
              icon: Icons.map,
              onTap: () => onChipTap('Circuits'),
            ),
          ],
        ),
      ),
    );
  }
}