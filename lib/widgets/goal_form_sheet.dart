import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal_style.dart';
import '../providers/database_provider.dart';
import '../services/price_lookup.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';
import 'icon_picker_sheet.dart';
import 'sheet_scaffold.dart';

/// Ergebnis des Sparziel-Formulars.
class GoalFormResult {
  const GoalFormResult({
    required this.name,
    required this.targetAmount,
    required this.iconKey,
    required this.color,
    required this.productUrl,
  });

  final String name;
  final double targetAmount;
  final String iconKey;
  final Color color;
  final String? productUrl;
}

/// BottomSheet zum Anlegen oder Bearbeiten eines Sparziels.
class GoalFormSheet extends ConsumerStatefulWidget {
  const GoalFormSheet({
    super.key,
    this.initialName,
    this.initialTargetAmount,
    this.initialIconKey,
    this.initialColor,
    this.initialProductUrl,
  });

  final String? initialName;
  final double? initialTargetAmount;
  final String? initialIconKey;
  final Color? initialColor;
  final String? initialProductUrl;

  static Future<GoalFormResult?> show(
    BuildContext context, {
    String? initialName,
    double? initialTargetAmount,
    String? initialIconKey,
    Color? initialColor,
    String? initialProductUrl,
  }) {
    return showModalBottomSheet<GoalFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => GoalFormSheet(
        initialName: initialName,
        initialTargetAmount: initialTargetAmount,
        initialIconKey: initialIconKey,
        initialColor: initialColor,
        initialProductUrl: initialProductUrl,
      ),
    );
  }

  @override
  ConsumerState<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<GoalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _urlController;
  late String _selectedIconKey;
  late Color _selectedColor;

  bool _lookingUpPrice = false;

  bool get _isEditing => widget.initialName != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _amountController = TextEditingController(
      text: widget.initialTargetAmount != null
          ? widget.initialTargetAmount!.toStringAsFixed(2)
          : '',
    );
    _urlController = TextEditingController(
      text: widget.initialProductUrl ?? '',
    );
    _selectedIconKey = widget.initialIconKey ?? kDefaultGoalIconKey;
    _selectedColor = widget.initialColor ?? kGoalColorChoices.first.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickIcon() async {
    final picked = await IconPickerSheet.show(
      context,
      selectedKey: _selectedIconKey,
      color: _selectedColor,
    );
    if (picked != null) {
      setState(() => _selectedIconKey = picked);
    }
  }

  /// Holt den Preis aus dem hinterlegten Produktlink und trägt ihn ein.
  Future<void> _lookUpPrice() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _lookingUpPrice = true);
    try {
      final result = await ref.read(priceLookupProvider).lookup(url);
      if (!mounted) return;

      _amountController.text = result.price!.toStringAsFixed(2);
      // Name nur vorschlagen, wenn der Nutzer noch keinen eingetragen hat.
      if (_nameController.text.trim().isEmpty && result.title != null) {
        _nameController.text = _shorten(result.title!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preis gefunden: ${formatEuro(result.price!)}')),
      );
    } on PriceLookupException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _lookingUpPrice = false);
    }
  }

  static String _shorten(String title) {
    final clean = title.trim();
    return clean.length <= 60 ? clean : '${clean.substring(0, 57)}...';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final url = _urlController.text.trim();

    Navigator.of(context).pop(
      GoalFormResult(
        name: _nameController.text.trim(),
        targetAmount: amount,
        iconKey: _selectedIconKey,
        color: _selectedColor,
        productUrl: url.isEmpty ? null : url,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SheetScaffold(
      title: _isEditing ? 'Sparziel bearbeiten' : 'Neues Sparziel',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Symbol-Auswahl + Name nebeneinander.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconButton(
                  iconKey: _selectedIconKey,
                  color: _selectedColor,
                  onTap: _pickIcon,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    autofocus: !_isEditing,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'z. B. Neues Fahrrad',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bitte einen Namen eingeben';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Zielbetrag',
                suffixText: '€',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte einen Zielbetrag eingeben';
                }
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return 'Bitte eine gültige Zahl größer 0 eingeben';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Produktlink (optional)',
                hintText: 'https://...',
                suffixIcon: _lookingUpPrice
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: 'Preis von der Seite holen',
                        onPressed: _lookUpPrice,
                      ),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'Der Preis wird aus den Produktdaten der Seite gelesen. '
              'Klappt nicht bei jedem Shop - dann einfach selbst eintragen.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text('Farbe', style: theme.textTheme.titleSmall),
            const SizedBox(height: Spacing.xs),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                for (final choice in kGoalColorChoices)
                  _ColorChoice(
                    choice: choice,
                    selected:
                        choice.color.toARGB32() == _selectedColor.toARGB32(),
                    onTap: () => setState(() => _selectedColor = choice.color),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Speichern' : 'Anlegen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Große, tonale Schaltfläche mit dem aktuell gewählten Symbol.
class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.iconKey,
    required this.color,
    required this.onTap,
  });

  final String iconKey;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = goalPalette(context, color.toARGB32());
    return Semantics(
      label: 'Symbol auswählen, aktuell ${goalIconLabel(iconKey)}',
      button: true,
      excludeSemantics: true,
      child: Tooltip(
        message: 'Symbol auswählen',
        child: InkWell(
          onTap: onTap,
          borderRadius: Corner.largeAll,
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.container,
              borderRadius: Corner.largeAll,
            ),
            child: Icon(
              goalIconOrDefault(iconKey),
              size: 28,
              color: palette.onContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final GoalColorChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = goalPalette(context, choice.color.toARGB32());
    final scheme = Theme.of(context).colorScheme;

    // Der Name macht die Auswahl auch ohne Farbwahrnehmung bedienbar,
    // `selected` meldet den Zustand an den Screenreader.
    return Semantics(
      label: choice.name,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: choice.name,
          // 48dp Berührungsziel, der Farbkreis darin bleibt 40dp.
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
