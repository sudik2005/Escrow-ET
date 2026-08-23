import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class PillNavItem {
  const PillNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class PillNavBar extends StatelessWidget {
  const PillNavBar({
    super.key,
    required this.index,
    required this.items,
    required this.onSelected,
  });

  final int index;
  final List<PillNavItem> items;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 10 + bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? AppColors.darkContainer : AppColors.snow,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _PillNavButton(
                    item: items[i],
                    selected: i == index,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillNavButton extends StatelessWidget {
  const _PillNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final PillNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.isDark(context)
        ? AppColors.darkMuted
        : AppColors.lightMuted;
    final color = selected ? AppColors.crimson : muted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.crimson.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.geist(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
