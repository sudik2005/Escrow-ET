import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/api_exception.dart';
import '../../models/escrow_contract.dart';
import '../../state/auth_controller.dart';
import '../../state/escrow_controller.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_header.dart';
import 'scan_confirm_screen.dart';

class BuyerScanTab extends ConsumerStatefulWidget {
  const BuyerScanTab({super.key});

  @override
  ConsumerState<BuyerScanTab> createState() => _BuyerScanTabState();
}

class _BuyerScanTabState extends ConsumerState<BuyerScanTab> {
  var _busy = false;

  Future<void> _scanAndConfirm() async {
    final token = ref.read(authControllerProvider).session?.token;
    if (token == null) return;

    final scanned = await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (_) => const ScanConfirmScreen()),
    );

    if (scanned == null || scanned.isEmpty || !mounted) return;

    setState(() => _busy = true);

    try {
      final contracts = ref.read(escrowListProvider).valueOrNull ?? [];
      final match =
          contracts.where((c) => c.deliveryQrToken == scanned).firstOrNull;

      if (match == null) {
        _snack('No matching contract found for this QR code.');
        setState(() => _busy = false);
        return;
      }

      await ref.read(escrowApiProvider).confirmDelivery(
            token: token,
            id: match.id,
            qrToken: scanned,
          );

      ref.invalidate(escrowListProvider);
      await ref.read(authControllerProvider.notifier).refreshUser();

      if (mounted) {
        _snack('Delivery confirmed! Funds released to seller.');
      }
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack('Could not confirm delivery. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _enterPinAndConfirm() async {
    final token = ref.read(authControllerProvider).session?.token;
    if (token == null) return;

    final contracts = ref.read(escrowListProvider).valueOrNull ?? [];
    final confirmable = contracts.where((c) => c.canConfirm).toList();

    if (confirmable.isEmpty) {
      _snack('You have no active deliveries to confirm.');
      return;
    }

    EscrowContract? target;
    if (confirmable.length == 1) {
      target = confirmable.first;
    } else {
      target = await showModalBottomSheet<EscrowContract>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _ContractPickerSheet(contracts: confirmable),
      );
    }

    if (target == null || !mounted) return;

    final pinCtrl = TextEditingController();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PinEntrySheet(controller: pinCtrl, contract: target!),
    );
    final pin = pinCtrl.text.trim();
    pinCtrl.dispose();

    if (confirmed != true || pin.isEmpty || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(escrowApiProvider).confirmDelivery(
            token: token,
            id: target.id,
            pin: pin,
          );
      ref.invalidate(escrowListProvider);
      await ref.read(authControllerProvider.notifier).refreshUser();
      if (mounted) _snack('Delivery confirmed! Funds released to seller.');
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack('Could not confirm delivery. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);

    return Column(
      children: [
        const AppHeader(title: 'Scan QR', showAvatar: false),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── QR frame illustration ──────────────────
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: dark
                          ? AppColors.darkContainerHigh
                          : AppColors.lightContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomPaint(
                      painter: _FramePainter(),
                      child: Center(
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: 72,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Title ──────────────────────────────────
                  Text(
                    'Confirm Delivery',
                    style: GoogleFonts.geist(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Scan the QR code shown by your seller to confirm you received the item and release the funds.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.6,
                          color: dark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                  ),
                  const SizedBox(height: 36),

                  // ── Scan button ────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _scanAndConfirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.crimson,
                        foregroundColor: AppColors.snow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.snow,
                              ),
                            )
                          : const Icon(Icons.qr_code_scanner, size: 18),
                      label: Text(
                        _busy ? 'CONFIRMING...' : 'SCAN QR CODE',
                        style: GoogleFonts.geist(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── PIN divider ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: dark
                                    ? AppColors.darkMuted
                                    : AppColors.lightMuted,
                              ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── PIN button ─────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _enterPinAndConfirm,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.pin_outlined, size: 18),
                      label: Text(
                        'ENTER PIN INSTEAD',
                        style: GoogleFonts.geist(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Contract picker sheet ─────────────────────────────────────────────────────
class _ContractPickerSheet extends StatelessWidget {
  const _ContractPickerSheet({required this.contracts});
  final List<EscrowContract> contracts;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.snow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color:
                    dark ? AppColors.darkContainerHigh : AppColors.lightContainer,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Which delivery?',
            style: GoogleFonts.geist(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select the transaction you are confirming.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark ? AppColors.darkMuted : AppColors.lightMuted,
                ),
          ),
          const SizedBox(height: 16),
          ...contracts.map(
            (c) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.crimson.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.swap_horiz_rounded,
                    color: AppColors.crimson, size: 20),
              ),
              title: Text(
                c.itemName,
                style: GoogleFonts.geist(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                '${c.amount} ${c.currency}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? AppColors.darkMuted : AppColors.lightMuted,
                    ),
              ),
              onTap: () => Navigator.of(context).pop(c),
            ),
          ),
        ],
      ),
    );
  }
}

// ── PIN entry sheet ───────────────────────────────────────────────────────────
class _PinEntrySheet extends StatelessWidget {
  const _PinEntrySheet({
    required this.controller,
    required this.contract,
  });
  final TextEditingController controller;
  final EscrowContract contract;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkSurface : AppColors.snow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: dark
                      ? AppColors.darkContainerHigh
                      : AppColors.lightContainer,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Enter Delivery PIN',
              style: GoogleFonts.geist(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              contract.itemName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.crimson,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ask your seller for the PIN, then enter it below to release the funds.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? AppColors.darkMuted : AppColors.lightMuted,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 8,
              style: GoogleFonts.geistMono(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 6,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '• • • • • • • •',
                hintStyle: GoogleFonts.geistMono(
                  fontSize: 20,
                  letterSpacing: 4,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.2),
                ),
                filled: true,
                fillColor: dark
                    ? AppColors.darkContainerHigh
                    : AppColors.lightContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.crimson,
                  foregroundColor: AppColors.snow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'CONFIRM DELIVERY',
                  style: GoogleFonts.geist(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Corner bracket painter ─────────────────────────────────────────────────────
class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const w = 3.0;
    const r = 10.0;
    final paint = Paint()
      ..color = AppColors.crimson
      ..strokeWidth = w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corners = [
      [Offset(r, 0), Offset(0, 0), Offset(0, r)],
      [Offset(size.width - r, 0), Offset(size.width, 0), Offset(size.width, r)],
      [Offset(0, size.height - r), Offset(0, size.height), Offset(r, size.height)],
      [
        Offset(size.width, size.height - r),
        Offset(size.width, size.height),
        Offset(size.width - r, size.height),
      ],
    ];

    for (final pts in corners) {
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
