import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/account_dao.dart';
import '../data/allocations_dao.dart';
import '../data/database.dart';
import '../data/goals_dao.dart';
import '../services/price_lookup.dart';

/// Stellt die einzige [AppDatabase]-Instanz der App bereit.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final goalsDaoProvider = Provider<GoalsDao>((ref) {
  return ref.watch(appDatabaseProvider).goalsDao;
});

final accountDaoProvider = Provider<AccountDao>((ref) {
  return ref.watch(appDatabaseProvider).accountDao;
});

final allocationsDaoProvider = Provider<AllocationsDao>((ref) {
  return ref.watch(appDatabaseProvider).allocationsDao;
});

final priceLookupProvider = Provider<PriceLookupService>((ref) {
  final service = PriceLookupService();
  ref.onDispose(service.dispose);
  return service;
});
