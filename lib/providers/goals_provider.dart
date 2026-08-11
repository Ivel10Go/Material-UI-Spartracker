import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import 'database_provider.dart';

/// Alle aktiven (nicht archivierten) Sparziele, live aktualisiert.
final activeGoalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  return ref.watch(goalsDaoProvider).watchActiveGoals();
});

/// Ein einzelnes Sparziel anhand seiner ID, live aktualisiert.
final goalProvider = StreamProvider.family<SavingsGoal, int>((ref, goalId) {
  return ref.watch(goalsDaoProvider).watchGoal(goalId);
});
