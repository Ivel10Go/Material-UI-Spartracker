import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/goals_dao.dart';
import 'l10n/gen/app_localizations.dart';
import 'providers/goals_provider.dart';
import 'screens/goal_detail_screen.dart';
import 'screens/home_screen.dart';
import 'services/home_widget_service.dart';
import 'settings/app_settings.dart';
import 'theme/app_theme.dart';

/// Zugriff auf den Navigator außerhalb des Widget-Baums - gebraucht, wenn
/// Android einen Tipp auf das Homescreen-Widget meldet.
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Datumsformate für alle unterstützten Sprachen laden.
  await initializeDateFormatting();

  // Einstellungen vor dem ersten Frame lesen: Sprache und Farbe werden
  // schon beim Aufbau des Themes gebraucht.
  final prefs = await SharedPreferences.getInstance();

  // Edge-to-edge wie bei den Pixel-Systemapps: Inhalt läuft hinter
  // Status- und Navigationsleiste, beide bleiben transparent.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SpartrackerApp(),
    ),
  );
}

/// Wurzel-Widget der Spartracker-App.
class SpartrackerApp extends ConsumerWidget {
  const SpartrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    // DynamicColorBuilder liefert die Farbschemata des Systems:
    // auf Android 12+ aus dem Wallpaper, auf Windows/macOS/Linux aus
    // der Akzentfarbe.
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme lightScheme;
        final ColorScheme darkScheme;

        final useDynamic =
            settings.useDynamicColor && lightDynamic != null && darkDynamic != null;

        if (useDynamic) {
          // harmonized() zieht abweichende Farbtöne sanft in Richtung
          // der Systemfarbe - genau das macht den Material-You-Look aus.
          lightScheme = lightDynamic.harmonized();
          darkScheme = darkDynamic.harmonized();
        } else {
          lightScheme = ColorScheme.fromSeed(seedColor: settings.seedColor);
          darkScheme = ColorScheme.fromSeed(
            seedColor: settings.seedColor,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          navigatorKey: _navigatorKey,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          // null = der Systemsprache folgen.
          locale: settings.language.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: buildAppTheme(lightScheme),
          darkTheme: buildAppTheme(darkScheme),
          // Folgt automatisch dem Hell-/Dunkelmodus des Systems.
          themeMode: ThemeMode.system,
          // Hält das Homescreen-Widget auf Stand. Als `builder` liegt die
          // Brücke über dem Navigator und bleibt damit über alle
          // Bildschirmwechsel hinweg am Leben.
          builder: (context, child) => _HomeWidgetBridge(
            lightSeed: lightScheme.primary,
            darkSeed: darkScheme.primary,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}

/// Hält das Android-Homescreen-Widget mit der App synchron.
///
/// In eine Richtung: Ändern sich Sparziele oder Zuteilungen, wandert der
/// neue Stand nach Android. In die andere: Tippt jemand auf das Widget,
/// öffnet die App direkt das dazugehörige Sparziel.
class _HomeWidgetBridge extends ConsumerStatefulWidget {
  const _HomeWidgetBridge({
    required this.lightSeed,
    required this.darkSeed,
    required this.child,
  });

  /// Primärfarbe des hellen Schemas - Bezugspunkt für die Harmonisierung
  /// der Zielfarben.
  final Color lightSeed;

  /// Dasselbe für das dunkle Schema.
  final Color darkSeed;

  final Widget child;

  @override
  ConsumerState<_HomeWidgetBridge> createState() => _HomeWidgetBridgeState();
}

class _HomeWidgetBridgeState extends ConsumerState<_HomeWidgetBridge> {
  /// Zuletzt gesendete Sprache - ein Wechsel muss die Beschriftungen im
  /// Widget nachziehen, obwohl sich an den Sparzielen nichts geändert hat.
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    unawaited(HomeWidgetService.instance.attach(_openGoal));

    // `ref.listen` im build meldet nur *Änderungen*. Liegen beim Aufbau
    // schon Daten vor, würden sie sonst nie gesendet. Erst nach dem Frame,
    // weil die Übersetzungen im initState noch nicht abfragbar sind.
    WidgetsBinding.instance.addPostFrameCallback((_) => _publish());
  }

  @override
  void didUpdateWidget(_HomeWidgetBridge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Farbwechsel in den Einstellungen ändern die Zielfarben, nicht die
    // Sparziele selbst - ohne das hier bliebe das Widget im alten Farbton.
    if (oldWidget.lightSeed != widget.lightSeed ||
        oldWidget.darkSeed != widget.darkSeed) {
      _publish();
    }
  }

  /// Schickt den aktuellen Stand ans Widget.
  ///
  /// Mehrfachaufrufe sind unkritisch: Der Dienst vergleicht die Nutzlast
  /// mit der zuletzt gesendeten und bricht bei Gleichstand ab.
  void _publish() {
    if (!mounted) return;
    final goals = ref.read(goalProgressProvider).valueOrNull;
    if (goals == null) return;

    unawaited(
      HomeWidgetService.instance.publish(
        goals,
        lightHarmonizeSeed: widget.lightSeed,
        darkHarmonizeSeed: widget.darkSeed,
        texts: HomeWidgetTexts.of(context),
      ),
    );
  }

  void _openGoal(int goalId) {
    // Beim Kaltstart über das Widget steht der Navigator noch nicht -
    // deshalb erst nach dem nächsten Frame navigieren.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;
      navigator.popUntil((route) => route.isFirst);
      navigator.push(
        MaterialPageRoute<void>(
          builder: (context) => GoalDetailScreen(goalId: goalId),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<GoalProgress>>>(
      goalProgressProvider,
      (previous, next) => _publish(),
    );

    final locale = Localizations.localeOf(context);
    if (locale != _locale) {
      _locale = locale;
      // Nicht mitten im Aufbau senden - der Kanalaufruf würde sonst einen
      // weiteren Rebuild auslösen können.
      WidgetsBinding.instance.addPostFrameCallback((_) => _publish());
    }

    return widget.child;
  }
}
