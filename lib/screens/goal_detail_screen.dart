import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database.dart';
import '../l10n/l10n_labels.dart';
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
    final t = l10n(context);
    final formats = Formats.of(context);
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
        SnackBar(content: Text(t.allocationDone(formats.money(result.amount)))),
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
    final t = l10n(context);
    await ref.read(allocationsDaoProvider).deleteAllocation(allocation.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.detailAllocationDeleted),
        action: SnackBarAction(
          label: t.commonUndo,
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
      initialPurchasedAt: goal.purchasedAt,
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
            purchasedAt: Value(result.purchasedAt),
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

    final t = l10n(context);
    final formats = Formats.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(t.detailSearchingPrice)),
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
              purchasedAt: Value(goal.purchasedAt),
            ),
          );
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.detailPriceUpdated(formats.money(result.price!))),
        ),
      );
    } on PriceLookupException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.priceLookupMessage(e))),
      );
    }
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final t = l10n(context);
    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.detailLinkFailed)));
    }
  }

  Future<void> _archiveGoal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final t = l10n(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.inventory_2_outlined),
        title: Text(t.archiveTitle),
        content: Text(t.archiveBody(goal.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.archiveMenu),
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
    final t = l10n(context);
    final formats = Formats.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: Text(t.deleteGoalTitle),
        content: Text(
          allocated > 0
              ? t.deleteGoalBodyWithMoney(goal.name, formats.money(allocated))
              : t.deleteGoalBodyEmpty(goal.name),
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
            child: Text(t.commonDelete),
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
              ? t.goalDeletedWithMoney(
                  goal.name,
                  formats.money(deleted.releasedAmount),
                )
              : t.goalDeleted(goal.name),
        ),
        action: SnackBarAction(
          label: t.commonUndo,
          onPressed: () {
            ref.read(goalsDaoProvider).restoreGoal(deleted);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = l10n(context);
    final goalAsync = ref.watch(goalProvider(goalId));
    final allocationsAsync = ref.watch(allocationsForGoalProvider(goalId));
    final totalAsync = ref.watch(goalTotalProvider(goalId));
    final margin = adaptivePageMargin(context);

    return Scaffold(
      body: goalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text(t.commonErrorWithMessage('$error'))),
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
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: const Icon(Icons.edit_outlined),
                          title: Text(t.commonEdit),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (goal.productUrl != null) ...[
                        PopupMenuItem(
                          value: 'open-link',
                          child: ListTile(
                            leading: const Icon(Icons.open_in_new),
                            title: Text(t.detailOpenProductPage),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'refresh-price',
                          child: ListTile(
                            leading: const Icon(Icons.refresh),
                            title: Text(t.detailRefreshPrice),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      PopupMenuItem(
                        value: 'archive',
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text(t.archiveMenu),
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
                            t.commonDelete,
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
                      t.detailAllocationsSection,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
              ...allocationsAsync.when<List<Widget>>(
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
                      child: Center(
                        child: Text(t.commonErrorWithMessage('$error')),
                      ),
                    ),
                  ),
                ],
                data: (allocations) {
                  if (allocations.isEmpty) {
                    return [
                      // Unten Platz lassen, damit der FAB den Text
                      // nicht überdeckt.
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: Spacing.xs,
                            bottom: 120,
                          ),
                          child: EmptyState(
                            icon: Icons.savings_outlined,
                            title: t.detailEmptyTitle,
                            subtitle: t.detailEmptySubtitle,
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
                                ? t.detailReturnedToAccount
                                : t.detailAllocation,
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
              label: Text(
                goalAsync.value!.purchasedAt != null
                    ? t.detailSettleFab
                    : t.detailAssignFab,
              ),
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
    final t = l10n(context);
    final theme = Theme.of(context);
    final formats = Formats.of(context);
    final palette = goalPalette(context, goal.colorValue);
    final progress = goal.targetAmount <= 0
        ? 0.0
        : (allocated / goal.targetAmount).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final remaining = (goal.targetAmount - allocated).clamp(
      0.0,
      double.infinity,
    );
    final isPurchased = goal.purchasedAt != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.xl,
          horizontal: Spacing.lg,
        ),
        child: Column(
          children: [
            if (isPurchased) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: Corner.full,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 16,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: Spacing.xxs),
                    Text(
                      t.detailPurchasedOn(formats.date(goal.purchasedAt!)),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.lg),
            ],
            // Der Ring ist rein visuell; die Zahlen darunter tragen die
            // Information. Für Screenreader wird er deshalb zu einem
            // einzigen, sprechenden Element zusammengefasst.
            Semantics(
              label: t.detailProgressSemantics(percent),
              value: t.goalCardOf(
                formats.money(allocated),
                formats.money(goal.targetAmount),
              ),
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
              formats.money(allocated),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.xxs),
            Text(
              t.detailOfAmount(formats.money(goal.targetAmount)),
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
                    ? (isPurchased ? t.detailPurchaseSettled : t.detailGoalReached)
                    : (isPurchased
                          ? t.detailStillToSettle(formats.money(remaining))
                          : t.detailRemaining(formats.money(remaining))),
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
