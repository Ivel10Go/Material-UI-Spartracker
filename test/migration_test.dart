// Prüft die Migration v1 -> v2: aus zielgebundenen Einträgen werden
// Kontobuchungen plus Zuteilungen, ohne dass Geld verloren geht.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:spartracker/data/database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Erzeugt eine Datenbankdatei im alten Schema (v1) - bewusst mit rohem
/// SQLite, damit Drift die Datei erst danach öffnet und die Migration
/// tatsächlich durchläuft.
File createLegacyDatabaseFile() {
  final dir = Directory.systemTemp.createTempSync('spartracker_migration');
  addTearDown(() => dir.deleteSync(recursive: true));

  final file = File(p.join(dir.path, 'spartracker.sqlite'));
  final raw = sqlite3.open(file.path);

  raw.execute('''
    CREATE TABLE savings_goals (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      target_amount REAL NOT NULL,
      created_at INTEGER NOT NULL,
      icon_code_point INTEGER NULL,
      color_value INTEGER NULL,
      archived INTEGER NOT NULL DEFAULT 0
    )
  ''');
  raw.execute('''
    CREATE TABLE savings_entries (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      goal_id INTEGER NOT NULL REFERENCES savings_goals (id) ON DELETE CASCADE,
      amount REAL NOT NULL,
      source TEXT NOT NULL,
      date INTEGER NOT NULL,
      note TEXT NULL
    )
  ''');

  // 60201 (0xEB29) = Codepoint des alten pedal_bike-Icons.
  raw.execute(
    'INSERT INTO savings_goals (id, name, target_amount, created_at, '
    'icon_code_point, color_value, archived) '
    'VALUES (1, ?, 450.0, 1700000000, 60201, 4283215696, 0)',
    ['Neues Fahrrad'],
  );
  raw.execute(
    'INSERT INTO savings_entries (goal_id, amount, source, date, note) '
    'VALUES (1, 150.0, ?, 1700000000, ?)',
    ['Geburtstag', 'Von Oma'],
  );
  raw.execute(
    'INSERT INTO savings_entries (goal_id, amount, source, date, note) '
    'VALUES (1, -25.0, ?, 1700000100, NULL)',
    ['Sonstiges'],
  );

  raw.execute('PRAGMA user_version = 1');
  raw.close();
  return file;
}

