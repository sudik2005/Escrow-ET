import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/escrow_contract.dart';
import '../../state/escrow_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/list_error.dart';
import 'tracking_detail_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(escrowListProvider);

    return Column(
      children: [
        const AppHeader(title: 'Notifications'),
        Expanded(
          child: list.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ListError(
              message: error.toString(),
              onRetry: () => ref.invalidate(escrowListProvider),
            ),
            data: (contracts) {
              if (contracts.isEmpty) {
                return Center(
                  child: Text(
                    'No alerts yet. Escrow activity will show up here.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(escrowListProvider);
                  await ref.read(escrowListProvider.future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  itemCount: contracts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _AlertCard(contract: contracts[index]);
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

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.contract});

  final EscrowContract contract;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final unread = contract.isPendingPayment || contract.isFunded || contract.status == 'DISPUTED';
    final fill = unread
        ? (dark ? AppColors.darkContainerHigh : AppColors.lightContainer)
        : (dark ? AppColors.darkContainer : AppColors.snow);
    final alert = _alertFor(contract);

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TrackingDetailScreen(contract: contract)),
          );
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: alert.tone == _Tone.error
                        ? AppColors.crimson
                        : (dark ? AppColors.darkContainerHigh : AppColors.lightContainer),
                    child: Icon(
                      alert.icon,
                      size: 20,
                      color: alert.tone == _Tone.error
                          ? AppColors.snow
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                alert.title,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: alert.tone == _Tone.error
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                              ),
                            ),
                            Text(
                              _when(contract),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (unread)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 3,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _Tone { normal, error }

class _Alert {
  const _Alert({required this.title, required this.body, required this.icon, this.tone = _Tone.normal});

  final String title;
  final String body;
  final IconData icon;
  final _Tone tone;
}

_Alert _alertFor(EscrowContract contract) {
  final amount = '${contract.amount} ${contract.currency}';
  return switch (contract.status) {
    'FUNDED' => _Alert(
      title: 'Payment Received',
      body: 'Escrow for ${contract.itemName} is funded ($amount). Funds are locked until delivery is confirmed.',
      icon: Icons.payments_outlined,
    ),
    'DISPUTED' => _Alert(
      title: 'New Dispute Opened',
      body: 'A dispute is open for ${contract.itemName}. Review the contract and respond.',
      icon: Icons.gavel,
      tone: _Tone.error,
    ),
    'COMPLETED' => _Alert(
      title: 'Funds Released',
      body: '$amount for ${contract.itemName} was released after delivery confirmation.',
      icon: Icons.account_balance_outlined,
    ),
    'IN_TRANSIT' => _Alert(
      title: 'In Transit',
      body: '${contract.itemName} is marked shipped. Confirm delivery with PIN or QR when it arrives.',
      icon: Icons.local_shipping_outlined,
    ),
    'CANCELLED' => _Alert(
      title: 'Escrow Cancelled',
      body: '${contract.itemName} was cancelled.',
      icon: Icons.cancel_outlined,
    ),
    _ => _Alert(
      title: 'Awaiting Payment',
      body: '${contract.itemName} is waiting for $amount.',
      icon: Icons.hourglass_empty,
    ),
  };
}

String _when(EscrowContract contract) {
  final raw = contract.updatedAt ?? contract.createdAt;
  if (raw == null) {
    return '';
  }
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    return '';
  }
  final delta = DateTime.now().difference(parsed.toLocal());
  if (delta.inMinutes < 2) {
    return 'Just now';
  }
  if (delta.inHours < 1) {
    return '${delta.inMinutes}m ago';
  }
  if (delta.inHours < 24) {
    return '${delta.inHours} hours ago';
  }
  if (delta.inDays == 1) {
    return 'Yesterday';
  }
  return '${delta.inDays}d ago';
}
