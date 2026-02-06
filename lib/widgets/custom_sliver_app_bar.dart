import 'package:flutter/material.dart';
import 'package:TunisiaBook/constants/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final AppTheme theme;
  final VoidCallback onMenuTap;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.theme,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: theme.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: theme.text),
        onPressed: onMenuTap,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: theme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
