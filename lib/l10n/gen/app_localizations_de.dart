// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Spartracker';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonAdd => 'Hinzufügen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonUndo => 'Rückgängig';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonDate => 'Datum';

  @override
  String get commonNoteOptional => 'Notiz (optional)';

  @override
  String commonErrorWithMessage(String message) {
    return 'Fehler: $message';
  }

  @override
  String get homeGoalsSection => 'Sparziele';

  @override
  String get homeNewGoalFab => 'Sparziel';

  @override
  String get homeEmptyTitle => 'Noch keine Sparziele';

  @override
  String get homeEmptySubtitle =>
      'Lege ein Sparziel an und teile ihm Geld vom Konto zu.';

  @override
  String homeGoalCreated(String name) {
    return 'Sparziel \"$name\" wurde angelegt';
  }

  @override
  String get accountTitle => 'Sparkonto';

  @override
  String get accountBalance => 'Kontostand';

  @override
  String get accountAllocated => 'Zugeteilt';

  @override
  String get accountAvailable => 'Frei verfügbar';

  @override
  String get accountAvailableShort => 'Frei';

  @override
  String get accountOverAllocatedWarning =>
      'Achtung: Es ist mehr zugeteilt als auf dem Konto liegt.';

  @override
  String get accountEntriesSection => 'Buchungen';

  @override
  String get accountDepositFab => 'Einzahlen';

  @override
  String get accountEmptyTitle => 'Noch kein Geld auf dem Konto';

  @override
  String get accountEmptySubtitle =>
      'Zahle Geld ein – danach kannst du es deinen Sparzielen zuteilen.';

  @override
  String get accountEntryAdded => 'Buchung hinzugefügt';

  @override
  String get accountEntrySaved => 'Buchung gespeichert';

  @override
  String get accountEntryDeleted => 'Buchung gelöscht';

  @override
  String accountSemantics(String balance, String allocated, String available) {
    return 'Sparkonto, Kontostand $balance, zugeteilt $allocated, frei verfügbar $available';
  }

  @override
  String get resetMoneyMenu => 'Geld zurücksetzen';

  @override
  String get resetMoneyTitle => 'Geld zurücksetzen?';

  @override
  String resetMoneyBody(String balance, String allocated, String zero) {
    return 'Alle Buchungen und Zuteilungen werden gelöscht.\n\nKontostand: $balance → $zero\nZugeteilt: $allocated → $zero\n\nDeine Sparziele bleiben erhalten, stehen danach aber wieder bei 0 %. Das lässt sich nicht rückgängig machen.';
  }

  @override
  String get resetMoneyConfirm => 'Zurücksetzen';

  @override
  String get resetMoneyDone => 'Geld wurde auf null zurückgesetzt';

  @override
  String get goalFormNewTitle => 'Neues Sparziel';

  @override
  String get goalFormEditTitle => 'Sparziel bearbeiten';

  @override
  String get goalFormName => 'Name';

  @override
  String get goalFormNameHint => 'z. B. Neues Fahrrad';

  @override
  String get goalFormNameMissing => 'Bitte einen Namen eingeben';

  @override
  String get goalFormTargetAmount => 'Zielbetrag';

  @override
  String get goalFormAmountMissing => 'Bitte einen Zielbetrag eingeben';

  @override
  String get goalFormAmountInvalid => 'Bitte eine Zahl größer 0 eingeben';

  @override
  String get goalFormProductLink => 'Produktlink (optional)';

  @override
  String get goalFormProductLinkHint => 'https://...';

  @override
  String get goalFormLookUpPrice => 'Preis von der Seite holen';

  @override
  String get goalFormPriceHint =>
      'Der Preis wird aus den Produktdaten der Seite gelesen. Das klappt nicht bei jedem Shop – dann einfach selbst eintragen.';

  @override
  String get goalFormColor => 'Farbe';

  @override
  String get goalFormCreate => 'Anlegen';

  @override
  String goalFormPriceFound(String price) {
    return 'Preis gefunden: $price';
  }

  @override
  String get goalFormAlreadyPurchased => 'Bereits gekauft';

  @override
  String get goalFormAlreadyPurchasedHint =>
      'Du hast das schon aus eigener Tasche bezahlt und gleichst es jetzt mit später gespartem Geld aus – etwa aus einem eBay-Verkauf oder einem Geldgeschenk.';

  @override
  String get goalFormPurchaseDate => 'Kaufdatum';

  @override
  String get iconPickerTitle => 'Symbol auswählen';

  @override
  String get iconPickerButtonTooltip => 'Symbol auswählen';

  @override
  String iconPickerButtonSemantics(String label) {
    return 'Symbol auswählen, aktuell $label';
  }

  @override
  String get entryFormNewTitle => 'Geld einzahlen';

  @override
  String get entryFormEditTitle => 'Buchung bearbeiten';

  @override
  String get entryFormAmount => 'Betrag';

  @override
  String get entryFormAmountHelper => 'Negativer Betrag = Entnahme';

  @override
  String get entryFormAmountMissing => 'Bitte einen Betrag eingeben';

  @override
  String get entryFormAmountInvalid =>
      'Bitte eine gültige Zahl ungleich 0 eingeben';

  @override
  String get entryFormSource => 'Quelle';

  @override
  String get entryFormSourceHint =>
      'z. B. Geburtstag, eBay, Zeitung austragen ...';

  @override
  String get entryFormSourceMissing => 'Bitte eine Quelle eingeben';

  @override
  String get entryFormFooter =>
      'Das Geld landet auf dem Sparkonto und kann danach einzelnen Sparzielen zugeteilt werden.';

  @override
  String get allocationNewTitle => 'Geld zuteilen';

  @override
  String get allocationEditTitle => 'Zuteilung bearbeiten';

  @override
  String get allocationAvailableLabel => 'Frei verfügbar auf dem Konto';

  @override
  String allocationAmountFor(String name) {
    return 'Betrag für \"$name\"';
  }

  @override
  String get allocationAmountHelper =>
      'Negativer Betrag holt Geld zurück aufs Konto';

  @override
  String allocationTooMuch(String amount) {
    return 'Nur $amount frei verfügbar';
  }

  @override
  String allocationFillRemaining(String amount) {
    return 'Rest bis Ziel ($amount)';
  }

  @override
  String allocationFillAll(String amount) {
    return 'Alles ($amount)';
  }

  @override
  String get allocationConfirm => 'Zuteilen';

  @override
  String allocationDone(String amount) {
    return '$amount zugeteilt';
  }

  @override
  String get detailAllocationsSection => 'Zuteilungen';

  @override
  String get detailAllocation => 'Zuteilung';

  @override
  String get detailReturnedToAccount => 'Zurück aufs Konto';

  @override
  String get detailEmptyTitle => 'Noch nichts zugeteilt';

  @override
  String get detailEmptySubtitle => 'Teile diesem Ziel Geld vom Sparkonto zu.';

  @override
  String get detailAllocationDeleted => 'Zuteilung gelöscht';

  @override
  String get detailAssignFab => 'Zuteilen';

  @override
  String get detailSettleFab => 'Ausgleichen';

  @override
  String detailOfAmount(String amount) {
    return 'von $amount';
  }

  @override
  String get detailGoalReached => 'Ziel erreicht 🎉';

  @override
  String get detailPurchaseSettled => 'Vollständig ausgeglichen 🎉';

  @override
  String detailRemaining(String amount) {
    return 'Noch $amount';
  }

  @override
  String detailStillToSettle(String amount) {
    return 'Noch $amount auszugleichen';
  }

  @override
  String detailPurchasedOn(String date) {
    return 'Gekauft am $date';
  }

  @override
  String detailProgressSemantics(int percent) {
    return 'Fortschritt $percent Prozent';
  }

  @override
  String get detailOpenProductPage => 'Produktseite öffnen';

  @override
  String get detailRefreshPrice => 'Preis aktualisieren';

  @override
  String get detailSearchingPrice => 'Preis wird gesucht ...';

  @override
  String detailPriceUpdated(String price) {
    return 'Zielbetrag aktualisiert: $price';
  }

  @override
  String get detailLinkFailed => 'Link konnte nicht geöffnet werden';

  @override
  String get archiveMenu => 'Archivieren';

  @override
  String get archiveTitle => 'Sparziel archivieren?';

  @override
  String archiveBody(String name) {
    return '\"$name\" wird ausgeblendet. Das zugeteilte Geld bleibt reserviert – lösche vorher die Zuteilungen, wenn du es wieder frei verfügbar haben willst.';
  }

  @override
  String get deleteGoalTitle => 'Sparziel löschen?';

  @override
  String deleteGoalBodyWithMoney(String name, String amount) {
    return '\"$name\" wird mitsamt allen Zuteilungen gelöscht.\n\n$amount gehen zurück aufs Konto und sind danach wieder frei verfügbar.';
  }

  @override
  String deleteGoalBodyEmpty(String name) {
    return '\"$name\" wird gelöscht. Es ist kein Geld zugeteilt, der Kontostand ändert sich also nicht.';
  }

  @override
  String goalDeleted(String name) {
    return '\"$name\" gelöscht';
  }

  @override
  String goalDeletedWithMoney(String name, String amount) {
    return '\"$name\" gelöscht · $amount zurück aufs Konto';
  }

  @override
  String goalCardSemantics(
    String name,
    String allocated,
    String target,
    String progress,
  ) {
    return '$name, $allocated von $target, $progress';
  }

  @override
  String get goalCardReached => 'Ziel erreicht';

  @override
  String get goalCardSettled => 'Vollständig ausgeglichen';

  @override
  String goalCardPercent(int percent) {
    return '$percent Prozent';
  }

  @override
  String goalCardOf(String allocated, String target) {
    return '$allocated von $target';
  }

  @override
  String get goalPurchasedBadge => 'Gekauft';

  @override
  String widgetTargetOf(String target) {
    return 'von $target';
  }

  @override
  String widgetRemaining(String amount) {
    return 'noch $amount';
  }

  @override
  String get widgetReached => 'Ziel erreicht';

  @override
  String get widgetHintPickGoal => 'Tippen, um ein Sparziel zu wählen';

  @override
  String get widgetHintNoData => 'Spartracker öffnen, um loszulegen';

  @override
  String get widgetConfigTitle => 'Sparziel wählen';

  @override
  String get widgetConfigConfirm => 'Übernehmen';

  @override
  String get widgetConfigEmptyTitle => 'Noch keine Sparziele';

  @override
  String get widgetConfigEmptyBody =>
      'Lege zuerst in der App ein Sparziel an, dann taucht es hier auf.';

  @override
  String get widgetConfigOpenApp => 'App öffnen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAppearance => 'Darstellung';

  @override
  String get settingsDynamicColor => 'Systemfarben verwenden';

  @override
  String get settingsDynamicColorOn =>
      'Farben richten sich nach Hintergrundbild bzw. Systemakzent';

  @override
  String get settingsDynamicColorOff => 'Unten eine eigene Farbe auswählen';

  @override
  String get settingsDynamicColorUnavailable =>
      'Dieses Gerät liefert keine Systemfarben';

  @override
  String get settingsOwnColor => 'Eigene Farbe';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageGerman => 'Deutsch';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsOpen => 'Einstellungen';

  @override
  String get sourceBirthday => 'Geburtstag';

  @override
  String get sourceGift => 'Geschenk';

  @override
  String get sourceEbay => 'eBay';

  @override
  String get sourcePocketMoney => 'Taschengeld';

  @override
  String get sourceOther => 'Sonstiges';

  @override
  String get priceErrorInvalidUrl =>
      'Das sieht nicht nach einem gültigen Link aus.';

  @override
  String get priceErrorNetwork =>
      'Die Seite konnte nicht geladen werden. Internet prüfen?';

  @override
  String priceErrorBlocked(String status) {
    return 'Der Shop blockiert automatische Zugriffe (Fehler $status). Bitte den Preis von Hand eintragen.';
  }

  @override
  String get priceErrorNotFound =>
      'Auf der Seite wurde kein Preis gefunden. Bitte von Hand eintragen.';

  @override
  String get colorViolet => 'Violett';

  @override
  String get colorGreen => 'Grün';

  @override
  String get colorBlue => 'Blau';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorRed => 'Rot';

  @override
  String get colorTeal => 'Türkis';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get colorBrown => 'Braun';

  @override
  String get iconGroupPopular => 'Beliebt';

  @override
  String get iconGroupTech => 'Technik';

  @override
  String get iconGroupTravel => 'Reisen';

  @override
  String get iconGroupVehicles => 'Fahrzeuge';

  @override
  String get iconGroupHome => 'Wohnen';

  @override
  String get iconGroupLeisure => 'Freizeit';

  @override
  String get iconGroupOther => 'Sonstiges';

  @override
  String get iconSavings => 'Sparschwein';

  @override
  String get iconFlag => 'Ziel';

  @override
  String get iconStar => 'Stern';

  @override
  String get iconGift => 'Geschenk';

  @override
  String get iconCart => 'Einkauf';

  @override
  String get iconPayments => 'Geld';

  @override
  String get iconTrophy => 'Pokal';

  @override
  String get iconFavorite => 'Herz';

  @override
  String get iconSmartphone => 'Smartphone';

  @override
  String get iconLaptop => 'Laptop';

  @override
  String get iconDesktop => 'PC';

  @override
  String get iconHeadphones => 'Kopfhörer';

  @override
  String get iconGaming => 'Gaming';

  @override
  String get iconCamera => 'Kamera';

  @override
  String get iconWatch => 'Smartwatch';

  @override
  String get iconTv => 'Fernseher';

  @override
  String get iconKeyboard => 'Tastatur';

  @override
  String get iconPrinter => 'Drucker';

  @override
  String get iconSpeaker => 'Lautsprecher';

  @override
  String get iconTablet => 'Tablet';

  @override
  String get iconFlight => 'Flug';

  @override
  String get iconBeach => 'Strand';

  @override
  String get iconMap => 'Karte';

  @override
  String get iconBackpack => 'Rucksack';

  @override
  String get iconHotel => 'Hotel';

  @override
  String get iconLuggage => 'Koffer';

  @override
  String get iconTrain => 'Zug';

  @override
  String get iconBoat => 'Schiff';

  @override
  String get iconMountain => 'Berge';

  @override
  String get iconCamping => 'Camping';

  @override
  String get iconHiking => 'Wandern';

  @override
  String get iconWorld => 'Welt';

  @override
  String get iconTicket => 'Ticket';

  @override
  String get iconCar => 'Auto';

  @override
  String get iconBike => 'Fahrrad';

  @override
  String get iconScooter => 'Roller';

  @override
  String get iconBus => 'Bus';

  @override
  String get iconEScooter => 'E-Scooter';

  @override
  String get iconTruck => 'Transporter';

  @override
  String get iconCarRepair => 'Werkstatt';

  @override
  String get iconEvStation => 'Ladesäule';

  @override
  String get iconHome => 'Zuhause';

  @override
  String get iconChair => 'Möbel';

  @override
  String get iconBed => 'Bett';

  @override
  String get iconKitchen => 'Küche';

  @override
  String get iconShower => 'Bad';

  @override
  String get iconLaundry => 'Waschmaschine';

  @override
  String get iconPlant => 'Pflanzen';

  @override
  String get iconLamp => 'Lampe';

  @override
  String get iconSoccer => 'Fußball';

  @override
  String get iconBasketball => 'Basketball';

  @override
  String get iconMusic => 'Musik';

  @override
  String get iconPiano => 'Klavier';

  @override
  String get iconArt => 'Kunst';

  @override
  String get iconBook => 'Buch';

  @override
  String get iconMovie => 'Film';

  @override
  String get iconMic => 'Mikrofon';

  @override
  String get iconSki => 'Ski';

  @override
  String get iconSurf => 'Surfen';

  @override
  String get iconSkate => 'Skateboard';

  @override
  String get iconGym => 'Fitness';

  @override
  String get iconSchool => 'Schule';

  @override
  String get iconPets => 'Haustier';

  @override
  String get iconEco => 'Natur';

  @override
  String get iconRing => 'Schmuck';

  @override
  String get iconCake => 'Feier';

  @override
  String get iconFood => 'Essen';

  @override
  String get iconClothes => 'Kleidung';

  @override
  String get iconHealth => 'Gesundheit';

  @override
  String get iconTools => 'Werkzeug';

  @override
  String get iconFlower => 'Blumen';

  @override
  String get iconBrush => 'Renovieren';

  @override
  String get iconCelebration => 'Party';
}
