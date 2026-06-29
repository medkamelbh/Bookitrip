import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/availability_provider.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Reusable widget that renders UI based on [AvailabilityStatus].
class AvailabilityStatusWidget extends StatelessWidget {
  final AvailabilityStatus status;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget successChild;
  final AppTheme theme;

  const AvailabilityStatusWidget({
    super.key,
    required this.status,
    this.errorMessage,
    this.onRetry,
    required this.successChild,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AvailabilityStatus.idle:
        return _buildIdleState();
      case AvailabilityStatus.loading:
        return _buildLoadingState();
      case AvailabilityStatus.error:
        return _buildErrorState();
      case AvailabilityStatus.empty:
        return _buildEmptyState();
      case AvailabilityStatus.success:
        return successChild;
    }
  }

  Widget _buildIdleState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded, size: 64, color: theme.text.withOpacity(0.12)),
          const SizedBox(height: 16),
          Text(
            'availability.launch_search'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.text.withOpacity(0.35), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 48, height: 48, child: CircularProgressIndicator(color: theme.primary, strokeWidth: 3)),
          const SizedBox(height: 20),
          Text('availability.searching'.tr(), style: TextStyle(color: theme.text.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(Icons.error_outline_rounded, size: 32, color: Colors.red.shade400),
            ),
            const SizedBox(height: 16),
            Text(errorMessage ?? 'availability.error_occurred'.tr(), textAlign: TextAlign.center, style: TextStyle(color: theme.text.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w500)),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('availability.retry'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: theme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(Icons.hotel_rounded, size: 32, color: Colors.amber.shade600),
            ),
            const SizedBox(height: 16),
            Text('availability.no_availability'.tr(), style: TextStyle(color: theme.text, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('availability.try_modify'.tr(), textAlign: TextAlign.center, style: TextStyle(color: theme.text.withOpacity(0.45), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
