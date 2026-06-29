import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final Color primaryColor;
  final Color textColor;
  final Function(int) onPageChange;
  final bool isEmptyOrLoading;

  const PaginationControls({
    super.key,
    required this.totalPages,
    required this.currentPage,
    required this.primaryColor,
    required this.textColor,
    required this.onPageChange,
    this.isEmptyOrLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmptyOrLoading || totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(totalPages, (index) {
            final page = index + 1;
            final bool isSelected = currentPage == page;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isSelected ? primaryColor : primaryColor.withValues(alpha: 0.3),
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => onPageChange(page),
                child: Text(
                  page.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
