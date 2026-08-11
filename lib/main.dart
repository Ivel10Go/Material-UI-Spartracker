import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de_DE');

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

  runApp(const ProviderScope(child: SpartrackerApp()));
}

/// Wurzel-Widget der Spartracker-App.
class SpartrackerApp extends StatelessWidget {
  const SpartrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // DynamicColorBuilder liefert die Farbschemata des Systems:
    // auf Android 12+ aus dem Wallpaper, auf Windows/macOS/Linux aus
    // der Akzentfarbe. Fehlt beides, wird der Seed-Fallback genutzt.
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme lightScheme;
        final ColorScheme darkScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // harmonized() zieht abweichende Farbtöne sanft in Richtung
          // der Systemfarbe - genau das macht den Material-You-Look aus.
          lightScheme = lightDynamic.harmonized();
          darkScheme = darkDynamic.harmonized();
        } else {
          lightScheme = ColorScheme.fromSeed(seedColor: kFallbackSeedColor);
          darkScheme = ColorScheme.fromSeed(
            seedColor: kFallbackSeedColor,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: 'Spartracker',
          debugShowCheckedModeBanner: false,
          locale: const Locale('de', 'DE'),
          supportedLocales: const [Locale('de', 'DE')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: buildAppTheme(lightScheme),
          darkTheme: buildAppTheme(darkScheme),
          // Folgt automatisch dem Hell-/Dunkelmodus des Systems.
          themeMode: ThemeMode.system,
          home: const HomeScreen(),
        );
      },
    );
  }
}
