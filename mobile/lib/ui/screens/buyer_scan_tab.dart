import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/api_exception.dart';
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

    // Launch scanner full-screen, returns scanned QR string or null
    final scanned = await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (_) => const ScanConfirmScreen()),
    );

    if (scanned == null || scanned.isEmpty || !mounted) return;

    setState(() => _busy = true);

    try {
      // Find the contract with a matching deliveryQrToken
      final contracts = ref.read(escrowListProvider).valueOrNull ?? [];
      final match = contracts.where((c) => c.deliveryQrToken == scanned).firstOrNull;

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
                    ],
                  ),
                ),
              ),
            ),
          ],
      );
  }
}

// ── Corner bracket painter ────────────────────────────────────────────────────
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
