import 'package:flutter/material.dart';
import 'app_tokens.dart';

/// Builds the WhiskyHikes Material 3 [ThemeData] from design tokens.
///
/// Usage in MaterialApp:
/// ```dart
/// theme: AppTheme.light,
/// darkTheme: AppTheme.dark,
/// themeMode: ThemeMode.system,
/// ```
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark ? _darkScheme : _lightScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      // --- Scaffold ---
      scaffoldBackgroundColor: isDark ? AppColors.peat900 : AppColors.cream,

      // --- App Bar ---
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.peat900 : AppColors.cream,
        foregroundColor: isDark ? AppColors.cream : AppColors.peat900,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: isDark ? AppColors.cream : AppColors.peat900,
        ),
      ),

      // --- Cards ---
      cardTheme: CardThemeData(
        color: isDark ? AppColors.peat700 : AppColors.white,
        elevation: AppElevation.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),

      // --- Elevated Button ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber700,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(AppTouchTargets.comfortable),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // --- Outlined Button ---
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.amber700,
          minimumSize: const Size.fromHeight(AppTouchTargets.comfortable),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          side: const BorderSide(color: AppColors.amber700, width: 1.5),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // --- Text Button ---
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.amber700,
          minimumSize: const Size(
            AppTouchTargets.minimum,
            AppTouchTargets.minimum,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // --- Input / TextField ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.peat700.withValues(alpha: 0.5)
            : AppColors.peat100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.amber700, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.peat300),
      ),

      // --- Bottom Navigation ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.peat900 : AppColors.white,
        selectedItemColor: AppColors.amber700,
        unselectedItemColor: AppColors.peat300,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: AppElevation.raised,
      ),

      // --- Navigation Bar (M3) ---
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.peat900 : AppColors.white,
        indicatorColor: AppColors.amber100,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.amber800, size: 24);
          }
          return const IconThemeData(color: AppColors.peat300, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMedium.copyWith(
              color: AppColors.amber800,
            );
          }
          return AppTextStyles.labelMedium.copyWith(color: AppColors.peat300);
        }),
      ),

      // --- Chip ---
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.peat700 : AppColors.peat100,
        selectedColor: AppColors.amber100,
        labelStyle: AppTextStyles.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // --- Divider ---
      dividerTheme: const DividerThemeData(
        color: AppColors.peat100,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      // --- Text ---
      textTheme: _buildTextTheme(isDark),

      // --- Icon ---
      iconTheme: IconThemeData(
        color: isDark ? AppColors.peat100 : AppColors.peat700,
        size: 24,
      ),

      // --- FAB ---
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.amber700,
        foregroundColor: AppColors.white,
        elevation: AppElevation.raised,
      ),

      // --- Snack Bar ---
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.peat900,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.cream,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ColorScheme get _lightScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.amber700,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.amber100,
    onPrimaryContainer: AppColors.amber800,
    secondary: AppColors.green700,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.green100,
    onSecondaryContainer: AppColors.green800,
    surface: AppColors.cream,
    onSurface: AppColors.peat900,
    error: AppColors.error,
    onError: AppColors.white,
    outline: AppColors.peat100,
    outlineVariant: AppColors.peat300,
  );

  static ColorScheme get _darkScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.amber100,
    onPrimary: AppColors.amber800,
    primaryContainer: AppColors.amber800,
    onPrimaryContainer: AppColors.amber100,
    secondary: AppColors.green100,
    onSecondary: AppColors.green800,
    secondaryContainer: AppColors.green800,
    onSecondaryContainer: AppColors.green100,
    surface: AppColors.peat900,
    onSurface: AppColors.cream,
    error: Color(0xFFFF6B6B),
    onError: AppColors.peat900,
    outline: AppColors.peat700,
    outlineVariant: AppColors.peat500,
  );

  static TextTheme _buildTextTheme(bool isDark) {
    final base = isDark ? AppColors.cream : AppColors.peat900;
    final muted = isDark ? AppColors.peat300 : AppColors.peat500;
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: base),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: base),
      displaySmall: AppTextStyles.headlineLarge.copyWith(color: base),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: base),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: base),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: base),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: base),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: base),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: muted),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: base),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: base),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: muted),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: base),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: muted),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: muted),
    );
  }
}
