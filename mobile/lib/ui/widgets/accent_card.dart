import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AccentCard extends StatelessWidget {
  const AccentCard({
    super.key,
    required this.child,
    this.onTap,
    this.stripe = false,
    this.alert = false,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool stripe;
  final bool alert;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final brand = Theme.of(context).colorScheme.primary;
    final border = Theme.of(context).colorScheme.outline;
    final fill = alert
        ? brand.withValues(alpha: dark ? 0.18 : 0.08)
        : (dark ? AppColors.darkSurface : AppColors.snow);

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          top: BorderSide(color: alert ? brand.withValues(alpha: 0.45) : border),
          right: BorderSide(color: alert ? brand.withValues(alpha: 0.45) : border),
          bottom: BorderSide(color: alert ? brand.withValues(alpha: 0.45) : border),
          left: BorderSide(
            color: stripe ? brand : (alert ? brand.withValues(alpha: 0.45) : border),
            width: stripe ? (dark ? 2 : 3) : 1,
          ),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return card;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      ),
    );
  }
}
