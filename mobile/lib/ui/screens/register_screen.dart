import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/phone.dart';
import '../../models/registration_data.dart';
import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/icon_field.dart';
import 'fayda_scan_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _username = TextEditingController();
  final _phone = TextEditingController(text: '+2519');
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  var _role = 'BUYER';
  var _hidePassword = true;
  var _hideConfirm = true;
  String? _localError;

  @override
  void dispose() {
    _username.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _openFaydaScan() {
    final username = _username.text.trim();
    final phone = _phone.text.trim();
    final password = _password.text;
    final confirm = _confirmPassword.text;

    if (username.isEmpty) {
      setState(() => _localError = 'Username is required.');
      return;
    }
    if (phone.isEmpty || phone == '+2519') {
      setState(() => _localError = 'Phone number is required.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _localError = 'Password is required.');
      return;
    }
    if (password.length < 8) {
      setState(() => _localError = 'Password must be at least 8 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _localError = 'Passwords do not match.');
      return;
    }

    setState(() => _localError = null);

    final regData = RegistrationData(
      username: username,
      phoneNumber: normalizeEtPhone(phone),
      password: password,
      role: _role,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FaydaScanScreen(
          mode: FaydaScanMode.register,
          registrationData: regData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final dark = AppColors.isDark(context);

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
                  'Create account',
                  style: GoogleFonts.geist(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fill in your details, then scan your Fayda ID to verify your identity.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: dark
                            ? AppColors.darkMuted
                            : AppColors.lightMuted,
                      ),
                ),
                const SizedBox(height: 32),

                // ── Username ─────────────────────────────────────────────────
                IconField(
                  controller: _username,
                  icon: Icons.person_outline,
                  hint: 'Username',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                ),
                const SizedBox(height: 14),

                // ── Phone ────────────────────────────────────────────────────
                IconField(
                  controller: _phone,
                  icon: Icons.phone_outlined,
                  hint: '+2519...',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                ),
                const SizedBox(height: 14),

                // ── Role picker ──────────────────────────────────────────────
                Text(
                  'I AM A',
                  style: GoogleFonts.geist(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _RoleChip(
                        label: 'BUYER',
                        selected: _role == 'BUYER',
                        onTap: () => setState(() => _role = 'BUYER'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleChip(
                        label: 'SELLER',
                        selected: _role == 'SELLER',
                        onTap: () => setState(() => _role = 'SELLER'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Password ─────────────────────────────────────────────────
                IconField(
                  controller: _password,
                  icon: Icons.lock_outline,
                  hint: 'Password',
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
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
                const SizedBox(height: 14),

                // ── Confirm password ─────────────────────────────────────────
                IconField(
                  controller: _confirmPassword,
                  icon: Icons.lock_outline,
                  hint: 'Confirm password',
                  obscureText: _hideConfirm,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) {
                    if (!auth.busy) _openFaydaScan();
                  },
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _hideConfirm = !_hideConfirm),
                    icon: Icon(
                      _hideConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                  ),
                ),

                // ── Error ────────────────────────────────────────────────────
                if (_localError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _localError!,
                    style: const TextStyle(
                      color: AppColors.crimson,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // ── Fayda verify button ──────────────────────────────────────
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: auth.busy ? null : _openFaydaScan,
                    icon: const Icon(Icons.badge_outlined, size: 20),
                    label: Text(
                      'VERIFY WITH FAYDA ID',
                      style: GoogleFonts.geist(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your Fayda ID is used for identity verification only. Requires a physical V4 Fayda card.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark
                            ? AppColors.darkMuted
                            : AppColors.lightMuted,
                      ),
                ),

                // ── Sign in link ─────────────────────────────────────────────
                const SizedBox(height: 36),
                Center(
                  child: GestureDetector(
                    onTap: auth.busy ? null : () => Navigator.of(context).pop(),
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: GoogleFonts.geist(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.crimson,
                            ),
                          ),
                        ],
                      ),
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

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 46,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.crimson
              : (dark ? AppColors.darkSurface : AppColors.snow),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.crimson
                : Theme.of(context).colorScheme.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.geist(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: selected
                  ? AppColors.snow
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
