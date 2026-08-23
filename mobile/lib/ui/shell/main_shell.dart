import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../../theme/app_colors.dart';
import '../screens/buyer_home_screen.dart';
import '../screens/buyer_scan_tab.dart';
import '../screens/dashboard_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/payments_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tracking_list_screen.dart';
import '../widgets/pill_nav_bar.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(escrowListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final user = ref.watch(authControllerProvider).session?.user;
    final isBuyer = user?.isBuyer ?? false;

    // Clamp the tab index to the number of destinations so a role-switch
    // never leaves an out-of-bounds index in the provider.
    final tabCount = isBuyer ? 4 : 5;
    final rawIndex = ref.watch(shellTabProvider);
    final index = rawIndex.clamp(0, tabCount - 1);
    if (rawIndex != index) {
      // Schedule correction outside the build frame
      Future<void>.microtask(
        () => ref.read(shellTabProvider.notifier).state = index,
      );
    }

    return isBuyer
        ? _BuyerShell(index: index, dark: dark)
        : _SellerShell(index: index, dark: dark);
  }
}

// ── Seller shell — 5 tabs ────────────────────────────────────────────────────
class _SellerShell extends ConsumerWidget {
  const _SellerShell({required this.index, required this.dark});
  final int index;
  final bool dark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: dark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: index,
          children: const [
            DashboardScreen(),
            PaymentsScreen(),
            TrackingListScreen(),
            NotificationsScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: PillNavBar(
        index: index,
        onSelected: (i) {
          ref.read(shellTabProvider.notifier).state = i;
          ref.invalidate(escrowListProvider);
        },
        items: const [
          PillNavItem(
            icon: Icons.grid_view_outlined,
            selectedIcon: Icons.grid_view,
            label: 'Dashboard',
          ),
          PillNavItem(
            icon: Icons.account_balance_wallet_outlined,
            selectedIcon: Icons.account_balance_wallet,
            label: 'Payments',
          ),
          PillNavItem(
            icon: Icons.location_on_outlined,
            selectedIcon: Icons.location_on,
            label: 'Tracking',
          ),
          PillNavItem(
            icon: Icons.notifications_outlined,
            selectedIcon: Icons.notifications,
            label: 'Alerts',
          ),
          PillNavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ── Buyer shell — 4 tabs ─────────────────────────────────────────────────────
class _BuyerShell extends ConsumerWidget {
  const _BuyerShell({required this.index, required this.dark});
  final int index;
  final bool dark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: dark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: index,
          children: const [
            BuyerHomeScreen(),
            BuyerScanTab(),
            NotificationsScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: PillNavBar(
        index: index,
        onSelected: (i) {
          ref.read(shellTabProvider.notifier).state = i;
          ref.invalidate(escrowListProvider);
        },
        items: const [
          PillNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
          ),
          PillNavItem(
            icon: Icons.qr_code_scanner_outlined,
            selectedIcon: Icons.qr_code_scanner,
            label: 'Scan QR',
          ),
          PillNavItem(
            icon: Icons.notifications_outlined,
            selectedIcon: Icons.notifications,
            label: 'Alerts',
          ),
          PillNavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
