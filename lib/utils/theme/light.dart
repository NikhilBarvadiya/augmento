import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConfig {
  static MaterialColor createPrimarySwatch() {
    return MaterialColor(0xFF2B6777, {
      50: Color(0xFFE3F8FD),
      100: Color(0xFFBBEDFB),
      200: Color(0xFF91E2F8),
      300: Color(0xFF65D7F5),
      400: Color(0xFF44CEF3),
      500: Color(0xFF2B6777),
      600: Color(0xFF205E6F),
      700: Color(0xFF1B505E),
      800: Color(0xFF17434F),
      900: Color(0xFF102F37),
    });
  }

  static ThemeData getThemeByIndex(BuildContext context) {
    return _tealTheme(context);
  }

  static ColorScheme getColorSchemeByIndex(int index) {
    return _tealColorScheme;
  }

  static const _tealColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2B6777),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE3F8FD),
    onPrimaryContainer: Color(0xFF144552),
    secondary: Color(0xFF2E9BB8),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF3F6F7),
    onSecondaryContainer: Color(0xFF1D5463),
    tertiary: Color(0xFF1B9ABB),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFF0F3F4),
    onTertiaryContainer: Color(0xFF034F63),
    error: Color(0xFFD32F2F),
    errorContainer: Color(0xFFFFEBEE),
    onError: Color(0xFFFFFFFF),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1C1E),
    surfaceContainer: Color(0xFFF8F9FA),
    surfaceContainerHighest: Color(0xFFF5F5F5),
    onSurfaceVariant: Color(0xFF424242),
    outline: Color(0xFF757575),
    onInverseSurface: Color(0xFFF1F0F4),
    inverseSurface: Color(0xFF2F3033),
    inversePrimary: Color(0xFF91E2F8),
    shadow: Color(0xFF000000),
    surfaceTint: Color(0xFF2B6777),
    outlineVariant: Color(0xFFBDBDBD),
    scrim: Color(0xFF000000),
  );

  static ThemeData _tealTheme(BuildContext context) => _buildTheme(_tealColorScheme, context);

  static ThemeData _buildTheme(ColorScheme colorScheme, BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: createPrimarySwatch(),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: colorScheme.onSurface, displayColor: colorScheme.onSurface),
      cardTheme: cardThemeData(colorScheme),
      appBarTheme: appBarThemeData(colorScheme),
      dialogTheme: dialogTheme,
      elevatedButtonTheme: elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: outlinedButtonTheme(colorScheme),
      textButtonTheme: textButtonTheme(colorScheme),
      inputDecorationTheme: inputDecorationTheme(colorScheme),
      iconTheme: iconTheme(colorScheme),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: colorScheme.primary,
        textTheme: CupertinoTextThemeData(textStyle: GoogleFonts.poppins(color: colorScheme.onSurface)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 4,
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashColor: colorScheme.primary.withOpacity(0.12),
      highlightColor: colorScheme.primary.withOpacity(0.08),
    );
  }

  static CardThemeData cardThemeData(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 2,
      color: colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: colorScheme.surface,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
    );
  }

  static AppBarThemeData appBarThemeData(ColorScheme colorScheme) {
    return AppBarThemeData(
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0.0,
      scrolledUnderElevation: 1,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.primary,
      shadowColor: colorScheme.shadow,
      surfaceTintColor: colorScheme.surfaceTint,
      iconTheme: IconThemeData(color: colorScheme.primary),
      titleTextStyle: GoogleFonts.poppins(fontSize: 20, letterSpacing: 0.5, fontWeight: FontWeight.w600),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  static const DialogThemeData dialogTheme = DialogThemeData(
    elevation: 4,
    backgroundColor: Color(0xFFFFFFFF),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  );

  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        elevation: 2,
      ),
    );
  }

  static OutlinedButtonThemeData outlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
      hintStyle: GoogleFonts.poppins(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
    );
  }

  static IconThemeData iconTheme(ColorScheme colorScheme) {
    return IconThemeData(color: colorScheme.onSurface, size: 24);
  }

  static List<ThemeData> getAllThemes(BuildContext context) {
    return [_tealTheme(context)];
  }

  static List<Map<String, dynamic>> getThemeOptions() {
    return [
      {
        'name': 'Professional Teal',
        'description': 'Calm and trustworthy',
        'colors': [Color(0xFF2B6777), Color(0xFF2E9BB8), Color(0xFF1B9ABB)],
        'index': 0,
      },
    ];
  }
}
