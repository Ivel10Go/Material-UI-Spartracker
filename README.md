# Spartracker

Eine Flutter-App zum Sparen auf mehrere Ziele – mit einem **gemeinsamen Konto**
statt getrennter Sparschweine. Geld wird einmal eingezahlt und danach frei auf
Sparziele verteilt.

Vollständig offline, ohne Konto, ohne Cloud. Alle Daten bleiben auf dem Gerät.

---

## Das Grundprinzip

Die meisten Spar-Apps verwalten pro Ziel einen eigenen Topf. Spartracker trennt
stattdessen **wo das Geld liegt** von **wofür es gedacht ist**:

```
        Einzahlungen                       Zuteilungen
   (Geburtstag, Ferienjob, …)         (reserviert für ein Ziel)
              │                                  │
              ▼                                  ▼
      ┌───────────────┐                  ┌────────────────┐
      │  Sparkonto    │ ───────────────► │  🚲 Fahrrad    │  150 €
      │   300,00 €    │                  ├────────────────┤
      └───────────────┘ ───────────────► │  🎧 Kopfhörer  │   50 €
              │                          └────────────────┘
              │
       frei verfügbar: 100 €
```

Daraus ergeben sich drei Werte, die überall in der App auftauchen:

| Wert | Bedeutung |
| --- | --- |
| **Kontostand** | Summe aller Ein- und Auszahlungen |
| **Zugeteilt** | Summe des Geldes, das Zielen zugeordnet ist |
| **Frei verfügbar** | Kontostand − Zugeteilt |

Wichtig: Eine Zuteilung verschiebt kein Geld, sie *reserviert* es. Der
Kontostand ändert sich dabei nicht. Löscht man ein Ziel, verschwindet nur die
Reservierung – das Geld ist sofort wieder frei verfügbar.

Wird mehr zugeteilt, als auf dem Konto liegt (etwa nach einer nachträglichen
Entnahme), wird „frei verfügbar" negativ. Die App blendet dann eine Warnung
ein, statt den Wert stillschweigend zu beschönigen.

---

## Funktionen

- **Sparkonto** mit Buchungshistorie – Ein- und Auszahlungen mit frei
  eingebbarer Quelle, Datum und Notiz
- **Sparziele** mit Zielbetrag, Symbol und Farbe; Fortschritt als Ring und
  Balken
