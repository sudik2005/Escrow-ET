import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../theme/app_colors.dart';

class ScanConfirmScreen extends StatefulWidget {
  const ScanConfirmScreen({super.key});

  @override
  State<ScanConfirmScreen> createState() => _ScanConfirmScreenState();
}

class _ScanConfirmScreenState extends State<ScanConfirmScreen> {
  var _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera ──────────────────────────────────
          MobileScanner(
            onDetect: (capture) {
              if (_scanned) return;
              final value = capture.barcodes.firstOrNull?.rawValue;
              if (value != null && value.isNotEmpty) {
                _scanned = true;
                Navigator.of(context).pop(value);
              }
            },
          ),

          // ── Corner bracket overlay ───────────────────
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(painter: _BracketPainter()),
            ),
          ),

          // ── Top bar ──────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: AppColors.snow, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Scan QR Code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.snow,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom hint ──────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Align the seller\'s QR code within the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.snow.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const len = 28.0;
    const w = 3.0;
    const r = 8.0;
    final paint = Paint()
      ..color = AppColors.crimson
      ..strokeWidth = w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corners = [
      // top-left
      [Offset(r, 0), Offset(0, 0), Offset(0, r)],
      // top-right
      [
        Offset(size.width - r, 0),
        Offset(size.width, 0),
        Offset(size.width, r)
      ],
      // bottom-left
      [
        Offset(0, size.height - r),
        Offset(0, size.height),
        Offset(r, size.height)
      ],
      // bottom-right
      [
        Offset(size.width, size.height - r),
        Offset(size.width, size.height),
        Offset(size.width - r, size.height)
      ],
    ];

    for (final pts in corners) {
      final path = Path();
      path.moveTo(pts[0].dx, pts[0].dy);
      path.lineTo(pts[1].dx, pts[1].dy);
      path.lineTo(pts[2].dx, pts[2].dy);
      canvas.drawPath(path, paint);
    }
    // extend arms
    final _ = len;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
