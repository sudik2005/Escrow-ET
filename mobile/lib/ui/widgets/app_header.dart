import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/api_exception.dart';
import '../../state/auth_controller.dart';
import '../../theme/app_colors.dart';

/// Page-level header used on all screens.
///
/// Tab screens (no back):
///   Dark  → [● ] Title ········ [avatar circle]
///   Light → [avatar square] Title ········ [search icon]
///
/// Push screens (has back):
///   [‹] Title ·············· [avatar circle/square]
class AppHeader extends ConsumerWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.showAvatar = true,
    this.showBack = false,
  });

  final String title;
  final bool showAvatar;
  final bool showBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = AppColors.isDark(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            // ── leading ──────────────────────────────
            if (showBack) ...[
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Icon(
                  Icons.chevron_left,
                  size: 28,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 2),
            ] else if (!dark) ...[
              _AvatarWidget(circular: false, onTap: () => _openMenu(context, ref)),
              const SizedBox(width: 12),
            ] else ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.crimson,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
            ],

            // ── title ─────────────────────────────────
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.geist(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ),

            // ── trailing ──────────────────────────────
            if (showAvatar && dark)
              _AvatarWidget(circular: true, onTap: () => _openMenu(context, ref))
            else if (showAvatar && showBack)
              _AvatarWidget(circular: dark, onTap: () => _openMenu(context, ref))
            else if (!dark && !showBack)
              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
          ],
        ),
      ),
    );
  }

  void _openMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ProfileSheet(),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({required this.circular, required this.onTap});
  final bool circular;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.crimson,
          borderRadius: BorderRadius.circular(circular ? 18 : 10),
        ),
        child: const Icon(Icons.person, color: AppColors.snow, size: 18),
      ),
    );
  }
}

// ── Profile sheet ─────────────────────────────────────────────────────────────

class _ProfileSheet extends ConsumerWidget {
  const _ProfileSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).session?.user;
    final dark = AppColors.isDark(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + name row ─────────────────────
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.crimson,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: AppColors.snow, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.crimson.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user?.role ?? '',
                        style: GoogleFonts.geist(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: AppColors.crimson,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 8),

            // ── Edit username ─────────────────────────
            _SheetTile(
              icon: Icons.edit_outlined,
              label: 'Edit Username',
              dark: dark,
              onTap: () =>
                  _showEditUsernameDialog(context, ref, user?.username ?? ''),
            ),

            const SizedBox(height: 4),

            // ── Switch role ───────────────────────────
            _SheetTile(
              icon: Icons.swap_horiz_outlined,
              label: 'Switch Role',
              sublabel: user?.role == 'BUYER' ? 'Currently: Buyer' : 'Currently: Seller',
              dark: dark,
              onTap: () =>
                  _showSwitchRoleDialog(context, ref, user?.role ?? 'BUYER'),
            ),

            const SizedBox(height: 16),
            Divider(color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),

            // ── Sign out ──────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(authControllerProvider.notifier).logout();
                },
                child: const Text('SIGN OUT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUsernameDialog(
      BuildContext sheetContext, WidgetRef ref, String current) {
    final controller = TextEditingController(text: current);
    showDialog<void>(
      context: sheetContext,
      builder: (ctx) => _EditUsernameDialog(
        controller: controller,
        onConfirm: (newUsername) async {
          if (newUsername.trim().isEmpty || newUsername.trim() == current) {
            if (ctx.mounted) Navigator.of(ctx).pop();
            return;
          }
          try {
            await ref
                .read(authControllerProvider.notifier)
                .updateProfile(username: newUsername.trim());
            // close dialog first, then sheet
            if (ctx.mounted) Navigator.of(ctx).pop();
            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          } on ApiException catch (e) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx)
                  .showSnackBar(SnackBar(content: Text(e.message)));
            }
          } catch (e) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        },
      ),
    );
  }

  void _showSwitchRoleDialog(
      BuildContext sheetContext, WidgetRef ref, String currentRole) {
    showDialog<void>(
      context: sheetContext,
      builder: (ctx) => _SwitchRoleDialog(
        currentRole: currentRole,
        onSelect: (newRole) async {
          if (newRole == currentRole) {
            Navigator.of(ctx).pop();
            return;
          }
          try {
            await ref
                .read(authControllerProvider.notifier)
                .updateProfile(role: newRole);
            // close dialog first, then sheet
            if (ctx.mounted) Navigator.of(ctx).pop();
            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          } on ApiException catch (e) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx)
                  .showSnackBar(SnackBar(content: Text(e.message)));
            }
          } catch (e) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        },
      ),
    );
  }
}

// ── Sheet tile ────────────────────────────────────────────────────────────────

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.dark,
    required this.onTap,
    this.sublabel,
  });

  final IconData icon;
  final String label;
  final String? sublabel;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: dark ? AppColors.darkContainerHigh : AppColors.lightContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (sublabel != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      sublabel!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: dark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit username dialog ──────────────────────────────────────────────────────

class _EditUsernameDialog extends StatefulWidget {
  const _EditUsernameDialog({
    required this.controller,
    required this.onConfirm,
  });

  final TextEditingController controller;
  final Future<void> Function(String) onConfirm;

  @override
  State<_EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<_EditUsernameDialog> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Edit Username',
        style: GoogleFonts.geist(fontWeight: FontWeight.w700),
      ),
      content: TextField(
        controller: widget.controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'New username',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.crimson),
          child: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.snow),
                )
              : const Text('SAVE'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    await widget.onConfirm(widget.controller.text);
    if (mounted) setState(() => _busy = false);
  }
}

// ── Switch role dialog ────────────────────────────────────────────────────────

class _SwitchRoleDialog extends StatefulWidget {
  const _SwitchRoleDialog({
    required this.currentRole,
    required this.onSelect,
  });

  final String currentRole;
  final Future<void> Function(String) onSelect;

  @override
  State<_SwitchRoleDialog> createState() => _SwitchRoleDialogState();
}

class _SwitchRoleDialogState extends State<_SwitchRoleDialog> {
  late String _selected;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentRole;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Switch Role',
        style: GoogleFonts.geist(fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoleTile(
            role: 'BUYER',
            label: 'Buyer',
            subtitle: 'Pay for items held in escrow',
            icon: Icons.shopping_bag_outlined,
            selected: _selected == 'BUYER',
            onTap: _busy ? null : () => setState(() => _selected = 'BUYER'),
          ),
          const SizedBox(height: 8),
          _RoleTile(
            role: 'SELLER',
            label: 'Seller',
            subtitle: 'Create contracts and receive payment',
            icon: Icons.storefront_outlined,
            selected: _selected == 'SELLER',
            onTap: _busy ? null : () => setState(() => _selected = 'SELLER'),
          ),
          const SizedBox(height: 12),
          Text(
            'Changing role resets your navigation.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.45),
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.crimson),
          child: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.snow),
                )
              : const Text('CONFIRM'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    await widget.onSelect(_selected);
    if (mounted) setState(() => _busy = false);
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String role;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.crimson.withValues(alpha: 0.1)
              : (dark ? AppColors.darkContainerHigh : AppColors.lightContainer),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.crimson.withValues(alpha: 0.45)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? AppColors.crimson
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.crimson
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 18, color: AppColors.crimson),
          ],
        ),
      ),
    );
  }
}
