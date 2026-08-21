import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/escrow_contract.dart';
import '../../theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.contract});

  final EscrowContract contract;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final (fg, bg) = _colors(context, dark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        _label,
        style: GoogleFonts.geist(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: fg,
        ),
      ),
    );
  }

  String get _label => switch (contract.status) {
        'PENDING_PAYMENT' => 'PENDING',
        'FUNDED' => 'FUNDED',
        'IN_TRANSIT' => 'IN TRANSIT',
        'COMPLETED' => 'COMPLETED',
        'DISPUTED' => 'DISPUTED',
        'CANCELLED' => 'CANCELLED',
        _ => contract.status,
      };

  (Color, Color) _colors(BuildContext context, bool dark) {
    final crimson = AppColors.crimson;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;
    final surface = dark ? AppColors.darkContainerHigh : AppColors.lightContainer;

    return switch (contract.status) {
      'PENDING_PAYMENT' => (muted, surface),
      'FUNDED' => (crimson, crimson.withValues(alpha: 0.12)),
      'IN_TRANSIT' => (crimson, crimson.withValues(alpha: 0.12)),
      'COMPLETED' => (
          dark ? AppColors.darkTextH : AppColors.lightTextH,
          surface,
        ),
      'DISPUTED' => (crimson, crimson.withValues(alpha: 0.18)),
      'CANCELLED' => (muted, surface),
      _ => (muted, surface),
    };
  }
}
