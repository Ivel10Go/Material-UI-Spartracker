// Prüft den echten Bedienweg: Zahnrad antippen, Sprache umstellen,
// Farbe wählen - und dass die App das sofort übernimmt.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spartracker/main.dart';
import 'package:spartracker/settings/app_settings.dart';

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  Map<String, Object> preferences = const {},
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const SpartrackerApp(),
    ),
  );
  await tester.pump();
  return container;
}

/// Öffnet die Einstellungen über das Zahnrad in der App-Bar.
Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('Zahnrad öffnet die Einstellungen', (tester) async {
    await pumpApp(tester, preferences: {'settings.language': 'german'});
    await openSettings(tester);

    expect(find.text('Einstellungen'), findsAtLeastNWidgets(1));
    expect(find.text('Systemfarben verwenden'), findsOneWidget);
    expect(find.text('Sprache'), findsOneWidget);
  });

  testWidgets('Sprachwechsel auf Englisch schlägt sofort durch', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      preferences: {'settings.language': 'german'},
    );
    await openSettings(tester);

    // Deutsch ist aktiv ...
    expect(find.text('Darstellung'), findsOneWidget);

    // ... auf Englisch umstellen.
    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(settingsProvider).language, AppLanguage.english);
    // Der Bildschirm selbst ist jetzt englisch beschriftet.
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Darstellung'), findsNothing);
  });

  testWidgets('Eigene Farbe wählen schaltet die Systemfarben ab', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      preferences: {'settings.language': 'english'},
    );
    await openSettings(tester);

    expect(container.read(settingsProvider).useDynamicColor, isTrue);

    // Farbfelder tragen ihren Namen - hier "Green".
    await tester.tap(find.bySemanticsLabel('Green').first);
    await tester.pump();

    final settings = container.read(settingsProvider);
    expect(settings.useDynamicColor, isFalse);
    expect(settings.seedColor.toARGB32(), const Color(0xFF2E7D32).toARGB32());
  });

  testWidgets('Die Startseite folgt der gewählten Sprache', (tester) async {
    await pumpApp(tester, preferences: {'settings.language': 'german'});
    expect(find.text('Sparziele'), findsOneWidget);

    await openSettings(tester);
    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Zurück zur Startseite - sie ist jetzt ebenfalls englisch.
    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Savings goals'), findsOneWidget);
  });
}
