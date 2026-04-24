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

  /// No description provided for @imageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Image could not be loaded'**
  String get imageLoadError;

  /// No description provided for @kilometers.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get kilometers;

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get meters;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @invalidOrderId.
  ///
  /// In en, this message translates to:
  /// **'Invalid order ID'**
  String get invalidOrderId;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @pickupOnSite.
  ///
  /// In en, this message translates to:
  /// **'Pick up on site'**
  String get pickupOnSite;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @shippingByPost.
  ///
  /// In en, this message translates to:
  /// **'Ship by post'**
  String get shippingByPost;

  /// No description provided for @shippingCost.
  ///
  /// In en, this message translates to:
  /// **'+5.00 € shipping costs'**
  String get shippingCost;

  /// No description provided for @redirectingToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to checkout...'**
  String get redirectingToCheckout;

  /// No description provided for @orderTracking.
  ///
  /// In en, this message translates to:
  /// **'Order tracking'**
  String get orderTracking;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @unexpectedState.
  ///
  /// In en, this message translates to:
  /// **'Unexpected state: No order data available'**
  String get unexpectedState;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrder;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @cancelOrderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to cancel this order?'**
  String get cancelOrderConfirmation;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancellationRequested.
  ///
  /// In en, this message translates to:
  /// **'Order cancellation has been requested'**
  String get cancellationRequested;

  /// No description provided for @contactingSupport.
  ///
  /// In en, this message translates to:
  /// **'Contacting support...'**
  String get contactingSupport;

  /// No description provided for @tastingSet.
  ///
  /// In en, this message translates to:
  /// **'Tasting Set'**
  String get tastingSet;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to checkout'**
  String get proceedToCheckout;

  /// No description provided for @trackingOpen.
  ///
  /// In en, this message translates to:
  /// **'Open tracking'**
  String get trackingOpen;

  /// No description provided for @unknownOrderType.
  ///
  /// In en, this message translates to:
  /// **'Unknown order type'**
  String get unknownOrderType;

  /// No description provided for @mobileLayout.
  ///
  /// In en, this message translates to:
  /// **'Mobile Layout'**
  String get mobileLayout;

  /// No description provided for @webAppRunning.
  ///
  /// In en, this message translates to:
  /// **'Web app running successfully! 🎉'**
  String get webAppRunning;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @hikingRoutes.
  ///
  /// In en, this message translates to:
  /// **'Hiking Routes'**
  String get hikingRoutes;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @flutterWebEnabled.
  ///
  /// In en, this message translates to:
  /// **'✅ Flutter Web enabled'**
  String get flutterWebEnabled;

  /// No description provided for @responsiveLayoutImplemented.
  ///
  /// In en, this message translates to:
  /// **'✅ Responsive Layout implemented'**
  String get responsiveLayoutImplemented;

  /// No description provided for @adminDashboardCreated.
  ///
  /// In en, this message translates to:
  /// **'✅ Admin Dashboard created'**
  String get adminDashboardCreated;

  /// No description provided for @navigationImplemented.
  ///
  /// In en, this message translates to:
  /// **'✅ Navigation implemented'**
  String get navigationImplemented;

  /// No description provided for @webDependenciesAdded.
  ///
  /// In en, this message translates to:
  /// **'✅ Web-specific dependencies added'**
  String get webDependenciesAdded;

  /// No description provided for @manageHikingRoutes.
  ///
  /// In en, this message translates to:
  /// **'Manage Hiking Routes'**
  String get manageHikingRoutes;

  /// No description provided for @manageHikingRoutesDescription.
  ///
  /// In en, this message translates to:
  /// **'Here you can create and manage hiking routes'**
  String get manageHikingRoutesDescription;

  /// No description provided for @inDevelopment.
  ///
  /// In en, this message translates to:
  /// **'🚧 In Development 🚧'**
  String get inDevelopment;

  /// No description provided for @manageOrders.
  ///
  /// In en, this message translates to:
  /// **'Manage Orders'**
  String get manageOrders;

  /// No description provided for @manageOrdersDescription.
  ///
  /// In en, this message translates to:
  /// **'Here you can view and process all orders'**
  String get manageOrdersDescription;

  /// No description provided for @manageWhiskyCatalog.
  ///
  /// In en, this message translates to:
  /// **'Manage Whisky Catalog'**
  String get manageWhiskyCatalog;

  /// No description provided for @manageWhiskyCatalogDescription.
  ///
  /// In en, this message translates to:
  /// **'Here you can manage the whisky catalog'**
  String get manageWhiskyCatalogDescription;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @newRoute.
  ///
  /// In en, this message translates to:
  /// **'New Route'**
  String get newRoute;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @noOrdersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No orders available'**
  String get noOrdersAvailable;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image too large'**
  String get imageTooLarge;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @tastingSets.
  ///
  /// In en, this message translates to:
  /// **'Tasting Sets'**
  String get tastingSets;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @createNewTastingSet.
  ///
  /// In en, this message translates to:
  /// **'Create New Tasting Set'**
  String get createNewTastingSet;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @catalogOverview.
  ///
  /// In en, this message translates to:
  /// **'Catalog Overview'**
  String get catalogOverview;

  /// No description provided for @totalSets.
  ///
  /// In en, this message translates to:
  /// **'Total Sets'**
  String get totalSets;

  /// No description provided for @availableSets.
  ///
  /// In en, this message translates to:
  /// **'Available Sets'**
  String get availableSets;

  /// No description provided for @totalSamples.
  ///
  /// In en, this message translates to:
  /// **'Total Samples'**
  String get totalSamples;

  /// No description provided for @avgSamplesPerSet.
  ///
  /// In en, this message translates to:
  /// **'Avg Samples per Set'**
  String get avgSamplesPerSet;

  /// No description provided for @regions.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get regions;

  /// No description provided for @distilleries.
  ///
  /// In en, this message translates to:
  /// **'Distilleries'**
  String get distilleries;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @samples.
  ///
  /// In en, this message translates to:
  /// **'Samples'**
  String get samples;

  /// No description provided for @searchTastingSets.
  ///
  /// In en, this message translates to:
  /// **'Search tasting sets'**
  String get searchTastingSets;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @newTastingSet.
  ///
  /// In en, this message translates to:
  /// **'New Tasting Set'**
  String get newTastingSet;

  /// No description provided for @sampleCount.
  ///
  /// In en, this message translates to:
  /// **'Sample Count'**
  String get sampleCount;

  /// No description provided for @averageAge.
  ///
  /// In en, this message translates to:
  /// **'Average Age'**
  String get averageAge;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @addTastingSet.
  ///
  /// In en, this message translates to:
  /// **'Add Tasting Set'**
  String get addTastingSet;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @noTastingSetsMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No tasting sets match the current filter'**
  String get noTastingSetsMatchFilter;

  /// No description provided for @noTastingSetsYet.
  ///
  /// In en, this message translates to:
  /// **'No tasting sets created yet'**
  String get noTastingSetsYet;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting the filters or'**
  String get tryAdjustingFilters;

  /// No description provided for @createFirstTastingSet.
  ///
  /// In en, this message translates to:
  /// **'Create your first tasting set'**
  String get createFirstTastingSet;

  /// No description provided for @createTastingSet.
  ///
  /// In en, this message translates to:
  /// **'Create Tasting Set'**
  String get createTastingSet;

  /// No description provided for @editTastingSet.
  ///
  /// In en, this message translates to:
  /// **'Edit Tasting Set'**
  String get editTastingSet;

  /// No description provided for @deleteTastingSet.
  ///
  /// In en, this message translates to:
  /// **'Delete Tasting Set'**
  String get deleteTastingSet;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name, distillery, or region'**
  String get searchPlaceholder;

  /// No description provided for @deleteTastingSetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the tasting set \'{name}\'?'**
  String deleteTastingSetConfirmation(String name);

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @allRegions.
  ///
  /// In en, this message translates to:
  /// **'All Regions'**
  String get allRegions;

  /// No description provided for @distillery.
  ///
  /// In en, this message translates to:
  /// **'Distillery'**
  String get distillery;

  /// No description provided for @allDistilleries.
  ///
  /// In en, this message translates to:
  /// **'All Distilleries'**
  String get allDistilleries;

  /// No description provided for @quickFilters.
  ///
  /// In en, this message translates to:
  /// **'Quick Filters'**
  String get quickFilters;

  /// No description provided for @availableOnly.
  ///
  /// In en, this message translates to:
  /// **'Available Only'**
  String get availableOnly;

  /// No description provided for @hasImages.
  ///
  /// In en, this message translates to:
  /// **'Has Images'**
  String get hasImages;

  /// No description provided for @newThisMonth.
  ///
  /// In en, this message translates to:
  /// **'New This Month'**
  String get newThisMonth;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @avgAge.
  ///
  /// In en, this message translates to:
  /// **'Avg Age'**
  String get avgAge;

  /// No description provided for @avgAbv.
  ///
  /// In en, this message translates to:
  /// **'Avg ABV'**
  String get avgAbv;

  /// No description provided for @hikeId.
  ///
  /// In en, this message translates to:
  /// **'Hike ID'**
  String get hikeId;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @sampleDetails.
  ///
  /// In en, this message translates to:
  /// **'Sample Details'**
  String get sampleDetails;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @chooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose Image'**
  String get chooseImage;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImage;

  /// No description provided for @imageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully'**
  String get imageUploaded;

  /// No description provided for @imageRemoved.
  ///
  /// In en, this message translates to:
  /// **'Image removed successfully'**
  String get imageRemoved;

  /// No description provided for @errorUploadingImageGeneral.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image'**
  String get errorUploadingImageGeneral;

  /// No description provided for @errorRemovingImage.
  ///
  /// In en, this message translates to:
  /// **'Error removing image'**
  String get errorRemovingImage;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @mainRegion.
  ///
  /// In en, this message translates to:
  /// **'Main Region'**
  String get mainRegion;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get totalVolume;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @whiskySamples.
  ///
  /// In en, this message translates to:
  /// **'Whisky Samples'**
  String get whiskySamples;

  /// No description provided for @noSamplesYet.
  ///
  /// In en, this message translates to:
  /// **'No samples yet'**
  String get noSamplesYet;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @averageAbv.
  ///
  /// In en, this message translates to:
  /// **'Average ABV'**
  String get averageAbv;
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
