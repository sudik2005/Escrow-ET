import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../widgets/accent_card.dart';
import '../widgets/app_controls.dart';
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
    final seller = ref.watch(authControllerProvider).session?.user.isSeller ?? false;
    final list = ref.watch(escrowListProvider);

    return Column(
      children: [
        const AppHeader(title: 'Payments'),
        Expanded(
          child: list.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ListError(
              message: error.toString(),
              onRetry: () => ref.invalidate(escrowListProvider),
            ),
            data: (contracts) {
              final pending = contracts.where((c) => c.isPendingPayment).toList();
              final others = contracts.where((c) => !c.isPendingPayment).toList();
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(escrowListProvider);
                  await ref.read(escrowListProvider.future);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    if (seller) ...[
                      AppButton(
                        label: 'NEW PAYMENT LINK',
                        onPressed: () async {
                          final created = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(builder: (_) => const NewPaymentScreen()),
                          );
                          if (created == true) {
                            ref.invalidate(escrowListProvider);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      seller ? 'Awaiting payment' : 'To pay',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (pending.isEmpty)
                      AccentCard(
                        child: Text(
                          seller
                              ? 'Create a payment link with the buyer’s phone number.'
                              : 'When a seller creates an escrow with your phone, it shows up here to pay.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      )
                    else
                      for (final contract in pending) ...[
                        AccentCard(
                          stripe: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => seller
                                    ? TrackingDetailScreen(contract: contract)
                                    : CheckoutScreen(contract: contract),
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
                        ),
                        const SizedBox(height: 8),
                      ],
                    if (others.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Other',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final contract in others.take(8)) ...[
                        AccentCard(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TrackingDetailScreen(contract: contract),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Expanded(child: Text(contract.itemName)),
                              StatusChip(contract: contract),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
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
