import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/icon_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends ConsumerState<RegisterScreen> {
  final _username = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _hidePassword = true;
  var _role = 'BUYER';
  String? _localError;

  @override
  void dispose() {
    _username.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _username.text.trim();
    final phone = _phone.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    if (username.isEmpty || phone.isEmpty || password.isEmpty) {
      setState(() =>
          _localError = 'Username, phone, and password are required.');
      return;
    }
    setState(() => _localError = null);
    await ref.read(authControllerProvider.notifier).register(
          username: username,
          password: password,
          phoneNumber: phone,
          role: _role,
          email: email,
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
              padding:
                  const EdgeInsets.fromLTRB(28, 60, 28, 40),
              children: [
                // ── Brand header ───────────────────────
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // ── Title ──────────────────────────────
                Text(
                  'Create account',
                  style: GoogleFonts.geist(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color:
                        Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join Escrow ET as a buyer or seller.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color: dark
                            ? AppColors.darkMuted
                            : AppColors.lightMuted,
                      ),
                ),
                const SizedBox(height: 32),

                // ── Role selector ──────────────────────
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
                      onTap: () =>
                          setState(() => _role = 'BUYER'),
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _RoleChip(
                      label: 'SELLER',
                      selected: _role == 'SELLER',
                      onTap: () =>
                          setState(() => _role = 'SELLER'),
                    )),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Fields ─────────────────────────────
                AutofillGroup(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      IconField(
                        controller: _username,
                        icon: Icons.person_outline,
                        hint: 'Username',
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.username
                        ],
                      ),
                      const SizedBox(height: 14),
                      IconField(
                        controller: _phone,
                        icon: Icons.phone_outlined,
                        hint: '+2519...',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.telephoneNumber
                        ],
                      ),
                      const SizedBox(height: 14),
                      IconField(
                        controller: _email,
                        icon: Icons.mail_outline,
                        hint: 'Email (optional)',
                        keyboardType:
                            TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.email
                        ],
                      ),
                      const SizedBox(height: 14),
                      IconField(
                        controller: _password,
                        icon: Icons.lock_outline,
                        hint: 'Password',
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [
                          AutofillHints.newPassword
                        ],
                        onSubmitted: (_) => _submit(),
                        suffix: IconButton(
                          onPressed: () => setState(() =>
                              _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                        ),
                      ),

                      // ── Error ─────────────────────────
                      if (error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          error,
                          style: const TextStyle(
                            color: AppColors.crimson,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // ── Register ──────────────────────
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed:
                              auth.busy ? null : _submit,
                          child: auth.busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.snow),
                                )
                              : Text(
                                  'CREATE ACCOUNT',
                                  style: GoogleFonts.geist(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Divider ───────────────────────
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                            child: Text(
                              'OR',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      letterSpacing: 1.6),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── FAYDA placeholder ─────────────
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.badge_outlined,
                              size: 19),
                          label: Text(
                            'SIGN UP WITH FAYDA',
                            style: GoogleFonts.geist(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.crimson
                                .withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(4),
                          ),
                          child: Text(
                            'COMING SOON',
                            style: GoogleFonts.geist(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.crimson,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Back to login ─────────────────
                      Center(
                        child: GestureDetector(
                          onTap: auth.busy
                              ? null
                              : () =>
                                  Navigator.of(context).pop(),
                          child: Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
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
              : (dark
                  ? AppColors.darkSurface
                  : AppColors.snow),
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
