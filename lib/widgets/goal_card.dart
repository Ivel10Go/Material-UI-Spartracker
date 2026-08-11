import 'package:flutter/material.dart';

import '../data/database.dart';
import '../models/goal_style.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';

/// Card für ein Sparziel in der Übersicht: Emoji, Name, Fortschritt.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.allocatedAmount,
    required this.onTap,
  });

  final SavingsGoal goal;

  /// Bereits vom Konto zugeteilter Betrag.
  final double allocatedAmount;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = goalPalette(context, goal.colorValue);
    final progress = goal.targetAmount <= 0
        ? 0.0
        : (allocatedAmount / goal.targetAmount).clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final isDone = progress >= 1.0;

    // Die Karte wird als *ein* Element vorgelesen - sonst hört man
    // Emoji, Name, Beträge und Prozentzahl als vier lose Fragmente.
    return Semantics(
      container: true,
      button: true,
      label:
          '${goal.name}, ${formatEuro(allocatedAmount)} von '
          '${formatEuro(goal.targetAmount)}, '
          '${isDone ? 'Ziel erreicht' : '$percent Prozent'}',
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
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
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: palette.container,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        goalIconOrDefault(goal.iconKey),
                        size: 24,
                        color: palette.onContainer,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  goal.name,
                                  style: theme.textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (goal.productUrl != null) ...[
                                const SizedBox(width: Spacing.xxs),
                                Icon(
                                  Icons.link,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: Spacing.xxs),
                          Text(
                            '${formatEuro(allocatedAmount)} von '
                            '${formatEuro(goal.targetAmount)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    if (isDone)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: palette.container,
                          borderRadius: Corner.full,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 18,
                          color: palette.onContainer,
                        ),
                      )
                    else
                      Text(
                        '$percent %',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: palette.accent,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: Corner.full,
                  backgroundColor: palette.track,
                  color: palette.accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
