// Prüft die MD3-Layoutregeln: Fensterklassen, Ränder und die
// Begrenzung der Inhaltsbreite auf großen Fenstern.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spartracker/theme/tokens.dart';

/// Baut einen Context mit fest vorgegebener Fensterbreite.
Future<T> withWidth<T>(
  WidgetTester tester,
  double width,
  T Function(BuildContext context) body,
) async {
  late T result;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Builder(
        builder: (context) {
          result = body(context);
          return const SizedBox();
        },
      ),
    ),
  );
  return result;
}

void main() {
  group('Fensterklassen nach MD3-Breakpoints', () {
    final cases = <double, WindowSizeClass>{
      320.0: WindowSizeClass.compact,
      599.0: WindowSizeClass.compact,
      600.0: WindowSizeClass.medium,
      839.0: WindowSizeClass.medium,
      840.0: WindowSizeClass.expanded,
      1199.0: WindowSizeClass.expanded,
      1200.0: WindowSizeClass.large,
      1599.0: WindowSizeClass.large,
      1600.0: WindowSizeClass.extraLarge,
    };

    for (final entry in cases.entries) {
      testWidgets('${entry.key.toInt()}dp -> ${entry.value.name}', (
        tester,
      ) async {
        final actual = await withWidth(
          tester,
          entry.key,
          windowSizeClassOf,
        );
        expect(actual, entry.value);
      });
    }
  });

  group('Seitenränder', () {
    testWidgets('Telefon: 16dp Rand, Inhalt füllt die Breite', (tester) async {
      const width = 400.0;
      final margin = await withWidth(tester, width, adaptivePageMargin);

      expect(margin.left, Spacing.md);
      expect(margin.right, Spacing.md);
      // Der Inhalt nutzt die volle Breite abzüglich der Ränder.
      expect(width - margin.horizontal, 400 - 32);
    });

    testWidgets('Tablet: 24dp Rand ab Medium', (tester) async {
      final margin = await withWidth(tester, 700, adaptivePageMargin);
      expect(margin.left, Spacing.lg);
    });

    testWidgets('Desktop: Inhalt wird begrenzt und zentriert', (tester) async {
      const width = 1600.0;
      final margin = await withWidth(tester, width, adaptivePageMargin);

      // Kernzusage: Der Inhalt läuft NICHT über den ganzen Bildschirm.
      expect(width - margin.horizontal, kMaxContentWidth);
      // ... und steht mittig, also links wie rechts gleich viel Rand.
      expect(margin.left, margin.right);
      expect(margin.left, greaterThan(Spacing.lg));
    });

    testWidgets('Genau an der Grenze bleibt es beim regulären Rand', (
      tester,
    ) async {
      // 840 + 2*24 = 888: der Inhalt passt exakt, Ränder bleiben 24dp.
      final margin = await withWidth(tester, 888, adaptivePageMargin);
      expect(margin.left, Spacing.lg);
    });
  });

  test('Berührungsziele erfüllen die 48dp-Vorgabe', () {
    expect(kMinTouchTarget, greaterThanOrEqualTo(48));
  });

  test('Abstände liegen auf dem 4dp-Raster', () {
    const values = [
      Spacing.xxs,
      Spacing.xs,
      Spacing.sm,
      Spacing.md,
      Spacing.lg,
      Spacing.xl,
      Spacing.xxl,
    ];
    for (final value in values) {
      expect(value % 4, 0, reason: '$value liegt nicht auf dem 4dp-Raster');
    }
  });
}
