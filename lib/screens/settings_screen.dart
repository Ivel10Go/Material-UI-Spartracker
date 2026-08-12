import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n_labels.dart';
import '../models/goal_style.dart';
import '../settings/app_settings.dart';
import '../theme/tokens.dart';

/// Einstellungen: Farbquelle und Sprache.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = l10n(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final margin = adaptivePageMargin(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(pinned: true, title: Text(t.settingsTitle)),
          SliverPadding(
            padding: margin.copyWith(bottom: Spacing.xl),
            sliver: SliverList.list(
              children: [
                _SectionHeader(t.settingsAppearance),
                Card(
                  child: Column(
                    children: [
                      // DynamicColorBuilder verrät, ob das Gerät überhaupt
                      // Systemfarben liefert. Ohne diese Prüfung könnte man
                      // einen Schalter umlegen, der sichtbar nichts tut.
                      DynamicColorBuilder(
                        builder: (lightDynamic, darkDynamic) {
                          final available = lightDynamic != null;
                          return SwitchListTile(
                            value: settings.useDynamicColor && available,
                            onChanged: available
                                ? controller.setUseDynamicColor
                                : null,
                            title: Text(t.settingsDynamicColor),
                            subtitle: Text(
                              !available
                                  ? t.settingsDynamicColorUnavailable
                                  : settings.useDynamicColor
                                  ? t.settingsDynamicColorOn
                                  : t.settingsDynamicColorOff,
                            ),
                            secondary: const Icon(Icons.palette_outlined),
                          );
                        },
                      ),
                      const Divider(indent: Spacing.md, endIndent: Spacing.md),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.md,
                          Spacing.xs,
                          Spacing.md,
                          Spacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.settingsOwnColor,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: Spacing.sm),
                            Wrap(
                              spacing: Spacing.xs,
                              runSpacing: Spacing.xs,
                              children: [
                                for (final choice in kGoalColorChoices)
                                  _ColorOption(
                                    choice: choice,
                                    // Nur hervorheben, wenn die eigene
                                    // Farbe auch tatsächlich greift.
                                    selected:
                                        !settings.useDynamicColor &&
                                        settings.seedColor.toARGB32() ==
                                            choice.color.toARGB32(),
                                    onTap: () =>
                                        controller.setSeedColor(choice.color),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                _SectionHeader(t.settingsLanguage),
                Card(
                  child: RadioGroup<AppLanguage>(
                    groupValue: settings.language,
                    onChanged: (value) {
                      if (value != null) controller.setLanguage(value);
                    },
                    child: Column(
                      children: [
                        for (final language in AppLanguage.values)
                          RadioListTile<AppLanguage>(
                            value: language,
                            title: Text(switch (language) {
                              AppLanguage.system => t.settingsLanguageSystem,
                              AppLanguage.german => t.settingsLanguageGerman,
                              AppLanguage.english => t.settingsLanguageEnglish,
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.xxs,
        Spacing.md,
        Spacing.xxs,
        Spacing.xs,
      ),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

/// Farbfeld mit Namen - die Auswahl darf sich nicht allein über Farbe
/// unterscheiden, sonst ist sie ohne Farbwahrnehmung nicht bedienbar.
class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final GoalColorChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = l10n(context).goalColorLabel(choice.key);
    final palette = goalPalette(context, choice.color.toARGB32());

    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: kMinTouchTarget,
            height: kMinTouchTarget,
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                  border: selected
                      ? Border.all(color: scheme.onSurface, width: 3)
                      : null,
                ),
                child: selected
                    ? Icon(Icons.check, color: scheme.surface, size: 20)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
