import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SyncTheme {
  // True OLED Black (#000000)
  static const Color oledBlack = Color(0xFF000000);
  
  // Stark White for text/icons
  static const Color starkWhite = Color(0xFFFFFFFF);
  
  // Muted Greys for secondary elements
  static const Color mutedGrey = Color(0xFFA0A0A0);
  static const Color darkGrey = Color(0xFF1E1E1E);

  static ThemeData get minimalistTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: oledBlack,
      primaryColor: starkWhite,
      canvasColor: oledBlack,
      
      // Zero nonsense colors
      colorScheme: const ColorScheme.dark(
        primary: starkWhite,
        secondary: mutedGrey,
        surface: oledBlack,
        background: oledBlack,
        error: Colors.redAccent,
        onPrimary: oledBlack,
        onSecondary: starkWhite,
        onSurface: starkWhite,
        onBackground: starkWhite,
      ),

      // Minimalist Typography using Google Fonts (Inter)
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w300, color: starkWhite),
        displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w300, color: starkWhite),
        displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w300, color: starkWhite),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w300, color: starkWhite),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400, color: starkWhite),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w300, color: starkWhite),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w300, color: mutedGrey),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: starkWhite),
        labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w300, color: mutedGrey),
      ),

      // Remove default borders and shadows
      appBarTheme: const AppBarTheme(
        backgroundColor: oledBlack,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: starkWhite, size: 28),
      ),
      
      iconTheme: const IconThemeData(
        color: starkWhite,
        size: 28,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: oledBlack,
        elevation: 0,
        selectedItemColor: starkWhite,
        unselectedItemColor: mutedGrey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),

      // Strip cards of elevation and outlines
      cardTheme: const CardThemeData(
        color: oledBlack,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      
      // Remove splash effects
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );
  }
}
