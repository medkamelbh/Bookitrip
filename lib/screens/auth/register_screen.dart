/*import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/auth_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prenomCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Clear any stale error from a previous auth attempt when arriving at this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _villeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isNavigating) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth.accept_terms_required'.tr())),
      );
      return;
    }

    // Dismiss keyboard to stop any scroll activity before async work
    FocusScope.of(context).unfocus();
    // Wait one frame for the keyboard-dismiss scroll to settle
    await Future.delayed(Duration.zero);

    if (!mounted || _isNavigating) return;

    final auth = context.read<AuthProvider>();
    auth.clearError();

    final success = await auth.register(
      name: _nomCtrl.text.trim(),
      prenom: _prenomCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      tel: _telCtrl.text.trim(),
      ville: _villeCtrl.text.trim(),
    );

    if (!mounted || _isNavigating) return;
    if (success) {
      _isNavigating = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth.account_created'.tr()), backgroundColor: Colors.green),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.text),
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
        title: Text('auth.register_title'.tr(),
            style: TextStyle(color: theme.text, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (auth.errorMessage != null) ...[
                  _ErrorBanner(message: auth.errorMessage!),
                  const SizedBox(height: 16),
                ],
                Row(children: [
                  Expanded(child: _field(_prenomCtrl, 'auth.first_name'.tr(), Icons.person_outline, theme)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_nomCtrl, 'auth.last_name'.tr(), Icons.person_outline, theme)),
                ]),
                const SizedBox(height: 14),
                _field(_emailCtrl, 'auth.email'.tr(), Icons.email_outlined, theme,
                    type: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'auth.field_required'.tr();
                      if (!v.contains('@')) return 'auth.email_invalid'.tr();
                      return null;
                    }),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _field(_telCtrl, 'auth.phone'.tr(), Icons.phone_outlined, theme, type: TextInputType.phone)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_villeCtrl, 'auth.city'.tr(), Icons.location_city_outlined, theme)),
                ]),
                const SizedBox(height: 14),
                _field(_passwordCtrl, 'auth.password'.tr(), Icons.lock_outline_rounded, theme,
                    obscure: _obscurePassword,
                    toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'auth.field_required'.tr();
                      if (v.length < 6) return 'auth.password_min_length'.tr();
                      return null;
                    }),
                const SizedBox(height: 14),
                _field(_confirmCtrl, 'auth.confirm_password'.tr(), Icons.lock_outline_rounded, theme,
                    obscure: _obscureConfirm,
                    toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (v) {
                      if (v != _passwordCtrl.text) return 'auth.passwords_dont_match'.tr();
                      return null;
                    }),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                  child: Row(children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                      activeColor: theme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Expanded(
                      child: Text('auth.accept_terms'.tr(),
                          style: TextStyle(color: theme.text.withValues(alpha: 0.7), fontSize: 13)),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text('auth.register'.tr(),
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('auth.already_have_account'.tr(),
                      style: TextStyle(color: theme.text.withValues(alpha: 0.6), fontSize: 14)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text('auth.sign_in'.tr(),
                        style: TextStyle(color: theme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ]),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl, String label, IconData icon, AppTheme theme, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      style: TextStyle(color: theme.text, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.text.withValues(alpha: 0.5), fontSize: 13),
        prefixIcon: Icon(icon, color: theme.text.withValues(alpha: 0.4), size: 19),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: theme.text.withValues(alpha: 0.4), size: 19),
                onPressed: toggleObscure)
            : null,
        filled: true,
        fillColor: theme.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: theme.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        errorStyle: const TextStyle(fontSize: 11),
      ),
      validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? 'auth.field_required'.tr() : null,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
      ]),
    );
  }
}
*/