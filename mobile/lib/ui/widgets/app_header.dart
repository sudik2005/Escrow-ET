import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: brand,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Material(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => ref.read(themeControllerProvider.notifier).toggle(),
              borderRadius: BorderRadius.circular(20),
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.person_outline, color: AppColors.snow, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
