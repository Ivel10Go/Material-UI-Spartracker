import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../l10n/l10n_labels.dart';
import '../providers/account_provider.dart';
import '../providers/database_provider.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import '../widgets/entry_form_sheet.dart';
import '../widgets/money_tile.dart';

/// Kontoansicht: alle Ein- und Auszahlungen des zentralen Sparkontos.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _addEntry(BuildContext context, WidgetRef ref) async {
    final t = l10n(context);
    final result = await EntryFormSheet.show(context);
    if (result == null) return;

    await ref
        .read(accountDaoProvider)
        .addEntry(
          AccountEntriesCompanion.insert(
            amount: result.amount,
            source: result.source,
            date: result.date,
            note: Value(result.note),
          ),
        );

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.accountEntryAdded)));
    }
  }

  Future<void> _editEntry(
    BuildContext context,
    WidgetRef ref,
    AccountEntry entry,
  ) async {
    final t = l10n(context);
    final result = await EntryFormSheet.show(
      context,
      initialAmount: entry.amount,
      initialSource: entry.source,
      initialDate: entry.date,
      initialNote: entry.note,
    );
    if (result == null) return;

    await ref
        .read(accountDaoProvider)
        .updateEntry(
          AccountEntriesCompanion(
            id: Value(entry.id),
            amount: Value(result.amount),
            source: Value(result.source),
            date: Value(result.date),
            note: Value(result.note),
          ),
        );

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.accountEntrySaved)));
    }
  }

  Future<void> _deleteEntry(
    BuildContext context,
    WidgetRef ref,
    AccountEntry entry,
  ) async {
    final t = l10n(context);
    await ref.read(accountDaoProvider).deleteEntry(entry.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.accountEntryDeleted),
        action: SnackBarAction(
          label: t.commonUndo,
          onPressed: () {
            // Legt die Buchung mit denselben Werten wieder an.
            ref
                .read(accountDaoProvider)
                .addEntry(
                  AccountEntriesCompanion.insert(
                    amount: entry.amount,
                    source: entry.source,
                    date: entry.date,
                    note: Value(entry.note),
                  ),
                );
          },
        ),
      ),
    );
  }

  /// Setzt alles Geld auf null zurück: Buchungen und Zuteilungen werden
  /// gelöscht, die Sparziele selbst bleiben bestehen.
  Future<void> _resetMoney(BuildContext context, WidgetRef ref) async {
    final t = l10n(context);
    final formats = Formats.of(context);
    final balance = ref.read(accountBalanceProvider).valueOrNull ?? 0;
    final allocated = ref.read(allocatedTotalProvider).valueOrNull ?? 0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.restart_alt),
        title: Text(t.resetMoneyTitle),
        content: Text(
          t.resetMoneyBody(
            formats.money(balance),
            formats.money(0),
            formats.money(allocated),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.resetMoneyConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(accountDaoProvider).resetAllMoney();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.resetMoneyDone)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = l10n(context);
    final entriesAsync = ref.watch(accountEntriesProvider);
    final margin = adaptivePageMargin(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(t.accountTitle),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'reset') _resetMoney(context, ref);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'reset',
                    child: ListTile(
                      leading: Icon(
                        Icons.restart_alt,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        t.resetMoneyMenu,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverPadding(
            padding: margin,
            sliver: const SliverToBoxAdapter(child: _BalanceHeader()),
          ),
          SliverPadding(
            padding: margin,
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.xxs,
                  Spacing.lg,
                  Spacing.xxs,
                  Spacing.xs,
                ),
                child: Text(
                  t.accountEntriesSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          ...entriesAsync.when<List<Widget>>(
            loading: () => const [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
            error: (error, stack) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.xl),
                  child: Center(child: Text(t.commonErrorWithMessage('$error'))),
                ),
              ),
            ],
            data: (entries) {
              if (entries.isEmpty) {
                return [
                  // Unten Platz lassen, damit der FAB den Text nicht
                  // überdeckt.
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: Spacing.xs,
                        bottom: 120,
                      ),
                      child: EmptyState(
                        icon: Icons.account_balance_wallet_outlined,
                        title: t.accountEmptyTitle,
                        subtitle: t.accountEmptySubtitle,
                      ),
                    ),
                  ),
                ];
              }
              return [
                SliverPadding(
                  padding: margin.copyWith(bottom: 96),
                  sliver: SliverList.separated(
                    itemCount: entries.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: Spacing.xxs),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return MoneyTile(
                        id: entry.id,
                        amount: entry.amount,
                        title: entry.source,
                        date: entry.date,
                        note: entry.note,
                        onTap: () => _editEntry(context, ref, entry),
                        onDismissed: () => _deleteEntry(context, ref, entry),
                      );
                    },
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addEntry(context, ref),
        icon: const Icon(Icons.add),
        label: Text(t.accountDepositFab),
      ),
    );
  }
}

/// Kopfbereich mit Kontostand und Aufteilung.
class _BalanceHeader extends ConsumerWidget {
  const _BalanceHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = l10n(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final formats = Formats.of(context);

    final balance = ref.watch(accountBalanceProvider).valueOrNull ?? 0;
    final allocated = ref.watch(allocatedTotalProvider).valueOrNull ?? 0;
    final available = ref.watch(availableAmountProvider);

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          children: [
            Text(
              t.accountBalance,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: Spacing.xxs),
            Text(
              formats.money(balance),
              style: theme.textTheme.displaySmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Chip(
                  label: t.accountAllocated,
                  value: allocated,
                  color: scheme.onPrimaryContainer,
                ),
                _Chip(
                  label: t.accountAvailableShort,
                  value: available,
                  color: available < 0
                      ? scheme.error
                      : scheme.onPrimaryContainer,
                ),
              ],
            ),
            if (available < 0) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                t.accountOverAllocatedWarning,
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color)),
        const SizedBox(height: Spacing.xxs),
        Text(
          Formats.of(context).money(value),
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
