import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

/// Themengruppen der Symbolauswahl. Die Beschriftung kommt aus der
/// Übersetzung, nicht aus dem Namen hier.
enum GoalIconGroup { popular, tech, travel, vehicles, home, leisure, other }

/// Ein auswählbares Symbol für ein Sparziel.
///
/// Gespeichert wird der stabile [key], nicht der Codepoint: Damit bleibt
/// die Zuordnung nachvollziehbar und - wichtiger - alle [IconData] bleiben
/// konstant. Würde man `IconData` zur Laufzeit aus einem Codepoint bauen,
/// könnte Flutter die Icon-Fonts nicht mehr ausdünnen und der Release-Build
/// bräche ab.
class GoalIcon {
  const GoalIcon(this.key, this.icon);

  /// Stabiler Schlüssel, wie er in der Datenbank landet. Über ihn wird
  /// auch der übersetzte Name nachgeschlagen.
  final String key;

  final IconData icon;
}

/// Auswählbare Symbole, nach Themen gruppiert.
const Map<GoalIconGroup, List<GoalIcon>> kGoalIconGroups = {
  GoalIconGroup.popular: [
    GoalIcon('savings', Icons.savings),
    GoalIcon('flag', Icons.flag),
    GoalIcon('star', Icons.star),
    GoalIcon('gift', Icons.card_giftcard),
    GoalIcon('cart', Icons.shopping_cart),
    GoalIcon('payments', Icons.payments),
    GoalIcon('trophy', Icons.emoji_events),
    GoalIcon('favorite', Icons.favorite),
  ],
  GoalIconGroup.tech: [
    GoalIcon('smartphone', Icons.smartphone),
    GoalIcon('laptop', Icons.laptop),
    GoalIcon('desktop', Icons.desktop_windows),
    GoalIcon('headphones', Icons.headphones),
    GoalIcon('gaming', Icons.sports_esports),
    GoalIcon('camera', Icons.photo_camera),
    GoalIcon('watch', Icons.watch),
    GoalIcon('tv', Icons.tv),
    GoalIcon('keyboard', Icons.keyboard),
    GoalIcon('printer', Icons.print),
    GoalIcon('speaker', Icons.speaker),
    GoalIcon('tablet', Icons.tablet_mac),
  ],
  GoalIconGroup.travel: [
    GoalIcon('flight', Icons.flight),
    GoalIcon('beach', Icons.beach_access),
    GoalIcon('map', Icons.map),
    GoalIcon('backpack', Icons.backpack),
    GoalIcon('hotel', Icons.hotel),
    GoalIcon('luggage', Icons.luggage),
    GoalIcon('train', Icons.train),
    GoalIcon('boat', Icons.directions_boat),
    GoalIcon('mountain', Icons.terrain),
    GoalIcon('camping', Icons.cabin),
    GoalIcon('hiking', Icons.hiking),
    GoalIcon('world', Icons.public),
    GoalIcon('ticket', Icons.local_activity),
  ],
  GoalIconGroup.vehicles: [
    GoalIcon('car', Icons.directions_car),
    GoalIcon('bike', Icons.pedal_bike),
    GoalIcon('scooter', Icons.two_wheeler),
    GoalIcon('bus', Icons.directions_bus),
    GoalIcon('e_scooter', Icons.electric_scooter),
    GoalIcon('truck', Icons.local_shipping),
    GoalIcon('car_repair', Icons.car_repair),
    GoalIcon('ev_station', Icons.ev_station),
  ],
  GoalIconGroup.home: [
    GoalIcon('home', Icons.home),
    GoalIcon('chair', Icons.chair),
    GoalIcon('bed', Icons.bed),
    GoalIcon('kitchen', Icons.kitchen),
    GoalIcon('shower', Icons.shower),
    GoalIcon('laundry', Icons.local_laundry_service),
    GoalIcon('plant', Icons.yard),
    GoalIcon('lamp', Icons.lightbulb),
  ],
  GoalIconGroup.leisure: [
    GoalIcon('soccer', Icons.sports_soccer),
    GoalIcon('basketball', Icons.sports_basketball),
    GoalIcon('music', Icons.music_note),
    GoalIcon('piano', Icons.piano),
    GoalIcon('art', Icons.palette),
    GoalIcon('book', Icons.menu_book),
    GoalIcon('movie', Icons.movie),
    GoalIcon('mic', Icons.mic),
    GoalIcon('ski', Icons.downhill_skiing),
    GoalIcon('surf', Icons.surfing),
    GoalIcon('skate', Icons.skateboarding),
    GoalIcon('gym', Icons.fitness_center),
  ],
  GoalIconGroup.other: [
    GoalIcon('school', Icons.school),
    GoalIcon('pets', Icons.pets),
    GoalIcon('eco', Icons.eco),
    GoalIcon('ring', Icons.diamond),
    GoalIcon('cake', Icons.cake),
    GoalIcon('food', Icons.restaurant),
    GoalIcon('clothes', Icons.checkroom),
    GoalIcon('health', Icons.medication),
    GoalIcon('tools', Icons.build),
    GoalIcon('flower', Icons.local_florist),
    GoalIcon('brush', Icons.brush),
    GoalIcon('celebration', Icons.celebration),
  ],
};

