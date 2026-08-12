import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sprachwahl der App.
enum AppLanguage {
  /// Folgt der Systemsprache.
  system,
  german,
  english;

  /// Locale für die [MaterialApp]; `null` bedeutet "Systemsprache".
  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.german => const Locale('de'),
    AppLanguage.english => const Locale('en'),
  };

  static AppLanguage fromName(String? name) => AppLanguage.values.firstWhere(
    (value) => value.name == name,
    orElse: () => AppLanguage.system,
  );
}

/// Alle vom Nutzer einstellbaren Optionen.
@immutable
class AppSettings {
  const AppSettings({
    this.useDynamicColor = true,
    this.seedColor = const Color(0xFF6750A4),
    this.language = AppLanguage.system,
  });

  /// Systemfarben übernehmen (Wallpaper auf Android 12+, Akzentfarbe auf
  /// Windows). Ist das aus, gilt [seedColor].
  final bool useDynamicColor;

  /// Selbst gewählte Grundfarbe, aus der das Farbschema abgeleitet wird.
  final Color seedColor;

  final AppLanguage language;

  AppSettings copyWith({
    bool? useDynamicColor,
    Color? seedColor,
    AppLanguage? language,
  }) {
    return AppSettings(
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      seedColor: seedColor ?? this.seedColor,
      language: language ?? this.language,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.useDynamicColor == useDynamicColor &&
      other.seedColor.toARGB32() == seedColor.toARGB32() &&
      other.language == language;

  @override
  int get hashCode => Object.hash(useDynamicColor, seedColor.toARGB32(), language);
}

/// Hält die Einstellungen und schreibt jede Änderung sofort auf die Platte.
///
/// Die Einstellungen liegen bewusst *nicht* in der Datenbank: Sie werden
/// schon beim Aufbau des Themes gebraucht, also bevor die Datenbank offen
/// ist, und "Geld zurücksetzen" soll sie nicht mitlöschen.
class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._prefs) : super(_read(_prefs));

  final SharedPreferences _prefs;

  static const _keyDynamicColor = 'settings.useDynamicColor';
  static const _keySeedColor = 'settings.seedColor';
  static const _keyLanguage = 'settings.language';

  static AppSettings _read(SharedPreferences prefs) {
    const defaults = AppSettings();
    final storedSeed = prefs.getInt(_keySeedColor);
    return AppSettings(
      useDynamicColor:
          prefs.getBool(_keyDynamicColor) ?? defaults.useDynamicColor,
      seedColor: storedSeed != null ? Color(storedSeed) : defaults.seedColor,
      language: AppLanguage.fromName(prefs.getString(_keyLanguage)),
    );
  }

  Future<void> setUseDynamicColor(bool value) async {
    state = state.copyWith(useDynamicColor: value);
    await _prefs.setBool(_keyDynamicColor, value);
  }

  Future<void> setSeedColor(Color color) async {
    // Eine eigene Farbe zu wählen bedeutet zwangsläufig, die Systemfarben
    // abzuschalten - sonst hätte die Auswahl keinen sichtbaren Effekt.
    state = state.copyWith(seedColor: color, useDynamicColor: false);
    await _prefs.setInt(_keySeedColor, color.toARGB32());
    await _prefs.setBool(_keyDynamicColor, false);
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    await _prefs.setString(_keyLanguage, language.name);
  }
}

/// Wird in `main()` mit der geladenen Instanz überschrieben.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider muss überschrieben werden');
});

final settingsProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
      return SettingsController(ref.watch(sharedPreferencesProvider));
    });
