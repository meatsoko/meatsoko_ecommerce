import 'package:flutter/material.dart';


// Brighter than the light theme's BrandColors.burgundyDark on purpose:
// against this theme's dark surfaces (~0xFF242424), burgundyDark reads as
// near-black and buttons/accents lose contrast. BrandColors.burgundy is the
// same shade user_app uses for its own dark theme, already proven legible.
Color _primaryColor = const Color(0xFF7A1C1C); // BrandColors.burgundy
Color _secondaryColor = const Color(0xFFE5A93C); // BrandColors.ochre

ThemeData dark = ThemeData(
  fontFamily: 'TitilliumWeb',
  primaryColor: _primaryColor,
  brightness: Brightness.dark,
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent),
  highlightColor: const Color(0xFF252525),
  hintColor: const Color(0xFFc7c7c7),
  cardColor: const Color(0xFF333333),


  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFE9EEF4)),  // Text color primary
    bodyMedium: TextStyle(color: Color(0xFFE9EEF4)), // Text color Secondary
    bodySmall: TextStyle(color: Color(0xFFE9EEF4)),  // Text color Light grey
    headlineMedium: TextStyle(color: Color(0xFFA0A0A0)),
    headlineLarge : TextStyle(color: Color(0xFF656566)),
  ),


  colorScheme : ColorScheme.dark(
      primary: _primaryColor,  // Primary Color
      secondary: _secondaryColor,  // Secondary Color
      tertiary: const Color(0xFFFFBB38), // Warning Color
      tertiaryContainer: const Color(0xFF8E6C74),
      onTertiaryContainer: const Color(0xFF04BB7B), // Success Color
      primaryContainer: const Color(0xFF208458),
      secondaryContainer: const Color(0xFFF2F2F2),
      surface: const Color(0xFF242424),
      outline: const Color(0xff5C8FFC), // Info Color / Pending color
      surfaceTint: const Color(0xff5C8FFC),
      onPrimary: const Color(0xFFE8B4B4),
      onSecondary: const Color(0xFF3D0C0C),
      error: const Color(0xFFFF4040), // Danger Color
  ),

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);
