import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/vehicle.dart';
import 'package:BookiTrip/providers/vehicle_provider.dart';
import 'package:BookiTrip/services/vehicle_pricing_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VehicleReservationForm extends StatefulWidget {
  final Vehicle vehicle;
  final AppTheme theme;
  final DateTime? initialFromDate;
  final DateTime? initialToDate;

  const VehicleReservationForm({
    super.key,
    required this.vehicle,
    required this.theme,
    this.initialFromDate,
    this.initialToDate,
  });

  /// Shows the reservation form as a full-screen modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required Vehicle vehicle,
    required AppTheme theme,
    DateTime? initialFromDate,
    DateTime? initialToDate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VehicleReservationForm(
        vehicle: vehicle,
        theme: theme,
        initialFromDate: initialFromDate,
        initialToDate: initialToDate,
      ),
    );
  }

  @override
  State<VehicleReservationForm> createState() => _VehicleReservationFormState();
}

class _VehicleReservationFormState extends State<VehicleReservationForm> {
  final _formKey = GlobalKey<FormState>();

  // Date controllers
  late DateTime? _fromDate;
  late DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _fromDate = widget.initialFromDate;
    _toDate = widget.initialToDate;
    if (_fromDate != null && _toDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recalculatePrice();
      });
    }
  }

  // Client controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cinCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // Pricing
  VehiclePricingResult? _pricingResult;
  String? _pricingError;

  // Submission
  bool _isSubmitting = false;
  String? _submissionError;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cinCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _recalculatePrice() {
    if (_fromDate != null && _toDate != null) {
      final result = VehiclePricingService.calculatePrice(
        vehicle: widget.vehicle,
        from: _fromDate!,
        to: _toDate!,
      );
      setState(() {
        _pricingResult = result;
        _pricingError = result == null ? 'vehicles.no_pricing'.tr() : null;
      });
    } else {
      setState(() {
        _pricingResult = null;
        _pricingError = null;
      });
    }
  }

  Future<void> _selectDate({
    required bool isFrom,
  }) async {
    final now = DateTime.now();
    final initial = isFrom
        ? (_fromDate ?? now.add(const Duration(days: 1)))
        : (_toDate ??
            (_fromDate?.add(const Duration(days: 1)) ??
                now.add(const Duration(days: 2))));

    final firstDate = isFrom ? now : (_fromDate?.add(const Duration(days: 1)) ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.theme.primary,
              onPrimary: Colors.white,
              surface: widget.theme.surface,
              onSurface: widget.theme.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          // Reset toDate if it's before the new fromDate
          if (_toDate != null && !_toDate!.isAfter(picked)) {
            _toDate = null;
          }
        } else {
          _toDate = picked;
        }
      });
      _recalculatePrice();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fromDate == null || _toDate == null) {
      setState(() {
        _submissionError = 'vehicles.select_dates'.tr();
      });
      return;
    }

    if (_pricingResult == null) {
      setState(() {
        _submissionError = 'vehicles.no_pricing'.tr();
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    final payload = {
      'from': _formatDate(_fromDate!),
      'to': _formatDate(_toDate!),
      'price': _pricingResult!.pricePerDay,
      'total': _pricingResult!.total,
      'client': {
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'cin': _cinCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      },
      'vehicle_id': widget.vehicle.id,
    };

    final provider = context.read<VehicleProvider>();
    final success = await provider.submitReservation(payload);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('vehicles.reservation_success'.tr()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
        ),
      );
      // Refresh vehicle list in case status changed
      provider.fetchVehicles();
    } else {
      setState(() {
        _isSubmitting = false;
        _submissionError =
            provider.reservationError ?? 'vehicles.reservation_error'.tr();
      });
      provider.resetReservationState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // ── Handle bar ────────────────────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.text.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'vehicles.reservation_title'.tr(),
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: theme.text),
                    ),
                  ],
                ),
              ),

              // ── Vehicle info bar ──────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.directions_car_rounded,
                        color: theme.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.vehicle.title ?? widget.vehicle.model ?? '',
                            style: TextStyle(
                              color: theme.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${widget.vehicle.marque ?? ''} ${widget.vehicle.model ?? ''}'
                                .trim(),
                            style: TextStyle(
                              color: theme.text.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form body ─────────────────────────────────────────────
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Dates Section ─────────────────────────────
                        _sectionTitle(
                            theme, 'vehicles.reservation_dates'.tr()),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _datePicker(
                                theme: theme,
                                label: 'vehicles.date_from'.tr(),
                                value: _fromDate,
                                onTap: () => _selectDate(isFrom: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _datePicker(
                                theme: theme,
                                label: 'vehicles.date_to'.tr(),
                                value: _toDate,
                                onTap: () => _selectDate(isFrom: false),
                              ),
                            ),
                          ],
                        ),

                        // ── Pricing display ───────────────────────────
                        if (_pricingResult != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.primary.withOpacity(0.1),
                                  theme.primary.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: theme.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                _priceRow(
                                  theme,
                                  'vehicles.days_count'.tr(namedArgs: {
                                    'count': _pricingResult!.rentalDays.toString()
                                  }),
                                  '',
                                ),
                                _priceRow(
                                  theme,
                                  'vehicles.price_per_day'.tr(),
                                  '${_pricingResult!.pricePerDay.toStringAsFixed(0)} TND',
                                ),
                                const Divider(height: 20),
                                _priceRow(
                                  theme,
                                  'vehicles.total_price'.tr(),
                                  '${_pricingResult!.total.toStringAsFixed(0)} TND',
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (_pricingError != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _pricingError!,
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // ── Client Info Section ───────────────────────
                        _sectionTitle(theme, 'vehicles.client_info'.tr()),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                theme: theme,
                                ctrl: _firstNameCtrl,
                                label: 'vehicles.first_name'.tr(),
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                theme: theme,
                                ctrl: _lastNameCtrl,
                                label: 'vehicles.last_name'.tr(),
                                icon: Icons.person_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          theme: theme,
                          ctrl: _emailCtrl,
                          label: 'vehicles.email'.tr(),
                          icon: Icons.email_outlined,
                          type: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'vehicles.field_required'.tr();
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(v.trim())) {
                              return 'vehicles.invalid_email'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          theme: theme,
                          ctrl: _phoneCtrl,
                          label: 'vehicles.phone'.tr(),
                          icon: Icons.phone_outlined,
                          type: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          theme: theme,
                          ctrl: _cinCtrl,
                          label: 'vehicles.cin'.tr(),
                          icon: Icons.badge_outlined,
                          type: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          theme: theme,
                          ctrl: _addressCtrl,
                          label: 'vehicles.address'.tr(),
                          icon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),

                        // ── Error message ─────────────────────────────
                        if (_submissionError != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red.shade700, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _submissionError!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // ── Submit button ─────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  theme.primary.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation(
                                                  Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'vehicles.submitting'.tr(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'vehicles.submit_reservation'.tr(),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Full-screen loading overlay ────────────────────────────
          if (_isSubmitting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.15),
              ),
            ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Widget _sectionTitle(AppTheme theme, String title) {
    return Text(
      title,
      style: TextStyle(
        color: theme.text,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _datePicker({
    required AppTheme theme,
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: theme.isDark ? theme.surface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.text.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 18, color: theme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: theme.text.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value != null
                        ? _formatDateDisplay(value)
                        : 'vehicles.select_dates'.tr(),
                    style: TextStyle(
                      color:
                          value != null ? theme.text : theme.text.withOpacity(0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(AppTheme theme, String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.text.withOpacity(isBold ? 1 : 0.7),
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isBold ? theme.primary : theme.text,
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required AppTheme theme,
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      style: TextStyle(color: theme.text, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.text.withOpacity(0.5),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: theme.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.text.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.text.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        filled: true,
        fillColor: theme.isDark ? theme.surface : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator ??
          (v) => (v == null || v.trim().isEmpty)
              ? 'vehicles.field_required'.tr()
              : null,
    );
  }
}
