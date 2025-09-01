import 'package:flutter/material.dart';

/// Responsive Layout System für verschiedene Bildschirmgrößen
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop;
        } else if (constraints.maxWidth >= 768) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Breakpoints für verschiedene Bildschirmgrößen
class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1024;
  static const double desktop = 1200;
}

/// Responsive Builder für bedingte Widgets
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < ResponsiveBreakpoints.mobile;
        final isTablet = constraints.maxWidth >= ResponsiveBreakpoints.mobile && 
                        constraints.maxWidth < ResponsiveBreakpoints.desktop;
        final isDesktop = constraints.maxWidth >= ResponsiveBreakpoints.desktop;

        return builder(context, isMobile, isTablet, isDesktop);
      },
    );
  }
}

/// Plattform-Erkennung
class PlatformUtils {
  static bool get isWeb => identical(0, 0.0);
  static bool get isMobile => !isWeb;
  
  /// Gibt die aktuelle Plattform zurück
  static String get platform {
    if (isWeb) return 'web';
    return 'mobile';
  }
}

/// ResponsiveLayout Utility Methods
class ResponsiveLayoutUtils {
  /// Prüft, ob der aktuelle Kontext mobile Größe hat
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;
  }
  
  /// Prüft, ob der aktuelle Kontext Tablet-Größe hat
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.mobile && width < ResponsiveBreakpoints.desktop;
  }
  
  /// Prüft, ob der aktuelle Kontext Desktop-Größe hat
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktop;
  }
}
