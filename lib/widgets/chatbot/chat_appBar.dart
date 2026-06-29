import 'package:flutter/material.dart';
import 'package:BookiTrip/constants/theme.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppTheme theme;
  final VoidCallback? onBack;
  final VoidCallback? onMenuTap;

  const ChatAppBar({
    super.key,
    required this.theme,
    this.onBack,
    this.onMenuTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.surface,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: theme.text),
        onPressed: onMenuTap,
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primary,
                  theme.primary.withValues(alpha: 0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BookiTrip Assistant IA',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Toujours là pour vous aider',
                  style: TextStyle(
                    color: theme.text.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (onBack != null)
          IconButton(
            icon: Icon(Icons.close, color: theme.text),
            onPressed: onBack,
          ),

      ],
    );
  }
}