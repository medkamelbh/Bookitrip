import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/reservation_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final provider = context.watch<ReservationProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'reservation.confirmed_title'.tr(),
                style: TextStyle(
                  color: theme.text,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'reservation.confirmed_message'.tr(namedArgs: {
                  'name': provider.contactInfo?.firstName ?? '',
                  'hotel': provider.hotel.hotelName,
                }),
                style: TextStyle(
                  color: theme.text.withOpacity(0.6),
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.primary.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('reservation.total_amount'.tr(), '${provider.totalPrice.toStringAsFixed(0)} ${provider.hotel.currency}', theme, isHighlight: true),
                    const Divider(height: 32),
                    _buildDetailRow('reservation.hotel_label'.tr(), provider.hotel.hotelName, theme),
                    const SizedBox(height: 12),
                    _buildDetailRow('reservation.rooms'.tr(), '${provider.totalSelectedRooms}', theme),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'reservation.back_to_home'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, AppTheme theme, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.text.withOpacity(0.6),
            fontSize: isHighlight ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? theme.primary : theme.text,
            fontSize: isHighlight ? 18 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
