// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Spartracker';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDate => 'Date';

  @override
  String get commonNoteOptional => 'Note (optional)';

  @override
  String commonErrorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get homeGoalsSection => 'Savings goals';

  @override
  String get homeNewGoalFab => 'Goal';

  @override
  String get homeEmptyTitle => 'No savings goals yet';

  @override
  String get homeEmptySubtitle =>
      'Create a goal and assign money from your account to it.';

  @override
  String homeGoalCreated(String name) {
    return 'Goal \"$name\" created';
  }

  @override
  String get accountTitle => 'Savings account';

  @override
  String get accountBalance => 'Balance';

  @override
  String get accountAllocated => 'Allocated';

  @override
  String get accountAvailable => 'Available';

  @override
  String get accountAvailableShort => 'Free';

  @override
  String get accountOverAllocatedWarning =>
      'Careful: more is allocated than the account holds.';

  @override
  String get accountEntriesSection => 'Transactions';

  @override
  String get accountDepositFab => 'Deposit';

  @override
  String get accountEmptyTitle => 'No money in the account yet';

  @override
  String get accountEmptySubtitle =>
      'Deposit money, then assign it to your savings goals.';

  @override
  String get accountEntryAdded => 'Transaction added';

  @override
  String get accountEntrySaved => 'Transaction saved';

  @override
  String get accountEntryDeleted => 'Transaction deleted';

  @override
  String accountSemantics(String balance, String allocated, String available) {
    return 'Savings account, balance $balance, allocated $allocated, available $available';
  }

  @override
  String get resetMoneyMenu => 'Reset money';

  @override
  String get resetMoneyTitle => 'Reset money?';

  @override
  String resetMoneyBody(String balance, String allocated, String zero) {
    return 'All transactions and allocations will be deleted.\n\nBalance: $balance → $zero\nAllocated: $allocated → $zero\n\nYour savings goals are kept but will be back at 0 %. This cannot be undone.';
  }

  @override
  String get resetMoneyConfirm => 'Reset';

  @override
  String get resetMoneyDone => 'Money has been reset to zero';

  @override
  String get goalFormNewTitle => 'New savings goal';

  @override
  String get goalFormEditTitle => 'Edit savings goal';

  @override
  String get goalFormName => 'Name';

  @override
  String get goalFormNameHint => 'e.g. New bike';

  @override
  String get goalFormNameMissing => 'Please enter a name';

  @override
  String get goalFormTargetAmount => 'Target amount';

  @override
  String get goalFormAmountMissing => 'Please enter a target amount';

  @override
  String get goalFormAmountInvalid => 'Please enter a number greater than 0';

  @override
  String get goalFormProductLink => 'Product link (optional)';

  @override
  String get goalFormProductLinkHint => 'https://...';

  @override
  String get goalFormLookUpPrice => 'Fetch price from the page';

  @override
  String get goalFormPriceHint =>
      'The price is read from the page\'s product data. This does not work with every shop — you can always enter it yourself.';

  @override
  String get goalFormColor => 'Colour';

  @override
  String get goalFormCreate => 'Create';

  @override
  String goalFormPriceFound(String price) {
    return 'Price found: $price';
  }

  @override
  String get goalFormAlreadyPurchased => 'Already purchased';

  @override
  String get goalFormAlreadyPurchasedHint =>
      'You already paid for this out of pocket and are settling it with money you save later – say, from an eBay sale or a cash gift.';

  @override
  String get goalFormPurchaseDate => 'Purchase date';

  @override
  String get iconPickerTitle => 'Choose a symbol';

  @override
  String get iconPickerButtonTooltip => 'Choose a symbol';

  @override
  String iconPickerButtonSemantics(String label) {
    return 'Choose a symbol, currently $label';
  }

  @override
  String get entryFormNewTitle => 'Deposit money';

  @override
  String get entryFormEditTitle => 'Edit transaction';

  @override
  String get entryFormAmount => 'Amount';

  @override
  String get entryFormAmountHelper => 'A negative amount is a withdrawal';

  @override
  String get entryFormAmountMissing => 'Please enter an amount';

  @override
  String get entryFormAmountInvalid =>
      'Please enter a valid number other than 0';

  @override
  String get entryFormSource => 'Source';

  @override
  String get entryFormSourceHint => 'e.g. birthday, eBay, paper round ...';

  @override
  String get entryFormSourceMissing => 'Please enter a source';

  @override
  String get entryFormFooter =>
      'The money goes into your savings account and can then be assigned to individual goals.';

  @override
  String get allocationNewTitle => 'Assign money';

  @override
  String get allocationEditTitle => 'Edit allocation';

  @override
  String get allocationAvailableLabel => 'Available in the account';

  @override
  String allocationAmountFor(String name) {
    return 'Amount for \"$name\"';
  }

  @override
  String get allocationAmountHelper =>
      'A negative amount returns money to the account';

  @override
  String allocationTooMuch(String amount) {
    return 'Only $amount available';
  }

  @override
  String allocationFillRemaining(String amount) {
    return 'Remaining ($amount)';
  }

  @override
  String allocationFillAll(String amount) {
    return 'All ($amount)';
  }

  @override
  String get allocationConfirm => 'Assign';

  @override
  String allocationDone(String amount) {
    return '$amount assigned';
  }

  @override
  String get detailAllocationsSection => 'Allocations';

  @override
  String get detailAllocation => 'Allocation';

  @override
  String get detailReturnedToAccount => 'Back to the account';

  @override
  String get detailEmptyTitle => 'Nothing assigned yet';

  @override
  String get detailEmptySubtitle =>
      'Assign money from your savings account to this goal.';

  @override
  String get detailAllocationDeleted => 'Allocation deleted';

  @override
  String get detailAssignFab => 'Assign';

  @override
  String get detailSettleFab => 'Settle up';

  @override
  String detailOfAmount(String amount) {
    return 'of $amount';
  }

  @override
  String get detailGoalReached => 'Goal reached 🎉';

  @override
  String get detailPurchaseSettled => 'Fully settled 🎉';

  @override
  String detailRemaining(String amount) {
    return '$amount to go';
  }

  @override
  String detailStillToSettle(String amount) {
    return '$amount still to settle';
  }

  @override
  String detailPurchasedOn(String date) {
    return 'Purchased on $date';
  }

  @override
  String detailProgressSemantics(int percent) {
    return 'Progress $percent percent';
  }

  @override
  String get detailOpenProductPage => 'Open product page';

  @override
  String get detailRefreshPrice => 'Refresh price';

  @override
  String get detailSearchingPrice => 'Searching for the price ...';

  @override
  String detailPriceUpdated(String price) {
    return 'Target amount updated: $price';
  }

  @override
  String get detailLinkFailed => 'The link could not be opened';

  @override
  String get archiveMenu => 'Archive';

  @override
  String get archiveTitle => 'Archive savings goal?';

  @override
  String archiveBody(String name) {
    return '\"$name\" will be hidden. The allocated money stays reserved — delete the allocations first if you want it available again.';
  }

  @override
  String get deleteGoalTitle => 'Delete savings goal?';

  @override
  String deleteGoalBodyWithMoney(String name, String amount) {
    return '\"$name\" will be deleted together with all its allocations.\n\n$amount goes back to the account and will be available again.';
  }

  @override
  String deleteGoalBodyEmpty(String name) {
    return '\"$name\" will be deleted. No money is allocated, so the balance stays the same.';
  }

  @override
  String goalDeleted(String name) {
    return '\"$name\" deleted';
  }

  @override
  String goalDeletedWithMoney(String name, String amount) {
    return '\"$name\" deleted · $amount back in the account';
  }

  @override
  String goalCardSemantics(
    String name,
    String allocated,
    String target,
    String progress,
  ) {
    return '$name, $allocated of $target, $progress';
  }

  @override
  String get goalCardReached => 'goal reached';

  @override
  String get goalCardSettled => 'fully settled';

  @override
  String goalCardPercent(int percent) {
    return '$percent percent';
  }

  @override
  String goalCardOf(String allocated, String target) {
    return '$allocated of $target';
  }

  @override
  String get goalPurchasedBadge => 'Purchased';

  @override
  String widgetTargetOf(String target) {
    return 'of $target';
  }

  @override
  String widgetRemaining(String amount) {
    return '$amount to go';
  }

  @override
  String get widgetReached => 'Goal reached';

  @override
  String get widgetHintPickGoal => 'Tap to choose a savings goal';

  @override
  String get widgetHintNoData => 'Open Spartracker to get started';

  @override
  String get widgetConfigTitle => 'Choose savings goal';

  @override
  String get widgetConfigConfirm => 'Apply';

  @override
  String get widgetConfigEmptyTitle => 'No savings goals yet';

  @override
  String get widgetConfigEmptyBody =>
      'Create a savings goal in the app first, then it will show up here.';

  @override
  String get widgetConfigOpenApp => 'Open app';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDynamicColor => 'Use system colours';

  @override
  String get settingsDynamicColorOn =>
      'Colours follow your wallpaper or system accent';

  @override
  String get settingsDynamicColorOff => 'Pick your own colour below';

  @override
  String get settingsDynamicColorUnavailable =>
      'This device does not provide system colours';

  @override
  String get settingsOwnColor => 'Your colour';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageGerman => 'Deutsch';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsOpen => 'Settings';

  @override
  String get sourceBirthday => 'Birthday';

  @override
  String get sourceGift => 'Gift';

  @override
  String get sourceEbay => 'eBay';

  @override
  String get sourcePocketMoney => 'Pocket money';

  @override
  String get sourceOther => 'Other';

  @override
  String get priceErrorInvalidUrl => 'That does not look like a valid link.';

  @override
  String get priceErrorNetwork =>
      'The page could not be loaded. Check your connection?';

  @override
  String priceErrorBlocked(String status) {
    return 'The shop blocks automated access (error $status). Please enter the price yourself.';
  }

  @override
  String get priceErrorNotFound =>
      'No price was found on that page. Please enter it yourself.';

  @override
  String get colorViolet => 'Violet';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorRed => 'Red';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get colorBrown => 'Brown';

  @override
  String get iconGroupPopular => 'Popular';

  @override
  String get iconGroupTech => 'Tech';

  @override
  String get iconGroupTravel => 'Travel';

  @override
  String get iconGroupVehicles => 'Vehicles';

  @override
  String get iconGroupHome => 'Home';

  @override
  String get iconGroupLeisure => 'Leisure';

  @override
  String get iconGroupOther => 'Other';

  @override
  String get iconSavings => 'Piggy bank';

  @override
  String get iconFlag => 'Goal';

  @override
  String get iconStar => 'Star';

  @override
  String get iconGift => 'Gift';

  @override
  String get iconCart => 'Shopping';

  @override
  String get iconPayments => 'Money';

  @override
  String get iconTrophy => 'Trophy';

  @override
  String get iconFavorite => 'Heart';

  @override
  String get iconSmartphone => 'Smartphone';

  @override
  String get iconLaptop => 'Laptop';

  @override
  String get iconDesktop => 'PC';

  @override
  String get iconHeadphones => 'Headphones';

  @override
  String get iconGaming => 'Gaming';

  @override
  String get iconCamera => 'Camera';

  @override
  String get iconWatch => 'Smartwatch';

  @override
  String get iconTv => 'TV';

  @override
  String get iconKeyboard => 'Keyboard';

  @override
  String get iconPrinter => 'Printer';

  @override
  String get iconSpeaker => 'Speaker';

  @override
  String get iconTablet => 'Tablet';

  @override
  String get iconFlight => 'Flight';

  @override
  String get iconBeach => 'Beach';

  @override
  String get iconMap => 'Map';

  @override
  String get iconBackpack => 'Backpack';

  @override
  String get iconHotel => 'Hotel';

  @override
  String get iconLuggage => 'Luggage';

  @override
  String get iconTrain => 'Train';

  @override
  String get iconBoat => 'Boat';

  @override
  String get iconMountain => 'Mountains';

  @override
  String get iconCamping => 'Camping';

  @override
  String get iconHiking => 'Hiking';

  @override
  String get iconWorld => 'World';

  @override
  String get iconTicket => 'Ticket';

  @override
  String get iconCar => 'Car';

  @override
  String get iconBike => 'Bicycle';

  @override
  String get iconScooter => 'Scooter';

  @override
  String get iconBus => 'Bus';

  @override
  String get iconEScooter => 'E-scooter';

  @override
  String get iconTruck => 'Van';

  @override
  String get iconCarRepair => 'Garage';

  @override
  String get iconEvStation => 'Charging station';

  @override
  String get iconHome => 'Home';

  @override
  String get iconChair => 'Furniture';

  @override
  String get iconBed => 'Bed';

  @override
  String get iconKitchen => 'Kitchen';

  @override
  String get iconShower => 'Bathroom';

  @override
  String get iconLaundry => 'Washing machine';

  @override
  String get iconPlant => 'Plants';

  @override
  String get iconLamp => 'Lamp';

  @override
  String get iconSoccer => 'Football';

  @override
  String get iconBasketball => 'Basketball';

  @override
  String get iconMusic => 'Music';

  @override
  String get iconPiano => 'Piano';

  @override
  String get iconArt => 'Art';

  @override
  String get iconBook => 'Book';

  @override
  String get iconMovie => 'Film';

  @override
  String get iconMic => 'Microphone';

  @override
  String get iconSki => 'Skiing';

  @override
  String get iconSurf => 'Surfing';

  @override
  String get iconSkate => 'Skateboard';

  @override
  String get iconGym => 'Fitness';

  @override
  String get iconSchool => 'School';

  @override
  String get iconPets => 'Pet';

  @override
  String get iconEco => 'Nature';

  @override
  String get iconRing => 'Jewellery';

  @override
  String get iconCake => 'Celebration';

  @override
  String get iconFood => 'Food';

  @override
  String get iconClothes => 'Clothing';

  @override
  String get iconHealth => 'Health';

  @override
  String get iconTools => 'Tools';

  @override
  String get iconFlower => 'Flowers';

  @override
  String get iconBrush => 'Renovation';

  @override
  String get iconCelebration => 'Party';
}
