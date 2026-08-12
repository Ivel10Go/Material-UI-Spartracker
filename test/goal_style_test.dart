// Prüft die Symbol- und Farbtabellen samt ihrer Übersetzungen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spartracker/l10n/gen/app_localizations.dart';
import 'package:spartracker/l10n/l10n_labels.dart';
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

  test('Symbole stammen aus der Material-Icon-Schrift', () {
    // Konstante IconData sind Voraussetzung dafür, dass Flutter die
    // Icon-Fonts im Release-Build ausdünnen kann.
    for (final icon in allIcons) {
      expect(icon.icon.fontFamily, 'MaterialIcons', reason: icon.key);
    }
  });

  test('Farbauswahl hat eindeutige Schlüssel und Werte', () {
    final keys = kGoalColorChoices.map((c) => c.key).toList();
    final values = kGoalColorChoices.map((c) => c.color.toARGB32()).toList();
    expect(keys.toSet().length, keys.length);
    expect(values.toSet().length, values.length);
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

  // Kern der Lokalisierung: Jeder Schlüssel muss in *beiden* Sprachen einen
  // eigenen Text haben. Ohne das fiele ein vergessener Eintrag lautlos auf
  // "Sparschwein" zurück - sichtbar erst beim Nutzer.
  group('Übersetzungen', () {
    for (final locale in AppLocalizations.supportedLocales) {
      group(locale.languageCode, () {
        late AppLocalizations t;

        setUp(() async {
          t = await AppLocalizations.delegate.load(locale);
        });

        test('jedes Symbol hat einen eigenen Namen', () {
          final labels = <String, String>{};
          for (final icon in allIcons) {
            final label = t.goalIconLabel(icon.key);
            expect(label.trim(), isNotEmpty, reason: icon.key);
            labels[icon.key] = label;
          }
          // Doppelte Namen wären ein Zeichen für einen fehlenden Eintrag,
          // der still auf den Standardtext zurückfällt.
          final duplicates = labels.values
              .fold<Map<String, int>>({}, (map, label) {
                map[label] = (map[label] ?? 0) + 1;
                return map;
              })
              ..removeWhere((_, count) => count < 2);
          expect(duplicates, isEmpty, reason: 'Doppelte Symbolnamen');
        });

        test('jede Gruppe hat eine Überschrift', () {
          for (final group in GoalIconGroup.values) {
            expect(t.goalIconGroupLabel(group).trim(), isNotEmpty);
          }
        });

        test('jede Farbe hat einen eigenen Namen', () {
          final names = kGoalColorChoices
              .map((c) => t.goalColorLabel(c.key))
              .toList();
          for (final name in names) {
            expect(name.trim(), isNotEmpty);
          }
          expect(names.toSet().length, names.length);
        });

        test('es gibt Vorschläge für die Quelle', () {
          expect(t.entrySourceSuggestions, isNotEmpty);
          for (final suggestion in t.entrySourceSuggestions) {
            expect(suggestion.trim(), isNotEmpty);
          }
        });
      });
    }

    test('Deutsch und Englisch unterscheiden sich tatsächlich', () async {
      final de = await AppLocalizations.delegate.load(const Locale('de'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      expect(de.goalIconLabel('bike'), 'Fahrrad');
      expect(en.goalIconLabel('bike'), 'Bicycle');
      expect(de.settingsTitle, isNot(en.settingsTitle));
      expect(de.homeEmptyTitle, isNot(en.homeEmptyTitle));
    });
  });
}
