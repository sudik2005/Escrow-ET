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
import 'tracking_detail_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(escrowListProvider);
    final user = ref.watch(authControllerProvider).session?.user;
    final phone = user?.phoneNumber ?? '';

    return Column(
      children: [
        const AppHeader(title: 'Alerts'),
        Expanded(
          child: list.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => ListError(
              message: e.toString(),
              onRetry: () => ref.invalidate(escrowListProvider),
            ),
            data: (contracts) {
              final mine = (user?.isSeller ?? false)
                  ? contracts.where((c) => c.isSaleFor(phone)).toList()
                  : contracts.where((c) => c.isPurchaseFor(phone)).toList();
              final alerts = _buildAlerts(mine);
              if (alerts.isEmpty) {
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
                  itemCount: alerts.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) => _AlertRow(
                    alert: alerts[i],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TrackingDetailScreen(
                          contract: alerts[i].contract,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<_Alert> _buildAlerts(List<EscrowContract> contracts) {
    final alerts = <_Alert>[];
    for (final c in contracts) {
      switch (c.status) {
        case 'PENDING_PAYMENT':
          alerts.add(_Alert(
            contract: c,
            icon: Icons.payment_outlined,
            title: 'Payment required',
            body: '${c.itemName} — ${c.amount} ${c.currency}',
            urgent: true,
          ));
        case 'FUNDED':
          alerts.add(_Alert(
            contract: c,
            icon: Icons.lock_outline,
            title: 'Funds locked',
            body: '${c.itemName} is now secured in escrow.',
            urgent: false,
          ));
        case 'IN_TRANSIT':
          alerts.add(_Alert(
            contract: c,
            icon: Icons.local_shipping_outlined,
            title: 'Item in transit',
            body: '${c.itemName} has been dispatched.',
            urgent: false,
          ));
        case 'DISPUTED':
          alerts.add(_Alert(
            contract: c,
            icon: Icons.warning_amber_rounded,
            title: 'Dispute opened',
            body: '${c.itemName} — review needed.',
            urgent: true,
          ));
        default:
          break;
      }
    }
    // urgent first
    alerts.sort((a, b) => (b.urgent ? 1 : 0) - (a.urgent ? 1 : 0));
    return alerts;
  }
}

class _Alert {
  const _Alert({
    required this.contract,
    required this.icon,
    required this.title,
    required this.body,
    required this.urgent,
  });
  final EscrowContract contract;
  final IconData icon;
  final String title;
  final String body;
  final bool urgent;
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert, required this.onTap});
  final _Alert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return AccentCard(
      alert: alert.urgent,
      stripe: alert.urgent,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: alert.urgent
                  ? AppColors.crimson.withValues(alpha: 0.15)
                  : (dark
                      ? AppColors.darkContainerHigh
                      : AppColors.lightContainer),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              alert.icon,
              size: 20,
              color: alert.urgent
                  ? AppColors.crimson
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.body,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (alert.urgent)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.crimson,
                shape: BoxShape.circle,
              ),
            ),
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
              Icons.notifications_none_outlined,
              size: 56,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No alerts',
              style: GoogleFonts.geist(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Escrow activity will show up here.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
