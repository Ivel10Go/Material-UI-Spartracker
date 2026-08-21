import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n_labels.dart';
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
    required this.purchasedAt,
  });

  final String name;
  final double targetAmount;
  final String iconKey;
  final Color color;
  final String? productUrl;

  /// Gesetzt, wenn das Produkt schon aus eigener Tasche gekauft wurde und
  /// jetzt mit späterem Geld ausgeglichen werden soll.
  final DateTime? purchasedAt;
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
    this.initialPurchasedAt,
  });

  final String? initialName;
  final double? initialTargetAmount;
  final String? initialIconKey;
  final Color? initialColor;
  final String? initialProductUrl;
  final DateTime? initialPurchasedAt;

  static Future<GoalFormResult?> show(
    BuildContext context, {
    String? initialName,
    double? initialTargetAmount,
    String? initialIconKey,
    Color? initialColor,
    String? initialProductUrl,
    DateTime? initialPurchasedAt,
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
        initialPurchasedAt: initialPurchasedAt,
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
  late DateTime? _purchasedAt;

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
    _purchasedAt = widget.initialPurchasedAt;
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

    final t = l10n(context);
    final formats = Formats.of(context);

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
        SnackBar(
          content: Text(t.goalFormPriceFound(formats.money(result.price!))),
        ),
      );
    } on PriceLookupException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.priceLookupMessage(e))));
    } finally {
      if (mounted) setState(() => _lookingUpPrice = false);
    }
  }

  static String _shorten(String title) {
    final clean = title.trim();
    return clean.length <= 60 ? clean : '${clean.substring(0, 57)}...';
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchasedAt ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _purchasedAt = picked);
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
        purchasedAt: _purchasedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = l10n(context);
    final theme = Theme.of(context);

    return SheetScaffold(
      title: _isEditing ? t.goalFormEditTitle : t.goalFormNewTitle,
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
                    // Bewusst kein autofocus: Das Sheet soll sich ruhig
                    // öffnen und die Tastatur erst kommen, wenn der Nutzer
                    // das Feld antippt.
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: t.goalFormName,
                      hintText: t.goalFormNameHint,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return t.goalFormNameMissing;
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
              decoration: InputDecoration(
                labelText: t.goalFormTargetAmount,
                suffixText: '€',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t.goalFormAmountMissing;
                }
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return t.goalFormAmountInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: t.goalFormProductLink,
                hintText: t.goalFormProductLinkHint,
                suffixIcon: _lookingUpPrice
                    ? const Padding(
                        padding: EdgeInsets.all(Spacing.sm),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: t.goalFormLookUpPrice,
                        onPressed: _lookUpPrice,
                      ),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              t.goalFormPriceHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            // Für Produkte, die schon aus eigener Tasche bezahlt wurden -
            // die Zuteilung gleicht den vorgestreckten Betrag dann später
            // aus, statt auf den Kauf hinzusparen.
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.goalFormAlreadyPurchased),
              subtitle: Text(t.goalFormAlreadyPurchasedHint),
              value: _purchasedAt != null,
              onChanged: (value) {
                setState(() => _purchasedAt = value ? DateTime.now() : null);
              },
            ),
            if (_purchasedAt != null) ...[
              const SizedBox(height: Spacing.sm),
              InkWell(
                onTap: _pickPurchaseDate,
                borderRadius: Corner.largeAll,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: t.goalFormPurchaseDate,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(Formats.of(context).date(_purchasedAt!)),
                ),
              ),
            ],
            const SizedBox(height: Spacing.lg),
            Text(t.goalFormColor, style: theme.textTheme.titleSmall),
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
                child: Text(_isEditing ? t.commonSave : t.goalFormCreate),
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
    final t = l10n(context);
    final palette = goalPalette(context, color.toARGB32());

    return Semantics(
      label: t.iconPickerButtonSemantics(t.goalIconLabel(iconKey)),
      button: true,
      excludeSemantics: true,
      child: Tooltip(
        message: t.iconPickerButtonTooltip,
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
    final label = l10n(context).goalColorLabel(choice.key);

    // Der Name macht die Auswahl auch ohne Farbwahrnehmung bedienbar,
    // `selected` meldet den Zustand an den Screenreader.
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: label,
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
