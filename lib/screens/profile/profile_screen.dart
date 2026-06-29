/*import 'dart:ui';
import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/user_reservation.dart';
import 'package:BookiTrip/providers/auth_provider.dart';
import 'package:BookiTrip/providers/reservation_history_provider.dart';
import 'package:BookiTrip/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  dynamic _cachedUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReservationHistoryProvider>().fetchReservations();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final auth = context.watch<AuthProvider>();
    
    if (auth.currentUser != null) {
      _cachedUser = auth.currentUser;
    }
    
    final user = _cachedUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return Scaffold(
        backgroundColor: theme.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: theme.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => context.go('/home'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Premium Background Image
                  Image.network(
                    'https://images.unsplash.com/photo-1539020140153-e479b8c22e70?q=80&w=1000&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                  // Smooth Gradient Overlay blending into the background color
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          theme.background.withValues(alpha: 0.8),
                          theme.background,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // User Information
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Avatar with glowing ring
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.background,
                            boxShadow: [
                              BoxShadow(
                                color: theme.primary.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: theme.primary.withValues(alpha: 0.1),
                            backgroundImage: user.photo != null && user.photo!.isNotEmpty
                                ? NetworkImage(user.photo!)
                                : null,
                            child: user.photo == null || user.photo!.isEmpty
                                ? Text(
                                    user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : '?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: theme.primary,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${user.prenom} ${user.name}',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: theme.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.email,
                            style: TextStyle(
                              color: theme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Custom Tab Selector
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 74.0,
              maxHeight: 74.0,
              child: Container(
                color: theme.background,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: theme.text.withValues(alpha: 0.5),
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Mon Profil'),
                      Tab(text: 'Mes Voyages'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ProfileTab(theme: theme, user: user),
            _ReservationsTab(theme: theme),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

// ── Profile Tab ────────────────────────────────────────────────────────────────

class _ProfileTab extends StatefulWidget {
  final AppTheme theme;
  final dynamic user;

  const _ProfileTab({required this.theme, required this.user});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  
  late TextEditingController _prenomCtrl;
  late TextEditingController _nomCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _cityCtrl;
  
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _prenomCtrl = TextEditingController(text: widget.user.prenom);
    _nomCtrl = TextEditingController(text: widget.user.name);
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _cityCtrl = TextEditingController(text: widget.user.city ?? '');
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    final provider = context.read<UserProvider>();
    final success = await provider.updateProfile(
      name: _nomCtrl.text.trim(),
      prenom: _prenomCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Profil mis à jour avec succès !' : (provider.errorMessage ?? 'Erreur')),
        backgroundColor: success ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();
    
    final provider = context.read<UserProvider>();
    final success = await provider.changePassword(
      _newPasswordCtrl.text,
      _confirmPasswordCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Mot de passe modifié !' : (provider.errorMessage ?? 'Erreur')),
        backgroundColor: success ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final userProvider = context.watch<UserProvider>();
    final auth = context.watch<AuthProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information Section
          _buildSectionCard(
            theme: theme,
            title: 'Informations Personnelles',
            icon: Icons.person_outline_rounded,
            child: Form(
              key: _profileFormKey,
              child: Column(
                children: [
                  Row(children: [
                    Expanded(child: _inputField(_prenomCtrl, 'Prénom', theme, icon: Icons.badge_outlined)),
                    const SizedBox(width: 16),
                    Expanded(child: _inputField(_nomCtrl, 'Nom', theme, icon: Icons.badge_outlined)),
                  ]),
                  const SizedBox(height: 16),
                  _inputField(_phoneCtrl, 'Téléphone', theme, type: TextInputType.phone, icon: Icons.phone_outlined, required: false),
                  const SizedBox(height: 16),
                  _inputField(_cityCtrl, 'Ville', theme, icon: Icons.location_city_outlined, required: false),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: userProvider.isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: userProvider.isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text('Sauvegarder les modifications', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),

          // Security Section
          _buildSectionCard(
            theme: theme,
            title: 'Sécurité & Mot de passe',
            icon: Icons.security_rounded,
            child: Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  _inputField(
                    _newPasswordCtrl, 'Nouveau mot de passe', theme,
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscureNew,
                    toggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      if (v.length < 6) return 'Au moins 6 caractères';
                      return null;
                    }
                  ),
                  const SizedBox(height: 16),
                  _inputField(
                    _confirmPasswordCtrl, 'Confirmer le mot de passe', theme,
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscureConfirm,
                    toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (v) {
                      if (v != _newPasswordCtrl.text) return 'Les mots de passe ne correspondent pas';
                      return null;
                    }
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: userProvider.isLoading ? null : _changePassword,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primary,
                        side: BorderSide(color: theme.primary.withValues(alpha: 0.5), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Mettre à jour le mot de passe', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                await auth.logout();
                if (context.mounted) context.go('/home');
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: Text('Se déconnecter', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 16)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required AppTheme theme,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: theme.isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: theme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: theme.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _inputField(
    TextEditingController ctrl, String label, AppTheme theme, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    VoidCallback? toggleObscure,
    bool required = true,
    String? Function(String?)? validator,
    IconData? icon,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      style: TextStyle(color: theme.text, fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.text.withValues(alpha: 0.5), fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: theme.text.withValues(alpha: 0.4), size: 20) : null,
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: theme.text.withValues(alpha: 0.4), size: 19),
                onPressed: toggleObscure)
            : null,
        filled: true,
        fillColor: theme.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: theme.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent)),
      ),
      validator: validator ?? (v) => (required && (v == null || v.trim().isEmpty)) ? 'Requis' : null,
    );
  }
}

// ── Reservations Tab ───────────────────────────────────────────────────────────

class _ReservationsTab extends StatelessWidget {
  final AppTheme theme;
  const _ReservationsTab({required this.theme});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationHistoryProvider>();

    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.primary));
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: theme.text.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(provider.error!, style: TextStyle(color: theme.text.withValues(alpha: 0.6))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.fetchReservations(),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              label: const Text('Réessayer', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    if (provider.reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primary.withValues(alpha: 0.05),
              ),
              child: Icon(Icons.flight_takeoff_rounded, size: 64, color: theme.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            Text('Aucun voyage prévu', style: GoogleFonts.poppins(color: theme.text, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Vos réservations et aventures apparaîtront ici.',
                style: TextStyle(color: theme.text.withValues(alpha: 0.5), fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Explorer les offres', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: provider.reservations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) => _ReservationTicket(reservation: provider.reservations[i], theme: theme),
    );
  }
}

class _ReservationTicket extends StatelessWidget {
  final UserReservation reservation;
  final AppTheme theme;

  const _ReservationTicket({required this.reservation, required this.theme});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'fr_FR');

    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;
    
    switch (reservation.status.toLowerCase()) {
      case 'confirmed': 
        statusColor = Colors.green; 
        statusBgColor = Colors.green.withValues(alpha: 0.1);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'cancelled': 
        statusColor = Colors.redAccent; 
        statusBgColor = Colors.redAccent.withValues(alpha: 0.1);
        statusIcon = Icons.cancel_rounded;
        break;
      default: 
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.withValues(alpha: 0.1);
        statusIcon = Icons.hourglass_top_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: theme.isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header Section (Hotel Name & Status)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.hotel_rounded, color: theme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.hotelName ?? 'Hôtel',
                        style: GoogleFonts.poppins(color: theme.text, fontWeight: FontWeight.w700, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, color: statusColor, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              reservation.statusLabel,
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Ticket Dashed Divider
          Row(
            children: [
              SizedBox(
                height: 20,
                width: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final dashCount = (constraints.constrainWidth() / 10).floor();
                    return Flex(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      direction: Axis.horizontal,
                      children: List.generate(dashCount, (_) {
                        return SizedBox(
                          width: 5,
                          height: 1.5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: theme.text.withValues(alpha: 0.15)),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 20,
                width: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                  ),
                ),
              ),
            ],
          ),

          // Footer Section (Dates & Price)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (reservation.startAt != null && reservation.endAt != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dates du séjour', style: TextStyle(color: theme.text.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 16, color: theme.text.withValues(alpha: 0.7)),
                          const SizedBox(width: 6),
                          Text(
                            '${fmt.format(reservation.startAt!)} → ${fmt.format(reservation.endAt!)}',
                            style: TextStyle(color: theme.text, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total', style: TextStyle(color: theme.text.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      '${reservation.total.toStringAsFixed(0)} TND',
                      style: GoogleFonts.poppins(color: theme.primary, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/