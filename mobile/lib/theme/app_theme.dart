import 'package:flutter/material.dart';

class AppTheme {
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentLight = Color(0xFF9C97FF);
  static const Color surface = Color(0xFF1E1E2E);
  static const Color surfaceVariant = Color(0xFF2A2A3E);
  static const Color background = Color(0xFF13131F);
  static const Color onSurface = Color(0xFFE8E8F0);
  static const Color onSurfaceMuted = Color(0xFF8888AA);
  static const Color divider = Color(0xFF2E2E42);
  static const Color error = Color(0xFFFF6B6B);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentLight,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      cardTheme: CardTheme(
        color: surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: onSurfaceMuted,
        textColor: onSurface,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? accent : Colors.grey),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? accent.withOpacity(0.4) : Colors.grey.withOpacity(0.3)),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: divider,
        thumbColor: accent,
        overlayColor: Color(0x336C63FF),
        trackHeight: 3,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: onSurfaceMuted, fontWeight: FontWeight.w400),
        bodyLarge: TextStyle(color: onSurface),
        bodyMedium: TextStyle(color: onSurfaceMuted),
        labelLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w500),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accentLight,
        surface: Color(0xFFF5F5FF),
        onPrimary: Colors.white,
        onSurface: Color(0xFF1A1A2E),
        error: error,
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F0F8),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF0F0F8),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
      ),
    );
  }
}

// Extension accessible statically
extension AppThemeExtension on ThemeData {
  bool get isDark => brightness == Brightness.dark;
}
