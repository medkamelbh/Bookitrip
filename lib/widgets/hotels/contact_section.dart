import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/widgets/contact_section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ContactSection extends StatelessWidget {
  final AppTheme theme;
  final String email;
  final String phone;
  final String address;

  const ContactSection({
    required this.theme,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.contact'.tr(),
          style: TextStyle(
            color: theme.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ContactDetailRow(
            theme: theme, icon: Icons.email_outlined, text: email, isLink: true),
        ContactDetailRow(
            theme: theme, icon: Icons.phone_outlined, text: phone, isLink: true),
        ContactDetailRow(
            theme: theme,
            icon: Icons.location_on_outlined,
            text: address,
            isLink: false),
      ],
    );
  }
}