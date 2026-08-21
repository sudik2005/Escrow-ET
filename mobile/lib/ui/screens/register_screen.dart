import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import 'fayda_scan_screen.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  void _openScan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FaydaScanScreen(mode: FaydaScanMode.register),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  'Scan the back of your Fayda ID. We fill name, gender, and Fayda number from the card.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: dark
                            ? AppColors.darkMuted
                            : AppColors.lightMuted,
                      ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: auth.busy ? null : () => _openScan(context),
                    icon: const Icon(Icons.badge_outlined, size: 20),
                    label: Text(
                      'SCAN FAYDA ID',
                      style: GoogleFonts.geist(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Requires a physical V4 Fayda card. Not affiliated with NIDP.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dark
                            ? AppColors.darkMuted
                            : AppColors.lightMuted,
                      ),
                ),
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
