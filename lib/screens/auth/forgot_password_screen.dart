/*import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/auth_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Dismiss keyboard to stop any keyboard-triggered scroll before async work
    FocusScope.of(context).unfocus();
    // Wait one frame for the keyboard-dismiss scroll to settle
    await Future.delayed(Duration.zero);

    if (!mounted) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordReset(_emailCtrl.text.trim());

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _sent = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.text),
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: _sent ? _buildSuccessView(theme) : _buildForm(theme),
        ),
      ),
    );
  }

  Widget _buildForm(AppTheme theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.lock_reset_rounded, color: theme.primary, size: 32),
          ),
          const SizedBox(height: 24),
          Text('auth.forgot_password_title'.tr(),
              style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: theme.text)),
          const SizedBox(height: 10),
          Text('auth.forgot_password_subtitle'.tr(),
              style: TextStyle(fontSize: 14, color: theme.text.withValues(alpha: 0.6))),
          const SizedBox(height: 36),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: theme.text),
            decoration: InputDecoration(
              labelText: 'auth.email'.tr(),
              labelStyle: TextStyle(color: theme.text.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.email_outlined, color: theme.text.withValues(alpha: 0.4)),
              filled: true,
              fillColor: theme.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: theme.primary, width: 1.5)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.redAccent)),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'auth.email_required'.tr();
              if (!v.contains('@')) return 'auth.email_invalid'.tr();
              return null;
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text('auth.send_link'.tr(),
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(AppTheme theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 44),
        ),
        const SizedBox(height: 24),
        Text('auth.email_sent'.tr(),
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w800, color: theme.text)),
        const SizedBox(height: 12),
        Text(
          '${'auth.reset_link_sent'.tr()}\n${_emailCtrl.text.trim()}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: theme.text.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 36),
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text('auth.back_to_login'.tr(),
              style: TextStyle(color: theme.primary, fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ],
    );
  }
}
*/