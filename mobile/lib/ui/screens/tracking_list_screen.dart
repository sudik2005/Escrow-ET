import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/escrow_contract.dart';
import '../../state/escrow_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/accent_card.dart';
import '../widgets/app_header.dart';
import '../widgets/list_error.dart';
import '../widgets/status_chip.dart';
import 'tracking_detail_screen.dart';

class TrackingListScreen extends ConsumerWidget {
  const TrackingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(escrowListProvider);

    return Column(
      children: [
        const AppHeader(title: 'Tracking'),
        Expanded(
          child: list.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => ListError(
              message: e.toString(),
              onRetry: () => ref.invalidate(escrowListProvider),
            ),
            data: (contracts) {
              if (contracts.isEmpty) {
                return _EmptyState();
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(escrowListProvider);
                  await ref.read(escrowListProvider.future);
                },
                child: ListView.separated(
                  padding:
                      const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  itemCount: contracts.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      _TrackRow(contract: contracts[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.contract});
  final EscrowContract contract;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return AccentCard(
      stripe: contract.isFunded || contract.isInTransit,
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
              Icons.swap_horiz_rounded,
              size: 20,
              color: (contract.isFunded || contract.isInTransit)
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 56,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No active transactions',
              style: GoogleFonts.geist(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your escrow contracts will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
