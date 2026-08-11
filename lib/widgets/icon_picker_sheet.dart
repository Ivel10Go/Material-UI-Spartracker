import 'package:flutter/material.dart';

import '../models/goal_style.dart';
import '../theme/tokens.dart';
import 'sheet_scaffold.dart';

/// BottomSheet zur Auswahl des Symbols eines Sparziels.
///
/// Zeigt die Symbole in der Farbe des Sparziels, damit die Auswahl schon
/// im Picker so aussieht wie später auf der Karte.
class IconPickerSheet extends StatelessWidget {
  const IconPickerSheet({
    super.key,
    required this.selectedKey,
    required this.color,
  });

  /// Aktuell gewählter Symbol-Schlüssel.
  final String selectedKey;

  /// Farbe des Sparziels - bestimmt die tonale Darstellung.
  final Color color;

  static Future<String?> show(
    BuildContext context, {
    required String selectedKey,
    required Color color,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) =>
          IconPickerSheet(selectedKey: selectedKey, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = goalPalette(context, color.toARGB32());

    return SheetScaffold(
      title: 'Symbol auswählen',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final group in kGoalIconGroups.entries) ...[
            Text(group.key, style: theme.textTheme.titleSmall),
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: [
                for (final choice in group.value)
                  _IconChoice(
                    choice: choice,
                    palette: palette,
                    selected: choice.key == selectedKey,
                    onTap: () => Navigator.of(context).pop(choice.key),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
          ],
        ],
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.choice,
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final GoalIcon choice;
  final GoalPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: choice.label,
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: Tooltip(
        message: choice.label,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: kMinTouchTarget,
            height: kMinTouchTarget,
            decoration: BoxDecoration(
              color: selected
                  ? palette.container
                  : scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: palette.accent, width: 2)
                  : null,
            ),
            child: Icon(
              choice.icon,
              size: 22,
              color: selected ? palette.onContainer : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
