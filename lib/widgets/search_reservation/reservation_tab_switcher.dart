import 'package:BookiTrip/constants/theme.dart';
import 'package:flutter/material.dart';

class ReservationTabSwitcher extends StatelessWidget {
  const ReservationTabSwitcher({
    super.key,
    required this.selectedTab,
    required this.theme,
    required this.onTabChanged,
  });

  final int selectedTab;
  final AppTheme theme;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final Color tabBg =
    theme.isDark ? theme.surface : const Color(0xFFF0F0F0);

    return Container(
      decoration: BoxDecoration(
        color: tabBg,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _buildTab('Réservation', 0),
          _buildTab('Circuit', 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? theme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (theme.isDark ? Colors.white54 : Colors.black54),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}