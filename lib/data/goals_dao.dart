import 'package:drift/drift.dart';

import 'database.dart';

part 'goals_dao.g.dart';

/// Ein gelöschtes Sparziel samt seiner Zuteilungen - wird für die
/// Rückgängig-Funktion nach dem Löschen aufbewahrt.
class DeletedGoal {
  const DeletedGoal({required this.goal, required this.allocations});

  final SavingsGoal goal;
  final List<Allocation> allocations;

  /// Betrag, der durch das Löschen wieder frei aufs Konto zurückfließt.
  double get releasedAmount =>
      allocations.fold(0.0, (sum, a) => sum + a.amount);
}

/// Datenzugriff für Sparziele.
@DriftAccessor(tables: [SavingsGoals, Allocations])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  /// Alle aktiven (nicht archivierten) Sparziele, neueste zuerst.
  Stream<List<SavingsGoal>> watchActiveGoals() {
    return (select(savingsGoals)
          ..where((g) => g.archived.equals(false))
          ..orderBy([(g) => OrderingTerm.desc(g.createdAt)]))
        .watch();
  }

  /// Einmalige Abfrage aller aktiven Sparziele (z. B. für Auswahllisten).
  Future<List<SavingsGoal>> activeGoals() {
    return (select(savingsGoals)
          ..where((g) => g.archived.equals(false))
          ..orderBy([(g) => OrderingTerm.desc(g.createdAt)]))
        .get();
  }

  Stream<SavingsGoal> watchGoal(int id) {
    return (select(savingsGoals)..where((g) => g.id.equals(id))).watchSingle();
  }

  Future<int> addGoal(SavingsGoalsCompanion goal) {
    return into(savingsGoals).insert(goal);
  }

  Future<bool> updateGoal(SavingsGoalsCompanion goal) {
    return update(savingsGoals).replace(goal);
  }

  Future<int> archiveGoal(int id) {
    return (update(savingsGoals)..where((g) => g.id.equals(id))).write(
      const SavingsGoalsCompanion(archived: Value(true)),
    );
  }

  /// Löscht ein Sparziel; zugehörige Zuteilungen entfernt SQLite per
  /// ON DELETE CASCADE mit.
  Future<int> deleteGoal(int id) {
    return (delete(savingsGoals)..where((g) => g.id.equals(id))).go();
  }

  /// Löscht ein Sparziel und gibt Ziel samt Zuteilungen zurück.
  ///
  /// Da die Zuteilungen mit entfernt werden, ist das bisher reservierte
  /// Geld danach wieder frei auf dem Konto verfügbar. Der Rückgabewert
  /// erlaubt es, das Ganze per [restoreGoal] rückgängig zu machen.
  Future<DeletedGoal> deleteGoalWithAllocations(int id) {
    return transaction(() async {
      final goal = await (select(
        savingsGoals,
      )..where((g) => g.id.equals(id))).getSingle();
      final related = await (select(
        allocations,
      )..where((a) => a.goalId.equals(id))).get();

      await (delete(savingsGoals)..where((g) => g.id.equals(id))).go();

      return DeletedGoal(goal: goal, allocations: related);
    });
  }

  /// Stellt ein gelöschtes Sparziel samt seiner Zuteilungen wieder her.
  Future<void> restoreGoal(DeletedGoal deleted) {
    return transaction(() async {
      await into(savingsGoals).insert(
        deleted.goal.toCompanion(false),
        mode: InsertMode.insertOrReplace,
      );
      for (final allocation in deleted.allocations) {
        await into(allocations).insert(
          allocation.toCompanion(false),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}
