import 'package:flutter/material.dart';

import '../../models/escrow_contract.dart';
import '../../theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.contract});

  final EscrowContract contract;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final brand = Theme.of(context).colorScheme.primary;
    final Color fg;
    final Color bg;
    if (contract.status == 'DISPUTED') {
      fg = brand;
      bg = brand.withValues(alpha: dark ? 0.2 : 0.1);
    } else if (contract.status == 'COMPLETED') {
      fg = dark ? AppColors.darkMuted : const Color(0xFF2E7D32);
      bg = dark ? AppColors.darkContainerHigh : const Color(0x1A2E7D32);
    } else {
      fg = dark ? AppColors.darkPrimary : AppColors.lightPrimary;
      bg = brand.withValues(alpha: 0.08);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Text(
        contract.statusLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
