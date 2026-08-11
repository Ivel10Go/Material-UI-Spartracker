// Prüft die Symbol-Tabelle: eindeutige Schlüssel, auflösbare Werte und
// die Rückfallebene für unbekannte Einträge.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spartracker/models/goal_style.dart';

void main() {
  final allIcons = kGoalIconGroups.values.expand((g) => g).toList();

  test('Symbol-Schlüssel sind eindeutig', () {
    final keys = allIcons.map((i) => i.key).toList();
    expect(keys.toSet().length, keys.length, reason: 'Doppelter Schlüssel');
  });

  test('Jeder Schlüssel liefert sein eigenes Symbol zurück', () {
    for (final icon in allIcons) {
      expect(goalIconOrDefault(icon.key), icon.icon, reason: icon.key);
      expect(goalIconLabel(icon.key), icon.label);
    }
  });

  test('Unbekannte und fehlende Schlüssel fallen auf den Standard zurück', () {
    expect(goalIconOrDefault(null), kDefaultGoalIcon);
    expect(goalIconOrDefault('gibt-es-nicht'), kDefaultGoalIcon);
    expect(goalIconOrDefault(''), kDefaultGoalIcon);
  });

  test('Der Standardschlüssel existiert im Katalog', () {
    expect(allIcons.map((i) => i.key), contains(kDefaultGoalIconKey));
    expect(goalIconOrDefault(kDefaultGoalIconKey), kDefaultGoalIcon);
  });

  test('Jedes Symbol hat einen nicht-leeren Namen', () {
    for (final icon in allIcons) {
      expect(icon.label.trim(), isNotEmpty, reason: icon.key);
    }
  });

  test('Symbole stammen aus der Material-Icon-Schrift', () {
    // Konstante IconData sind Voraussetzung dafür, dass Flutter die
    // Icon-Fonts im Release-Build ausdünnen kann.
    for (final icon in allIcons) {
      expect(icon.icon.fontFamily, 'MaterialIcons', reason: icon.key);
    }
  });

  test('Farbauswahl hat eindeutige Namen und Werte', () {
    final names = kGoalColorChoices.map((c) => c.name).toList();
    final values = kGoalColorChoices.map((c) => c.color.toARGB32()).toList();
    expect(names.toSet().length, names.length);
    expect(values.toSet().length, values.length);
    for (final name in names) {
      expect(name.trim(), isNotEmpty);
    }
  });

  test('Standardfarbe ist Teil der Auswahl', () {
    expect(
      kGoalColorChoices.map((c) => c.color.toARGB32()),
      contains(kDefaultGoalColor.toARGB32()),
    );
  });

  test('goalColorFromValue fällt bei null auf die Standardfarbe zurück', () {
    expect(goalColorFromValue(null), kDefaultGoalColor);
    const blue = Color(0xFF1565C0);
    expect(goalColorFromValue(blue.toARGB32()), blue);
  });
}
