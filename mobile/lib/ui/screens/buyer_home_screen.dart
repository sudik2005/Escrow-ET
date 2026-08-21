import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/escrow_contract.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/status_chip.dart';
import 'checkout_screen.dart';
import 'tracking_detail_screen.dart';

class BuyerHomeScreen extends ConsumerWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = AppColors.isDark(context);
    final asyncContracts = ref.watch(escrowListProvider);
    final user = ref.watch(authControllerProvider).session?.user;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(title: 'My Orders'),
            Expanded(
              child: asyncContracts.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.crimson,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Could not load orders.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref.invalidate(escrowListProvider),
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                ),
                data: (contracts) {
                  if (contracts.isEmpty) {
                    return _EmptyState(dark: dark);
                  }

                  final pending = contracts
                      .where((c) => c.isPendingPayment)
                      .toList();
                  final active = contracts
                      .where((c) => c.isFunded || c.isInTransit)
                      .toList();
                  final done = contracts
                      .where(
                        (c) =>
                            c.status == 'COMPLETED' ||
                            c.status == 'REFUNDED' ||
                            c.status == 'DISPUTED',
                      )
                      .toList();

                  return RefreshIndicator(
                    color: AppColors.crimson,
                    onRefresh: () async => ref.invalidate(escrowListProvider),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      children: [
                        // ── Greeting ────────────────────
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Hello, ${user?.username ?? 'there'}',
                            style: GoogleFonts.geist(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: dark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                          ),
                        ),

                        if (pending.isNotEmpty) ...[
                          _SectionLabel('AWAITING PAYMENT', context),
                          const SizedBox(height: 8),
                          for (final c in pending) ...[
                            _ContractCard(
                              contract: c,
                              dark: dark,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CheckoutScreen(contract: c),
                                ),
                              ),
                              cta: 'PAY NOW',
                              ctaIcon: Icons.payment_outlined,
                            ),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 8),
                        ],

                        if (active.isNotEmpty) ...[
                          _SectionLabel('IN PROGRESS', context),
                          const SizedBox(height: 8),
                          for (final c in active) ...[
                            _ContractCard(
                              contract: c,
                              dark: dark,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TrackingDetailScreen(contract: c),
                                ),
                              ),
                              cta: 'TRACK',
                              ctaIcon: Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 8),
                        ],

                        if (done.isNotEmpty) ...[
                          _SectionLabel('COMPLETED', context),
                          const SizedBox(height: 8),
                          for (final c in done) ...[
                            _ContractCard(
                              contract: c,
                              dark: dark,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TrackingDetailScreen(contract: c),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
Widget _SectionLabel(String text, BuildContext context) {
  return Text(
    text,
    style: GoogleFonts.geist(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
    ),
  );
}

// ── Contract card ─────────────────────────────────────────────────────────────
class _ContractCard extends StatelessWidget {
  const _ContractCard({
    required this.contract,
    required this.dark,
    required this.onTap,
    this.cta,
    this.ctaIcon,
  });

  final EscrowContract contract;
  final bool dark;
  final VoidCallback onTap;
  final String? cta;
  final IconData? ctaIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkSurface : AppColors.snow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: contract.isPendingPayment
                ? AppColors.crimson.withValues(alpha: 0.35)
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: contract.isPendingPayment
                        ? AppColors.crimson.withValues(alpha: 0.12)
                        : (dark
                            ? AppColors.darkContainerHigh
                            : AppColors.lightContainer),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: contract.isPendingPayment
                        ? AppColors.crimson
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contract.itemName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'From ${contract.sellerPhone}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: dark
                                  ? AppColors.darkMuted
                                  : AppColors.lightMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${contract.amount}',
                      style: GoogleFonts.geist(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.crimson,
                      ),
                    ),
                    Text(
                      contract.currency,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: dark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                StatusChip(contract: contract),
                const Spacer(),
                if (cta != null)
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: contract.isPendingPayment
                            ? AppColors.crimson
                            : (dark
                                ? AppColors.darkContainerHigh
                                : AppColors.lightContainer),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ctaIcon != null) ...[
                            Icon(
                              ctaIcon,
                              size: 14,
                              color: contract.isPendingPayment
                                  ? AppColors.snow
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            cta!,
                            style: GoogleFonts.geist(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: contract.isPendingPayment
                                  ? AppColors.snow
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: dark
                    ? AppColors.darkContainerHigh
                    : AppColors.lightContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 32,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No orders yet',
              style: GoogleFonts.geist(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When a seller creates an escrow for you,\nyour orders will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.6,
                    color: dark ? AppColors.darkMuted : AppColors.lightMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
