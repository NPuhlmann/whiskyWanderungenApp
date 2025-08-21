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
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  /// **'Whisky Hikes'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get passwordConfirm;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordNotMatch;

  /// No description provided for @legalAgeInfo.
  ///
  /// In en, this message translates to:
  /// **'You must be of legal drinking age to use this app'**
  String get legalAgeInfo;

  /// No description provided for @iAmLegalAge.
  ///
  /// In en, this message translates to:
  /// **'I am of legal drinking age'**
  String get iAmLegalAge;

  /// No description provided for @hikes.
  ///
  /// In en, this message translates to:
  /// **'Hikes'**
  String get hikes;

  /// No description provided for @myHikes.
  ///
  /// In en, this message translates to:
  /// **'My Hikes'**
  String get myHikes;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @greeting_home_page.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}! Ready for an adventure?'**
  String greeting_home_page(Object name);

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'hard'**
  String get hard;

  /// No description provided for @middle.
  ///
  /// In en, this message translates to:
  /// **'middle'**
  String get middle;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'easy'**
  String get easy;

  /// No description provided for @very_hard.
  ///
  /// In en, this message translates to:
  /// **'very hard'**
  String get very_hard;

  /// No description provided for @buyButtonText.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buyButtonText;

  /// No description provided for @startHikeButtonText.
  ///
  /// In en, this message translates to:
  /// **'Start Hike'**
  String get startHikeButtonText;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'refresh'**
  String get refresh;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'try again'**
  String get tryAgain;

  /// No description provided for @noHikesFound.
  ///
  /// In en, this message translates to:
  /// **'No hikes found'**
  String get noHikesFound;

  /// No description provided for @noHikesPurchased.
  ///
  /// In en, this message translates to:
  /// **'You did not purchase any hikes, yet.'**
  String get noHikesPurchased;

  /// No description provided for @loginRequiredForHikes.
  ///
  /// In en, this message translates to:
  /// **'Please log in to see your purchased hikes.'**
  String get loginRequiredForHikes;

  /// No description provided for @errorLoadingHikes.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get errorLoadingHikes;

  /// No description provided for @show_favorites.
  ///
  /// In en, this message translates to:
  /// **'Show favorites'**
  String get show_favorites;

  /// No description provided for @show_all_hikes.
  ///
  /// In en, this message translates to:
  /// **'Show all hikes'**
  String get show_all_hikes;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @mustBeAtLeast18.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old'**
  String get mustBeAtLeast18;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @changeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Change profile picture'**
  String get changeProfilePicture;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @errorUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image'**
  String get errorUploadingImage;

  /// No description provided for @noWaypointsFound.
  ///
  /// In en, this message translates to:
  /// **'No waypoints found for this hike'**
  String get noWaypointsFound;

  /// No description provided for @errorLoadingWaypoints.
  ///
  /// In en, this message translates to:
  /// **'Error loading waypoints'**
  String get errorLoadingWaypoints;

  /// No description provided for @errorCalculatingRoute.
  ///
  /// In en, this message translates to:
  /// **'Error calculating route'**
  String get errorCalculatingRoute;

  /// No description provided for @waypointReached.
  ///
  /// In en, this message translates to:
  /// **'Waypoint reached!'**
  String get waypointReached;

  /// No description provided for @continueHike.
  ///
  /// In en, this message translates to:
  /// **'Continue hike'**
  String get continueHike;

  /// No description provided for @saveMapOffline.
  ///
  /// In en, this message translates to:
  /// **'Save map offline'**
  String get saveMapOffline;

  /// No description provided for @savingMapOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Saving map for offline use...'**
  String get savingMapOfflineMessage;

  /// No description provided for @rebuyHike.
  ///
  /// In en, this message translates to:
  /// **'Rebuy hike'**
  String get rebuyHike;

  /// No description provided for @rebuyingHikeMessage.
  ///
  /// In en, this message translates to:
  /// **'Rebuying hike...'**
  String get rebuyingHikeMessage;

  /// No description provided for @removeOfflineData.
  ///
  /// In en, this message translates to:
  /// **'Remove offline data'**
  String get removeOfflineData;

  /// No description provided for @removingOfflineData.
  ///
  /// In en, this message translates to:
  /// **'Removing offline data...'**
  String get removingOfflineData;

  /// No description provided for @hikeOfflineSaved.
  ///
  /// In en, this message translates to:
  /// **'Hike saved for offline use'**
  String get hikeOfflineSaved;

  /// No description provided for @errorSavingOffline.
  ///
  /// In en, this message translates to:
  /// **'Error saving hike for offline use'**
  String get errorSavingOffline;

  /// No description provided for @offlineDataRemoved.
  ///
  /// In en, this message translates to:
  /// **'Offline data removed'**
  String get offlineDataRemoved;

  /// No description provided for @errorRemovingOfflineData.
  ///
  /// In en, this message translates to:
  /// **'Error removing offline data'**
  String get errorRemovingOfflineData;

  /// No description provided for @signupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get signupSuccess;
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
