import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Spartracker'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get commonDate;

  /// No description provided for @commonNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get commonNoteOptional;

  /// No description provided for @commonErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String commonErrorWithMessage(String message);

  /// No description provided for @homeGoalsSection.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get homeGoalsSection;

  /// No description provided for @homeNewGoalFab.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get homeNewGoalFab;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a goal and assign money from your account to it.'**
  String get homeEmptySubtitle;

  /// No description provided for @homeGoalCreated.
  ///
  /// In en, this message translates to:
  /// **'Goal \"{name}\" created'**
  String homeGoalCreated(String name);

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings account'**
  String get accountTitle;

  /// No description provided for @accountBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get accountBalance;

  /// No description provided for @accountAllocated.
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get accountAllocated;

  /// No description provided for @accountAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get accountAvailable;

  /// No description provided for @accountAvailableShort.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get accountAvailableShort;

  /// No description provided for @accountOverAllocatedWarning.
  ///
  /// In en, this message translates to:
  /// **'Careful: more is allocated than the account holds.'**
  String get accountOverAllocatedWarning;

  /// No description provided for @accountEntriesSection.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get accountEntriesSection;

  /// No description provided for @accountDepositFab.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get accountDepositFab;

  /// No description provided for @accountEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No money in the account yet'**
  String get accountEmptyTitle;

  /// No description provided for @accountEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit money, then assign it to your savings goals.'**
  String get accountEmptySubtitle;

  /// No description provided for @accountEntryAdded.
  ///
  /// In en, this message translates to:
  /// **'Transaction added'**
  String get accountEntryAdded;

  /// No description provided for @accountEntrySaved.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved'**
  String get accountEntrySaved;

  /// No description provided for @accountEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get accountEntryDeleted;

  /// No description provided for @accountSemantics.
  ///
  /// In en, this message translates to:
  /// **'Savings account, balance {balance}, allocated {allocated}, available {available}'**
  String accountSemantics(String balance, String allocated, String available);

  /// No description provided for @resetMoneyMenu.
  ///
  /// In en, this message translates to:
  /// **'Reset money'**
  String get resetMoneyMenu;

  /// No description provided for @resetMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset money?'**
  String get resetMoneyTitle;

  /// No description provided for @resetMoneyBody.
  ///
  /// In en, this message translates to:
  /// **'All transactions and allocations will be deleted.\n\nBalance: {balance} → {zero}\nAllocated: {allocated} → {zero}\n\nYour savings goals are kept but will be back at 0 %. This cannot be undone.'**
  String resetMoneyBody(String balance, String allocated, String zero);

  /// No description provided for @resetMoneyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetMoneyConfirm;

  /// No description provided for @resetMoneyDone.
  ///
  /// In en, this message translates to:
  /// **'Money has been reset to zero'**
  String get resetMoneyDone;

  /// No description provided for @goalFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New savings goal'**
  String get goalFormNewTitle;

  /// No description provided for @goalFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit savings goal'**
  String get goalFormEditTitle;

  /// No description provided for @goalFormName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get goalFormName;

  /// No description provided for @goalFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. New bike'**
  String get goalFormNameHint;

  /// No description provided for @goalFormNameMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get goalFormNameMissing;

  /// No description provided for @goalFormTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalFormTargetAmount;

  /// No description provided for @goalFormAmountMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a target amount'**
  String get goalFormAmountMissing;

  /// No description provided for @goalFormAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number greater than 0'**
  String get goalFormAmountInvalid;

  /// No description provided for @goalFormProductLink.
  ///
  /// In en, this message translates to:
  /// **'Product link (optional)'**
  String get goalFormProductLink;

  /// No description provided for @goalFormProductLinkHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get goalFormProductLinkHint;

  /// No description provided for @goalFormLookUpPrice.
  ///
  /// In en, this message translates to:
  /// **'Fetch price from the page'**
  String get goalFormLookUpPrice;

  /// No description provided for @goalFormPriceHint.
  ///
  /// In en, this message translates to:
  /// **'The price is read from the page\'s product data. This does not work with every shop — you can always enter it yourself.'**
  String get goalFormPriceHint;

  /// No description provided for @goalFormColor.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get goalFormColor;

  /// No description provided for @goalFormCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get goalFormCreate;

  /// No description provided for @goalFormPriceFound.
  ///
  /// In en, this message translates to:
  /// **'Price found: {price}'**
  String goalFormPriceFound(String price);

  /// No description provided for @goalFormAlreadyPurchased.
  ///
  /// In en, this message translates to:
  /// **'Already purchased'**
  String get goalFormAlreadyPurchased;

  /// No description provided for @goalFormAlreadyPurchasedHint.
  ///
  /// In en, this message translates to:
  /// **'You already paid for this out of pocket and are settling it with money you save later – say, from an eBay sale or a cash gift.'**
  String get goalFormAlreadyPurchasedHint;

  /// No description provided for @goalFormPurchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase date'**
  String get goalFormPurchaseDate;

  /// No description provided for @iconPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a symbol'**
  String get iconPickerTitle;

  /// No description provided for @iconPickerButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose a symbol'**
  String get iconPickerButtonTooltip;

  /// No description provided for @iconPickerButtonSemantics.
  ///
  /// In en, this message translates to:
  /// **'Choose a symbol, currently {label}'**
  String iconPickerButtonSemantics(String label);

  /// No description provided for @entryFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit money'**
  String get entryFormNewTitle;

  /// No description provided for @entryFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get entryFormEditTitle;

  /// No description provided for @entryFormAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get entryFormAmount;

  /// No description provided for @entryFormAmountHelper.
  ///
  /// In en, this message translates to:
  /// **'A negative amount is a withdrawal'**
  String get entryFormAmountHelper;

  /// No description provided for @entryFormAmountMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get entryFormAmountMissing;

  /// No description provided for @entryFormAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number other than 0'**
  String get entryFormAmountInvalid;

  /// No description provided for @entryFormSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get entryFormSource;

  /// No description provided for @entryFormSourceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. birthday, eBay, paper round ...'**
  String get entryFormSourceHint;

  /// No description provided for @entryFormSourceMissing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a source'**
  String get entryFormSourceMissing;

  /// No description provided for @entryFormFooter.
  ///
  /// In en, this message translates to:
  /// **'The money goes into your savings account and can then be assigned to individual goals.'**
  String get entryFormFooter;

  /// No description provided for @allocationNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign money'**
  String get allocationNewTitle;

  /// No description provided for @allocationEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit allocation'**
  String get allocationEditTitle;

  /// No description provided for @allocationAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available in the account'**
  String get allocationAvailableLabel;

  /// No description provided for @allocationAmountFor.
  ///
  /// In en, this message translates to:
  /// **'Amount for \"{name}\"'**
  String allocationAmountFor(String name);

  /// No description provided for @allocationAmountHelper.
  ///
  /// In en, this message translates to:
  /// **'A negative amount returns money to the account'**
  String get allocationAmountHelper;

  /// No description provided for @allocationTooMuch.
  ///
  /// In en, this message translates to:
  /// **'Only {amount} available'**
  String allocationTooMuch(String amount);

  /// No description provided for @allocationFillRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining ({amount})'**
  String allocationFillRemaining(String amount);

  /// No description provided for @allocationFillAll.
  ///
  /// In en, this message translates to:
  /// **'All ({amount})'**
  String allocationFillAll(String amount);

  /// No description provided for @allocationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get allocationConfirm;

  /// No description provided for @allocationDone.
  ///
  /// In en, this message translates to:
  /// **'{amount} assigned'**
  String allocationDone(String amount);

  /// No description provided for @detailAllocationsSection.
  ///
  /// In en, this message translates to:
  /// **'Allocations'**
  String get detailAllocationsSection;

  /// No description provided for @detailAllocation.
  ///
  /// In en, this message translates to:
  /// **'Allocation'**
  String get detailAllocation;

  /// No description provided for @detailReturnedToAccount.
  ///
  /// In en, this message translates to:
  /// **'Back to the account'**
  String get detailReturnedToAccount;

  /// No description provided for @detailEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing assigned yet'**
  String get detailEmptyTitle;

  /// No description provided for @detailEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assign money from your savings account to this goal.'**
  String get detailEmptySubtitle;

  /// No description provided for @detailAllocationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Allocation deleted'**
  String get detailAllocationDeleted;

  /// No description provided for @detailAssignFab.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get detailAssignFab;

  /// No description provided for @detailSettleFab.
  ///
  /// In en, this message translates to:
  /// **'Settle up'**
  String get detailSettleFab;

  /// No description provided for @detailOfAmount.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String detailOfAmount(String amount);

  /// No description provided for @detailGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached 🎉'**
  String get detailGoalReached;

  /// No description provided for @detailPurchaseSettled.
  ///
  /// In en, this message translates to:
  /// **'Fully settled 🎉'**
  String get detailPurchaseSettled;

  /// No description provided for @detailRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String detailRemaining(String amount);

  /// No description provided for @detailStillToSettle.
  ///
  /// In en, this message translates to:
  /// **'{amount} still to settle'**
  String detailStillToSettle(String amount);

  /// No description provided for @detailPurchasedOn.
  ///
  /// In en, this message translates to:
  /// **'Purchased on {date}'**
  String detailPurchasedOn(String date);

  /// No description provided for @detailProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'Progress {percent} percent'**
  String detailProgressSemantics(int percent);

  /// No description provided for @detailOpenProductPage.
  ///
  /// In en, this message translates to:
  /// **'Open product page'**
  String get detailOpenProductPage;

  /// No description provided for @detailRefreshPrice.
  ///
  /// In en, this message translates to:
  /// **'Refresh price'**
  String get detailRefreshPrice;

  /// No description provided for @detailSearchingPrice.
  ///
  /// In en, this message translates to:
  /// **'Searching for the price ...'**
  String get detailSearchingPrice;

  /// No description provided for @detailPriceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Target amount updated: {price}'**
  String detailPriceUpdated(String price);

  /// No description provided for @detailLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'The link could not be opened'**
  String get detailLinkFailed;

  /// No description provided for @archiveMenu.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveMenu;

  /// No description provided for @archiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive savings goal?'**
  String get archiveTitle;

  /// No description provided for @archiveBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be hidden. The allocated money stays reserved — delete the allocations first if you want it available again.'**
  String archiveBody(String name);

  /// No description provided for @deleteGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete savings goal?'**
  String get deleteGoalTitle;

  /// No description provided for @deleteGoalBodyWithMoney.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be deleted together with all its allocations.\n\n{amount} goes back to the account and will be available again.'**
  String deleteGoalBodyWithMoney(String name, String amount);

  /// No description provided for @deleteGoalBodyEmpty.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be deleted. No money is allocated, so the balance stays the same.'**
  String deleteGoalBodyEmpty(String name);

  /// No description provided for @goalDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted'**
  String goalDeleted(String name);

  /// No description provided for @goalDeletedWithMoney.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted · {amount} back in the account'**
  String goalDeletedWithMoney(String name, String amount);

  /// No description provided for @goalCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {allocated} of {target}, {progress}'**
  String goalCardSemantics(
    String name,
    String allocated,
    String target,
    String progress,
  );

  /// No description provided for @goalCardReached.
  ///
  /// In en, this message translates to:
  /// **'goal reached'**
  String get goalCardReached;

  /// No description provided for @goalCardSettled.
  ///
  /// In en, this message translates to:
  /// **'fully settled'**
  String get goalCardSettled;

  /// No description provided for @goalCardPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent'**
  String goalCardPercent(int percent);

  /// No description provided for @goalCardOf.
  ///
  /// In en, this message translates to:
  /// **'{allocated} of {target}'**
  String goalCardOf(String allocated, String target);

  /// No description provided for @goalPurchasedBadge.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get goalPurchasedBadge;

  /// No description provided for @widgetTargetOf.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String widgetTargetOf(String target);

  /// No description provided for @widgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String widgetRemaining(String amount);

  /// No description provided for @widgetReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get widgetReached;

  /// No description provided for @widgetHintPickGoal.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a savings goal'**
  String get widgetHintPickGoal;

  /// No description provided for @widgetHintNoData.
  ///
  /// In en, this message translates to:
  /// **'Open Spartracker to get started'**
  String get widgetHintNoData;

  /// No description provided for @widgetConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose savings goal'**
  String get widgetConfigTitle;

  /// No description provided for @widgetConfigConfirm.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get widgetConfigConfirm;

  /// No description provided for @widgetConfigEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet'**
  String get widgetConfigEmptyTitle;

  /// No description provided for @widgetConfigEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a savings goal in the app first, then it will show up here.'**
  String get widgetConfigEmptyBody;

  /// No description provided for @widgetConfigOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open app'**
  String get widgetConfigOpenApp;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDynamicColor.
  ///
  /// In en, this message translates to:
  /// **'Use system colours'**
  String get settingsDynamicColor;

  /// No description provided for @settingsDynamicColorOn.
  ///
  /// In en, this message translates to:
  /// **'Colours follow your wallpaper or system accent'**
  String get settingsDynamicColorOn;

  /// No description provided for @settingsDynamicColorOff.
  ///
  /// In en, this message translates to:
  /// **'Pick your own colour below'**
  String get settingsDynamicColorOff;

  /// No description provided for @settingsDynamicColorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This device does not provide system colours'**
  String get settingsDynamicColorUnavailable;

  /// No description provided for @settingsOwnColor.
  ///
  /// In en, this message translates to:
  /// **'Your colour'**
  String get settingsOwnColor;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get settingsLanguageGerman;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsOpen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsOpen;

  /// No description provided for @sourceBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get sourceBirthday;

  /// No description provided for @sourceGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get sourceGift;

  /// No description provided for @sourceEbay.
  ///
  /// In en, this message translates to:
  /// **'eBay'**
  String get sourceEbay;

  /// No description provided for @sourcePocketMoney.
  ///
  /// In en, this message translates to:
  /// **'Pocket money'**
  String get sourcePocketMoney;

  /// No description provided for @sourceOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sourceOther;

  /// No description provided for @priceErrorInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'That does not look like a valid link.'**
  String get priceErrorInvalidUrl;

  /// No description provided for @priceErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'The page could not be loaded. Check your connection?'**
  String get priceErrorNetwork;

  /// No description provided for @priceErrorBlocked.
  ///
  /// In en, this message translates to:
  /// **'The shop blocks automated access (error {status}). Please enter the price yourself.'**
  String priceErrorBlocked(String status);

  /// No description provided for @priceErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'No price was found on that page. Please enter it yourself.'**
  String get priceErrorNotFound;

  /// No description provided for @colorViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get colorViolet;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorMagenta.
  ///
  /// In en, this message translates to:
  /// **'Magenta'**
  String get colorMagenta;

  /// No description provided for @colorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get colorBrown;

  /// No description provided for @iconGroupPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get iconGroupPopular;

  /// No description provided for @iconGroupTech.
  ///
  /// In en, this message translates to:
  /// **'Tech'**
  String get iconGroupTech;

  /// No description provided for @iconGroupTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get iconGroupTravel;

  /// No description provided for @iconGroupVehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get iconGroupVehicles;

  /// No description provided for @iconGroupHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get iconGroupHome;

  /// No description provided for @iconGroupLeisure.
  ///
  /// In en, this message translates to:
  /// **'Leisure'**
  String get iconGroupLeisure;

  /// No description provided for @iconGroupOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get iconGroupOther;

  /// No description provided for @iconSavings.
  ///
  /// In en, this message translates to:
  /// **'Piggy bank'**
  String get iconSavings;

  /// No description provided for @iconFlag.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get iconFlag;

  /// No description provided for @iconStar.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get iconStar;

  /// No description provided for @iconGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get iconGift;

  /// No description provided for @iconCart.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get iconCart;

  /// No description provided for @iconPayments.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get iconPayments;

  /// No description provided for @iconTrophy.
  ///
  /// In en, this message translates to:
  /// **'Trophy'**
  String get iconTrophy;

  /// No description provided for @iconFavorite.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get iconFavorite;

  /// No description provided for @iconSmartphone.
  ///
  /// In en, this message translates to:
  /// **'Smartphone'**
  String get iconSmartphone;

  /// No description provided for @iconLaptop.
  ///
  /// In en, this message translates to:
  /// **'Laptop'**
  String get iconLaptop;

  /// No description provided for @iconDesktop.
  ///
  /// In en, this message translates to:
  /// **'PC'**
  String get iconDesktop;

  /// No description provided for @iconHeadphones.
  ///
  /// In en, this message translates to:
  /// **'Headphones'**
  String get iconHeadphones;

  /// No description provided for @iconGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get iconGaming;

  /// No description provided for @iconCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get iconCamera;

  /// No description provided for @iconWatch.
  ///
  /// In en, this message translates to:
  /// **'Smartwatch'**
  String get iconWatch;

  /// No description provided for @iconTv.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get iconTv;

  /// No description provided for @iconKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get iconKeyboard;

  /// No description provided for @iconPrinter.
  ///
  /// In en, this message translates to:
  /// **'Printer'**
  String get iconPrinter;

  /// No description provided for @iconSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get iconSpeaker;

  /// No description provided for @iconTablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get iconTablet;

  /// No description provided for @iconFlight.
  ///
  /// In en, this message translates to:
  /// **'Flight'**
  String get iconFlight;

  /// No description provided for @iconBeach.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get iconBeach;

  /// No description provided for @iconMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get iconMap;

  /// No description provided for @iconBackpack.
  ///
  /// In en, this message translates to:
  /// **'Backpack'**
  String get iconBackpack;

  /// No description provided for @iconHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get iconHotel;

  /// No description provided for @iconLuggage.
  ///
  /// In en, this message translates to:
  /// **'Luggage'**
  String get iconLuggage;

  /// No description provided for @iconTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get iconTrain;

  /// No description provided for @iconBoat.
  ///
  /// In en, this message translates to:
  /// **'Boat'**
  String get iconBoat;

  /// No description provided for @iconMountain.
  ///
  /// In en, this message translates to:
  /// **'Mountains'**
  String get iconMountain;

  /// No description provided for @iconCamping.
  ///
  /// In en, this message translates to:
  /// **'Camping'**
  String get iconCamping;

  /// No description provided for @iconHiking.
  ///
  /// In en, this message translates to:
  /// **'Hiking'**
  String get iconHiking;

  /// No description provided for @iconWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get iconWorld;

  /// No description provided for @iconTicket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get iconTicket;

  /// No description provided for @iconCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get iconCar;

  /// No description provided for @iconBike.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get iconBike;

  /// No description provided for @iconScooter.
  ///
  /// In en, this message translates to:
  /// **'Scooter'**
  String get iconScooter;

  /// No description provided for @iconBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get iconBus;

  /// No description provided for @iconEScooter.
  ///
  /// In en, this message translates to:
  /// **'E-scooter'**
  String get iconEScooter;

  /// No description provided for @iconTruck.
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get iconTruck;

  /// No description provided for @iconCarRepair.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get iconCarRepair;

  /// No description provided for @iconEvStation.
  ///
  /// In en, this message translates to:
  /// **'Charging station'**
  String get iconEvStation;

  /// No description provided for @iconHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get iconHome;

  /// No description provided for @iconChair.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get iconChair;

  /// No description provided for @iconBed.
  ///
  /// In en, this message translates to:
  /// **'Bed'**
  String get iconBed;

  /// No description provided for @iconKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get iconKitchen;

  /// No description provided for @iconShower.
  ///
  /// In en, this message translates to:
  /// **'Bathroom'**
  String get iconShower;

  /// No description provided for @iconLaundry.
  ///
  /// In en, this message translates to:
  /// **'Washing machine'**
  String get iconLaundry;

  /// No description provided for @iconPlant.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get iconPlant;

  /// No description provided for @iconLamp.
  ///
  /// In en, this message translates to:
  /// **'Lamp'**
  String get iconLamp;

  /// No description provided for @iconSoccer.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get iconSoccer;

  /// No description provided for @iconBasketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get iconBasketball;

  /// No description provided for @iconMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get iconMusic;

  /// No description provided for @iconPiano.
  ///
  /// In en, this message translates to:
  /// **'Piano'**
  String get iconPiano;

  /// No description provided for @iconArt.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get iconArt;

  /// No description provided for @iconBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get iconBook;

  /// No description provided for @iconMovie.
  ///
  /// In en, this message translates to:
  /// **'Film'**
  String get iconMovie;

  /// No description provided for @iconMic.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get iconMic;

  /// No description provided for @iconSki.
  ///
  /// In en, this message translates to:
  /// **'Skiing'**
  String get iconSki;

  /// No description provided for @iconSurf.
  ///
  /// In en, this message translates to:
  /// **'Surfing'**
  String get iconSurf;

  /// No description provided for @iconSkate.
  ///
  /// In en, this message translates to:
  /// **'Skateboard'**
  String get iconSkate;

  /// No description provided for @iconGym.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get iconGym;

  /// No description provided for @iconSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get iconSchool;

  /// No description provided for @iconPets.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get iconPets;

  /// No description provided for @iconEco.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get iconEco;

  /// No description provided for @iconRing.
  ///
  /// In en, this message translates to:
  /// **'Jewellery'**
  String get iconRing;

  /// No description provided for @iconCake.
  ///
  /// In en, this message translates to:
  /// **'Celebration'**
  String get iconCake;

  /// No description provided for @iconFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get iconFood;

  /// No description provided for @iconClothes.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get iconClothes;

  /// No description provided for @iconHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get iconHealth;

  /// No description provided for @iconTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get iconTools;

  /// No description provided for @iconFlower.
  ///
  /// In en, this message translates to:
  /// **'Flowers'**
  String get iconFlower;

  /// No description provided for @iconBrush.
  ///
  /// In en, this message translates to:
  /// **'Renovation'**
  String get iconBrush;

  /// No description provided for @iconCelebration.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get iconCelebration;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
