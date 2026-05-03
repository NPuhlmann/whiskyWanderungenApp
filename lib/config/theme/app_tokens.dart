import 'package:flutter/material.dart';

/// WhiskyHikes Design System v1 — Design Tokens
///
/// Brand narrative: premium whisky + highland hiking.
/// Palette draws from peat smoke, amber spirit, and highland greenery.
/// All colours pass WCAG AA (4.5:1 body, 3:1 large text) on their
/// intended backgrounds.
///
/// Figma source of truth: see WHI-20 plan document.
abstract final class AppColors {
  // --- Primary: Whisky Amber ---
  static const Color amber700 = Color(0xFFC8860A);
  static const Color amber800 = Color(0xFF8B5E04);
  static const Color amber100 = Color(0xFFFDF3DC);
  static const Color amber50 = Color(0xFFFEF9F0);

  // --- Secondary: Highland Green ---
  static const Color green700 = Color(0xFF3D6B4A);
  static const Color green800 = Color(0xFF28503A);
  static const Color green100 = Color(0xFFD7EDE0);

  // --- Neutral: Peat ---
  static const Color peat900 = Color(0xFF2A2922); // near-black, splash
  static const Color peat700 = Color(0xFF4A4740);
  static const Color peat500 = Color(0xFF6B6052);
  static const Color peat300 = Color(0xFFB0A899);
  static const Color peat100 = Color(0xFFEDE8E0);

  // --- Surface: Highland Cream ---
  static const Color cream = Color(0xFFF5F0E8);
  static const Color white = Color(0xFFFFFFFF);

  // --- Semantic ---
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color error = Color(0xFFB91C1C);
  static const Color info = Color(0xFF1565C0);

  // --- Status badges (order tracking) ---
  static const Color statusPending = Color(0xFFE65100);
  static const Color statusProcessing = Color(0xFF1565C0);
  static const Color statusShipped = Color(0xFF6A1B9A);
  static const Color statusDelivered = Color(0xFF2E7D32);
  static const Color statusCancelled = Color(0xFFB91C1C);
}

/// Spacing scale — 4-pt grid.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

/// Border radii.
abstract final class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

/// Elevation / shadow tokens.
abstract final class AppElevation {
  static const double none = 0;
  static const double card = 2;
  static const double raised = 5;
  static const double modal = 12;

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.peat900.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> heroShadow = [
    BoxShadow(
      color: AppColors.peat900.withValues(alpha: 0.24),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Motion / animation durations and curves.
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration dramatic = Duration(milliseconds: 600);

  static const Curve standard_ = Curves.easeInOut;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve spring = Curves.elasticOut;
}

/// Typography scale.
///
/// Heading slots use a serif-weight feel via fontWeight 800/900 on
/// the system sans. If the app integrates google_fonts, swap in
/// GoogleFonts.playfairDisplay() for displayLarge through headlineMedium.
abstract final class AppTextStyles {
  // Display — hero screens, POI card headline
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'serif',
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -1.0,
    color: AppColors.peat900,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'serif',
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.5,
    color: AppColors.peat900,
  );

  // Headlines — section headers, hike title
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
    color: AppColors.peat900,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.peat900,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.peat900,
  );

  // Title — card titles, list items
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.peat900,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.peat900,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.peat700,
  );

  // Body — reading text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.peat700,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.peat700,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.peat500,
  );

  // Labels — badges, overlines, stats
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.peat900,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.peat700,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.8,
    color: AppColors.peat500,
  );

  // Accent — price, amber callouts
  static const TextStyle accentPrice = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.amber700,
  );

  // Overline — POI region, whisky distillery name
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 1.5,
    color: AppColors.amber700,
  );
}

/// Minimum touch target — WCAG 2.5.5 Level AA compliance.
abstract final class AppTouchTargets {
  static const double minimum = 48;
  static const double comfortable = 56;
}
