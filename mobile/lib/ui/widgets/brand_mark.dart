import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.crimson,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Center(
        child: Text(
          'ET',
          style: GoogleFonts.geist(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            color: AppColors.snow,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
