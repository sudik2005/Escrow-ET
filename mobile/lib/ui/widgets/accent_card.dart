import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AccentCard extends StatelessWidget {
  const AccentCard({
    super.key,
    required this.child,
    this.onTap,
    this.stripe = false,
    this.alert = false,
    this.padding = const EdgeInsets.all(16),
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
    final surface = dark ? AppColors.darkSurface : AppColors.snow;
    final border = Theme.of(context).colorScheme.outline;
    const stripeW = 3.0;

    final fill = alert ? brand.withValues(alpha: dark ? 0.16 : 0.07) : surface;
    final edgeColor = alert ? brand.withValues(alpha: 0.4) : border;

    final inner = Padding(
      padding: stripe ? padding.copyWith(left: padding.left + stripeW) : padding,
      child: child,
    );

    final decorated = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: edgeColor, width: 1),
        ),
        child: stripe
            ? Stack(
                children: [
                  inner,
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(width: stripeW, color: brand),
                  ),
                ],
              )
            : inner,
      ),
    );

    if (onTap == null) return decorated;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: decorated,
      ),
    );
  }
}
