import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Einheitlicher Rahmen für alle BottomSheets der App.
///
/// Löst den Bottom-Overflow: Der Inhalt ist scrollbar und der Innenabstand
/// unten berücksichtigt die eingeblendete Tastatur ([viewInsets]). Dadurch
/// passt das Formular auch auf kleinen Displays bzw. bei offener Tastatur.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: ConstrainedBox(
        // Nie höher als 90 % des Bildschirms - der Rest wird gescrollt.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.xxs,
            Spacing.lg,
            viewInsets + Spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Der Sheet-Titel ist die Überschrift des Dialogs - MD3
              // sieht dafür headlineSmall vor.
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: Spacing.lg),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
