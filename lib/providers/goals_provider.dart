import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/goals_dao.dart';
import 'database_provider.dart';

/// Alle aktiven (nicht archivierten) Sparziele, live aktualisiert.
final activeGoalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  return ref.watch(goalsDaoProvider).watchActiveGoals();
});

/// Alle aktiven Sparziele samt zugeteiltem Betrag, live aktualisiert.
final goalProgressProvider = StreamProvider<List<GoalProgress>>((ref) {
  return ref.watch(goalsDaoProvider).watchGoalProgress();
});

/// Ein einzelnes Sparziel anhand seiner ID, live aktualisiert.
final goalProvider = StreamProvider.family<SavingsGoal, int>((ref, goalId) {
  return ref.watch(goalsDaoProvider).watchGoal(goalId);
});
