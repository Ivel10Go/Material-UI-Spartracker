import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/tokens.dart';
import '../utils/format.dart';
import 'sheet_scaffold.dart';

/// Ergebnis des Zuteilungs-Formulars.
class AllocationResult {
  const AllocationResult({
    required this.amount,
    required this.date,
    required this.note,
  });

  final double amount;
  final DateTime date;
  final String? note;
}

/// BottomSheet zum Zuteilen von Geld aus dem Konto an ein Sparziel
/// (bzw. zum Zurückholen einer Zuteilung mit negativem Betrag).
class AllocationSheet extends StatefulWidget {
  const AllocationSheet({
    super.key,
    required this.goalName,
    required this.available,
    this.stillNeeded,
    this.initialAmount,
    this.initialDate,
    this.initialNote,
  });

  final String goalName;

  /// Aktuell frei verfügbarer Betrag auf dem Konto.
  final double available;

  /// Noch fehlender Betrag bis zum Ziel (für den Schnellauswahl-Chip).
  final double? stillNeeded;

  final double? initialAmount;
  final DateTime? initialDate;
  final String? initialNote;

  static Future<AllocationResult?> show(
    BuildContext context, {
    required String goalName,
    required double available,
    double? stillNeeded,
    double? initialAmount,
    DateTime? initialDate,
    String? initialNote,
  }) {
    return showModalBottomSheet<AllocationResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AllocationSheet(
        goalName: goalName,
        available: available,
        stillNeeded: stillNeeded,
        initialAmount: initialAmount,
        initialDate: initialDate,
        initialNote: initialNote,
      ),
    );
  }

  @override
  State<AllocationSheet> createState() => _AllocationSheetState();
}

class _AllocationSheetState extends State<AllocationSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _selectedDate;

  bool get _isEditing => widget.initialAmount != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null
          ? widget.initialAmount!.toStringAsFixed(2)
          : '',
    );
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _fill(double value) {
    _amountController.text = value.toStringAsFixed(2);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    Navigator.of(context).pop(
      AllocationResult(
        amount: amount,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dateFormat = DateFormat('dd.MM.yyyy', 'de_DE');

    // Beim Bearbeiten steht der bisherige Betrag zusätzlich zur Verfügung.
    final maxAllocatable =
        widget.available + (_isEditing ? widget.initialAmount! : 0);

    final quickFillNeeded =
        widget.stillNeeded != null &&
        widget.stillNeeded! > 0 &&
        widget.stillNeeded! <= maxAllocatable;

    return SheetScaffold(
      title: _isEditing ? 'Zuteilung bearbeiten' : 'Geld zuteilen',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: Corner.largeAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frei verfügbar auf dem Konto',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: Spacing.xxs),
                  Text(
                    formatEuro(maxAllocatable),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),
            TextFormField(
              controller: _amountController,
              autofocus: !_isEditing,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(
                labelText: 'Betrag für "${widget.goalName}"',
                helperText: 'Negativer Betrag holt Geld zurück aufs Konto',
                suffixText: '€',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte einen Betrag eingeben';
                }
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed == null || parsed == 0) {
                  return 'Bitte eine gültige Zahl ungleich 0 eingeben';
                }
                // Es kann nur verteilt werden, was auch da ist.
                if (parsed > maxAllocatable) {
                  return 'Nur ${formatEuro(maxAllocatable)} frei verfügbar';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                if (quickFillNeeded)
                  ActionChip(
                    avatar: const Icon(Icons.flag, size: 18),
                    label: Text(
                      'Rest bis Ziel (${formatEuro(widget.stillNeeded!)})',
                    ),
                    onPressed: () => _fill(widget.stillNeeded!),
                  ),
                if (maxAllocatable > 0)
                  ActionChip(
                    avatar: const Icon(Icons.account_balance_wallet, size: 18),
                    label: Text('Alles (${formatEuro(maxAllocatable)})'),
                    onPressed: () => _fill(maxAllocatable),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            InkWell(
              onTap: _pickDate,
              borderRadius: Corner.largeAll,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Datum',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(dateFormat.format(_selectedDate)),
              ),
            ),
            const SizedBox(height: Spacing.md),
            TextFormField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Notiz (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: Spacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Speichern' : 'Zuteilen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
