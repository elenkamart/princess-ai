import 'package:flutter/material.dart';

/// Princess AI Dress-Up design system: tokens and the one app theme built
/// from them. Names match the published design system (tokens.json v2).
///
/// Fonts: the theme asks for Nunito (body) and Baloo 2 (display). Until those
/// font files are added under assets/fonts and declared in pubspec.yaml,
/// Flutter falls back to the platform font.

class PrincessColors {
  PrincessColors._();

  // Grounds
  static const Color canvas = Color(0xFFFFF6E9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfacePink = Color(0xFFFFF0F4);
  static const Color border = Color(0xFFF1DCCB);
  static const Color borderStrong = Color(0xFFE2C3AB);

  // Text
  static const Color ink = Color(0xFF2B2147);
  static const Color inkMuted = Color(0xFF5F5677);
  static const Color onBerry = Color(0xFFFFFFFF);

  // Brand and rewards
  static const Color berry = Color(0xFFD13667);
  static const Color berryDeep = Color(0xFF9E1F4B);
  static const Color berryTint = Color(0xFFFFD6E3);
  static const Color star = Color(0xFFFFC23D);
  static const Color starDeep = Color(0xFFC98A00);

  // Occasion pairs and art colors
  static const Color sky = Color(0xFF2A73C0);
  static const Color skyDeep = Color(0xFF1D5594);
  static const Color skyTint = Color(0xFFDCECFF);
  static const Color mint = Color(0xFF3CC48F);
  static const Color mintDeep = Color(0xFF17694B);
  static const Color mintTint = Color(0xFFD9F5E8);
  static const Color lilac = Color(0xFF8A63D2);
  static const Color lilacDeep = Color(0xFF5B3AA6);
  static const Color lilacTint = Color(0xFFECE3FF);
  static const Color coral = Color(0xFFFF7A59);
  static const Color coralDeep = Color(0xFFB8401F);
  static const Color coralTint = Color(0xFFFFE2D9);
  static const Color sandDeep = Color(0xFF8A5A00);
  static const Color sandTint = Color(0xFFFFF1C7);
  static const Color rainDeep = Color(0xFF3D6B7A);
  static const Color rainTint = Color(0xFFE3EEF2);
  static const Color night = Color(0xFF3A3170);
  static const Color scrim = Color(0x732B2147);
}

/// The occasions and their card tint + text/icon color.
enum PrincessOccasion {
  school('School', PrincessColors.skyTint, PrincessColors.skyDeep),
  park('Park', PrincessColors.mintTint, PrincessColors.mintDeep),
  beach('Beach', PrincessColors.sandTint, PrincessColors.sandDeep),
  sports('Sports', PrincessColors.mintTint, PrincessColors.mintDeep),
  snowplay('Snow day', PrincessColors.rainTint, PrincessColors.rainDeep),
  swimming('Swimming', PrincessColors.skyTint, PrincessColors.skyDeep),
  ballet('Ballet', PrincessColors.berryTint, PrincessColors.berryDeep),
  party('Party', PrincessColors.berryTint, PrincessColors.berryDeep),
  birthday('Birthday', PrincessColors.sandTint, PrincessColors.sandDeep),
  halloween('Halloween', PrincessColors.coralTint, PrincessColors.coralDeep),
  christmas('Christmas', PrincessColors.mintTint, PrincessColors.mintDeep),
  bedtime('Bedtime', PrincessColors.lilacTint, PrincessColors.lilacDeep);

  const PrincessOccasion(this.label, this.tint, this.deep);

  final String label;
  final Color tint;
  final Color deep;
}

class PrincessSpace {
  PrincessSpace._();

  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
}

class PrincessRadius {
  PrincessRadius._();

  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r28 = 28;
  static const double pill = 999;
}

class PrincessSizes {
  PrincessSizes._();

  static const double tap = 64;
  static const double tapMin = 56;
  static const double itemTileMin = 118;
  static const double starMeter = 52;
  static const double outline = 3;
  static const double focusRing = 4;
  static const Duration press = Duration(milliseconds: 120);
}

class PrincessShadows {
  PrincessShadows._();

  /// Solid edges under buttons; shrink the offset to 2 while pressed.
  static const List<BoxShadow> pressBerry = [
    BoxShadow(color: PrincessColors.berryDeep, offset: Offset(0, 6)),
  ];
  static const List<BoxShadow> pressWhite = [
    BoxShadow(color: PrincessColors.borderStrong, offset: Offset(0, 6)),
  ];
  static const List<BoxShadow> pressStar = [
    BoxShadow(color: PrincessColors.starDeep, offset: Offset(0, 6)),
  ];
  static const List<BoxShadow> lift = [
    BoxShadow(color: Color(0x1F2B2147), blurRadius: 24, offset: Offset(0, 10)),
  ];
}

class PrincessText {
  PrincessText._();

  static const String display = 'Baloo 2';
  static const String body = 'Nunito';
  static const List<String> fallback = ['Trebuchet MS', 'Segoe UI', 'Roboto'];

