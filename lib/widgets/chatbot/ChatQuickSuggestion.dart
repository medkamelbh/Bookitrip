import 'package:flutter/material.dart';
import 'package:TunisiaBook/constants/theme.dart';
import 'package:TunisiaBook/widgets/chatbot/chat_quick_chip.dart';

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
        color: theme.secondary.withOpacity(0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              label: 'Hotels',
              icon: Icons.hotel,
              onTap: () => onChipTap('Hotels'),
            ),
            const SizedBox(width: 8),
            ChatQuickChip(
              label: 'Restaurants',
              icon: Icons.restaurant,
              onTap: () => onChipTap('🍽Restaurants'),
            ),
            const SizedBox(width: 8),
            ChatQuickChip(
              label: 'Destinations',
              icon: Icons.location_on,
              onTap: () => onChipTap('Destinations'),
            ),
            const SizedBox(width: 8),
            ChatQuickChip(
              label: 'Circuits',
              icon: Icons.map,
              onTap: () => onChipTap('Circuits'),
            ),
          ],
        ),
      ),
    );
  }
}