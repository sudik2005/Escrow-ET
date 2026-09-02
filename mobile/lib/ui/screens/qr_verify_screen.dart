import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/escrow_contract.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_controls.dart';
import '../widgets/app_header.dart';

class QrVerifyScreen extends StatefulWidget {
  const QrVerifyScreen({
    super.key,
    required this.contract,
    this.sellerPin,
  });

  final EscrowContract contract;
  final String? sellerPin;

  @override
  State<QrVerifyScreen> createState() => _QrVerifyScreenState();
}

class _QrVerifyScreenState extends State<QrVerifyScreen> {
  static const _duration = Duration(minutes: 5);
  late Duration _remaining;
  Timer? _timer;
  bool _pinVisible = false;

  @override
  void initState() {
    super.initState();
    _remaining = _duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerLabel {
    final m = _remaining.inMinutes.toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _expired => _remaining.inSeconds == 0;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final qrData = widget.contract.deliveryQrToken ?? widget.contract.id;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Transaction Details',
              showBack: true,
              showAvatar: true,
            ),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(24, 16, 24, 40),
                children: [
                  const SizedBox(height: 16),

                  // ── Heading ───────────────────────────
                  Text(
                    'Identity Code',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.geist(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Align frame within scanner to verify identity.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark
                              ? AppColors.darkMuted
                              : AppColors.lightMuted,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // ── QR card with corner brackets ──────
                  Center(
                    child: Container(
                      width: 240,
                      height: 240,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.snow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: QrImageView(
                              data: qrData,
                              size: 200,
                              backgroundColor: AppColors.snow,
                              errorStateBuilder: (_, _) => const Icon(
                                Icons.qr_code_2,
                                size: 80,
                                color: AppColors.onyx,
                              ),
                            ),
                          ),
                          // Corner brackets
                          ..._brackets(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Timer ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: _expired
                            ? AppColors.crimson
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _expired ? 'Expired' : _timerLabel,
                        style: GoogleFonts.geist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _expired
                              ? AppColors.crimson
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Delivery PIN card ─────────────────
                  if (widget.sellerPin != null) ...[
                    _PinCard(
                      pin: widget.sellerPin!,
                      visible: _pinVisible,
                      onToggle: () =>
                          setState(() => _pinVisible = !_pinVisible),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Security notice ────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.crimson.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.crimson.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined,
                            color: AppColors.crimson, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Security Notice',
                                style: GoogleFonts.geist(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.crimson,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'The QR code grants one-time access and will expire. Share the PIN only with your buyer — never with third parties.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.crimson
                                          .withValues(alpha: 0.85),
                                      height: 1.4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Buttons ───────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'REGENERATE',
                          outlined: true,
                          icon: Icons.refresh,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Regenerate from the backend is not available yet.'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'DONE',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _brackets() {
    const len = 20.0;
    const thick = 2.5;
    final color = AppColors.crimson;
    return [
      // top-left
      Positioned(
        top: 0,
        left: 0,
        child: _L(color: color, len: len, thick: thick, flip: false, vFlip: false),
      ),
      // top-right
      Positioned(
        top: 0,
        right: 0,
        child: _L(color: color, len: len, thick: thick, flip: true, vFlip: false),
      ),
      // bottom-left
      Positioned(
        bottom: 0,
        left: 0,
        child: _L(color: color, len: len, thick: thick, flip: false, vFlip: true),
      ),
      // bottom-right
      Positioned(
        bottom: 0,
        right: 0,
        child: _L(color: color, len: len, thick: thick, flip: true, vFlip: true),
      ),
    ];
  }
}

// ── PIN display card ──────────────────────────────────────────────────────────
class _PinCard extends StatelessWidget {
  const _PinCard({
    required this.pin,
    required this.visible,
    required this.onToggle,
  });

  final String pin;
  final bool visible;
  final VoidCallback onToggle;

  String get _formatted {
    final half = (pin.length / 2).floor();
    return '${pin.substring(0, half)}  ${pin.substring(half)}';
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final surface = dark ? AppColors.darkSurface : AppColors.snow;
    final border = Theme.of(context).colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pin_outlined, size: 16, color: AppColors.crimson),
              const SizedBox(width: 8),
              Text(
                'DELIVERY PIN',
                style: GoogleFonts.geist(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.crimson,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  visible ? _formatted : '●●●●  ●●●●',
                  style: GoogleFonts.geistMono(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    color: visible
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.25),
                  ),
                ),
              ),
              if (visible)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: pin));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN copied to clipboard')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.crimson.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy_outlined,
                            size: 13, color: AppColors.crimson),
                        const SizedBox(width: 5),
                        Text(
                          'COPY',
                          style: GoogleFonts.geist(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.crimson,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Share this PIN with your buyer so they can confirm delivery remotely.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark ? AppColors.darkMuted : AppColors.lightMuted,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _L extends StatelessWidget {
  const _L({
    required this.color,
    required this.len,
    required this.thick,
    required this.flip,
    required this.vFlip,
  });
  final Color color;
  final double len;
  final double thick;
  final bool flip;
  final bool vFlip;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      scaleY: vFlip ? -1 : 1,
      child: SizedBox(
        width: len,
        height: len,
        child: CustomPaint(
          painter: _CornerPainter(color: color, thick: thick),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({required this.color, required this.thick});
  final Color color;
  final double thick;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), p);
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
