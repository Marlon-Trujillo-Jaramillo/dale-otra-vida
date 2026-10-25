import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle get display => GoogleFonts.fraunces(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get headline => GoogleFonts.fraunces(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get title => GoogleFonts.fraunces(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get sectionLabel => GoogleFonts.nunitoSans(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle get body => GoogleFonts.nunitoSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodyStrong => GoogleFonts.nunitoSans(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get caption => GoogleFonts.nunitoSans(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get button => GoogleFonts.nunitoSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.onPrimary,
  );

  static TextStyle get badge => GoogleFonts.nunitoSans(
    fontSize: 11.5,
    fontWeight: FontWeight.w800,
  );
}
