import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/icon_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialUsername});

  final String? initialUsername;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _username = TextEditingController();
  var _loading = false;
  var _sent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialUsername != null && widget.initialUsername!.isNotEmpty) {
      _username.text = widget.initialUsername!;
    }
  }

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _username.text.trim();
    if (username.isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(authApiProvider);
      await api.requestPasswordReset(username: username);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _sent = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not send the request. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              children: [
                // ── Back + Title ─────────────────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      'Reset password',
                      style: GoogleFonts.geist(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (_sent) ...[
                  // ── Success state ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.mark_email_read_outlined,
                          color: Color(0xFF2E7D32),
                          size: 48,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Request sent',
                          style: GoogleFonts.geist(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'If an account for "${_username.text.trim()}" exists, '
                          'you will receive instructions to reset your password.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF388E3C),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'BACK TO SIGN IN',
                        style: GoogleFonts.geist(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // ── Form ──────────────────────────────────────────────────
                  Text(
                    'Enter the name you used when creating your account. '
                    'We will send you instructions to reset your password.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                  ),
                  const SizedBox(height: 28),
                  IconField(
                    controller: _username,
                    icon: Icons.person_outline,
                    hint: 'Your name',
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.username],
                    onSubmitted: (_) {
                      if (!_loading) _submit();
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.crimson,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.snow,
                              ),
                            )
                          : Text(
                              'SEND RESET REQUEST',
                              style: GoogleFonts.geist(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
