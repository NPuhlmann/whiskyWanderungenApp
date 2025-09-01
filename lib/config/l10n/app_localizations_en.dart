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

  @override
  String get imageLoadError => 'Image could not be loaded';

  @override
  String get kilometers => 'km';

  @override
  String get meters => 'm';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get invalidOrderId => 'Invalid order ID';

  @override
  String get checkout => 'Checkout';

  @override
  String get pickupOnSite => 'Pick up on site';

  @override
  String get free => 'Free';

  @override
  String get shippingByPost => 'Ship by post';

  @override
  String get shippingCost => '+5.00 € shipping costs';

  @override
  String get redirectingToCheckout => 'Redirecting to checkout...';

  @override
  String get orderTracking => 'Order tracking';

  @override
  String get retry => 'Retry';

  @override
  String get unexpectedState => 'Unexpected state: No order data available';

  @override
  String get cancelOrder => 'Cancel order';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get cancelOrderConfirmation =>
      'Do you really want to cancel this order?';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancellationRequested => 'Order cancellation has been requested';

  @override
  String get contactingSupport => 'Contacting support...';

  @override
  String get tastingSet => 'Tasting Set';

  @override
  String get proceedToCheckout => 'Proceed to checkout';

  @override
  String get trackingOpen => 'Open tracking';

  @override
  String get unknownOrderType => 'Unknown order type';

  @override
  String get mobileLayout => 'Mobile Layout';

  @override
  String get webAppRunning => 'Web app running successfully! 🎉';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get hikingRoutes => 'Hiking Routes';

  @override
  String get orders => 'Orders';

  @override
  String get flutterWebEnabled => '✅ Flutter Web enabled';

  @override
  String get responsiveLayoutImplemented => '✅ Responsive Layout implemented';

  @override
  String get adminDashboardCreated => '✅ Admin Dashboard created';

  @override
  String get navigationImplemented => '✅ Navigation implemented';

  @override
  String get webDependenciesAdded => '✅ Web-specific dependencies added';

  @override
  String get manageHikingRoutes => 'Manage Hiking Routes';

  @override
  String get manageHikingRoutesDescription =>
      'Here you can create and manage hiking routes';

  @override
  String get inDevelopment => '🚧 In Development 🚧';

  @override
  String get manageOrders => 'Manage Orders';

  @override
  String get manageOrdersDescription =>
      'Here you can view and process all orders';

  @override
  String get manageWhiskyCatalog => 'Manage Whisky Catalog';

  @override
  String get manageWhiskyCatalogDescription =>
      'Here you can manage the whisky catalog';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get newRoute => 'New Route';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get showAll => 'Show all';

  @override
  String get noOrdersAvailable => 'No orders available';

  @override
  String get order => 'Order';

  @override
  String get customer => 'Customer';

  @override
  String get route => 'Route';

  @override
  String get amount => 'Amount';

  @override
  String get status => 'Status';

  @override
  String get date => 'Date';

  @override
  String get close => 'Close';

  @override
  String get imageTooLarge => 'Image too large';
}
