import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'AppSans',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundBlack,
      primaryColor: AppColors.primaryRed,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryRed,
        secondary: AppColors.primaryRed,
        onSecondary: AppColors.darkTextOverRed,
        onPrimary: AppColors.darkTextOverRed,
        surface: AppColors.primaryPanel,
        onSurface: AppColors.primaryText,
        surfaceContainerHighest: AppColors.secondaryPanel,
        outline: AppColors.subtleBorder,
        outlineVariant: AppColors.strongBorder,
        error: AppColors.deepRed,
      ),
      textTheme: AppTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryText),
      ),
      navigationBarTheme: NavigationBarThemeData(
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryRed
                : AppColors.primaryText,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return AppTypography.textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.primaryRed
                : AppColors.primaryText,
          );
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundBlack,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.faintText,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: AppColors.primaryPanel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.subtleBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.darkTextOverRed,
          textStyle: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.29,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryText,
          side: const BorderSide(color: AppColors.strongBorder, width: 1),
          textStyle: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.primaryPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primaryPanel,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.subtleBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.subtleBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.deepRed, width: 1),
        ),
        labelStyle: AppTypography.textTheme.labelMedium,
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.mutedText,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.subtleBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
