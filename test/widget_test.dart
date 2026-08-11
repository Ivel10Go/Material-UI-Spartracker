// Einfacher Smoke-Test: Die App startet ohne Fehler und zeigt den
// Home-Screen. Der eigentliche Datenbank-Stream lädt asynchron (native
// sqlite3), daher wird hier bewusst nicht auf pumpAndSettle() gewartet -
// die anfängliche Ladeanzeige (CircularProgressIndicator) animiert
// unendlich und würde den Timeout auslösen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spartracker/main.dart';

void main() {
  testWidgets('Spartracker startet und zeigt den Home-Screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SpartrackerApp()),
    );
    await tester.pump();

    // SliverAppBar.large rendert den Titel zweimal (eingeklappt und
    // ausgeklappt), daher hier bewusst kein findsOneWidget.
    expect(find.text('Spartracker'), findsAtLeastNWidgets(1));
  });
}