- **Zuteilen und Zurückholen** von Geld, mit Schnellauswahl („Rest bis Ziel",
  „Alles")
- **Produktlink mit Preissuche** – der Zielbetrag kann automatisch von der
  Produktseite gelesen werden (siehe [Grenzen](#preissuche-was-sie-kann-und-was-nicht))
- **Löschen mit Rückgängig** für Buchungen, Zuteilungen und ganze Sparziele
- **Archivieren** von Zielen, die nicht mehr in der Übersicht stehen sollen
- **Geld zurücksetzen** – leert alle Buchungen und Zuteilungen, behält die Ziele
- **73 Symbole** in sieben Kategorien und acht Farbtöne pro Ziel
- **Material You** – die App übernimmt die Systemfarbe (Wallpaper auf
  Android 12+, Akzentfarbe auf Windows) und folgt dem Hell-/Dunkelmodus
- Deutsche Oberfläche samt Währungs- und Datumsformat (`1.299,00 €`)

---

## Tech-Stack

| Bereich | Wahl | Warum |
| --- | --- | --- |
| Framework | Flutter 3.44 / Dart 3.12 | eine Codebasis für Mobile und Desktop |
| State | [Riverpod](https://riverpod.dev) 2.6 | `StreamProvider` auf Datenbank-Streams: die UI aktualisiert sich von selbst |
| Datenbank | [Drift](https://drift.simonbinder.eu) 2.22 (SQLite) | typsichere Queries zur Compile-Zeit, saubere Migrationen |
| Farben | `dynamic_color` 1.7 | Systemfarben für Material You |
| Preissuche | `http` + `html` | HTML laden und strukturierte Metadaten auslesen |

---

## Projektstruktur

```
lib/
├── data/                  Datenbank und Zugriffsschicht
│   ├── database.dart        Tabellen, Schema-Version, Migrationen
│   ├── goals_dao.dart       Sparziele (inkl. Löschen mit Wiederherstellung)
│   ├── account_dao.dart     Kontobuchungen, Kontostand, Reset
│   └── allocations_dao.dart Zuteilungen
├── models/
│   ├── goal_style.dart      Symbol-Katalog, Farbauswahl, tonale Paletten
│   └── entry_source.dart    Vorschläge für die Quelle einer Buchung
├── providers/             Riverpod-Provider (reaktive Sicht auf die DAOs)
├── screens/
│   ├── home_screen.dart     Kontokarte + Liste der Sparziele
│   ├── account_screen.dart  Kontostand und alle Buchungen
│   └── goal_detail_screen.dart  Fortschritt und Zuteilungen eines Ziels
├── services/
│   └── price_lookup.dart    Preisermittlung aus Produktseiten
├── theme/
│   ├── app_theme.dart       Material-3-Theme
│   └── tokens.dart          Abstands-/Form-Tokens, Fensterklassen
├── utils/format.dart      Deutsche Währungsformatierung
└── widgets/               Karten, Listeneinträge, BottomSheets
```

Die Schichten sind bewusst getrennt: Widgets kennen keine Datenbank, DAOs kennen
kein Flutter. Dazwischen stehen die Provider.

---

## Loslegen

Voraussetzung: [Flutter SDK](https://docs.flutter.dev/get-started/install)
3.44 oder neuer.

```bash
flutter pub get

# Drift-Code erzeugen (nach jeder Änderung an database.dart nötig)
dart run build_runner build

flutter run
```

Getestet auf **Android** und **Windows**. Die übrigen Plattformordner sind zwar
angelegt, aber ungeprüft – für **Web** genügt das nicht: Drift braucht dort eine
eigene SQLite-WASM-Einrichtung, die hier fehlt.

---

## Daten und Speicherort

Die Datenbank liegt im privaten Verzeichnis der App:

| Plattform | Pfad |
| --- | --- |
| Android | `/data/data/com.spartracker.spartracker/app_flutter/spartracker.sqlite` |
| Windows | `%USERPROFILE%\Documents\spartracker.sqlite` |

Jedes Gerät hat seine **eigene** Datenbank – es gibt keine Synchronisierung
zwischen Handy und PC.

Auf einem Debug-Build lässt sich die Android-Datei so herausziehen:

```bash
adb exec-out run-as com.spartracker.spartracker \
  cat app_flutter/spartracker.sqlite > spartracker.sqlite
```

### Schema-Historie

| Version | Änderung |
| --- | --- |
| 1 | Einträge hingen direkt am Sparziel |
| 2 | Umstellung auf zentrales Konto: jeder alte Eintrag wurde in eine Buchung **und** eine Zuteilung aufgeteilt, sodass Kontostand und Zielfortschritt erhalten blieben |
| 3 | Symbole von Emojis auf Material-Icons; gespeichert wird ein stabiler Schlüssel (`bike`) statt eines Icon-Codepoints |

Zu Version 3: Ein Codepoint würde bedeuten, `IconData` zur Laufzeit zu bauen –
dann kann Flutter die Icon-Schriften nicht mehr ausdünnen und der Release-Build
bricht ab. Im Debug-Modus fällt das nie auf, deshalb der Schlüssel.

Die Migrationen sind durch Tests abgedeckt, die eine echte Datenbank im alten
Schema anlegen und den kompletten Weg v1 → v2 → v3 durchlaufen.

---

## Preissuche: was sie kann und was nicht

Zum Sparziel lässt sich ein Produktlink hinterlegen; die App liest daraus den
Preis und trägt ihn als Zielbetrag ein.

**Ausgewertet werden**, in dieser Reihenfolge:

1. JSON-LD nach `schema.org/Product` (auch verschachtelt in `@graph`)
2. Meta-Tags: `product:price:amount`, `og:price:amount`
3. Microdata: `itemprop="price"`

Deutsche wie englische Schreibweisen werden erkannt (`1.299,00 €` und
`1,299.00`).

**Nicht funktionieren wird es**, wenn der Shop den Preis erst per JavaScript
nachlädt oder automatische Zugriffe blockiert – bei Amazon etwa meist. In dem
Fall erscheint eine klare Meldung und der Preis wird von Hand eingetragen.
Es wird **nie** ein geratener Wert eingesetzt.

---

## Tests

```bash
flutter analyze
flutter test
```

Aktuell **42 Tests**:

| Datei | Prüft |
| --- | --- |
| `migration_test.dart` | Schema-Migrationen an einer echten SQLite-Datei; Geldfreigabe beim Löschen, Rückgängig, Reset, Cascade |
| `price_lookup_test.dart` | Preiserkennung gegen einen Fake-HTTP-Client, inkl. Blockade, fehlendem Preis und kaputtem JSON-LD |
| `adaptive_layout_test.dart` | Fensterklassen, Seitenränder, Begrenzung der Inhaltsbreite |
| `goal_style_test.dart` | Symbol-Katalog: eindeutige Schlüssel, Rückfallebene, konstante `IconData` |
| `widget_test.dart` | Smoke-Test des Startbildschirms |

---

## Design

Die Oberfläche folgt Material Design 3:

- **Farbe** kommt aus `ColorScheme`-Rollen, nie aus festen Hex-Werten. Jedes
  Sparziel bekommt aus seiner Farbe ein eigenes tonales Schema, das per
  `harmonizeWith()` zur Systemfarbe hin ausgerichtet wird – Grün bleibt grün,
  passt aber zum Rest.
- **Tiefe** entsteht über tonale Flächen, nicht über Schatten.
- **Abstände und Formen** stammen aus `theme/tokens.dart` (4dp-Raster,
  MD3-Shape-Skala) statt aus verstreuten Zahlen im Widget-Code.
- **Adaptiv**: Ränder richten sich nach der Fensterklasse, auf breiten Fenstern
  wird der Inhalt auf 840dp begrenzt und zentriert, statt über den ganzen
  Bildschirm zu laufen.
- **Bedienbarkeit**: Berührungsziele mindestens 48dp; Karten, Fortschrittsringe
  und Farbfelder haben sprechende Labels für Screenreader.

---

## Grenzen

- Keine Synchronisierung zwischen Geräten, kein Backup-Export
- Web wird nicht unterstützt (siehe oben)
- Die Preissuche ist bewusst „best effort" und ersetzt keine Shop-API
- „Geld zurücksetzen" lässt sich nicht rückgängig machen – anders als das
  Löschen einzelner Einträge
