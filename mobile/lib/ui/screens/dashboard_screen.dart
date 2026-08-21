import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/escrow_contract.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/accent_card.dart';
import '../widgets/app_header.dart';
import '../widgets/status_chip.dart';
import 'tracking_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).session?.user;
    final list = ref.watch(escrowListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppHeader(title: 'Dashboard'),
        Expanded(
          child: list.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorView(
              text: e.toString(),
              onRetry: () => ref.invalidate(escrowListProvider),
            ),
            data: (contracts) {
              final available =
                  double.tryParse(user?.balance ?? '0') ?? 0;
              final locked = contracts
                  .where((c) => c.isFunded || c.isInTransit)
                  .fold<double>(0, (s, c) => s + c.amountValue);
              final released = contracts
                  .where((c) => c.status == 'COMPLETED')
                  .fold<double>(0, (s, c) => s + c.amountValue);
              final recent = contracts.take(6).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(authControllerProvider.notifier)
                      .refreshUser();
                  ref.invalidate(escrowListProvider);
                  await ref.read(escrowListProvider.future);
                },
                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    // ── Stat cards ───────────────────────
                    _StatCard(
                      label: 'AVAILABLE',
                      icon: Icons.account_balance_wallet_outlined,
                      amount: available,
                      subtitle: 'Your balance',
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      label: 'LOCKED ESCROW',
                      icon: Icons.lock_outline,
                      amount: locked,
                      subtitle: 'Pending buyer release',
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      label: 'TOTAL RELEASED',
                      icon: Icons.check_circle_outline,
                      amount: released,
                      subtitle: 'All time',
                    ),
                    const SizedBox(height: 20),

                    // ── Withdraw CTA ─────────────────────
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Withdrawals coming soon.'),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.crimson,
                          foregroundColor: AppColors.snow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.download, size: 18),
                        label: Text(
                          'WITHDRAW FUNDS',
                          style: GoogleFonts.geist(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Recent Activity ──────────────────
                    Row(
                      children: [
                        Text(
                          'Recent Activity',
                          style: GoogleFonts.geist(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => ref
                              .read(shellTabProvider.notifier)
                              .state = 2,
                          child: Text(
                            'VIEW ALL',
                            style: GoogleFonts.geist(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.crimson,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (recent.isEmpty)
                      AccentCard(
                        child: Text(
                          'No transactions yet. Start by creating or accepting an escrow.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.5),
                        ),
                      )
                    else
                      for (final c in recent) ...[
                        _ActivityRow(contract: c),
                        const SizedBox(height: 8),
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

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.icon,
    required this.amount,
    required this.subtitle,
  });

  final String label;
  final IconData icon;
  final double amount;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.snow,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
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
              const Spacer(),
              Icon(
                icon,
                size: 18,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: amount.toStringAsFixed(2),
                  style: GoogleFonts.geist(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: ' ETB',
                  style: GoogleFonts.geist(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark
                      ? AppColors.darkMuted
                      : AppColors.lightMuted,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Activity row ──────────────────────────────────────────────────────────────
class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.contract});
  final EscrowContract contract;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final isAlert = contract.status == 'DISPUTED';

    return AccentCard(
      alert: isAlert,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TrackingDetailScreen(contract: contract),
        ),
      ),
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
              isAlert
                  ? Icons.warning_amber_rounded
                  : Icons.account_balance_wallet_outlined,
              size: 20,
              color: isAlert
                  ? AppColors.crimson
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 12),
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
                  '${contract.amount} ${contract.currency}',
                  style: Theme.of(context).textTheme.bodySmall,
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.text, required this.onRetry});
  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AccentCard(
          alert: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: const Text('TRY AGAIN'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
