// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Whisky Wanderungen';

  @override
  String get login => 'Anmelden';

  @override
  String get logout => 'Abmelden';

  @override
  String get signup => 'Registrieren';

  @override
  String get password => 'Passwort';

  @override
  String get passwordConfirm => 'Passwort bestätigen';

  @override
  String get email => 'E-Mail';

  @override
  String get passwordNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get legalAgeInfo =>
      'Sie müssen volljährig sein, um diese App zu nutzen';

  @override
  String get iAmLegalAge => 'Ich bin volljährig';

  @override
  String get hikes => 'Wanderungen';

  @override
  String get myHikes => 'Meine Wanderungen';

  @override
  String get profile => 'Profil';

  @override
  String greeting_home_page(Object name) {
    return 'Hallo, $name! Bereit für ein Abenteuer?';
  }

  @override
  String get hard => 'schwer';

  @override
  String get middle => 'mittel';

  @override
  String get easy => 'leicht';

  @override
  String get very_hard => 'sehr schwer';

  @override
  String get buyButtonText => 'Kaufen';

  @override
  String get startHikeButtonText => 'Wanderung starten';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String get address => 'Adresse';

  @override
  String get save => 'Speichern';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get noHikesFound => 'Keine Wanderungen gefunden';

  @override
  String get noHikesPurchased => 'Du hast noch keine Wanderungen gekauft.';

  @override
  String get loginRequiredForHikes =>
      'Bitte melde dich an, um deine gekauften Wanderungen zu sehen.';

  @override
  String get errorLoadingHikes =>
      'Ein Fehler ist aufgetreten. Bitte versuche es später erneut.';

  @override
  String get show_favorites => 'Favoriten anzeigen';

  @override
  String get show_all_hikes => 'Alle Wanderungen anzeigen';

  @override
  String get dateOfBirth => 'Geburtsdatum';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get mustBeAtLeast18 => 'Du musst mindestens 18 Jahre alt sein';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get done => 'Fertig';

  @override
  String get changeProfilePicture => 'Profilbild ändern';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromGallery => 'Aus Galerie wählen';

  @override
  String get errorUploadingImage => 'Fehler beim Hochladen des Bildes';

  @override
  String get noWaypointsFound => 'Keine Wegpunkte für diese Wanderung gefunden';

  @override
  String get errorLoadingWaypoints => 'Fehler beim Laden der Wegpunkte';

  @override
  String get errorCalculatingRoute => 'Fehler bei der Routenberechnung';

  @override
  String get waypointReached => 'Wegpunkt erreicht!';

  @override
  String get continueHike => 'Wanderung fortsetzen';

  @override
  String get saveMapOffline => 'Karte offline speichern';

  @override
  String get savingMapOfflineMessage =>
      'Karte wird für die Offline-Nutzung gespeichert...';

  @override
  String get rebuyHike => 'Wanderung erneut kaufen';

  @override
  String get rebuyingHikeMessage => 'Wanderung wird erneut gekauft...';

  @override
  String get removeOfflineData => 'Offline-Daten entfernen';

  @override
  String get removingOfflineData => 'Offline-Daten werden entfernt...';

  @override
  String get hikeOfflineSaved =>
      'Wanderung wurde für die Offline-Nutzung gespeichert';

  @override
  String get errorSavingOffline =>
      'Fehler beim Speichern der Wanderung für die Offline-Nutzung';

  @override
  String get offlineDataRemoved => 'Offline-Daten wurden entfernt';

  @override
  String get errorRemovingOfflineData =>
      'Fehler beim Entfernen der Offline-Daten';

  @override
  String get signupSuccess => 'Registrierung erfolgreich!';

  @override
  String get imageLoadError => 'Bild konnte nicht geladen werden';

  @override
  String get kilometers => 'km';

  @override
  String get meters => 'm';

  @override
  String get orderNotFound => 'Bestellung nicht gefunden';

  @override
  String get invalidOrderId => 'Ungültige Bestell-ID';

  @override
  String get checkout => 'Checkout';

  @override
  String get pickupOnSite => 'Vor Ort abholen';

  @override
  String get free => 'Kostenlos';

  @override
  String get shippingByPost => 'Per Post versenden';

  @override
  String get shippingCost => '+5,00 € Versandkosten';

  @override
  String get redirectingToCheckout => 'Weiterleitung zum Checkout...';

  @override
  String get orderTracking => 'Bestellverfolgung';

  @override
  String get retry => 'Wiederholen';

  @override
  String get unexpectedState => 'Unexpected state: No order data available';

  @override
  String get cancelOrder => 'Bestellung stornieren';

  @override
  String get contactSupport => 'Support kontaktieren';

  @override
  String get cancelOrderConfirmation =>
      'Möchtest du diese Bestellung wirklich stornieren?';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get cancellationRequested =>
      'Stornierung der Bestellung wurde angefordert';

  @override
  String get contactingSupport => 'Kontaktiere Support...';

  @override
  String get tastingSet => 'Tasting Set';

  @override
  String get proceedToCheckout => 'Weiter zum Checkout';

  @override
  String get trackingOpen => 'Tracking öffnen';

  @override
  String get unknownOrderType => 'Unbekannter Bestelltyp';

  @override
  String get mobileLayout => 'Mobile Layout';

  @override
  String get webAppRunning => 'Web-App läuft erfolgreich! 🎉';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get hikingRoutes => 'Wanderrouten';

  @override
  String get orders => 'Bestellungen';

  @override
  String get flutterWebEnabled => '✅ Flutter Web aktiviert';

  @override
  String get responsiveLayoutImplemented => '✅ Responsive Layout implementiert';

  @override
  String get adminDashboardCreated => '✅ Admin-Dashboard erstellt';

  @override
  String get navigationImplemented => '✅ Navigation implementiert';

  @override
  String get webDependenciesAdded =>
      '✅ Web-spezifische Dependencies hinzugefügt';

  @override
  String get manageHikingRoutes => 'Wanderrouten verwalten';

  @override
  String get manageHikingRoutesDescription =>
      'Hier können Sie Wanderrouten erstellen und verwalten';

  @override
  String get inDevelopment => '🚧 In Entwicklung 🚧';

  @override
  String get manageOrders => 'Bestellungen verwalten';

  @override
  String get manageOrdersDescription =>
      'Hier können Sie alle Bestellungen einsehen und bearbeiten';

  @override
  String get manageWhiskyCatalog => 'Whisky-Katalog verwalten';

  @override
  String get manageWhiskyCatalogDescription =>
      'Hier können Sie den Whisky-Katalog verwalten';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get newRoute => 'Neue Route';

  @override
  String get noDataAvailable => 'Keine Daten verfügbar';

  @override
  String get showAll => 'Alle anzeigen';

  @override
  String get noOrdersAvailable => 'Keine Bestellungen verfügbar';

  @override
  String get order => 'Bestellung';

  @override
  String get customer => 'Kunde';

  @override
  String get route => 'Route';

  @override
  String get amount => 'Betrag';

  @override
  String get status => 'Status';

  @override
  String get date => 'Datum';

  @override
  String get close => 'Schließen';

  @override
  String get imageTooLarge => 'Bild zu groß';

  @override
  String get overview => 'Übersicht';

  @override
  String get tastingSets => 'Tasting Sets';

  @override
  String get filters => 'Filter';

  @override
  String get createNewTastingSet => 'Neues Tasting Set erstellen';

  @override
  String get create => 'Erstellen';

  @override
  String get catalogOverview => 'Katalog Übersicht';

  @override
  String get totalSets => 'Gesamtsets';

  @override
  String get availableSets => 'Verfügbare Sets';

  @override
  String get totalSamples => 'Gesamtproben';

  @override
  String get avgSamplesPerSet => 'Durchschn. Proben pro Set';

  @override
  String get regions => 'Regionen';

  @override
  String get distilleries => 'Brennereien';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get name => 'Name';

  @override
  String get samples => 'Proben';

  @override
  String get searchTastingSets => 'Tasting Sets suchen';

  @override
  String get clearFilters => 'Filter löschen';

  @override
  String get all => 'Alle';

  @override
  String get loading => 'Lädt';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get newTastingSet => 'Neues Tasting Set';

  @override
  String get sampleCount => 'Probenanzahl';

  @override
  String get averageAge => 'Durchschnittsalter';

  @override
  String get region => 'Region';

  @override
  String get addTastingSet => 'Tasting Set hinzufügen';

  @override
  String get errorLoadingData => 'Fehler beim Laden der Daten';

  @override
  String get noTastingSetsMatchFilter =>
      'Keine Tasting Sets entsprechen dem aktuellen Filter';

  @override
  String get noTastingSetsYet => 'Noch keine Tasting Sets erstellt';

  @override
  String get tryAdjustingFilters => 'Versuchen Sie, die Filter anzupassen oder';

  @override
  String get createFirstTastingSet => 'Erstellen Sie Ihr erstes Tasting Set';

  @override
  String get createTastingSet => 'Tasting Set erstellen';

  @override
  String get editTastingSet => 'Tasting Set bearbeiten';

  @override
  String get deleteTastingSet => 'Tasting Set löschen';

  @override
  String get searchPlaceholder => 'Nach Name, Brennerei oder Region suchen';

  @override
  String deleteTastingSetConfirmation(String name) {
    return 'Sind Sie sicher, dass Sie das Tasting Set \'$name\' löschen möchten?';
  }

  @override
  String get clearAll => 'Alle löschen';

  @override
  String get search => 'Suche';

  @override
  String get allRegions => 'Alle Regionen';

  @override
  String get distillery => 'Brennerei';

  @override
  String get allDistilleries => 'Alle Brennereien';

  @override
  String get quickFilters => 'Schnellfilter';

  @override
  String get availableOnly => 'Nur Verfügbare';

  @override
  String get hasImages => 'Mit Bildern';

  @override
  String get newThisMonth => 'Neu in diesem Monat';

  @override
  String get available => 'Verfügbar';

  @override
  String get unavailable => 'Nicht verfügbar';

  @override
  String get avgAge => 'Durchschn. Alter';

  @override
  String get avgAbv => 'Durchschn. Alkoholgehalt';

  @override
  String get hikeId => 'Wanderungs-ID';

  @override
  String get basicInformation => 'Grundinformationen';

  @override
  String get description => 'Beschreibung';

  @override
  String get availability => 'Verfügbarkeit';

  @override
  String get sampleDetails => 'Probendetails';

  @override
  String get viewDetails => 'Details anzeigen';

  @override
  String get quickActions => 'Schnellaktionen';

  @override
  String get uploadImage => 'Bild hochladen';

  @override
  String get chooseImage => 'Bild wählen';

  @override
  String get removeImage => 'Bild entfernen';

  @override
  String get imageUploaded => 'Bild erfolgreich hochgeladen';

  @override
  String get imageRemoved => 'Bild erfolgreich entfernt';

  @override
  String get errorUploadingImageGeneral => 'Fehler beim Hochladen des Bildes';

  @override
  String get errorRemovingImage => 'Fehler beim Entfernen des Bildes';

  @override
  String get noImageSelected => 'Kein Bild ausgewählt';

  @override
  String get years => 'Jahre';

  @override
  String get price => 'Preis';

  @override
  String get mainRegion => 'Hauptregion';

  @override
  String get totalVolume => 'Gesamtvolumen';

  @override
  String get createdAt => 'Erstellt';

  @override
  String get lastUpdated => 'Zuletzt aktualisiert';

  @override
  String get whiskySamples => 'Whisky-Proben';

  @override
  String get noSamplesYet => 'Noch keine Proben';

  @override
  String get statistics => 'Statistiken';

  @override
  String get averageAbv => 'Durchschnittlicher ABV';
}
