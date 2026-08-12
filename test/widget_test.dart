// Smoke-Tests: Die App startet ohne Fehler und respektiert die
// Spracheinstellung. Der Datenbank-Stream lädt asynchron (native
// sqlite3), daher wird bewusst nicht auf pumpAndSettle() gewartet - die
// anfängliche Ladeanzeige animiert unendlich und würde den Timeout
// auslösen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spartracker/main.dart';
import 'package:spartracker/settings/app_settings.dart';

/// Startet die App mit den übergebenen gespeicherten Einstellungen.
Future<void> pumpApp(
  WidgetTester tester, {
  Map<String, Object> preferences = const {},
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SpartrackerApp(),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('Spartracker startet und zeigt den Home-Screen', (tester) async {
    await pumpApp(tester);
    expect(find.text('Spartracker'), findsAtLeastNWidgets(1));
  });

  testWidgets('Gespeicherte Sprache "Deutsch" zeigt deutsche Texte', (
    tester,
  ) async {
    await pumpApp(
      tester,
      preferences: {'settings.language': AppLanguage.german.name},
    );
    expect(find.text('Sparziele'), findsOneWidget);
  });

  testWidgets('Gespeicherte Sprache "Englisch" zeigt englische Texte', (
    tester,
  ) async {
    await pumpApp(
      tester,
      preferences: {'settings.language': AppLanguage.english.name},
    );
    expect(find.text('Savings goals'), findsOneWidget);
    expect(find.text('Sparziele'), findsNothing);
  });
}
