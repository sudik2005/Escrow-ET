import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/escrow_contract.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/accent_card.dart';
import '../widgets/app_header.dart';
import '../widgets/list_error.dart';
import '../widgets/status_chip.dart';
import 'checkout_screen.dart';
import 'new_payment_screen.dart';
import 'tracking_detail_screen.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.watch(authControllerProvider).session?.user;
    final seller = user?.isSeller ?? false;
    final list = ref.watch(escrowListProvider);

    return Column(
      children: [
        const AppHeader(title: 'Payments'),
        Expanded(
          child: list.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => ListError(
              message: e.toString(),
              onRetry: () => ref.invalidate(escrowListProvider),
            ),
            data: (contracts) {
              final phone = user?.phoneNumber ?? '';
              final mine = seller
                  ? contracts.where((c) => c.isSaleFor(phone)).toList()
                  : contracts.where((c) => c.isPurchaseFor(phone)).toList();
              final pending = mine
                  .where((c) => c.isPendingPayment)
                  .toList();
              final others = mine
                  .where((c) => !c.isPendingPayment)
                  .toList();

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(escrowListProvider);
                  await ref.read(escrowListProvider.future);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      24, 8, 24, 40),
                  children: [
                    // ── Seller: create link entry ──────
                    if (seller) ...[
                      _CreateLinkCard(
                        onTap: () async {
                          final created =
                              await Navigator.of(context)
                                  .push<bool>(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NewPaymentScreen(),
                            ),
                          );
                          if (created == true) {
                            ref.invalidate(escrowListProvider);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Pending payments section ───────
                    _SectionHeader(
                      title: seller
                          ? 'Awaiting Payment'
                          : 'To Pay',
                    ),
                    const SizedBox(height: 12),
                    if (pending.isEmpty)
                      AccentCard(
                        child: Text(
                          seller
                              ? 'Buyers will show here once they receive a link.'
                              : 'When a seller creates an escrow for you, it appears here.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.5),
                        ),
                      )
                    else
                      for (final c in pending) ...[
                        _PaymentRow(
                          contract: c,
                          onTap: () => Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (_) => seller
                                  ? TrackingDetailScreen(
                                      contract: c)
                                  : CheckoutScreen(
                                      contract: c),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                    // ── Active / completed section ─────
                    if (others.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionHeader(title: 'All Transactions'),
                      const SizedBox(height: 12),
                      for (final c in others) ...[
                        _PaymentRow(
                          contract: c,
                          onTap: () => Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  TrackingDetailScreen(
                                      contract: c),
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
    );
  }
}

// ── Create link entry card ─────────────────────────────────────────────────────
class _CreateLinkCard extends StatelessWidget {
  const _CreateLinkCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkSurface : AppColors.snow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.crimson.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.link,
                  color: AppColors.crimson, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Payment Link',
                    style: GoogleFonts.geist(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Create a secure escrow for a buyer.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Payment row ───────────────────────────────────────────────────────────────
class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.contract, required this.onTap});
  final EscrowContract contract;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return AccentCard(
      stripe: contract.isPendingPayment,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: dark
                  ? AppColors.darkContainerHigh
                  : AppColors.lightContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 20,
              color: contract.isPendingPayment
                  ? AppColors.crimson
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contract.itemName,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${contract.amount} ${contract.currency}',
                  style:
                      Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          StatusChip(contract: contract),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.geist(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