/// Schneller Zugriff auf ein Symbol über seinen Schlüssel.
final Map<String, GoalIcon> _iconsByKey = {
  for (final group in kGoalIconGroups.values)
    for (final icon in group) icon.key: icon,
};

/// Schlüssel des Standard-Symbols.
const String kDefaultGoalIconKey = 'savings';

/// Symbol, falls für ein Sparziel keines gewählt wurde.
const IconData kDefaultGoalIcon = Icons.savings;

/// Liefert das Symbol zu einem gespeicherten Schlüssel (mit Fallback).
IconData goalIconOrDefault(String? key) =>
    _iconsByKey[key]?.icon ?? kDefaultGoalIcon;

/// Normalisiert einen gespeicherten Schlüssel auf einen bekannten Schlüssel.
///
/// Nützlich überall dort, wo aus dem Schlüssel ein Dateiname o. Ä. wird -
/// dann soll ein unbekannter Schlüssel denselben Namen ergeben wie das
/// Symbol, das [goalIconOrDefault] dafür liefert.
String goalIconKeyOrDefault(String? key) =>
    _iconsByKey.containsKey(key) ? key! : kDefaultGoalIconKey;

/// Eine auswählbare Ziel-Farbe.
///
/// Der Name kommt aus der Übersetzung: Eine Auswahl, die sich *nur* über
/// Farbe unterscheidet, ist für Screenreader-Nutzer sonst nicht bedienbar.
class GoalColorChoice {
  const GoalColorChoice(this.key, this.color);

  final String key;
  final Color color;
}

/// Vordefinierte Farbtöne zur Auswahl für ein Sparziel.
///
/// Diese Werte dienen nur als *Seed*: Die tatsächlich gezeichneten Farben
/// werden daraus passend zum Hell-/Dunkelmodus abgeleitet ([goalPalette]).
const List<GoalColorChoice> kGoalColorChoices = [
  GoalColorChoice('violet', Color(0xFF6750A4)),
  GoalColorChoice('green', Color(0xFF2E7D32)),
  GoalColorChoice('blue', Color(0xFF1565C0)),
  GoalColorChoice('orange', Color(0xFFEF6C00)),
  GoalColorChoice('red', Color(0xFFC62828)),
  GoalColorChoice('teal', Color(0xFF00838F)),
  GoalColorChoice('magenta', Color(0xFF8E24AA)),
  GoalColorChoice('brown', Color(0xFF5D4037)),
];

/// Standard-Farbe, falls für ein Sparziel keine gewählt wurde.
const Color kDefaultGoalColor = Color(0xFF6750A4);

/// Wandelt einen gespeicherten Farbwert in eine [Color] um (Seed-Farbe).
Color goalColorFromValue(int? value) {
  if (value == null) return kDefaultGoalColor;
  return Color(value);
}

/// Material-You-Farbrollen für ein einzelnes Sparziel.
class GoalPalette {
  const GoalPalette({
    required this.accent,
    required this.container,
    required this.onContainer,
    required this.track,
  });

  /// Kräftige Akzentfarbe (Fortschritt, Prozentzahl).
  final Color accent;

  /// Tonale Hintergrundfläche (z. B. hinter dem Symbol).
  final Color container;

  /// Lesbare Vordergrundfarbe auf [container].
  final Color onContainer;

  /// Dezente Spur hinter dem Fortschrittsbalken.
  final Color track;
}

/// Cache, damit [ColorScheme.fromSeed] nicht bei jedem Rebuild neu
/// rechnet - die Ableitung ist vergleichsweise teuer.
final Map<(int, Brightness), GoalPalette> _paletteCache = {};

/// Leitet aus der gewählten Ziel-Farbe ein vollwertiges tonales Farbschema
/// ab, das zum aktuellen Hell-/Dunkelmodus passt.
GoalPalette goalPalette(BuildContext context, int? colorValue) {
  final theme = Theme.of(context);
  return goalPaletteFor(
    colorValue: colorValue,
    harmonizeWith: theme.colorScheme.primary,
    brightness: theme.brightness,
  );
}

/// Wie [goalPalette], aber ohne [BuildContext].
///
/// Wird gebraucht, wo beide Helligkeiten auf einmal gefragt sind - etwa
/// beim Abgleich mit dem Homescreen-Widget, das erst zur Anzeige weiß, ob
/// der Launcher hell oder dunkel läuft.
GoalPalette goalPaletteFor({
  required int? colorValue,
  required Color harmonizeWith,
  required Brightness brightness,
}) {
  // harmonizeWith() zieht die gewählte Zielfarbe sanft in Richtung der
  // System-/Wallpaper-Farbe: Grün bleibt grün, passt aber zum Rest des
  // Schemas. Genau dieses Verfahren nutzt auch Android für App-Akzente.
  final seed = goalColorFromValue(colorValue).harmonizeWith(harmonizeWith);

  // Der Cache-Key enthält die bereits harmonisierte Farbe - wechselt die
  // Systemfarbe, ergibt sich automatisch ein neuer Eintrag.
  final key = (seed.toARGB32(), brightness);

  return _paletteCache.putIfAbsent(key, () {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return GoalPalette(
      accent: scheme.primary,
      container: scheme.primaryContainer,
      onContainer: scheme.onPrimaryContainer,
      track: scheme.secondaryContainer,
    );
  });
}
