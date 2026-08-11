// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocations_dao.dart';

// ignore_for_file: type=lint
mixin _$AllocationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SavingsGoalsTable get savingsGoals => attachedDatabase.savingsGoals;
  $AllocationsTable get allocations => attachedDatabase.allocations;
  AllocationsDaoManager get managers => AllocationsDaoManager(this);
}

class AllocationsDaoManager {
  final _$AllocationsDaoMixin _db;
  AllocationsDaoManager(this._db);
  $$SavingsGoalsTableTableManager get savingsGoals =>
      $$SavingsGoalsTableTableManager(_db.attachedDatabase, _db.savingsGoals);
  $$AllocationsTableTableManager get allocations =>
      $$AllocationsTableTableManager(_db.attachedDatabase, _db.allocations);
}
