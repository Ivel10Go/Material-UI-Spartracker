import 'package:drift/drift.dart';

import 'database.dart';

part 'account_dao.g.dart';

/// Datenzugriff auf das zentrale Sparkonto.
@DriftAccessor(tables: [AccountEntries, Allocations])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(super.db);

  /// Alle Kontobewegungen, neueste zuerst.
  Stream<List<AccountEntry>> watchEntries() {
    return (select(accountEntries)..orderBy([
          (e) => OrderingTerm.desc(e.date),
          (e) => OrderingTerm.desc(e.id),
        ]))
        .watch();
  }

  /// Gesamter Kontostand (Summe aller Ein- und Auszahlungen).
  Stream<double> watchBalance() {
    final sumExp = accountEntries.amount.sum();
    final query = selectOnly(accountEntries)..addColumns([sumExp]);
    return query.map((row) => row.read(sumExp) ?? 0.0).watchSingle();
  }

  /// Summe des bereits an Sparziele zugeteilten Geldes.
  Stream<double> watchAllocatedTotal() {
    final sumExp = allocations.amount.sum();
    final query = selectOnly(allocations)..addColumns([sumExp]);
    return query.map((row) => row.read(sumExp) ?? 0.0).watchSingle();
  }

  /// Einmalige Abfrage des frei verfügbaren Betrags
  /// (Kontostand abzüglich aller Zuteilungen).
  Future<double> availableAmount() async {
    final balanceExp = accountEntries.amount.sum();
    final balanceRow = await (selectOnly(
      accountEntries,
    )..addColumns([balanceExp])).getSingle();
    final balance = balanceRow.read(balanceExp) ?? 0.0;

    final allocExp = allocations.amount.sum();
    final allocRow = await (selectOnly(
      allocations,
    )..addColumns([allocExp])).getSingle();
    final allocated = allocRow.read(allocExp) ?? 0.0;

    return balance - allocated;
  }

  Future<int> addEntry(AccountEntriesCompanion entry) {
    return into(accountEntries).insert(entry);
  }

  Future<bool> updateEntry(AccountEntriesCompanion entry) {
    return update(accountEntries).replace(entry);
  }

  Future<int> deleteEntry(int id) {
    return (delete(accountEntries)..where((e) => e.id.equals(id))).go();
  }

  /// Setzt das gesamte Geld zurück: löscht alle Buchungen und alle
  /// Zuteilungen. Der Kontostand ist danach 0 €, jedes Sparziel steht
  /// wieder bei 0 %.
  ///
  /// Die Sparziele selbst bleiben erhalten - nur das Geld verschwindet.
  Future<void> resetAllMoney() {
    return transaction(() async {
      await delete(allocations).go();
      await delete(accountEntries).go();
    });
  }
}
