import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../fayda/fayda_decoder.dart';
import '../../models/registration_data.dart';
import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';

class FaydaConfirmScreen extends ConsumerWidget {
  const FaydaConfirmScreen({
    super.key,
    required this.fayda,
    this.registrationData,
  });

  final FaydaSuccess fayda;

  /// Carries user-entered fields from RegisterScreen.
  /// Null when this screen is reached from a legacy call site.
  final RegistrationData? registrationData;

  Uint8List? _faceBytes() {
    final face = fayda.faceBytes;
    if (face == null || face.isEmpty) return null;
    return face is Uint8List ? face : Uint8List.fromList(face);
  }

  String _maskedFan(String fan) {
    if (fan.length <= 4) return fan;
    return '${'•' * (fan.length - 4)}${fan.substring(fan.length - 4)}';
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final reg = registrationData;
    if (reg == null) return;
    await ref.read(authControllerProvider.notifier).registerWithFayda(
          rawPayload: fayda.rawPayload,
          phoneNumber: reg.phoneNumber,
          role: reg.role,
          password: reg.password,
          username: reg.username,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final dark = AppColors.isDark(context);
    final face = _faceBytes();
    final rawFan = fayda.fan ?? '';
    final reg = registrationData;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              children: [
                // ── Header ───────────────────────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      onPressed: auth.busy
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      'Confirm identity',
                      style: GoogleFonts.geist(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── KYC card (from Fayda) ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.darkSurface : AppColors.snow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Profile photo from card
                      if (face != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(44),
                          child: Image.memory(
                            face,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.crimson,
                            borderRadius: BorderRadius.circular(44),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: AppColors.snow,
                            size: 40,
                          ),
                        ),
                      const SizedBox(height: 14),
                      _InfoRow(label: 'Full name', value: fayda.fullName),
                      _InfoRow(label: 'Gender', value: fayda.genderLabel),
                      if (rawFan.isNotEmpty)
                        _InfoRow(
                          label: 'Fayda number',
                          value: _maskedFan(rawFan),
                          mono: true,
                        ),
                    ],
                  ),
                ),

                // ── KYC verified badge ───────────────────────────────────────
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF2E7D32),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'KYC Verified',
                      style: GoogleFonts.geist(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Identity confirmed from your Fayda card.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark
                            ? AppColors.darkMuted
                            : AppColors.lightMuted,
                      ),
                ),

                // ── Account summary (user-entered fields) ────────────────────
                if (reg != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'ACCOUNT DETAILS',
                    style: GoogleFonts.geist(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: dark
                          ? AppColors.darkSurface
                          : AppColors.lightContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Username', value: reg.username),
                        _InfoRow(label: 'Phone', value: reg.phoneNumber),
                        _InfoRow(label: 'Role', value: reg.role),
                      ],
                    ),
                  ),
                ],

                // ── Error ────────────────────────────────────────────────────
                if (auth.error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    auth.error!,
                    style: const TextStyle(
                      color: AppColors.crimson,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],

                // ── Submit ───────────────────────────────────────────────────
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed:
                        (auth.busy || reg == null) ? null : () => _submit(context, ref),
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
                            'CREATE ACCOUNT',
                            style: GoogleFonts.geist(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
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

// ── Supporting widget ────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: mono ? 'monospace' : null,
                    letterSpacing: mono ? 1.0 : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
