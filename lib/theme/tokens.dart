import 'package:flutter/material.dart';

/// Material-3-Design-Tokens der App.
///
/// MD3 verlangt, dass Abstände und Formen aus einem festen Token-Satz
/// kommen statt als verstreute Zahlenliterale im Widget-Code zu stehen.
/// Nur so lassen sich Dichte und Gerätekategorie später zentral ändern.

/// Abstandsskala auf 4dp-Basis (`md.sys.spacing`).
abstract final class Spacing {
  /// 4dp - Feinabstimmung innerhalb einer Komponente.
  static const double xxs = 4;

  /// 8dp - Abstand zwischen eng zusammengehörenden Elementen.
  static const double xs = 8;

  /// 12dp - Innenabstand kompakter Komponenten.
  static const double sm = 12;

  /// 16dp - Standard-Innenabstand, Rand auf kompakten Fenstern.
  static const double md = 16;

  /// 24dp - Abstand zwischen Komponenten, Rand ab Medium.
  static const double lg = 24;

  /// 32dp - Abstand zwischen Abschnitten.
  static const double xl = 32;

  /// 48dp - großzügige Trennung, z. B. um leere Zustände herum.
  static const double xxl = 48;
}

/// Eckradien der MD3-Shape-Skala (`md.sys.shape.corner`).
abstract final class Corner {
  static const Radius extraSmall = Radius.circular(4);
  static const Radius small = Radius.circular(8);
  static const Radius medium = Radius.circular(12);
  static const Radius large = Radius.circular(16);
  static const Radius largeIncreased = Radius.circular(20);
  static const Radius extraLarge = Radius.circular(28);
  static const Radius extraLargeIncreased = Radius.circular(32);

  static const BorderRadius extraSmallAll = BorderRadius.all(extraSmall);
  static const BorderRadius smallAll = BorderRadius.all(small);
  static const BorderRadius mediumAll = BorderRadius.all(medium);
  static const BorderRadius largeAll = BorderRadius.all(large);
  static const BorderRadius largeIncreasedAll = BorderRadius.all(
    largeIncreased,
  );
  static const BorderRadius extraLargeAll = BorderRadius.all(extraLarge);

  /// Vollständig gerundet - für Pills, Chips und Fortschrittsbalken.
  static const BorderRadius full = BorderRadius.all(Radius.circular(999));
}

/// Kleinste Größe für berührbare Flächen (WCAG / MD3: 48dp).
const double kMinTouchTarget = 48;

/// MD3-Fensterklassen. Bestimmen Ränder, Spaltenzahl und Navigationsform.
enum WindowSizeClass {
  /// < 600dp - Telefon im Hochformat.
  compact,

  /// 600-839dp - Tablet im Hochformat, aufgeklapptes Foldable.
  medium,

  /// 840-1199dp - Tablet im Querformat, kleiner Desktop.
  expanded,

  /// 1200-1599dp - Desktop.
  large,

  /// >= 1600dp - sehr breite Bildschirme.
  extraLarge;

  /// True ab Medium - dort beginnen breitere Ränder und mehrspaltige Layouts.
  bool get isAtLeastMedium => index >= WindowSizeClass.medium.index;
}

/// Ermittelt die Fensterklasse aus der aktuellen Fensterbreite.
WindowSizeClass windowSizeClassOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return WindowSizeClass.compact;
  if (width < 840) return WindowSizeClass.medium;
  if (width < 1200) return WindowSizeClass.expanded;
  if (width < 1600) return WindowSizeClass.large;
  return WindowSizeClass.extraLarge;
}

/// Maximale Breite einer einspaltigen Inhaltsspalte.
///
/// MD3 rät ausdrücklich davon ab, Inhalt auf breiten Fenstern über die
/// gesamte Breite zu ziehen - lange Zeilen sind schlecht lesbar.
const double kMaxContentWidth = 840;

/// Seitlicher Rand, der den Inhalt auf breiten Fenstern zentriert und auf
/// [kMaxContentWidth] begrenzt.
///
/// Auf schmalen Fenstern bleibt es beim regulären MD3-Rand
/// (16dp kompakt, 24dp ab Medium).
EdgeInsets adaptivePageMargin(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final margin = windowSizeClassOf(context) == WindowSizeClass.compact
      ? Spacing.md
      : Spacing.lg;

  final side = width - 2 * margin > kMaxContentWidth
      ? (width - kMaxContentWidth) / 2
      : margin;

  return EdgeInsets.symmetric(horizontal: side);
}
