import 'package:drift/drift.dart';

import 'database.dart';

part 'allocations_dao.g.dart';

/// Datenzugriff auf die Zuteilungen vom Konto an Sparziele.
@DriftAccessor(tables: [Allocations])
class AllocationsDao extends DatabaseAccessor<AppDatabase>
    with _$AllocationsDaoMixin {
  AllocationsDao(super.db);

  /// Alle Zuteilungen eines Sparziels, neueste zuerst.
  Stream<List<Allocation>> watchForGoal(int goalId) {
    return (select(allocations)
          ..where((a) => a.goalId.equals(goalId))
          ..orderBy([
            (a) => OrderingTerm.desc(a.date),
            (a) => OrderingTerm.desc(a.id),
          ]))
        .watch();
  }

  /// Aktuell zugeteilter Betrag eines Sparziels.
  Stream<double> watchTotalForGoal(int goalId) {
    final sumExp = allocations.amount.sum();
    final query = selectOnly(allocations)
      ..addColumns([sumExp])
      ..where(allocations.goalId.equals(goalId));
    return query.map((row) => row.read(sumExp) ?? 0.0).watchSingle();
  }

  Future<int> addAllocation(AllocationsCompanion allocation) {
    return into(allocations).insert(allocation);
  }

  Future<bool> updateAllocation(AllocationsCompanion allocation) {
    return update(allocations).replace(allocation);
  }

  Future<int> deleteAllocation(int id) {
    return (delete(allocations)..where((a) => a.id.equals(id))).go();
  }
}
