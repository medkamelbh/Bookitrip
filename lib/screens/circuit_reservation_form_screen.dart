import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/circuit_form_data.dart';
import 'package:BookiTrip/providers/circuit_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CircuitReservationFormScreen extends StatefulWidget {
  final Map<String, dynamic> circuitData;
  final CircuitFormData formData;

  const CircuitReservationFormScreen({
    super.key,
    required this.circuitData,
    required this.formData,
  });

  @override
  State<CircuitReservationFormScreen> createState() =>
      _CircuitReservationFormScreenState();
}

class _CircuitReservationFormScreenState
    extends State<CircuitReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Main contact controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // Per-room passenger controllers
  late List<List<Map<String, TextEditingController>>> _adultsCtrl;
  late List<List<Map<String, TextEditingController>>> _childrenCtrl;

  bool _isSubmitting = false;
  String? _error;

  // ── Init ──────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initPassengerControllers();
  }

  void _initPassengerControllers() {
    _adultsCtrl = widget.formData.rooms.map((room) {
      return List.generate(
        room.adults,
        (_) => {
          'firstName': TextEditingController(),
          'lastName': TextEditingController(),
          'title': TextEditingController(text: 'M.'),
        },
      );
    }).toList();

    _childrenCtrl = widget.formData.rooms.map((room) {
      return List.generate(
        room.children,
        (i) => {
          'firstName': TextEditingController(),
          'lastName': TextEditingController(),
          'age': TextEditingController(
            text: i < room.childAges.length
                ? room.childAges[i].toString()
                : '',
          ),
        },
      );
    }).toList();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _zipCtrl.dispose();
    _addressCtrl.dispose();
    for (final room in _adultsCtrl) {
      for (final p in room) {
        p.values.forEach((c) => c.dispose());
      }
    }
    for (final room in _childrenCtrl) {
      for (final p in room) {
        p.values.forEach((c) => c.dispose());
      }
    }
    super.dispose();
  }

  // ── Payload ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _buildPayload() {
    final rooms = <Map<String, dynamic>>[];
    for (int i = 0; i < _adultsCtrl.length; i++) {
      final adults = _adultsCtrl[i]
          .map((a) => {
                'firstName': a['firstName']!.text.trim(),
                'lastName': a['lastName']!.text.trim(),
                'title': a['title']!.text,
              })
          .toList();
      final children = i < _childrenCtrl.length
          ? _childrenCtrl[i]
              .map((c) => {
                    'firstName': c['firstName']!.text.trim(),
                    'lastName': c['lastName']!.text.trim(),
                    'age': c['age']!.text.trim(),
                  })
              .toList()
          : <Map<String, dynamic>>[];
      rooms.add({'adults': adults, 'children': children});
    }

    return {
      'planing': {
        'listparjours':
            widget.circuitData['listparjours'] ?? widget.circuitData,
        'alldestination': widget.circuitData['alldestination'] ?? [],
      },
      'hotelsReservation': [],
      'restaurantReservation': [],
      'user': {
        'nom': _lastNameCtrl.text.trim(),
        'prenom': _firstNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'telephone': _phoneCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'pays': _countryCtrl.text.trim(),
        'zip_code': _zipCtrl.text.trim(),
        'adresse': _addressCtrl.text.trim(),
        'rooms': rooms,
      },
      'reservation': widget.formData.toReservationMeta(),
    };
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final provider = context.read<CircuitFormProvider>();
      final success = await provider.submitReservation(_buildPayload());

      if (!mounted) return;
      if (success) {
        context.pushNamed('circuit-reservation-success');
      } else {
        setState(() {
          _error = provider.error ?? 'Une erreur est survenue. Réessayez.';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur réseau : $e';
          _isSubmitting = false;
        });
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.background,
          appBar: _buildAppBar(theme),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Summary card ─────────────────────────────────────
                  _SummaryCard(theme: theme, formData: widget.formData),
                  const SizedBox(height: 20),

                  // ── Contact info ─────────────────────────────────────
                  _SectionTitle(
                    theme: theme,
                    title: 'Informations de contact',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _FormCard(
                    theme: theme,
                    child: Column(
                      children: [
                        _RowFields(children: [
                          _CField(theme, _lastNameCtrl, 'Nom',
                              Icons.badge_outlined),
                          _CField(theme, _firstNameCtrl, 'Prénom',
                              Icons.person_outline_rounded),
                        ]),
                        const SizedBox(height: 12),
                        _CField(
                          theme,
                          _emailCtrl,
                          'Adresse email',
                          Icons.email_outlined,
                          type: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email requis';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(v)) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _CField(
                          theme,
                          _phoneCtrl,
                          'Téléphone',
                          Icons.phone_outlined,
                          type: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _RowFields(children: [
                          _CField(theme, _cityCtrl, 'Ville',
                              Icons.location_city_outlined),
                          _CField(theme, _countryCtrl, 'Pays',
                              Icons.flag_outlined),
                        ]),
                        const SizedBox(height: 12),
                        _RowFields(children: [
                          _CField(theme, _zipCtrl, 'Code postal',
                              Icons.local_post_office_outlined,
                              type: TextInputType.number),
                          _CField(theme, _addressCtrl, 'Adresse',
                              Icons.home_outlined),
                        ]),
                      ],
                    ),
                  ),

                  // ── Rooms ────────────────────────────────────────────
                  for (int ri = 0; ri < _adultsCtrl.length; ri++) ...[
                    const SizedBox(height: 20),
                    _SectionTitle(
                      theme: theme,
                      title:
                          'Chambre ${ri + 1} · ${_adultsCtrl[ri].length} adulte${_adultsCtrl[ri].length > 1 ? 's' : ''}'
                          '${ri < _childrenCtrl.length && _childrenCtrl[ri].isNotEmpty ? ' · ${_childrenCtrl[ri].length} enfant${_childrenCtrl[ri].length > 1 ? 's' : ''}' : ''}',
                      icon: Icons.hotel_outlined,
                    ),
                    const SizedBox(height: 12),
                    _FormCard(
                      theme: theme,
                      child: Column(
                        children: [
                          for (int ai = 0;
                              ai < _adultsCtrl[ri].length;
                              ai++) ...[
                            _PassengerSection(
                              theme: theme,
                              controllers: _adultsCtrl[ri][ai],
                              label: 'Adulte ${ai + 1}',
                              isChild: false,
                            ),
                            if (ai < _adultsCtrl[ri].length - 1 ||
                                (ri < _childrenCtrl.length &&
                                    _childrenCtrl[ri].isNotEmpty))
                              const Divider(height: 24, thickness: 0.5),
                          ],
                          if (ri < _childrenCtrl.length)
                            for (int ci = 0;
                                ci < _childrenCtrl[ri].length;
                                ci++) ...[
                              _PassengerSection(
                                theme: theme,
                                controllers: _childrenCtrl[ri][ci],
                                label: 'Enfant ${ci + 1}',
                                isChild: true,
                              ),
                              if (ci < _childrenCtrl[ri].length - 1)
                                const Divider(height: 24, thickness: 0.5),
                            ],
                        ],
                      ),
                    ),
                  ],

                  // ── Error ────────────────────────────────────────────
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: Colors.red.shade600, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
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
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildSubmitBar(theme),
        ),

        // ── Loading overlay ─────────────────────────────────────────────
        if (_isSubmitting)
          Container(
            color: Colors.black.withOpacity(0.35),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        color: theme.primary, strokeWidth: 3),
                    const SizedBox(height: 16),
                    Text(
                      'Envoi en cours...',
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(AppTheme theme) => AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Finaliser la réservation',
          style: TextStyle(
            color: theme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      );

  Widget _buildSubmitBar(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: theme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: const Icon(Icons.send_rounded, size: 20),
          label: Text(
            'Confirmer · ${widget.formData.budget.toStringAsFixed(0)} TND',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: theme.primary.withOpacity(0.5),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  // ── Field helpers ─────────────────────────────────────────────────────────

  Widget _CField(
    AppTheme theme,
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: theme.text.withOpacity(0.5), fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: theme.primary.withOpacity(0.6)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.text.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        filled: true,
        fillColor: theme.isDark ? theme.surface : Colors.white,
      ),
      style: TextStyle(color: theme.text, fontSize: 14),
      validator: validator ??
          (v) =>
              (v == null || v.trim().isEmpty) ? '$label requis' : null,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

class _RowFields extends StatelessWidget {
  final List<Widget> children;
  const _RowFields({required this.children});

  @override
  Widget build(BuildContext context) => Row(
        children: children
            .expand((w) => [Expanded(child: w), const SizedBox(width: 10)])
            .toList()
          ..removeLast(),
      );
}

class _SectionTitle extends StatelessWidget {
  final AppTheme theme;
  final String title;
  final IconData icon;
  const _SectionTitle(
      {required this.theme, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: theme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: theme.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
}

class _FormCard extends StatelessWidget {
  final AppTheme theme;
  final Widget child;
  const _FormCard({required this.theme, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.isDark ? theme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );
}

class _SummaryCard extends StatelessWidget {
  final AppTheme theme;
  final CircuitFormData formData;
  const _SummaryCard({required this.theme, required this.formData});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary.withOpacity(0.12),
            theme.primary.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.primary.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_rounded, color: theme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Résumé du circuit',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _Chip(
                icon: Icons.calendar_today_rounded,
                label:
                    '${fmt.format(formData.startDate)} → ${fmt.format(formData.endDate)}',
                theme: theme,
              ),
              _Chip(
                icon: Icons.people_alt_rounded,
                label:
                    '${formData.totalAdults} adulte${formData.totalAdults > 1 ? 's' : ''}'
                    '${formData.totalChildren > 0 ? ' · ${formData.totalChildren} enfant${formData.totalChildren > 1 ? 's' : ''}' : ''}',
                theme: theme,
              ),
              _Chip(
                icon: Icons.hotel_rounded,
                label:
                    '${formData.totalRooms} chambre${formData.totalRooms > 1 ? 's' : ''}',
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: theme.primary.withOpacity(0.15)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget total',
                style: TextStyle(
                  color: theme.text.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              Text(
                '${formData.budget.toStringAsFixed(0)} TND',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppTheme theme;
  const _Chip({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: theme.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: theme.text.withOpacity(0.75),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

class _PassengerSection extends StatefulWidget {
  final AppTheme theme;
  final Map<String, TextEditingController> controllers;
  final String label;
  final bool isChild;
  const _PassengerSection({
    required this.theme,
    required this.controllers,
    required this.label,
    required this.isChild,
  });

  @override
  State<_PassengerSection> createState() => _PassengerSectionState();
}

class _PassengerSectionState extends State<_PassengerSection> {
  @override
  Widget build(BuildContext context) {
    final color =
        widget.isChild ? Colors.orange.shade700 : widget.theme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              widget.isChild
                  ? Icons.child_care_rounded
                  : Icons.person_rounded,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (!widget.isChild) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              _TitleRadio('M.', widget.controllers['title']!, widget.theme),
              const SizedBox(width: 16),
              _TitleRadio('Mme', widget.controllers['title']!, widget.theme),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controllers['firstName'],
                decoration: _dec(widget.theme, 'Prénom'),
                style: TextStyle(color: widget.theme.text, fontSize: 14),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: widget.controllers['lastName'],
                decoration: _dec(widget.theme, 'Nom'),
                style: TextStyle(color: widget.theme.text, fontSize: 14),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
            ),
          ],
        ),
        if (widget.isChild) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: widget.controllers['age'],
              keyboardType: TextInputType.number,
              decoration: _dec(widget.theme, 'Âge'),
              style: TextStyle(color: widget.theme.text, fontSize: 14),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requis';
                final a = int.tryParse(v);
                if (a == null || a < 0 || a > 17) return 'Invalide';
                return null;
              },
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _dec(AppTheme theme, String label) => InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: theme.text.withOpacity(0.5), fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.text.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: theme.isDark ? theme.surface : Colors.white,
      );
}

class _TitleRadio extends StatefulWidget {
  final String value;
  final TextEditingController controller;
  final AppTheme theme;
  const _TitleRadio(this.value, this.controller, this.theme);

  @override
  State<_TitleRadio> createState() => _TitleRadioState();
}

class _TitleRadioState extends State<_TitleRadio> {
  @override
  Widget build(BuildContext context) {
    final selected = widget.controller.text == widget.value;
    return GestureDetector(
      onTap: () => setState(() => widget.controller.text = widget.value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? widget.theme.primary
                    : widget.theme.text.withOpacity(0.3),
                width: 2,
              ),
              color: selected
                  ? widget.theme.primary
                  : Colors.transparent,
            ),
            child: selected
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            widget.value,
            style: TextStyle(
              color: widget.theme.text.withOpacity(0.75),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
