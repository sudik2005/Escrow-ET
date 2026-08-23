import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Crimson Matrix grid + optional radial glow from the Stitch auth screens.
class MatrixBackdrop extends StatelessWidget {
  const MatrixBackdrop({super.key, required this.child, this.glow = true});

  final Widget child;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _GridPainter(
              color: dark
                  ? AppColors.crimson.withValues(alpha: 0.18)
                  : AppColors.lightBorder,
              glow: glow && dark,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color, required this.glow});

  final Color color;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 40.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    if (glow) {
      final rect = Offset.zero & size;
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0, -1),
            radius: 1.1,
            colors: [
              AppColors.crimson.withValues(alpha: 0.12),
              AppColors.onyx.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.glow != glow;
  }
}
