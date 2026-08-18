import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final dark = AppColors.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppHeader(title: 'Dashboard'),
        Expanded(
          child: list.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _Message(
              text: error.toString(),
              onRetry: () => ref.invalidate(escrowListProvider),
            ),
            data: (contracts) {
              final locked = contracts
                  .where((c) => c.isFunded || c.isInTransit)
                  .fold<double>(0, (sum, c) => sum + c.amountValue);
              final released = contracts
                  .where((c) => c.status == 'COMPLETED')
                  .fold<double>(0, (sum, c) => sum + c.amountValue);
              final recent = contracts.take(6).toList();
              return RefreshIndicator(
                onRefresh: () async {
                  await ref.read(authControllerProvider.notifier).refreshUser();
                  ref.invalidate(escrowListProvider);
                  await ref.read(escrowListProvider.future);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AccentCard(
                      stripe: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AVAILABLE BALANCE',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${user?.balance ?? '0.00'} ETB',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniStat(
                                  icon: Icons.lock_outline,
                                  label: 'Locked',
                                  value: '${locked.toStringAsFixed(2)} ETB',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _MiniStat(
                                  icon: Icons.check_circle_outline,
                                  label: 'Released',
                                  value: '${released.toStringAsFixed(2)} ETB',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Total Transactions',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Spacer(),
                              Text(
                                '${contracts.length}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (recent.isEmpty)
                      AccentCard(
                        child: Text(
                          'No escrows yet. Sellers create a payment link; buyers see it here.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      )
                    else
                      for (final contract in recent) ...[
                        _ActivityRow(contract: contract, dark: dark),
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkContainerHigh : AppColors.lightContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.contract, required this.dark});

  final EscrowContract contract;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return AccentCard(
      alert: contract.status == 'DISPUTED',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrackingDetailScreen(contract: contract)),
        );
      },
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: dark ? AppColors.darkContainerHigh : AppColors.lightContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              contract.status == 'DISPUTED' ? Icons.warning_amber_rounded : Icons.account_balance_wallet_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contract.itemName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
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

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AccentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text),
              TextButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ],
    );
  }
}
