import 'package:flutter/widgets.dart';

import '../models/goal_style.dart';
import '../services/price_lookup.dart';
import 'gen/app_localizations.dart';

/// Übersetzt die Schlüssel aus den Datenmodellen (Symbole, Farben,
/// Quellen-Vorschläge) in die aktuelle Sprache.
///
/// Die Modelle selbst kennen bewusst keine Texte: In der Datenbank stehen
/// stabile Schlüssel wie `bike`, die Beschriftung entscheidet sich erst
/// beim Anzeigen. Ein Sprachwechsel benennt damit auch bestehende Ziele um.
extension L10nLabels on AppLocalizations {
  /// Name eines Symbols, z. B. `bike` -> "Fahrrad" / "Bicycle".
  String goalIconLabel(String? key) => switch (key) {
    'savings' => iconSavings,
    'flag' => iconFlag,
    'star' => iconStar,
    'gift' => iconGift,
    'cart' => iconCart,
    'payments' => iconPayments,
    'trophy' => iconTrophy,
    'favorite' => iconFavorite,
    'smartphone' => iconSmartphone,
    'laptop' => iconLaptop,
    'desktop' => iconDesktop,
    'headphones' => iconHeadphones,
    'gaming' => iconGaming,
    'camera' => iconCamera,
    'watch' => iconWatch,
    'tv' => iconTv,
    'keyboard' => iconKeyboard,
    'printer' => iconPrinter,
    'speaker' => iconSpeaker,
    'tablet' => iconTablet,
    'flight' => iconFlight,
    'beach' => iconBeach,
    'map' => iconMap,
    'backpack' => iconBackpack,
    'hotel' => iconHotel,
    'luggage' => iconLuggage,
    'train' => iconTrain,
    'boat' => iconBoat,
    'mountain' => iconMountain,
    'camping' => iconCamping,
    'hiking' => iconHiking,
    'world' => iconWorld,
    'ticket' => iconTicket,
    'car' => iconCar,
    'bike' => iconBike,
    'scooter' => iconScooter,
    'bus' => iconBus,
    'e_scooter' => iconEScooter,
    'truck' => iconTruck,
    'car_repair' => iconCarRepair,
    'ev_station' => iconEvStation,
    'home' => iconHome,
    'chair' => iconChair,
    'bed' => iconBed,
    'kitchen' => iconKitchen,
    'shower' => iconShower,
    'laundry' => iconLaundry,
    'plant' => iconPlant,
    'lamp' => iconLamp,
    'soccer' => iconSoccer,
    'basketball' => iconBasketball,
    'music' => iconMusic,
    'piano' => iconPiano,
    'art' => iconArt,
    'book' => iconBook,
    'movie' => iconMovie,
    'mic' => iconMic,
    'ski' => iconSki,
    'surf' => iconSurf,
    'skate' => iconSkate,
    'gym' => iconGym,
    'school' => iconSchool,
    'pets' => iconPets,
    'eco' => iconEco,
    'ring' => iconRing,
    'cake' => iconCake,
    'food' => iconFood,
    'clothes' => iconClothes,
    'health' => iconHealth,
    'tools' => iconTools,
    'flower' => iconFlower,
    'brush' => iconBrush,
    'celebration' => iconCelebration,
    // Unbekannter Schlüssel (etwa aus einer neueren Version): auf das
    // Standardsymbol zurückfallen, statt leer zu bleiben.
    _ => iconSavings,
  };

  /// Überschrift einer Symbolgruppe.
  String goalIconGroupLabel(GoalIconGroup group) => switch (group) {
    GoalIconGroup.popular => iconGroupPopular,
    GoalIconGroup.tech => iconGroupTech,
    GoalIconGroup.travel => iconGroupTravel,
    GoalIconGroup.vehicles => iconGroupVehicles,
    GoalIconGroup.home => iconGroupHome,
    GoalIconGroup.leisure => iconGroupLeisure,
    GoalIconGroup.other => iconGroupOther,
  };

  /// Name einer Ziel-Farbe.
  String goalColorLabel(String key) => switch (key) {
    'violet' => colorViolet,
    'green' => colorGreen,
    'blue' => colorBlue,
    'orange' => colorOrange,
    'red' => colorRed,
    'teal' => colorTeal,
    'magenta' => colorMagenta,
    'brown' => colorBrown,
    _ => colorViolet,
  };

  /// Vorschläge für die Quelle einer Buchung.
  List<String> get entrySourceSuggestions => [
    sourceBirthday,
    sourceGift,
    sourceEbay,
    sourcePocketMoney,
    sourceOther,
  ];

  /// Übersetzt einen Fehler der Preissuche in eine Meldung für den Nutzer.
  String priceLookupMessage(PriceLookupException error) => switch (error.reason) {
    PriceLookupError.invalidUrl => priceErrorInvalidUrl,
    PriceLookupError.network => priceErrorNetwork,
    PriceLookupError.blocked => priceErrorBlocked('${error.statusCode}'),
    PriceLookupError.notFound => priceErrorNotFound,
  };
}

/// Kurzform für `AppLocalizations.of(context)`.
AppLocalizations l10n(BuildContext context) => AppLocalizations.of(context);
