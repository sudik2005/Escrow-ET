import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/escrow_controller.dart';
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ListError(
              message: error.toString(),
              onRetry: () => ref.invalidate(escrowListProvider),
            ),
            data: (contracts) {
              if (contracts.isEmpty) {
                return const Center(child: Text('Nothing to track yet.'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(escrowListProvider);
                  await ref.read(escrowListProvider.future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  itemCount: contracts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final contract = contracts[index];
                    return AccentCard(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TrackingDetailScreen(contract: contract),
                          ),
                        );
                      },
                      child: Row(
                        children: [
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
                                const SizedBox(height: 4),
                                Text('${contract.amount} ${contract.currency}'),
                              ],
                            ),
                          ),
                          StatusChip(contract: contract),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
