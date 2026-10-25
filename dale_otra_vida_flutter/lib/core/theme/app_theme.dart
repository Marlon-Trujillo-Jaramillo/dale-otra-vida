import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: AppColors.border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryVariant,
        onPrimaryContainer: AppColors.onPrimary,
        secondary: AppColors.accent,
        onSecondary: AppColors.textPrimary,
        secondaryContainer: AppColors.surface,
        onSecondaryContainer: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceMuted,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        error: AppColors.danger,
        onError: AppColors.onPrimary,
        errorContainer: Color(0xFFF8E5E5),
        onErrorContainer: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.headline,
        titleLarge: AppTypography.title,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.bodyStrong,
        labelLarge: AppTypography.button,
        labelSmall: AppTypography.caption,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          textStyle: AppTypography.button,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textHint),
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        showCheckmark: false,
        // Unselected chips were rendering light text on the light surface.
        // `secondaryLabelStyle` is the one Flutter uses for selected chips.
        labelStyle: AppTypography.bodyStrong.copyWith(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: AppTypography.bodyStrong.copyWith(
          fontSize: 14,
          color: AppColors.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        side: BorderSide(color: AppColors.border),
        shape: StadiumBorder(),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.onPrimary,
        unselectedItemColor: AppColors.categoryCircle,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: TextStyle(color: AppColors.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: const {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
