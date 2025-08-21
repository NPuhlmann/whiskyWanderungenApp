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
}
