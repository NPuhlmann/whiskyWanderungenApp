// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Whisky Hikes';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get signup => 'Sign Up';

  @override
  String get password => 'Password';

  @override
  String get passwordConfirm => 'Confirm Password';

  @override
  String get email => 'Email';

  @override
  String get passwordNotMatch => 'Passwords do not match';

  @override
  String get legalAgeInfo =>
      'You must be of legal drinking age to use this app';

  @override
  String get iAmLegalAge => 'I am of legal drinking age';

  @override
  String get hikes => 'Hikes';

  @override
  String get myHikes => 'My Hikes';

  @override
  String get profile => 'Profile';

  @override
  String greeting_home_page(Object name) {
    return 'Hello, $name! Ready for an adventure?';
  }

  @override
  String get hard => 'hard';

  @override
  String get middle => 'middle';

  @override
  String get easy => 'easy';

  @override
  String get very_hard => 'very hard';

  @override
  String get buyButtonText => 'Buy';

  @override
  String get startHikeButtonText => 'Start Hike';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get address => 'Address';

  @override
  String get save => 'Save';

  @override
  String get refresh => 'refresh';

  @override
  String get tryAgain => 'try again';

  @override
  String get noHikesFound => 'No hikes found';

  @override
  String get noHikesPurchased => 'You did not purchase any hikes, yet.';

  @override
  String get loginRequiredForHikes =>
      'Please log in to see your purchased hikes.';

  @override
  String get errorLoadingHikes => 'An error occurred. Please try again later.';

  @override
  String get show_favorites => 'Show favorites';

  @override
  String get show_all_hikes => 'Show all hikes';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get selectDate => 'Select date';

  @override
  String get mustBeAtLeast18 => 'You must be at least 18 years old';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get changeProfilePicture => 'Change profile picture';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get errorUploadingImage => 'Error uploading image';

  @override
  String get noWaypointsFound => 'No waypoints found for this hike';

  @override
  String get errorLoadingWaypoints => 'Error loading waypoints';

  @override
  String get errorCalculatingRoute => 'Error calculating route';

  @override
  String get waypointReached => 'Waypoint reached!';

  @override
  String get continueHike => 'Continue hike';

  @override
  String get saveMapOffline => 'Save map offline';

  @override
  String get savingMapOfflineMessage => 'Saving map for offline use...';

  @override
  String get rebuyHike => 'Rebuy hike';

  @override
  String get rebuyingHikeMessage => 'Rebuying hike...';

  @override
  String get removeOfflineData => 'Remove offline data';

  @override
  String get removingOfflineData => 'Removing offline data...';

  @override
  String get hikeOfflineSaved => 'Hike saved for offline use';

  @override
  String get errorSavingOffline => 'Error saving hike for offline use';

  @override
  String get offlineDataRemoved => 'Offline data removed';

  @override
  String get errorRemovingOfflineData => 'Error removing offline data';

  @override
  String get signupSuccess => 'Registration successful!';
}
