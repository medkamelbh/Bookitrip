import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:BookiTrip/providers/transfer_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:BookiTrip/constants/theme.dart';

/// A premium transfer booking dialog with blur background,
/// responsive layout, and full multilanguage support.
class TransferFormDialog extends StatefulWidget {
  final AppTheme theme;

  const TransferFormDialog({super.key, required this.theme});

  @override
  State<TransferFormDialog> createState() => _TransferFormDialogState();
}

class _TransferFormDialogState extends State<TransferFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departureAddressController = TextEditingController();
  final _arrivalAddressController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _persons = 1;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departureAddressController.dispose();
    _arrivalAddressController.dispose();
    super.dispose();
  }

  // ── Color helpers ──────────────────────────────────────────────────────────
  Color get _fieldBg => widget.theme.isDark
      ? widget.theme.surface.withOpacity(0.5)
      : Colors.grey.shade50;

  Color get _fieldBorder => widget.theme.isDark
      ? Colors.white12
      : Colors.grey.shade200;

  Color get _hintColor => widget.theme.isDark
      ? Colors.white38
      : Colors.grey.shade500;

  // ── Pickers ────────────────────────────────────────────────────────────────
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: widget.theme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: widget.theme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('search.transfer_select_datetime'.tr()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final String formattedHour = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    final provider = context.read<TransferProvider>();
    final success = await provider.submitTransfer(
      name: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      numberPerson: _persons,
      date: formattedDate,
      hour: formattedHour,
      adresseDepart: _departureAddressController.text.trim(),
      adresseArrive: _arrivalAddressController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('search.transfer_success'.tr())),
            ],
          ),
          backgroundColor: const Color(0xFF2ECC71),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      final errorMessage = provider.errorMessage ?? 'Failed to submit transfer reservation.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isSmall = mq.size.width < 380;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: isSmall ? 12 : 24,
              vertical: 24,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              decoration: BoxDecoration(
                color: widget.theme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          child: Column(
                            children: [
                              _buildField(
                                controller: _fullNameController,
                                label: 'search.transfer_full_name'.tr(),
                                icon: Icons.person_rounded,
                              ),
                              const SizedBox(height: 14),
                              _buildField(
                                controller: _emailController,
                                label: 'search.transfer_email'.tr(),
                                icon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 14),
                              _buildField(
                                controller: _phoneController,
                                label: 'search.transfer_phone'.tr(),
                                icon: Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 14),
                              _buildPersonsCounter(),
                              const SizedBox(height: 14),
                              _buildDateTimeRow(isSmall),
                              const SizedBox(height: 14),
                              _buildField(
                                controller: _departureAddressController,
                                label: 'search.transfer_departure'.tr(),
                                icon: Icons.trip_origin_rounded,
                              ),
                              const SizedBox(height: 14),
                              _buildField(
                                controller: _arrivalAddressController,
                                label: 'search.transfer_arrival'.tr(),
                                icon: Icons.flag_rounded,
                              ),
                              const SizedBox(height: 24),
                              _buildConfirmButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header with gradient ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 12, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.theme.primary,
            widget.theme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.directions_bus_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'search.transfer_title'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'search.transfer_subtitle'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date & Time row (responsive) ───────────────────────────────────────────
  Widget _buildDateTimeRow(bool isSmall) {
    final dateWidget = _buildPickerTile(
      label: 'search.transfer_date'.tr(),
      value: _selectedDate != null
          ? DateFormat('dd MMM yyyy').format(_selectedDate!)
          : 'search.transfer_select_date'.tr(),
      icon: Icons.calendar_month_rounded,
      hasValue: _selectedDate != null,
      onTap: _selectDate,
    );

    final timeWidget = _buildPickerTile(
      label: 'search.transfer_time'.tr(),
      value: _selectedTime != null
          ? _selectedTime!.format(context)
          : 'search.transfer_select_time'.tr(),
      icon: Icons.schedule_rounded,
      hasValue: _selectedTime != null,
      onTap: _selectTime,
    );

    if (isSmall) {
      return Column(
        children: [
          dateWidget,
          const SizedBox(height: 14),
          timeWidget,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: dateWidget),
        const SizedBox(width: 12),
        Expanded(child: timeWidget),
      ],
    );
  }

  // ── Picker tile ────────────────────────────────────────────────────────────
  Widget _buildPickerTile({
    required String label,
    required String value,
    required IconData icon,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _fieldBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: widget.theme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _hintColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                      color: hasValue ? widget.theme.text : _hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Text field ─────────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: widget.theme.text,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _hintColor,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: widget.theme.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: widget.theme.primary, size: 20),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: widget.theme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'search.transfer_field_required'.tr();
        }
        return null;
      },
    );
  }

  // ── Persons counter ────────────────────────────────────────────────────────
  Widget _buildPersonsCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _fieldBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.group_rounded, color: widget.theme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'search.transfer_persons'.tr(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: _hintColor,
              ),
            ),
          ),
          _buildCounterButton(
            icon: Icons.remove_rounded,
            onTap: _persons > 1
                ? () => setState(() => _persons--)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$_persons',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: widget.theme.text,
              ),
            ),
          ),
          _buildCounterButton(
            icon: Icons.add_rounded,
            onTap: _persons < 20
                ? () => setState(() => _persons++)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final bool enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled
              ? widget.theme.primary.withOpacity(0.12)
              : Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? widget.theme.primary : Colors.grey.shade400,
        ),
      ),
    );
  }

  // ── Confirm button ─────────────────────────────────────────────────────────
  Widget _buildConfirmButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.theme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'search.transfer_confirm'.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
