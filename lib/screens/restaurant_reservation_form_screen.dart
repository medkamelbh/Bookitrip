import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/restaurant.dart';
import 'package:BookiTrip/repositories/reservation_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RestaurantReservationFormScreen extends StatefulWidget {
  final Restaurant restaurant;
  final String? initialDate;
  final int? initialGuests;

  const RestaurantReservationFormScreen({
    super.key,
    required this.restaurant,
    this.initialDate,
    this.initialGuests,
  });

  @override
  State<RestaurantReservationFormScreen> createState() =>
      _RestaurantReservationFormScreenState();
}

class _RestaurantReservationFormScreenState
    extends State<RestaurantReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _guestsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _dateCtrl.text = widget.initialDate!;
    }
    if (widget.initialGuests != null) {
      _guestsCtrl.text = widget.initialGuests.toString();
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _guestsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _timeCtrl.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final repo = context.read<ReservationRepository>();
      
      final payload = {
        'restaurant_id': widget.restaurant.id,
        'date': _dateCtrl.text,
        'time': _timeCtrl.text,
        'guests': int.tryParse(_guestsCtrl.text) ?? 1,
        'nbr_personne': int.tryParse(_guestsCtrl.text) ?? 1, // Fallback for various API namings
        'nom': _lastNameCtrl.text.trim(),
        'prenom': _firstNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'telephone': _phoneCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'user': {
          'nom': _lastNameCtrl.text.trim(),
          'prenom': _firstNameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'telephone': _phoneCtrl.text.trim(),
        }
      };

      await repo.submitRestaurantReservation(payload);

      if (!mounted) return;
      
      // Navigate to a success screen or show dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Réservation confirmée'),
          content: const Text('Votre demande de réservation a été envoyée avec succès.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop(); // Pop the form
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors de la réservation : $e';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.background,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.text),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Réserver',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.restaurant, color: theme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.restaurant.name,
                            style: TextStyle(
                              color: theme.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reservation Details
                  Text(
                    'Détails de la réservation',
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          theme,
                          _dateCtrl,
                          'Date',
                          Icons.calendar_today,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          theme,
                          _timeCtrl,
                          'Heure',
                          Icons.access_time,
                          readOnly: true,
                          onTap: () => _selectTime(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    theme,
                    _guestsCtrl,
                    'Nombre de personnes',
                    Icons.people,
                    type: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Contact Info
                  Text(
                    'Informations de contact',
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(theme, _lastNameCtrl, 'Nom', Icons.person),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(theme, _firstNameCtrl, 'Prénom', Icons.person_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    theme,
                    _emailCtrl,
                    'Email',
                    Icons.email,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    theme,
                    _phoneCtrl,
                    'Téléphone',
                    Icons.phone,
                    type: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    theme,
                    _notesCtrl,
                    'Demandes spéciales (Optionnel)',
                    Icons.note,
                    required: false,
                    maxLines: 3,
                  ),
                  
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirmer la réservation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
        if (_isSubmitting)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(color: theme.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildField(
    AppTheme theme,
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    bool required = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.text.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.text.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primary),
        ),
        filled: true,
        fillColor: theme.isDark ? theme.surface : Colors.white,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null
          : null,
    );
  }
}
