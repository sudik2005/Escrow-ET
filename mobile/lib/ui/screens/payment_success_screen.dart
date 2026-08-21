import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/escrow_contract.dart';
import '../../theme/app_colors.dart';
import '../widgets/accent_card.dart';
import '../widgets/app_controls.dart';
import '../widgets/app_header.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key, required this.contract});

  final EscrowContract contract;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Payments', showBack: true, showAvatar: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                children: [
                  const SizedBox(height: 32),

                  // ── Success icon ──────────────────────
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.crimson,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.snow,
                        size: 52,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Amount hero ───────────────────────
                  Text(
                    '${contract.amount} ${contract.currency}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.geist(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Payment Confirmed',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: dark ? AppColors.darkMuted : AppColors.lightMuted,
                        ),
                  ),

                  const SizedBox(height: 36),

                  // ── Summary card ──────────────────────
                  AccentCard(
                    stripe: true,
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'REFERENCE',
                          value: contract.id.length >= 8
                              ? '#${contract.id.substring(0, 8).toUpperCase()}'
                              : contract.id,
                        ),
                        Divider(
                          height: 24,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        _SummaryRow(
                          label: 'ITEM',
                          value: contract.itemName,
                        ),
                        Divider(
                          height: 24,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        _SummaryRow(
                          label: 'STATUS',
                          value: contract.statusLabel.toUpperCase(),
                        ),
                        Divider(
                          height: 24,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        _SummaryRow(
                          label: 'SELLER',
                          value: contract.sellerPhone,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  AppButton(
                    label: 'DONE',
                    onPressed: () =>
                        Navigator.of(context).popUntil((route) => route.isFirst),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 0.8,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
