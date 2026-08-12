import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../l10n/l10n_labels.dart';
import '../providers/account_provider.dart';
import '../providers/database_provider.dart';
import '../providers/entries_provider.dart';
import '../providers/goals_provider.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_form_sheet.dart';
import 'account_screen.dart';
import 'goal_detail_screen.dart';
import 'settings_screen.dart';

/// Startbildschirm: Sparkonto oben, darunter die Sparziele.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _createGoal(BuildContext context, WidgetRef ref) async {
    final t = l10n(context);
    final result = await GoalFormSheet.show(context);
    if (result == null) return;

    await ref
        .read(goalsDaoProvider)
        .addGoal(
          SavingsGoalsCompanion.insert(
            name: result.name,
            targetAmount: result.targetAmount,
            iconKey: Value(result.iconKey),
            colorValue: Value(result.color.toARGB32()),
            productUrl: Value(result.productUrl),
          ),
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.homeGoalCreated(result.name))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = l10n(context);
    final goalsAsync = ref.watch(activeGoalsProvider);
    // Zentriert den Inhalt und begrenzt ihn auf lesbare Breite - auf
    // Desktop-Fenstern zieht er sich sonst über den ganzen Bildschirm.
    final margin = adaptivePageMargin(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Small Top App Bar (64dp): lässt dem Inhalt den meisten Platz.
          SliverAppBar(
            pinned: true,
            title: Text(t.appTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: t.settingsOpen,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverPadding(
            padding: margin,
            sliver: const SliverToBoxAdapter(child: _AccountCard()),
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
                  t.homeGoalsSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          ...goalsAsync.when<List<Widget>>(
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
            data: (goals) {
              if (goals.isEmpty) {
                return [
                  // Füllt den restlichen Platz und hält unten Abstand,
                  // damit der FAB den Text nicht überlagert.
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 96),
                      child: EmptyState(
                        icon: Icons.savings_outlined,
                        title: t.homeEmptyTitle,
                        subtitle: t.homeEmptySubtitle,
                      ),
                    ),
                  ),
                ];
              }
              return [
                SliverPadding(
                  // Unten Platz für den FAB, damit er nichts überdeckt.
                  padding: margin.copyWith(bottom: 96),
                  sliver: SliverList.separated(
                    itemCount: goals.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: Spacing.sm),
                    itemBuilder: (context, index) =>
                        _GoalCardTile(goal: goals[index]),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createGoal(context, ref),
        icon: const Icon(Icons.add),
        label: Text(t.homeNewGoalFab),
      ),
    );
  }
}

/// Karte mit Kontostand, zugeteiltem und frei verfügbarem Betrag.
class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = l10n(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final formats = Formats.of(context);

    final balance = ref.watch(accountBalanceProvider).valueOrNull ?? 0;
    final allocated = ref.watch(allocatedTotalProvider).valueOrNull ?? 0;
    final available = ref.watch(availableAmountProvider);

    return Semantics(
      container: true,
      button: true,
      label: t.accountSemantics(
        formats.money(balance),
        formats.money(allocated),
        formats.money(available),
      ),
      excludeSemantics: true,
      child: Card(
        color: scheme.primaryContainer,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AccountScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: kMinTouchTarget,
                      height: kMinTouchTarget,
                      decoration: BoxDecoration(
                        // Tonale Fläche aus der Palette statt halbtrans-
                        // parentem Schwarz - so bleibt der Kontrast in
                        // hell und dunkel gleichermaßen verlässlich.
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: scheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.accountTitle,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: Spacing.xxs),
                          Text(
                            formats.money(balance),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _AccountStat(
                        label: t.accountAllocated,
                        value: allocated,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: _AccountStat(
                        label: t.accountAvailable,
                        value: available,
                        // Negativ = mehr zugeteilt als vorhanden.
                        warn: available < 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountStat extends StatelessWidget {
  const _AccountStat({
    required this.label,
    required this.value,
    this.warn = false,
  });

  final String label;
  final double value;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = warn ? scheme.error : scheme.onPrimaryContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          Formats.of(context).money(value),
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _GoalCardTile extends ConsumerWidget {
  const _GoalCardTile({required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAsync = ref.watch(goalTotalProvider(goal.id));
    return GoalCard(
      goal: goal,
      allocatedAmount: totalAsync.valueOrNull ?? 0,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GoalDetailScreen(goalId: goal.id),
          ),
        );
      },
    );
  }
}
