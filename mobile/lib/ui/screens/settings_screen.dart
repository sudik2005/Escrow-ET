import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.watch(authControllerProvider).session?.user;
    final isDark = ref.watch(themeControllerProvider);
    final dark = AppColors.isDark(context);

    return Column(
      children: [
        const AppHeader(title: 'Settings'),
        Expanded(
          child: ListView(
            padding:
                const EdgeInsets.fromLTRB(24, 8, 24, 40),
            children: [
              // ── Account card ───────────────────────
              _SectionLabel('ACCOUNT'),
              const SizedBox(height: 10),
              _InfoCard(
                dark: dark,
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Name',
                      value: user?.displayName ?? '—',
                    ),
                    _Divider(dark: dark),
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Fayda number',
                      value: user?.maskedFaydaNumber ?? '—',
                    ),
                    _Divider(dark: dark),
                    _InfoRow(
                      icon: Icons.wc_outlined,
                      label: 'Gender',
                      value: user?.genderLabel ?? '—',
                    ),
                    _Divider(dark: dark),
                    _InfoRow(
                      icon: Icons.verified_outlined,
                      label: 'KYC',
                      value: user?.kycVerified == true
                          ? 'Verified'
                          : 'Not verified',
                    ),
                    _Divider(dark: dark),
                    _InfoRow(
                      icon: Icons.work_outline,
                      label: 'Role',
                      value: user?.role ?? '—',
                    ),
                    _Divider(dark: dark),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: user?.phoneNumber ?? '—',
                    ),
                    _Divider(dark: dark),
                    _InfoRow(
                      icon: Icons.mail_outline,
                      label: 'Email',
                      value: user?.email.isNotEmpty == true
                          ? user!.email
                          : '—',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Preferences ────────────────────────
              _SectionLabel('PREFERENCES'),
              const SizedBox(height: 10),
              _InfoCard(
                dark: dark,
                child: _ToggleRow(
                  icon: dark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  label: 'Dark Mode',
                  value: isDark,
                  onChanged: (_) => ref
                      .read(themeControllerProvider.notifier)
                      .toggle(),
                ),
              ),

              const SizedBox(height: 24),

              // ── About ──────────────────────────────
              _SectionLabel('ABOUT'),
              const SizedBox(height: 10),
              _InfoCard(
                dark: dark,
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.info_outline,
                      label: 'Version',
                      value: '1.0.0',
                    ),
                    _Divider(dark: dark),
                    _InfoRow(
                      icon: Icons.shield_outlined,
                      label: 'Payment',
                      value: 'Chapa · Escrow secured',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Sign out ───────────────────────────
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => ref
                      .read(authControllerProvider.notifier)
                      .logout(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.crimson,
                    side: const BorderSide(
                        color: AppColors.crimson),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'SIGN OUT',
                    style: GoogleFonts.geist(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.crimson,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.geist(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.45),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.dark, required this.child});
  final bool dark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.snow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).colorScheme.outline),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.45),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.45),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.crimson,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
