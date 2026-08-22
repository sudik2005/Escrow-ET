import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/icon_field.dart';
import 'fayda_scan_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  var _hidePassword = true;
  String? _localError;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submitPassword() async {
    final username = _username.text.trim();
    final password = _password.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _localError = 'Name and password are required.');
      return;
    }
    setState(() => _localError = null);
    await ref.read(authControllerProvider.notifier).login(
          username: username,
          password: password,
        );
  }

  Future<void> _openFaydaScan() async {
    setState(() => _localError = null);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const FaydaScanScreen(mode: FaydaScanMode.login),
      ),
    );
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
    );
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ForgotPasswordScreen(
          initialUsername: _username.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final dark = AppColors.isDark(context);
    final error = auth.error ?? _localError;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 60, 28, 40),
              children: [
                // ── Brand mark ───────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.crimson,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.hexagon_outlined,
                          color: AppColors.snow, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Escrow ET',
                      style: GoogleFonts.geist(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // ── Heading ──────────────────────────────────────────────────
                Text(
                  'Welcome back',
                  style: GoogleFonts.geist(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter your name and password to sign in.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: dark
                            ? AppColors.darkMuted
                            : AppColors.lightMuted,
                      ),
                ),
                const SizedBox(height: 32),

                // ── Name ─────────────────────────────────────────────────────
                IconField(
                  controller: _username,
                  icon: Icons.person_outline,
                  hint: 'Your name',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                ),
                const SizedBox(height: 14),

                // ── Password ─────────────────────────────────────────────────
                IconField(
                  controller: _password,
                  icon: Icons.lock_outline,
                  hint: 'Password',
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) {
                    if (!auth.busy) _submitPassword();
                  },
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                  ),
                ),

                // ── Forgot password ──────────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: auth.busy ? null : _openForgotPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.geist(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.crimson,
                      ),
                    ),
                  ),
                ),

                // ── Error ────────────────────────────────────────────────────
                if (error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    error,
                    style: const TextStyle(
                      color: AppColors.crimson,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // ── Sign in button ───────────────────────────────────────────
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: auth.busy ? null : _submitPassword,
                    child: auth.busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.snow,
                            ),
                          )
                        : Text(
                            'SIGN IN',
                            style: GoogleFonts.geist(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                  ),
                ),

                // ── Divider ──────────────────────────────────────────────────
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: dark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Fayda scan option ─────────────────────────────────────────
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: auth.busy ? null : _openFaydaScan,
                    icon: const Icon(Icons.badge_outlined, size: 18),
                    label: Text(
                      'SIGN IN WITH FAYDA ID',
                      style: GoogleFonts.geist(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                // ── Create account link ──────────────────────────────────────
                const SizedBox(height: 36),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodySmall,
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: auth.busy ? null : _openRegister,
                            child: Text(
                              'Create account',
                              style: GoogleFonts.geist(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.crimson,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
