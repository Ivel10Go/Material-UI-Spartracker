import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import 'database_provider.dart';

/// Alle Kontobewegungen (Ein- und Auszahlungen), neueste zuerst.
final accountEntriesProvider = StreamProvider<List<AccountEntry>>((ref) {
  return ref.watch(accountDaoProvider).watchEntries();
});

/// Gesamter Kontostand.
final accountBalanceProvider = StreamProvider<double>((ref) {
  return ref.watch(accountDaoProvider).watchBalance();
});

/// Summe des bereits an Sparziele zugeteilten Geldes.
final allocatedTotalProvider = StreamProvider<double>((ref) {
  return ref.watch(accountDaoProvider).watchAllocatedTotal();
});

/// Noch frei verfügbarer Betrag: Kontostand minus Zuteilungen.
///
/// Kann negativ werden, wenn nachträglich Geld vom Konto abgehoben wird,
/// das bereits einem Ziel zugeteilt war - die UI weist darauf hin.
final availableAmountProvider = Provider<double>((ref) {
  final balance = ref.watch(accountBalanceProvider).valueOrNull ?? 0;
  final allocated = ref.watch(allocatedTotalProvider).valueOrNull ?? 0;
  return balance - allocated;
});
