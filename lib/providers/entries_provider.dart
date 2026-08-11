import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import 'database_provider.dart';

/// Alle Zuteilungen eines Sparziels, neueste zuerst.
final allocationsForGoalProvider = StreamProvider.family<List<Allocation>, int>(
  (ref, goalId) {
    return ref.watch(allocationsDaoProvider).watchForGoal(goalId);
  },
);

/// Aktuell zugeteilter Betrag eines einzelnen Sparziels.
final goalTotalProvider = StreamProvider.family<double, int>((ref, goalId) {
  return ref.watch(allocationsDaoProvider).watchTotalForGoal(goalId);
});
