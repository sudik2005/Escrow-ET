import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.showAvatar = true,
    this.centerTitle = false,
    this.leading,
  });

  final String title;
  final bool showAvatar;
  final bool centerTitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 8),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            ?leading,
            Expanded(
              child: Text(
                title.toUpperCase(),
                textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                style: titleStyle,
              ),
            ),
            if (showAvatar)
              Material(
                color: AppColors.crimson,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => ref.read(shellTabProvider.notifier).state = 4,
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(Icons.person, color: AppColors.snow, size: 18),
                  ),
                ),
              )
            else
              const SizedBox(width: 32),
          ],
        ),
      ),
    );
  }
}