void main() {
  setUpAll(() {
    // In den Tests wird pro Fall bewusst eine eigene DB-Instanz erzeugt.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  test('Migration v1 -> v2 erhält Kontostand und Zielfortschritt', () async {
    final file = createLegacyDatabaseFile();
    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    // Erste Abfrage öffnet die Datenbank und löst die Migration aus.
    final goals = await db.goalsDao.activeGoals();
    expect(goals, hasLength(1));

    // Kontostand = Summe der alten Einträge (150 - 25).
    expect(await db.accountDao.watchBalance().first, 125.0);

    // Der Zielfortschritt bleibt ebenfalls erhalten.
    expect(await db.allocationsDao.watchTotalForGoal(1).first, 125.0);

    // Alles ist zugeteilt, also nichts mehr frei verfügbar.
    expect(await db.accountDao.availableAmount(), 0.0);

    // Quelle und Notiz der Buchungen überleben die Migration.
    final entries = await db.accountDao.watchEntries().first;
    expect(entries, hasLength(2));
    expect(
      entries.map((e) => e.source),
      containsAll(['Geburtstag', 'Sonstiges']),
    );
    expect(entries.firstWhere((e) => e.amount == 150.0).note, 'Von Oma');

    // Das alte Icon ueberlebt beide Migrationen (v1 -> v2 -> v3).
    expect(goals.single.iconKey, 'bike');

    // Die alte Tabelle existiert nicht mehr, die neuen schon.
    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
        .get();
    final names = tables.map((r) => r.data['name'] as String).toList();
    expect(names, isNot(contains('savings_entries')));
    expect(names, containsAll(['account_entries', 'allocations']));

    // Die Zwischenspalten aus Schema v1/v2 sind restlos verschwunden.
    final columns = await db
        .customSelect('PRAGMA table_info(savings_goals)')
        .get();
    final columnNames = columns.map((r) => r.data['name'] as String).toList();
    expect(columnNames, contains('icon_key'));
    expect(columnNames, isNot(contains('emoji')));
    expect(columnNames, isNot(contains('icon_code_point')));

    // Schema v3 -> v4 fügt die (nullable) Spalte für bereits gekaufte
    // Produkte hinzu, ohne bestehende Ziele zu beeinflussen.
    expect(columnNames, contains('purchased_at'));
    expect(goals.single.purchasedAt, null);
  });

  test('Frisch angelegte Datenbank nutzt direkt Schema v2', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final goalId = await db.goalsDao.addGoal(
      SavingsGoalsCompanion.insert(
        name: 'Urlaub',
        targetAmount: 1000,
        iconKey: const Value('beach'),
      ),
    );
    await db.accountDao.addEntry(
      AccountEntriesCompanion.insert(
        amount: 300,
        source: 'Ferienjob',
        date: DateTime(2026, 3, 1),
      ),
    );
    await db.allocationsDao.addAllocation(
      AllocationsCompanion.insert(
        goalId: goalId,
        amount: 200,
        date: DateTime(2026, 3, 2),
      ),
    );

    expect(await db.accountDao.watchBalance().first, 300.0);
    expect(await db.allocationsDao.watchTotalForGoal(goalId).first, 200.0);
    expect(await db.accountDao.availableAmount(), 100.0);
  });

  test('Löschen gibt zugeteiltes Geld frei und lässt sich rückgängig machen',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final goalId = await db.goalsDao.addGoal(
      SavingsGoalsCompanion.insert(
        name: 'Kopfhörer',
        targetAmount: 200,
        iconKey: const Value('headphones'),
      ),
    );
    await db.accountDao.addEntry(
      AccountEntriesCompanion.insert(
        amount: 300,
        source: 'Geburtstag',
        date: DateTime(2026, 5, 1),
      ),
    );
    await db.allocationsDao.addAllocation(
      AllocationsCompanion.insert(
        goalId: goalId,
        amount: 120,
        date: DateTime(2026, 5, 2),
      ),
    );
    await db.allocationsDao.addAllocation(
      AllocationsCompanion.insert(
        goalId: goalId,
        amount: 30,
        date: DateTime(2026, 5, 3),
      ),
    );

    expect(await db.accountDao.availableAmount(), 150.0);

    final deleted = await db.goalsDao.deleteGoalWithAllocations(goalId);

    // Das freigewordene Geld wird korrekt beziffert ...
    expect(deleted.releasedAmount, 150.0);
    expect(deleted.allocations, hasLength(2));
    // ... das Ziel ist weg ...
    expect(await db.goalsDao.activeGoals(), isEmpty);
    // ... der Kontostand bleibt unangetastet ...
    expect(await db.accountDao.watchBalance().first, 300.0);
    // ... und alles Geld ist wieder frei verfügbar.
    expect(await db.accountDao.availableAmount(), 300.0);

    // Rückgängig stellt Ziel und Zuteilungen exakt wieder her.
    await db.goalsDao.restoreGoal(deleted);

    final restored = await db.goalsDao.activeGoals();
    expect(restored, hasLength(1));
    expect(restored.single.name, 'Kopfhörer');
    expect(restored.single.iconKey, 'headphones');
    expect(await db.allocationsDao.watchTotalForGoal(goalId).first, 150.0);
    expect(await db.accountDao.availableAmount(), 150.0);
  });

  test('Geld zurücksetzen leert Buchungen und Zuteilungen, Ziele bleiben',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final goalId = await db.goalsDao.addGoal(
      SavingsGoalsCompanion.insert(name: 'Fahrrad', targetAmount: 400),
    );
    await db.accountDao.addEntry(
      AccountEntriesCompanion.insert(
        amount: 250,
        source: 'Ferienjob',
        date: DateTime(2026, 6, 1),
      ),
    );
    await db.allocationsDao.addAllocation(
      AllocationsCompanion.insert(
        goalId: goalId,
        amount: 100,
        date: DateTime(2026, 6, 2),
      ),
    );

    await db.accountDao.resetAllMoney();

    expect(await db.accountDao.watchBalance().first, 0.0);
    expect(await db.accountDao.availableAmount(), 0.0);
    expect(await db.allocationsDao.watchTotalForGoal(goalId).first, 0.0);
    expect(await db.accountDao.watchEntries().first, isEmpty);

    // Das Sparziel selbst überlebt den Reset.
    final goals = await db.goalsDao.activeGoals();
    expect(goals, hasLength(1));
    expect(goals.single.name, 'Fahrrad');
    expect(goals.single.targetAmount, 400.0);
  });

  test('Löschen eines Ziels entfernt seine Zuteilungen (Cascade)', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final goalId = await db.goalsDao.addGoal(
      SavingsGoalsCompanion.insert(name: 'Test', targetAmount: 100),
    );
    await db.accountDao.addEntry(
      AccountEntriesCompanion.insert(
        amount: 100,
        source: 'Test',
        date: DateTime(2026, 1, 1),
      ),
    );
    await db.allocationsDao.addAllocation(
      AllocationsCompanion.insert(
        goalId: goalId,
        amount: 50,
        date: DateTime(2026, 1, 1),
      ),
    );

    expect(await db.accountDao.availableAmount(), 50.0);

    await db.goalsDao.deleteGoal(goalId);

    // Nach dem Löschen ist das Geld wieder frei verfügbar.
    expect(await db.accountDao.availableAmount(), 100.0);
  });
}
