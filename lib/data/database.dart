import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'account_dao.dart';
import 'allocations_dao.dart';
import 'goals_dao.dart';

part 'database.g.dart';

/// Tabelle für Sparziele.
///
/// Ein Sparziel hält selbst kein Geld - der Fortschritt ergibt sich aus
/// den [Allocations], also dem vom zentralen Konto zugeteilten Betrag.
class SavingsGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get targetAmount => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Schlüssel des Symbols, z. B. `bike` (siehe `kGoalIconGroups`).
  ///
  /// Gespeichert wird der Schlüssel statt eines Icon-Codepoints: So bleiben
  /// alle `IconData` im Code konstant und Flutter kann die Icon-Fonts beim
  /// Release-Build weiterhin ausdünnen.
  TextColumn get iconKey => text().nullable()();

  /// Farbwert (ARGB) als Seed für das tonale Farbschema der Karte.
  IntColumn get colorValue => integer().nullable()();

  /// Optionaler Produktlink, aus dem der Preis ermittelt werden kann.
  TextColumn get productUrl => text().nullable()();

  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

/// Ein- und Auszahlungen auf das zentrale Sparkonto.
///
/// Hier landet *alles* Geld. Negative Beträge sind Entnahmen.
class AccountEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  RealColumn get amount => real()();

  /// Frei eingebbare Quelle, z. B. "Geburtstag", "eBay", "Zeitung austragen".
  TextColumn get source => text().withLength(min: 1, max: 100)();

  DateTimeColumn get date => dateTime()();

  TextColumn get note => text().nullable()();
}

/// Zuteilung von Geld aus dem Konto an ein Sparziel.
///
/// Das Geld bleibt physisch auf dem Konto, ist aber für dieses Ziel
/// reserviert. Negative Beträge holen eine Zuteilung wieder zurück.
class Allocations extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get goalId =>
      integer().references(SavingsGoals, #id, onDelete: KeyAction.cascade)();

  RealColumn get amount => real()();

  DateTimeColumn get date => dateTime()();

  TextColumn get note => text().nullable()();
}

@DriftDatabase(
  tables: [SavingsGoals, AccountEntries, Allocations],
  daos: [GoalsDao, AccountDao, AllocationsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await _migrateToCentralAccount(m);
      }
      if (from < 3) {
        await _migrateEmojiToIconKey(m);
      }
    },
    beforeOpen: (details) async {
      // Fremdschlüssel sind in SQLite standardmäßig aus - ohne das
      // greift das ON DELETE CASCADE der Zuteilungen nicht.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Migration v1 -> v2: von zielgebundenen Einträgen auf zentrales Konto.
  ///
  /// Jeder bisherige Eintrag wird aufgeteilt in
  ///   1. eine Einzahlung auf das Konto und
  ///   2. eine Zuteilung desselben Betrags an sein Sparziel.
  /// Dadurch bleiben sowohl Kontostand als auch Zielfortschritt erhalten.
  Future<void> _migrateToCentralAccount(Migrator m) async {
    await m.createTable(accountEntries);
    await m.createTable(allocations);
    await m.addColumn(savingsGoals, savingsGoals.productUrl);

    // Die Emoji-Spalte gab es nur in Schema v2. Sie wird hier per rohem
    // SQL angelegt, weil sie im heutigen Dart-Modell nicht mehr vorkommt -
    // der nächste Schritt (v2 -> v3) überführt sie in `icon_key`.
    await customStatement('ALTER TABLE savings_goals ADD COLUMN emoji TEXT');

    await customStatement(
      'INSERT INTO account_entries (amount, source, date, note) '
      'SELECT amount, source, date, note FROM savings_entries',
    );
    await customStatement(
      'INSERT INTO allocations (goal_id, amount, date, note) '
      'SELECT goal_id, amount, date, note FROM savings_entries',
    );
    await customStatement('DROP TABLE savings_entries');

    // Bisherige Material-Icons auf passende Emojis abbilden.
    final rows = await customSelect(
      'SELECT id, icon_code_point FROM savings_goals',
    ).get();
    for (final row in rows) {
      final codePoint = row.data['icon_code_point'] as int?;
      await customStatement('UPDATE savings_goals SET emoji = ? WHERE id = ?', [
        _emojiForLegacyIcon(codePoint),
        row.data['id'],
      ]);
    }
  }

  /// Migration v2 -> v3: Emojis zurück auf klare Material-Symbole.
  ///
  /// Aus dem gespeicherten Emoji wird der Schlüssel des passenden Symbols;
  /// Unbekanntes fällt auf das Standardsymbol zurück. Danach verschwindet
  /// die Emoji-Spalte.
  Future<void> _migrateEmojiToIconKey(Migrator m) async {
    await m.addColumn(savingsGoals, savingsGoals.iconKey);

    final rows = await customSelect(
      'SELECT id, emoji FROM savings_goals',
    ).get();
    for (final row in rows) {
      await customStatement(
        'UPDATE savings_goals SET icon_key = ? WHERE id = ?',
        [_iconKeyForLegacyEmoji(row.data['emoji'] as String?), row.data['id']],
      );
    }

    // Baut die Tabelle nach dem aktuellen Dart-Modell neu auf und entfernt
    // damit die alten Spalten `emoji` und `icon_code_point`.
    await m.alterTable(TableMigration(savingsGoals));
  }
}

/// Ordnet die früher genutzten Emojis wieder einem Symbol-Schlüssel zu.
String _iconKeyForLegacyEmoji(String? emoji) {
  const mapping = {
    '🐷': 'savings',
    '✈️': 'flight',
    '🚗': 'car',
    '🏠': 'home',
    '🎓': 'school',
    '💻': 'laptop',
    '🎁': 'gift',
    '🏖️': 'beach',
    '🎮': 'gaming',
    '🚲': 'bike',
    '📱': 'smartphone',
    '❤️': 'favorite',
    '🎯': 'flag',
  };
  return mapping[emoji] ?? 'savings';
}

/// Ordnet den zwölf früheren Icon-Codepoints ein passendes Emoji zu.
String _emojiForLegacyIcon(int? codePoint) {
  const mapping = {
    0xe04b: '🐷', // savings
    0xe539: '✈️', // flight_takeoff
    0xe531: '🚗', // directions_car
    0xe318: '🏠', // house
    0xe80c: '🎓', // school
    0xe31e: '💻', // laptop_mac
    0xe8f6: '🎁', // card_giftcard
    0xeb3e: '🏖️', // beach_access
    0xea28: '🎮', // sports_esports
    0xeb29: '🚲', // pedal_bike
    0xe325: '📱', // phone_iphone
    0xe87d: '❤️', // favorite
  };
  return mapping[codePoint] ?? '🎯';
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spartracker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
