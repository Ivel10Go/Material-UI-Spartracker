import 'package:flutter/material.dart';

import 'tokens.dart';

/// Fallback-Seed, falls das System keine dynamischen Farben liefert
/// (z. B. Android < 12). Entspricht dem Material-You-Standardviolett.
const Color kFallbackSeedColor = Color(0xFF6750A4);

/// Baut das App-Theme nach Material 3 aus einem [ColorScheme].
///
/// Tiefe entsteht über tonale Flächen statt über Schatten, Formen kommen
/// aus der MD3-Shape-Skala ([Corner]) und Bewegung aus den MD3-Easing-Kurven.
ThemeData buildAppTheme(ColorScheme scheme) {
  final textTheme = Typography.material2021(
    colorScheme: scheme,
  ).black.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,

    // Zentrale Shape-Skala: Komponenten ohne eigene Form greifen hierauf zu.
    visualDensity: VisualDensity.standard,

    // Small Top App Bar (64dp) - laut Spezifikation mit titleLarge.
    // Beim Scrollen hebt sie sich tonal ab (Elevation Level 2).
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: scheme.surfaceTint,
      elevation: 0,
      scrolledUnderElevation: 3,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
    ),

    // Tonale Cards ohne Schatten - MD3 kommuniziert Tiefe über Farbe.
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: Corner.extraLargeAll),
    ),

    // Buttons sind in MD3 vollständig gerundet; 48dp Mindesthöhe erfüllt
    // zugleich die Vorgabe für Berührungsziele.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, kMinTouchTarget),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, kMinTouchTarget),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, kMinTouchTarget),
        shape: const StadiumBorder(),
      ),
    ),

    // FAB: Elevation Level 3 laut Spezifikation, Radius large.
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 6,
      focusElevation: 6,
      hoverElevation: 8,
      shape: RoundedRectangleBorder(borderRadius: Corner.largeAll),
    ),

    // Gefüllte Eingabefelder mit Radius extraSmall oben - MD3-Standard für
    // Textfelder ist die kleine Shape-Stufe, nicht die große.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: const OutlineInputBorder(
        borderRadius: Corner.smallAll,
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: Corner.smallAll,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: Corner.smallAll,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: Corner.smallAll,
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: Corner.smallAll,
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    ),

    // Modale BottomSheets: Radius extraLarge oben, auf breiten Fenstern
    // begrenzt - sonst zieht sich das Sheet über den ganzen Desktop.
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Corner.extraLarge),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: Corner.extraLargeAll),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      shape: const RoundedRectangleBorder(borderRadius: Corner.extraSmallAll),
    ),

    listTileTheme: const ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: Corner.largeAll),
      minVerticalPadding: Spacing.sm,
    ),

    // Trennlinien nutzen outlineVariant; `outline` bleibt echten
    // Begrenzungen wie Textfeldrändern vorbehalten.
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      space: 1,
      thickness: 1,
    ),

    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: Corner.smallAll),
    ),

    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: scheme.outlineVariant),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      // Aktueller Material-3-Look (abgerundete Enden, Lücke zum Track,
      // Stop-Indikator). Das Flag ist als deprecated markiert, der Default
      // ist in dieser Flutter-Version aber weiterhin `true` (= alter Look),
      // daher aktuell die einzige Möglichkeit zum Opt-in.
      // ignore: deprecated_member_use
      year2023: false,
    ),

    // MD3-Bewegung: Seitenwechsel laufen mit der "emphasized"-Kurve.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}
