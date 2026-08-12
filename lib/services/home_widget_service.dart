import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/goals_dao.dart';
import '../l10n/gen/app_localizations.dart';
import '../l10n/l10n_labels.dart';
import '../models/goal_style.dart';
import '../utils/format.dart';

/// Wird aufgerufen, wenn das Homescreen-Widget angetippt wurde.
typedef GoalOpenHandler = void Function(int goalId);

/// Alle Texte, die im Widget und in dessen Einstellungen auftauchen.
///
/// Sie kommen bewusst aus der App und nicht aus Android-Ressourcen: Das
/// Widget soll der in der App eingestellten Sprache folgen, nicht der des
/// Systems. Auch die Beträge werden hier fertig formatiert - sonst wichen
/// Widget und App im Zahlenformat voneinander ab.
class HomeWidgetTexts {
  const HomeWidgetTexts(this._t, this._formats);

  factory HomeWidgetTexts.of(BuildContext context) =>
      HomeWidgetTexts(l10n(context), Formats.of(context));

  final AppLocalizations _t;
  final Formats _formats;

  /// Beschriftungen ohne Bezug zu einem einzelnen Sparziel.
  Map<String, String> get labels => {
    'pickGoal': _t.widgetHintPickGoal,
    'noData': _t.widgetHintNoData,
    'configTitle': _t.widgetConfigTitle,
    'confirm': _t.widgetConfigConfirm,
    'cancel': _t.commonCancel,
    'emptyTitle': _t.widgetConfigEmptyTitle,
    'emptyBody': _t.widgetConfigEmptyBody,
    'openApp': _t.widgetConfigOpenApp,
  };

  String money(double value) => _formats.money(value);

  /// "320,00 € von 800,00 €"
  String amountLine(double saved, double target) =>
      _t.goalCardOf(money(saved), money(target));

  /// "von 800,00 €" - steht im großen Layout unter dem Betrag.
  String targetLine(double target) => _t.widgetTargetOf(money(target));

  /// "noch 480,00 €" bzw. "Ziel erreicht".
  String statusLine(double remaining, {required bool reached}) =>
      reached ? _t.widgetReached : _t.widgetRemaining(money(remaining));
}

/// Verbindung zwischen App und Android-Homescreen-Widget.
///
/// Das Widget läuft im Launcher-Prozess und kann die Datenbank der App
/// nicht lesen. Deshalb schreibt die App bei jeder Änderung einen kleinen
/// Abzug aller Sparziele nach Android (SharedPreferences) und stößt dort
/// eine Aktualisierung an. Umgekehrt meldet Android einen Widget-Tipp
/// zurück, damit die App direkt das passende Sparziel öffnen kann.
///
/// Auf allen anderen Plattformen sind sämtliche Aufrufe wirkungslos.
class HomeWidgetService {
  HomeWidgetService._();

  static final HomeWidgetService instance = HomeWidgetService._();

  static const MethodChannel _channel = MethodChannel(
    'com.spartracker.spartracker/widget',
  );

  /// Kantenlänge der gerenderten Symbol-Grafiken in Pixeln.
  ///
  /// 96px reichen für die 24dp-Darstellung im Widget bis hinauf zu
  /// xxxhdpi-Displays (24dp * 4 = 96px).
  static const int _iconSizePx = 96;

  static bool get _isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Zuletzt gesendete Nutzlast - verhindert überflüssige Kanalaufrufe und
  /// damit auch unnötige Widget-Neuzeichnungen.
  String? _lastPayload;

  /// Symbol-Schlüssel, deren PNG in diesem Lauf bereits erzeugt wurde.
  final Set<String> _renderedIcons = <String>{};

  Directory? _iconDir;

