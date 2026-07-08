import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/reservation/contact_info.dart';
import 'package:BookiTrip/models/reservation/traveler.dart';
import 'package:BookiTrip/providers/reservation_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contact Controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _cinCtrl = TextEditingController();


  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _cinCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final provider = context.read<ReservationProvider>();
      
      provider.updateContactInfo(ContactInfo(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        cin: _cinCtrl.text.trim(),
        countryCode: 'TN',
      ));

      provider.submitReservation().then((_) {
        if (!mounted) return;
        if (provider.status == ReservationStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'reservation.error_generic'.tr()),
              backgroundColor: Colors.red,
            )
          );
        } else if (provider.status == ReservationStatus.success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              final theme = context.read<ThemeProvider>().currentTheme;
              return AlertDialog(
                backgroundColor: theme.background,
                title: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('reservation.confirmed_title'.tr(), style: TextStyle(color: theme.text)),
                    ),
                  ],
                ),
                content: Text(
                  'reservation.confirmed_message'.tr(namedArgs: {
                    'name': provider.contactInfo?.firstName ?? '',
                    'hotel': provider.hotel.hotelName,
                  }),
                  style: TextStyle(color: theme.text.withOpacity(0.8), height: 1.5),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); 
                      context.go('/home'); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text('reservation.back_to_home'.tr(), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final provider = context.watch<ReservationProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.text),
          onPressed: () {
            provider.goBackToRoomSelection();
          },
        ),
        title: Text(
          'reservation.title'.tr(),
          style: TextStyle(
            color: theme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildSummaryCard(theme, provider),
            const SizedBox(height: 24),
            _buildSectionTitle('reservation.contact_info'.tr(), theme),
            const SizedBox(height: 12),
            _buildContactSection(theme),
            const SizedBox(height: 24),
            _buildSectionTitle('reservation.traveler_details'.tr(), theme),
            const SizedBox(height: 12),
            ..._buildTravelerSections(theme, provider),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildStickyBottomBar(theme, provider),
    );
  }

  Widget _buildSummaryCard(AppTheme theme, ReservationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.hotel.hotelName,
            style: TextStyle(color: theme.text, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.searchParams.totalAdults} ${'reservation.adults'.tr()}, ${provider.searchParams.totalChildren} ${'reservation.children'.tr()}',
            style: TextStyle(color: theme.text.withOpacity(0.7), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.totalSelectedRooms} ${'reservation.rooms'.tr()} · ${provider.searchParams.nights} ${'reservation.nights'.tr()}',
            style: TextStyle(color: theme.text.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppTheme theme) {
    return Text(
      title,
      style: TextStyle(color: theme.text, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildContactSection(AppTheme theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField(_firstNameCtrl, 'reservation.first_name'.tr(), theme)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(_lastNameCtrl, 'reservation.last_name'.tr(), theme)),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(_emailCtrl, 'reservation.email'.tr(), theme, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _buildTextField(_phoneCtrl, 'reservation.phone'.tr(), theme, keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField(_cityCtrl, 'reservation.city'.tr(), theme)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(_cinCtrl, 'reservation.cin_passport'.tr(), theme)),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildTravelerSections(AppTheme theme, ReservationProvider provider) {
    List<Widget> sections = [];
    
    for (int i = 0; i < provider.roomTravelers.length; i++) {
      final rt = provider.roomTravelers[i];
      sections.add(
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.isDark ? Colors.white.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'reservation.room'.tr()} ${i + 1} - ${rt.room.title}',
                style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...rt.adults.asMap().entries.map((entry) {
                int index = entry.key;
                return _buildTravelerRow(
                  theme, provider, i, index, true, rt.adults[index],
                  '${'reservation.adult'.tr()} ${index + 1} ${rt.adults[index].isHolder ? 'reservation.holder'.tr() : ""}'
                );
              }),
              ...rt.children.asMap().entries.map((entry) {
                int index = entry.key;
                return _buildTravelerRow(
                  theme, provider, i, index, false, rt.children[index],
                  '${'reservation.child'.tr()} ${index + 1}'
                );
              }),
            ],
          ),
        )
      );
    }
    
    return sections;
  }
  
  Widget _buildTravelerRow(AppTheme theme, ReservationProvider provider, int roomIndex, int travelerIndex, bool isAdult, Traveler traveler, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: theme.text.withOpacity(0.7), fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: [
              // Civility Dropdown
              Container(
                width: 90,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: theme.isDark ? Colors.black26 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: traveler.civility,
                    items: [
                      DropdownMenuItem(value: 'Mr', child: Text('reservation.mr'.tr(), style: TextStyle(color: theme.text, fontSize: 13))),
                      DropdownMenuItem(value: 'Mme', child: Text('reservation.mrs'.tr(), style: TextStyle(color: theme.text, fontSize: 13))),
                      DropdownMenuItem(value: 'Mlle', child: Text('reservation.miss'.tr(), style: TextStyle(color: theme.text, fontSize: 13))),
                      DropdownMenuItem(value: 'Enfant', child: Text('reservation.child'.tr(), style: TextStyle(color: theme.text, fontSize: 13))),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      _updateTraveler(provider, roomIndex, travelerIndex, isAdult, traveler.copyWith(civility: val));
                    },
                    icon: Icon(Icons.arrow_drop_down, color: theme.text.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: traveler.firstName,
                  onChanged: (val) => _updateTraveler(provider, roomIndex, travelerIndex, isAdult, traveler.copyWith(firstName: val)),
                  validator: (v) => v!.isEmpty ? 'auth.field_required'.tr() : null,
                  style: TextStyle(color: theme.text, fontSize: 14),
                  decoration: _inputDecoration('reservation.first_name'.tr(), theme),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: traveler.lastName,
                  onChanged: (val) => _updateTraveler(provider, roomIndex, travelerIndex, isAdult, traveler.copyWith(lastName: val)),
                  validator: (v) => v!.isEmpty ? 'auth.field_required'.tr() : null,
                  style: TextStyle(color: theme.text, fontSize: 14),
                  decoration: _inputDecoration('reservation.last_name'.tr(), theme),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _updateTraveler(ReservationProvider provider, int roomIndex, int travelerIndex, bool isAdult, Traveler updated) {
    final rt = provider.roomTravelers[roomIndex];
    if (isAdult) {
      final newAdults = List<Traveler>.from(rt.adults);
      newAdults[travelerIndex] = updated;
      provider.updateRoomTraveler(roomIndex, rt.copyWith(adults: newAdults));
    } else {
      final newChildren = List<Traveler>.from(rt.children);
      newChildren[travelerIndex] = updated;
      provider.updateRoomTraveler(roomIndex, rt.copyWith(children: newChildren));
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, AppTheme theme, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.text),
      validator: (value) => value == null || value.trim().isEmpty ? 'auth.field_required'.tr() : null,
      decoration: _inputDecoration(label, theme),
    );
  }

  InputDecoration _inputDecoration(String label, AppTheme theme) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.text.withOpacity(0.5), fontSize: 14),
      filled: true,
      fillColor: theme.isDark ? Colors.black26 : Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  Widget _buildStickyBottomBar(AppTheme theme, ReservationProvider provider) {
    final isLoading = provider.status == ReservationStatus.loading;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'reservation.total'.tr(),
                  style: TextStyle(
                    color: theme.text.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${provider.totalPrice.toStringAsFixed(0)} ${provider.hotel.currency}',
                  style: TextStyle(
                    color: theme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: theme.text.withOpacity(0.1),
                disabledForegroundColor: theme.text.withOpacity(0.4),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'reservation.confirm'.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
