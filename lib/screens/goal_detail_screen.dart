import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database.dart';
import '../models/goal_style.dart';
import '../providers/account_provider.dart';
import '../providers/database_provider.dart';
import '../providers/entries_provider.dart';
import '../providers/goals_provider.dart';
import '../services/price_lookup.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';
import '../widgets/allocation_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/goal_form_sheet.dart';
import '../widgets/money_tile.dart';

/// Detailansicht eines Sparziels: Fortschritt und Zuteilungen.
class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final int goalId;

  Future<void> _allocate(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
    double alreadyAllocated,
  ) async {
    final available = ref.read(availableAmountProvider);
    final result = await AllocationSheet.show(
      context,
      goalName: goal.name,
      available: available,
      stillNeeded: goal.targetAmount - alreadyAllocated,
    );
    if (result == null) return;

    await ref
        .read(allocationsDaoProvider)
        .addAllocation(
          AllocationsCompanion.insert(
            goalId: goalId,
            amount: result.amount,
            date: result.date,
            note: Value(result.note),
          ),
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${formatEuro(result.amount)} zugeteilt')),
      );
    }
  }

  Future<void> _editAllocation(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
    Allocation allocation,
  ) async {
    final available = ref.read(availableAmountProvider);
    final result = await AllocationSheet.show(
      context,
      goalName: goal.name,
      available: available,
      initialAmount: allocation.amount,
      initialDate: allocation.date,
      initialNote: allocation.note,
    );
    if (result == null) return;

    await ref
        .read(allocationsDaoProvider)
        .updateAllocation(
          AllocationsCompanion(
            id: Value(allocation.id),
            goalId: Value(goalId),
            amount: Value(result.amount),
            date: Value(result.date),
            note: Value(result.note),
          ),
        );
  }

  Future<void> _deleteAllocation(
    BuildContext context,
    WidgetRef ref,
    Allocation allocation,
  ) async {
    await ref.read(allocationsDaoProvider).deleteAllocation(allocation.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Zuteilung gelöscht'),
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () {
            ref
                .read(allocationsDaoProvider)
                .addAllocation(
                  AllocationsCompanion.insert(
                    goalId: allocation.goalId,
                    amount: allocation.amount,
                    date: allocation.date,
                    note: Value(allocation.note),
                  ),
                );
          },
        ),
      ),
    );
  }

  Future<void> _editGoal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final result = await GoalFormSheet.show(
      context,
      initialName: goal.name,
      initialTargetAmount: goal.targetAmount,
      initialIconKey: goal.iconKey,
      initialColor: goalColorFromValue(goal.colorValue),
      initialProductUrl: goal.productUrl,
    );
    if (result == null) return;

    await ref
        .read(goalsDaoProvider)
        .updateGoal(
          SavingsGoalsCompanion(
            id: Value(goal.id),
            name: Value(result.name),
            targetAmount: Value(result.targetAmount),
            iconKey: Value(result.iconKey),
            colorValue: Value(result.color.toARGB32()),
            productUrl: Value(result.productUrl),
            createdAt: Value(goal.createdAt),
            archived: Value(goal.archived),
          ),
        );
  }

  /// Holt den aktuellen Preis erneut vom hinterlegten Produktlink.
  Future<void> _refreshPrice(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final url = goal.productUrl;
    if (url == null) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Preis wird gesucht ...')),
    );

    try {
      final result = await ref.read(priceLookupProvider).lookup(url);
      await ref
          .read(goalsDaoProvider)
          .updateGoal(
            SavingsGoalsCompanion(
              id: Value(goal.id),
              name: Value(goal.name),
              targetAmount: Value(result.price!),
              iconKey: Value(goal.iconKey),
              colorValue: Value(goal.colorValue),
              productUrl: Value(goal.productUrl),
              createdAt: Value(goal.createdAt),
              archived: Value(goal.archived),
            ),
          );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Zielbetrag aktualisiert: ${formatEuro(result.price!)}',
          ),
        ),
      );
    } on PriceLookupException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link konnte nicht geöffnet werden')),
      );
    }
  }

  Future<void> _archiveGoal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.inventory_2_outlined),
        title: const Text('Sparziel archivieren?'),
        content: Text(
          '"${goal.name}" wird ausgeblendet. Das zugeteilte Geld bleibt '
          'reserviert - lösche vorher die Zuteilungen, wenn du es wieder '
          'frei verfügbar haben willst.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archivieren'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(goalsDaoProvider).archiveGoal(goal.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  /// Löscht das Sparziel endgültig. Das zugeteilte Geld wandert dabei
  /// zurück aufs Konto und ist danach wieder frei verfügbar.
  Future<void> _deleteGoal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
    double allocated,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Sparziel löschen?'),
        content: Text(
          allocated > 0
              ? '"${goal.name}" wird mitsamt allen Zuteilungen gelöscht.\n\n'
                    '${formatEuro(allocated)} gehen zurück aufs Konto '
                    'und sind danach wieder frei verfügbar.'
              : '"${goal.name}" wird gelöscht. Es ist kein Geld zugeteilt, '
                    'der Kontostand ändert sich also nicht.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final deleted = await ref
        .read(goalsDaoProvider)
        .deleteGoalWithAllocations(goal.id);
    if (!context.mounted) return;

    // Detailansicht schließen - das Ziel existiert nicht mehr.
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          deleted.releasedAmount > 0
              ? '"${goal.name}" gelöscht · '
                    '${formatEuro(deleted.releasedAmount)} zurück aufs Konto'
              : '"${goal.name}" gelöscht',
        ),
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () {
            ref.read(goalsDaoProvider).restoreGoal(deleted);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalProvider(goalId));
    final allocationsAsync = ref.watch(allocationsForGoalProvider(goalId));
    final totalAsync = ref.watch(goalTotalProvider(goalId));
    final margin = adaptivePageMargin(context);

    return Scaffold(
      body: goalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Fehler: $error')),
        data: (goal) {
          final total = totalAsync.valueOrNull ?? 0;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Text(
                  goal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editGoal(context, ref, goal);
                        case 'refresh-price':
                          _refreshPrice(context, ref, goal);
                        case 'open-link':
                          _openLink(context, goal.productUrl!);
                        case 'archive':
                          _archiveGoal(context, ref, goal);
                        case 'delete':
                          _deleteGoal(context, ref, goal, total);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Bearbeiten'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (goal.productUrl != null) ...[
                        const PopupMenuItem(
                          value: 'open-link',
                          child: ListTile(
                            leading: Icon(Icons.open_in_new),
                            title: Text('Produktseite öffnen'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'refresh-price',
                          child: ListTile(
                            leading: Icon(Icons.refresh),
                            title: Text('Preis aktualisieren'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      const PopupMenuItem(
                        value: 'archive',
                        child: ListTile(
                          leading: Icon(Icons.inventory_2_outlined),
                          title: Text('Archivieren'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(
                            'Löschen',
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
                sliver: SliverToBoxAdapter(
                  child: _ProgressHeader(goal: goal, allocated: total),
                ),
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
                      'Zuteilungen',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
              ...allocationsAsync.when<List<Widget>>(
                loading: () => const [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ],
                error: (error, stack) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(child: Text('Fehler: $error')),
                    ),
                  ),
                ],
                data: (allocations) {
                  if (allocations.isEmpty) {
                    return const [
                      // Unten Platz lassen, damit der FAB den Text
                      // nicht überdeckt.
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 120),
                          child: EmptyState(
                            icon: Icons.savings_outlined,
                            title: 'Noch nichts zugeteilt',
                            subtitle:
                                'Teile diesem Ziel Geld vom Sparkonto zu.',
                          ),
                        ),
                      ),
                    ];
                  }
                  return [
                    SliverPadding(
                      padding: margin.copyWith(bottom: 96),
                      sliver: SliverList.separated(
                        itemCount: allocations.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: Spacing.xxs),
                        itemBuilder: (context, index) {
                          final allocation = allocations[index];
                          return MoneyTile(
                            id: allocation.id,
                            amount: allocation.amount,
                            title: allocation.amount < 0
                                ? 'Zurück aufs Konto'
                                : 'Zuteilung',
                            date: allocation.date,
                            note: allocation.note,
                            onTap: () =>
                                _editAllocation(context, ref, goal, allocation),
                            onDismissed: () =>
                                _deleteAllocation(context, ref, allocation),
                          );
                        },
                      ),
                    ),
                  ];
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: goalAsync.hasValue
          ? FloatingActionButton.extended(
              onPressed: () => _allocate(
                context,
                ref,
                goalAsync.value!,
                totalAsync.valueOrNull ?? 0,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Zuteilen'),
            )
          : null,
    );
  }
}

/// Großer Fortschrittsring mit Betrag/Zielbetrag im Material-You-Stil.
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.goal, required this.allocated});

  final SavingsGoal goal;
  final double allocated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = goalPalette(context, goal.colorValue);
    final progress = goal.targetAmount <= 0
        ? 0.0
        : (allocated / goal.targetAmount).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final remaining = (goal.targetAmount - allocated).clamp(
      0.0,
      double.infinity,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.xl,
          horizontal: Spacing.lg,
        ),
        child: Column(
          children: [
            // Der Ring ist rein visuell; die Zahlen darunter tragen die
            // Information. Für Screenreader wird er deshalb zu einem
            // einzigen, sprechenden Element zusammengefasst.
            Semantics(
              label: 'Fortschritt $percent Prozent',
              value:
                  '${formatEuro(allocated)} von '
                  '${formatEuro(goal.targetAmount)}',
              excludeSemantics: true,
              child: SizedBox(
                width: 190,
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        backgroundColor: palette.track,
                        color: palette.accent,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          goalIconOrDefault(goal.iconKey),
                          size: 34,
                          color: palette.accent,
                        ),
                        const SizedBox(height: Spacing.xxs),
                        Text(
                          '$percent %',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: palette.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              formatEuro(allocated),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.xxs),
            Text(
              'von ${formatEuro(goal.targetAmount)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.xs,
              ),
              decoration: BoxDecoration(
                color: palette.container,
                borderRadius: Corner.full,
              ),
              child: Text(
                remaining <= 0
                    ? 'Ziel erreicht 🎉'
                    : 'Noch ${formatEuro(remaining)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.onContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
