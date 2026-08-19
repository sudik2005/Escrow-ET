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

    // Web cannot paint borderRadius with mixed BorderSide colors. Stripe is a
    // separate bar so the outline stays uniform.
    final edge = alert ? brand.withValues(alpha: 0.45) : border;
    final stripeW = dark ? 2.0 : 3.0;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: edge),
        ),
        child: Stack(
          children: [
            Padding(
              padding: stripe
                  ? padding.copyWith(left: padding.left + stripeW)
                  : padding,
              child: child,
            ),
            if (stripe)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: ColoredBox(
                  color: brand,
                  child: SizedBox(width: stripeW),
                ),
              ),
          ],
        ),
      ),
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
