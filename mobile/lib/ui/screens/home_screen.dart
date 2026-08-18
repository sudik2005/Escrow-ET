import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/escrow_contract.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/brand_card.dart';
import '../widgets/brand_mark.dart';
import 'create_escrow_screen.dart';
import 'escrow_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).session;
    final isDark = ref.watch(themeControllerProvider);
    final user = session?.user;
    final colors = Theme.of(context).colorScheme;
    final list = ref.watch(escrowListProvider);
    final seller = user?.isSeller ?? false;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ESCROW ET',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 2),
            const Text('Escrows'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: () => ref.read(themeControllerProvider.notifier).toggle(),
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authControllerProvider.notifier).logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Log out')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: colors.outline),
        ),
      ),
      floatingActionButton: seller
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const CreateEscrowScreen()),
                );
                if (created == true) {
                  ref.invalidate(escrowListProvider);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New escrow'),
            )
          : null,
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            BrandCard(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      error is Exception ? error.toString() : 'Could not load escrows.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => ref.invalidate(escrowListProvider),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        data: (contracts) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(escrowListProvider);
            await ref.read(escrowListProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              BrandCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BrandLockup(subtitle: seller ? 'Seller' : 'Buyer'),
                      const SizedBox(height: 16),
                      Text(
                        user?.username ?? '',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phoneNumber ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (contracts.isEmpty)
                BrandCard(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                    child: Text(
                      seller
                          ? 'Create an escrow to hold a buyer’s payment until they confirm delivery.'
                          : 'When a seller creates an escrow with your phone number, it shows up here.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                )
              else
                for (final contract in contracts) ...[
                  _EscrowTile(contract: contract),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EscrowTile extends StatelessWidget {
  const _EscrowTile({required this.contract});

  final EscrowContract contract;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkText
        : AppColors.lightText;

    return BrandCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EscrowDetailScreen(contract: contract)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contract.itemName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${contract.amount} ${contract.currency}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            Text(
              contract.statusLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
