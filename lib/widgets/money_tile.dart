import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../utils/format.dart';

/// Listeneintrag für einen Geldbetrag (Kontobuchung oder Zuteilung).
///
/// Unterstützt Wischen zum Löschen und Antippen zum Bearbeiten.
class MoneyTile extends StatelessWidget {
  const MoneyTile({
    super.key,
    required this.id,
    required this.amount,
    required this.title,
    required this.date,
    this.note,
    required this.onTap,
    required this.onDismissed,
  });

  final int id;
  final double amount;
  final String title;
  final DateTime date;
  final String? note;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isNegative = amount < 0;

    // Farbrollen statt fester Farben - passt sich Systemfarbe und
    // Dark Mode automatisch an.
    final accent = isNegative ? scheme.error : scheme.primary;
    final container = isNegative
        ? scheme.errorContainer
        : scheme.primaryContainer;
    final onContainer = isNegative
        ? scheme.onErrorContainer
        : scheme.onPrimaryContainer;

    final formats = Formats.of(context);
    final hasNote = note != null && note!.isNotEmpty;

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: Corner.largeAll,
        ),
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      onDismissed: (_) => onDismissed(),
      child: ListTile(
        onTap: onTap,
        tileColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xxs,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: container, shape: BoxShape.circle),
          child: Icon(
            isNegative ? Icons.arrow_downward : Icons.arrow_upward,
            color: onContainer,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          hasNote
              ? '${formats.date(date)} · $note'
              : formats.date(date),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          formats.signedMoney(amount),
          style: theme.textTheme.titleMedium?.copyWith(color: accent),
        ),
      ),
    );
  }
}