  /// Meldet den Handler für Widget-Tipps an und holt einen eventuell schon
  /// beim Start vorliegenden Tipp ab.
  ///
  /// Beim Kaltstart über das Widget ist die App noch gar nicht da, wenn der
  /// Intent eintrifft. Android merkt sich die Ziel-ID deshalb und gibt sie
  /// hier heraus, sobald Flutter bereit ist.
  Future<void> attach(GoalOpenHandler onOpenGoal) async {
    if (!_isSupported) return;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openGoal') {
        final goalId = call.arguments as int?;
        if (goalId != null) onOpenGoal(goalId);
      }
      return null;
    });

    final pending = await _channel.invokeMethod<int>('consumeLaunchGoalId');
    if (pending != null) onOpenGoal(pending);
  }

  /// Schreibt den aktuellen Stand aller Sparziele nach Android.
  ///
  /// [lightHarmonizeSeed] und [darkHarmonizeSeed] sind die Primärfarben des
  /// hellen bzw. dunklen App-Schemas. Aus ihnen leitet sich - genau wie in
  /// der App - die harmonisierte Zielfarbe ab. Beide Varianten wandern ins
  /// Widget, weil dort erst zur Anzeige feststeht, ob der Launcher gerade
  /// hell oder dunkel läuft.
  Future<void> publish(
    List<GoalProgress> goals, {
    required Color lightHarmonizeSeed,
    required Color darkHarmonizeSeed,
    required HomeWidgetTexts texts,
  }) async {
    if (!_isSupported) return;

    try {
      final entries = <Map<String, Object?>>[];

      for (final entry in goals) {
        final goal = entry.goal;
        final saved = entry.allocatedAmount;
        final reached = goal.targetAmount > 0 && saved >= goal.targetAmount;
        final remaining = (goal.targetAmount - saved).clamp(
          0.0,
          double.infinity,
        );
        final light = goalPaletteFor(
          colorValue: goal.colorValue,
          harmonizeWith: lightHarmonizeSeed,
          brightness: Brightness.light,
        );
        final dark = goalPaletteFor(
          colorValue: goal.colorValue,
          harmonizeWith: darkHarmonizeSeed,
          brightness: Brightness.dark,
        );

        entries.add({
          'id': goal.id,
          'name': goal.name,
          'target': goal.targetAmount,
          'saved': saved,
          'icon': await _iconFileFor(goal.iconKey),
          // Fertig formatiert, damit Android weder Sprache noch
          // Zahlenformat der App kennen muss.
          'savedText': texts.money(saved),
          'amountLine': texts.amountLine(saved, goal.targetAmount),
          'targetLine': texts.targetLine(goal.targetAmount),
          'statusLine': texts.statusLine(remaining, reached: reached),
          'percentText': '${(entry.progress * 100).round()} %',
          'accentLight': light.accent.toARGB32(),
          'accentDark': dark.accent.toARGB32(),
          'containerLight': light.container.toARGB32(),
          'containerDark': dark.container.toARGB32(),
          'onContainerLight': light.onContainer.toARGB32(),
          'onContainerDark': dark.onContainer.toARGB32(),
          'trackLight': light.track.toARGB32(),
          'trackDark': dark.track.toARGB32(),
        });
      }

      final payload = jsonEncode({'labels': texts.labels, 'goals': entries});
      if (payload == _lastPayload) return;

      await _channel.invokeMethod<void>('publishGoals', {'goals': payload});
      _lastPayload = payload;
    } catch (error, stack) {
      // Ein fehlgeschlagener Widget-Abgleich darf die App nie stören - im
      // schlimmsten Fall zeigt das Widget kurzzeitig alte Zahlen.
      debugPrint('Widget-Abgleich fehlgeschlagen: $error\n$stack');
    }
  }

  /// Liefert den Dateipfad zum PNG des Symbols und erzeugt es bei Bedarf.
  ///
  /// Android kennt den Material-Icons-Font der App nicht. Statt die Symbole
  /// dort ein zweites Mal als Vektorgrafiken zu pflegen, rendert Flutter sie
  /// einmalig als weiße Maske; das Widget färbt sie anschließend passend
  /// zur Zielfarbe ein.
  Future<String?> _iconFileFor(String? iconKey) async {
    final key = goalIconKeyOrDefault(iconKey);

    final dir = _iconDir ??= Directory(
      p.join((await getApplicationSupportDirectory()).path, 'widget_icons'),
    );
    final file = File(p.join(dir.path, '$key.png'));

    // Innerhalb eines Laufs reicht der Merker; über Läufe hinweg entscheidet
    // die Existenz der Datei.
    if (_renderedIcons.contains(key)) return file.path;

    try {
      if (!await file.exists()) {
        await dir.create(recursive: true);
        await file.writeAsBytes(await _renderIcon(goalIconOrDefault(key)));
      }
      _renderedIcons.add(key);
      return file.path;
    } catch (error) {
      debugPrint('Symbol "$key" konnte nicht gerendert werden: $error');
      return null;
    }
  }

  /// Zeichnet ein Icon-Glyph mittig als weiße Maske auf transparenten Grund.
  Future<Uint8List> _renderIcon(IconData icon) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: _iconSizePx.toDouble(),
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: const Color(0xFFFFFFFF),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(
        (_iconSizePx - painter.width) / 2,
        (_iconSizePx - painter.height) / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
      _iconSizePx,
      _iconSizePx,
    );
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw StateError('toByteData() lieferte keine PNG-Daten');
      }
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}
