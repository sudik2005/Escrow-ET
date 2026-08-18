import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_controller.dart';
import '../widgets/accent_card.dart';
import '../widgets/app_controls.dart';
import '../widgets/app_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).session?.user;
    final isDark = ref.watch(themeControllerProvider);

    return Column(
      children: [
        const AppHeader(title: 'Settings'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              AccentCard(
                stripe: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? '',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text('${user?.role ?? ''} · ${user?.phoneNumber ?? ''}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AccentCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark mode'),
                  value: isDark,
                  onChanged: (_) => ref.read(themeControllerProvider.notifier).toggle(),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'LOG OUT',
                outlined: true,
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
