import 'package:flutter/material.dart';

import '../l10n/l10n_labels.dart';
import '../theme/tokens.dart';
import '../utils/format.dart';
import 'sheet_scaffold.dart';

/// Ergebnis des Konto-Eintrags-Formulars.
class EntryFormResult {
  const EntryFormResult({
    required this.amount,
    required this.source,
    required this.date,
    required this.note,
  });

  final double amount;
  final String source;
  final DateTime date;
  final String? note;
}

/// BottomSheet zum Hinzufügen oder Bearbeiten einer Kontobewegung.
class EntryFormSheet extends StatefulWidget {
  const EntryFormSheet({
    super.key,
    this.initialAmount,
    this.initialSource,
    this.initialDate,
    this.initialNote,
  });

  final double? initialAmount;
  final String? initialSource;
  final DateTime? initialDate;
  final String? initialNote;

  static Future<EntryFormResult?> show(
    BuildContext context, {
    double? initialAmount,
    String? initialSource,
    DateTime? initialDate,
    String? initialNote,
  }) {
    return showModalBottomSheet<EntryFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => EntryFormSheet(
        initialAmount: initialAmount,
        initialSource: initialSource,
        initialDate: initialDate,
        initialNote: initialNote,
      ),
    );
  }

  @override
  State<EntryFormSheet> createState() => _EntryFormSheetState();
}

class _EntryFormSheetState extends State<EntryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _sourceController;
  late final TextEditingController _noteController;
  late DateTime _selectedDate;

  bool get _isEditing => widget.initialSource != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null
          ? widget.initialAmount!.toStringAsFixed(2)
          : '',
    );
    _sourceController = TextEditingController(text: widget.initialSource ?? '');
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    Navigator.of(context).pop(
      EntryFormResult(
        amount: amount,
        source: _sourceController.text.trim(),
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = l10n(context);
    final theme = Theme.of(context);
    final formats = Formats.of(context);

    return SheetScaffold(
      title: _isEditing ? t.entryFormEditTitle : t.entryFormNewTitle,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(
                labelText: t.entryFormAmount,
                helperText: t.entryFormAmountHelper,
                suffixText: '€',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t.entryFormAmountMissing;
                }
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed == null || parsed == 0) {
                  return t.entryFormAmountInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),
            // Quelle: vollständig frei eingebbar.
            TextFormField(
              controller: _sourceController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: t.entryFormSource,
                hintText: t.entryFormSourceHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t.entryFormSourceMissing;
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.sm),
            // Vorschläge sind reine Abkürzung - antippen füllt das Feld,
            // überschreiben bleibt jederzeit möglich.
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                for (final suggestion in t.entrySourceSuggestions)
                  ActionChip(
                    label: Text(suggestion),
                    onPressed: () {
                      setState(() => _sourceController.text = suggestion);
                    },
                  ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            InkWell(
              onTap: _pickDate,
              borderRadius: Corner.largeAll,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: t.commonDate,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(formats.date(_selectedDate)),
              ),
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: t.commonNoteOptional),
              maxLines: 2,
            ),
            const SizedBox(height: Spacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: Text(_isEditing ? t.commonSave : t.commonAdd),
              ),
            ),
            const SizedBox(height: Spacing.xxs),
            Text(
              t.entryFormFooter,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