  static const TextStyle gameTitle = TextStyle(fontFamily: display, fontFamilyFallback: fallback, fontSize: 30, height: 1.05, fontWeight: FontWeight.w800);
  static const TextStyle sheetTitle = TextStyle(fontFamily: display, fontFamilyFallback: fallback, fontSize: 28, height: 1.1, fontWeight: FontWeight.w800);
  static const TextStyle panelTitle = TextStyle(fontFamily: display, fontFamilyFallback: fallback, fontSize: 26, height: 1.1, fontWeight: FontWeight.w800);
  static const TextStyle occasion = TextStyle(fontFamily: display, fontFamilyFallback: fallback, fontSize: 22, height: 1.15, fontWeight: FontWeight.w700);
  static const TextStyle speech = TextStyle(fontFamily: display, fontFamilyFallback: fallback, fontSize: 21, height: 1.3, fontWeight: FontWeight.w700);
  static const TextStyle button = TextStyle(fontFamily: display, fontFamilyFallback: fallback, fontSize: 20, height: 1, fontWeight: FontWeight.w700);

  static const TextStyle bodyText = TextStyle(fontFamily: body, fontFamilyFallback: fallback, fontSize: 18, height: 1.45, fontWeight: FontWeight.w600);
  static const TextStyle tab = TextStyle(fontFamily: body, fontFamilyFallback: fallback, fontSize: 17, height: 1.2, fontWeight: FontWeight.w800);
  static const TextStyle caption = TextStyle(fontFamily: body, fontFamilyFallback: fallback, fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: PrincessColors.inkMuted);
  static const TextStyle itemName = TextStyle(fontFamily: body, fontFamilyFallback: fallback, fontSize: 15, height: 1.2, fontWeight: FontWeight.w800);

  /// Uppercase the string yourself and color it with the occasion's deep color.
  static const TextStyle kicker = TextStyle(fontFamily: body, fontFamilyFallback: fallback, fontSize: 13, height: 1.2, fontWeight: FontWeight.w800, letterSpacing: 0.8);
}

class PrincessTheme {
  PrincessTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: PrincessColors.berry,
      brightness: Brightness.light,
      primary: PrincessColors.berry,
      onPrimary: PrincessColors.onBerry,
      secondary: PrincessColors.star,
      onSecondary: PrincessColors.ink,
      surface: PrincessColors.surface,
      onSurface: PrincessColors.ink,
      error: PrincessColors.coralDeep,
    );

    const pill = StadiumBorder();
    const buttonSize = Size(PrincessSizes.tap, PrincessSizes.tap);
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(PrincessRadius.r20),
      borderSide: const BorderSide(color: PrincessColors.border, width: 3),
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: PrincessText.body,
      fontFamilyFallback: PrincessText.fallback,
    );

    return base.copyWith(
      scaffoldBackgroundColor: PrincessColors.canvas,
      textTheme: base.textTheme.apply(
        bodyColor: PrincessColors.ink,
        displayColor: PrincessColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PrincessColors.canvas,
        foregroundColor: PrincessColors.ink,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: PrincessText.gameTitle,
      ),
      cardTheme: CardThemeData(
        color: PrincessColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PrincessRadius.r28)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PrincessColors.berry,
          foregroundColor: PrincessColors.onBerry,
          minimumSize: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: PrincessSpace.s24),
          textStyle: PrincessText.button,
          shape: pill,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PrincessColors.berry,
          foregroundColor: PrincessColors.onBerry,
          minimumSize: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: PrincessSpace.s24),
          textStyle: PrincessText.button,
          shape: pill,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: PrincessColors.surface,
          foregroundColor: PrincessColors.ink,
          minimumSize: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: PrincessSpace.s24),
          textStyle: PrincessText.button,
          side: const BorderSide(color: PrincessColors.borderStrong, width: 3),
          shape: pill,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PrincessColors.ink,
          minimumSize: const Size(PrincessSizes.tapMin, PrincessSizes.tapMin),
          textStyle: PrincessText.tab,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(PrincessSizes.tapMin, PrincessSizes.tapMin),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PrincessColors.surface,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: PrincessColors.sky, width: PrincessSizes.focusRing),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PrincessColors.surface,
        selectedColor: PrincessColors.surfacePink,
        labelStyle: PrincessText.tab,
        side: const BorderSide(color: PrincessColors.border, width: 3),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: PrincessSpace.s12, vertical: PrincessSpace.s8),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: PrincessColors.berry,
        thumbColor: PrincessColors.berry,
        inactiveTrackColor: PrincessColors.berryTint,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? PrincessColors.surface : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? PrincessColors.berry : null,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PrincessColors.ink,
        contentTextStyle: PrincessText.bodyText.copyWith(color: PrincessColors.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PrincessRadius.r28)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: PrincessColors.surface,
        barrierColor: PrincessColors.scrim,
        titleTextStyle: PrincessText.sheetTitle.copyWith(color: PrincessColors.ink),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PrincessRadius.r28)),
      ),
    );
  }
}
