import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final heading = GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final title = GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final body = GoogleFonts.cairo(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static final caption = GoogleFonts.cairo(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}
