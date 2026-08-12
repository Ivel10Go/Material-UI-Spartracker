// Prüft, dass Einstellungen korrekt gelesen, geschrieben und beim
// nächsten Start wieder gefunden werden.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spartracker/settings/app_settings.dart';

/// Baut einen Container mit den übergebenen gespeicherten Werten.
Future<ProviderContainer> containerWith([
  Map<String, Object> preferences = const {},
]) async {
  SharedPreferences.setMockInitialValues(preferences);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Standard: Systemfarben an, Sprache folgt dem System', () async {
    final container = await containerWith();
    final settings = container.read(settingsProvider);

    expect(settings.useDynamicColor, isTrue);
    expect(settings.language, AppLanguage.system);
    expect(settings.language.locale, isNull);
  });

  test('Gespeicherte Werte werden beim Start gelesen', () async {
    const stored = Color(0xFF1565C0);
    final container = await containerWith({
      'settings.useDynamicColor': false,
      'settings.seedColor': stored.toARGB32(),
      'settings.language': 'english',
    });
    final settings = container.read(settingsProvider);

    expect(settings.useDynamicColor, isFalse);
    expect(settings.seedColor.toARGB32(), stored.toARGB32());
    expect(settings.language, AppLanguage.english);
    expect(settings.language.locale, const Locale('en'));
  });

  test('Eine eigene Farbe schaltet die Systemfarben ab', () async {
    final container = await containerWith();
    final controller = container.read(settingsProvider.notifier);

    expect(container.read(settingsProvider).useDynamicColor, isTrue);

    const green = Color(0xFF2E7D32);
    await controller.setSeedColor(green);

    final settings = container.read(settingsProvider);
    expect(settings.seedColor.toARGB32(), green.toARGB32());
    // Sonst hätte die Farbwahl sichtbar keinen Effekt.
    expect(settings.useDynamicColor, isFalse);
  });

  test('Änderungen überleben einen Neustart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final first = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    await first.read(settingsProvider.notifier).setLanguage(AppLanguage.german);
    await first
        .read(settingsProvider.notifier)
        .setSeedColor(const Color(0xFFEF6C00));
    first.dispose();

    // Zweiter "Start" mit denselben gespeicherten Werten.
    final second = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(second.dispose);

    final settings = second.read(settingsProvider);
    expect(settings.language, AppLanguage.german);
    expect(settings.seedColor.toARGB32(), const Color(0xFFEF6C00).toARGB32());
    expect(settings.useDynamicColor, isFalse);
  });

  test('Unbekannte Sprache aus der Datei fällt auf "System" zurück', () async {
    final container = await containerWith({'settings.language': 'klingonisch'});
    expect(container.read(settingsProvider).language, AppLanguage.system);
  });

  test('Systemfarben lassen sich wieder einschalten', () async {
    final container = await containerWith({'settings.useDynamicColor': false});
    final controller = container.read(settingsProvider.notifier);

    await controller.setUseDynamicColor(true);
    expect(container.read(settingsProvider).useDynamicColor, isTrue);
  });
}
