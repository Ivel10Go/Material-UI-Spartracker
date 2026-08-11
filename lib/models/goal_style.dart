import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

/// Ein auswählbares Symbol für ein Sparziel.
///
/// Gespeichert wird der stabile [key], nicht der Codepoint: Damit bleibt
/// die Zuordnung nachvollziehbar und - wichtiger - alle [IconData] bleiben
/// konstant. Würde man `IconData` zur Laufzeit aus einem Codepoint bauen,
/// könnte Flutter die Icon-Fonts nicht mehr ausdünnen und der Release-Build
/// bräche ab.
class GoalIcon {
  const GoalIcon(this.key, this.label, this.icon);

  /// Stabiler Schlüssel, wie er in der Datenbank landet.
  final String key;

  /// Deutscher Name - dient als Tooltip und als Screenreader-Label.
  final String label;

  final IconData icon;
}

/// Auswählbare Symbole, nach Themen gruppiert.
const Map<String, List<GoalIcon>> kGoalIconGroups = {
  'Beliebt': [
    GoalIcon('savings', 'Sparschwein', Icons.savings),
    GoalIcon('flag', 'Ziel', Icons.flag),
    GoalIcon('star', 'Stern', Icons.star),
    GoalIcon('gift', 'Geschenk', Icons.card_giftcard),
    GoalIcon('cart', 'Einkauf', Icons.shopping_cart),
    GoalIcon('payments', 'Geld', Icons.payments),
    GoalIcon('trophy', 'Pokal', Icons.emoji_events),
    GoalIcon('favorite', 'Herz', Icons.favorite),
  ],
  'Technik': [
    GoalIcon('smartphone', 'Smartphone', Icons.smartphone),
    GoalIcon('laptop', 'Laptop', Icons.laptop),
    GoalIcon('desktop', 'PC', Icons.desktop_windows),
    GoalIcon('headphones', 'Kopfhörer', Icons.headphones),
    GoalIcon('gaming', 'Gaming', Icons.sports_esports),
    GoalIcon('camera', 'Kamera', Icons.photo_camera),
    GoalIcon('watch', 'Smartwatch', Icons.watch),
    GoalIcon('tv', 'Fernseher', Icons.tv),
    GoalIcon('keyboard', 'Tastatur', Icons.keyboard),
    GoalIcon('printer', 'Drucker', Icons.print),
    GoalIcon('speaker', 'Lautsprecher', Icons.speaker),
    GoalIcon('tablet', 'Tablet', Icons.tablet_mac),
  ],
  'Reisen': [
    GoalIcon('flight', 'Flug', Icons.flight),
    GoalIcon('beach', 'Strand', Icons.beach_access),
    GoalIcon('map', 'Karte', Icons.map),
    GoalIcon('backpack', 'Rucksack', Icons.backpack),
    GoalIcon('hotel', 'Hotel', Icons.hotel),
    GoalIcon('luggage', 'Koffer', Icons.luggage),
    GoalIcon('train', 'Zug', Icons.train),
    GoalIcon('boat', 'Schiff', Icons.directions_boat),
    GoalIcon('mountain', 'Berge', Icons.terrain),
    GoalIcon('camping', 'Camping', Icons.cabin),
    GoalIcon('hiking', 'Wandern', Icons.hiking),
    GoalIcon('world', 'Welt', Icons.public),
    GoalIcon('ticket', 'Ticket', Icons.local_activity),
  ],
  'Fahrzeuge': [
    GoalIcon('car', 'Auto', Icons.directions_car),
    GoalIcon('bike', 'Fahrrad', Icons.pedal_bike),
    GoalIcon('scooter', 'Roller', Icons.two_wheeler),
    GoalIcon('bus', 'Bus', Icons.directions_bus),
    GoalIcon('e_scooter', 'E-Scooter', Icons.electric_scooter),
    GoalIcon('truck', 'Transporter', Icons.local_shipping),
    GoalIcon('car_repair', 'Werkstatt', Icons.car_repair),
    GoalIcon('ev_station', 'Ladesäule', Icons.ev_station),
  ],
  'Wohnen': [
    GoalIcon('home', 'Zuhause', Icons.home),
    GoalIcon('chair', 'Möbel', Icons.chair),
    GoalIcon('bed', 'Bett', Icons.bed),
    GoalIcon('kitchen', 'Küche', Icons.kitchen),
    GoalIcon('shower', 'Bad', Icons.shower),
    GoalIcon('laundry', 'Waschmaschine', Icons.local_laundry_service),
    GoalIcon('plant', 'Pflanzen', Icons.yard),
    GoalIcon('lamp', 'Lampe', Icons.lightbulb),
  ],
  'Freizeit': [
    GoalIcon('soccer', 'Fußball', Icons.sports_soccer),
    GoalIcon('basketball', 'Basketball', Icons.sports_basketball),
    GoalIcon('music', 'Musik', Icons.music_note),
    GoalIcon('piano', 'Klavier', Icons.piano),
    GoalIcon('art', 'Kunst', Icons.palette),
    GoalIcon('book', 'Buch', Icons.menu_book),
    GoalIcon('movie', 'Film', Icons.movie),
    GoalIcon('mic', 'Mikrofon', Icons.mic),
    GoalIcon('ski', 'Ski', Icons.downhill_skiing),
    GoalIcon('surf', 'Surfen', Icons.surfing),
    GoalIcon('skate', 'Skateboard', Icons.skateboarding),
    GoalIcon('gym', 'Fitness', Icons.fitness_center),
  ],
  'Sonstiges': [
    GoalIcon('school', 'Schule', Icons.school),
    GoalIcon('pets', 'Haustier', Icons.pets),
    GoalIcon('eco', 'Natur', Icons.eco),
    GoalIcon('ring', 'Schmuck', Icons.diamond),
    GoalIcon('cake', 'Feier', Icons.cake),
    GoalIcon('food', 'Essen', Icons.restaurant),
    GoalIcon('clothes', 'Kleidung', Icons.checkroom),
    GoalIcon('health', 'Gesundheit', Icons.medication),
    GoalIcon('tools', 'Werkzeug', Icons.build),
    GoalIcon('flower', 'Blumen', Icons.local_florist),
    GoalIcon('brush', 'Renovieren', Icons.brush),
    GoalIcon('celebration', 'Party', Icons.celebration),
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

/// Liefert den Namen des Symbols - für Tooltips und Screenreader.
String goalIconLabel(String? key) =>
    _iconsByKey[key]?.label ?? 'Sparschwein';

/// Eine auswählbare Ziel-Farbe samt Namen.
///
/// Der Name ist nicht Deko: Eine Auswahl, die sich *nur* über Farbe
/// unterscheidet, ist für Screenreader-Nutzer sonst nicht bedienbar.
class GoalColorChoice {
  const GoalColorChoice(this.name, this.color);

  final String name;
  final Color color;
}

/// Vordefinierte Farbtöne zur Auswahl für ein Sparziel.
///
/// Diese Werte dienen nur als *Seed*: Die tatsächlich gezeichneten Farben
/// werden daraus passend zum Hell-/Dunkelmodus abgeleitet ([goalPalette]).
const List<GoalColorChoice> kGoalColorChoices = [
  GoalColorChoice('Violett', Color(0xFF6750A4)),
  GoalColorChoice('Grün', Color(0xFF2E7D32)),
  GoalColorChoice('Blau', Color(0xFF1565C0)),
  GoalColorChoice('Orange', Color(0xFFEF6C00)),
  GoalColorChoice('Rot', Color(0xFFC62828)),
  GoalColorChoice('Türkis', Color(0xFF00838F)),
  GoalColorChoice('Magenta', Color(0xFF8E24AA)),
  GoalColorChoice('Braun', Color(0xFF5D4037)),
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
  final brightness = theme.brightness;

  // harmonizeWith() zieht die gewählte Zielfarbe sanft in Richtung der
  // System-/Wallpaper-Farbe: Grün bleibt grün, passt aber zum Rest des
  // Schemas. Genau dieses Verfahren nutzt auch Android für App-Akzente.
  final seed = goalColorFromValue(
    colorValue,
  ).harmonizeWith(theme.colorScheme.primary);

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
