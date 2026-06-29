import 'package:BookiTrip/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoryItem {
  final String label;
  final IconData icon;
  const CategoryItem({required this.label, required this.icon});
}

class ReservationCategoryRow extends StatelessWidget {
  const ReservationCategoryRow({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.theme,
    required this.onCategorySelected,
  });

  final List<CategoryItem> categories;
  final int selectedIndex;
  final AppTheme theme;
  final ValueChanged<int> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final Color labelInactive =
    theme.isDark ? Colors.white54 : Colors.black54;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(categories.length, (index) {
          final category = categories[index];
          final bool isSelected = selectedIndex == index;
          final Color iconBg = isSelected
              ? theme.secondary
              : (theme.isDark ? theme.surface : const Color(0xFFF0F0F0));

          return GestureDetector(
            onTap: () => onCategorySelected(index),
            child: Padding(
              padding: EdgeInsets.only(
                right: index < categories.length - 1 ? 12 : 0,
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: theme.secondary.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                          : [],
                    ),
                    child: Icon(
                      category.icon,
                      color: isSelected ? Colors.white : labelInactive,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    category.label.tr(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected ? theme.text : labelInactive,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
    );
  }
}