import 'package:flutter/material.dart';
import 'package:whisky_hikes/UI/mobile/profile/profile_view_model.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.viewModel});

  final ProfilePageViewModel viewModel;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Formatierung für das Datum
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final ImagePicker _imagePicker = ImagePicker();

  // Funktion zur Überprüfung, ob der Benutzer mindestens 18 Jahre alt ist
  bool _isAtLeast18YearsOld(DateTime birthDate) {
    final DateTime today = DateTime.now();
    final DateTime adultDate = DateTime(
      birthDate.year + 18,
      birthDate.month,
      birthDate.day,
    );
    return adultDate.compareTo(today) <= 0;
  }

  // Funktion zum Anzeigen des plattformspezifischen Date Pickers
  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime initialDate =
        widget.viewModel.profile.dateOfBirth ??
        DateTime.now().subtract(const Duration(days: 365 * 18));

    DateTime? pickedDate;

    if (Platform.isIOS) {
      // iOS-spezifischer Date Picker
      await showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(AppLocalizations.of(context)!.cancel),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: Text(AppLocalizations.of(context)!.done),
                      onPressed: () {
                        Navigator.of(context).pop(pickedDate);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initialDate,
                    maximumDate: DateTime.now().subtract(
                      const Duration(days: 365 * 18),
                    ),
                    onDateTimeChanged: (DateTime newDate) {
                      pickedDate = newDate;
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Android-spezifischer Date Picker
      final DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
        helpText: AppLocalizations.of(context)!.dateOfBirth,
      );

      if (selectedDate != null) {
        pickedDate = selectedDate;
      }
    }

    if (pickedDate != null) {
      setState(() {
        widget.viewModel.profile.dateOfBirth = pickedDate;
      });
    }
  }

  // Funktion zum Anzeigen des Dialogs zum Auswählen eines Profilbilds
  Future<void> _showImagePickerDialog(BuildContext context) async {
    if (Platform.isIOS) {
      // iOS-spezifischer Dialog
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(AppLocalizations.of(context)!.changeProfilePicture),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                child: Text(AppLocalizations.of(context)!.takePhoto),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                child: Text(AppLocalizations.of(context)!.chooseFromGallery),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          );
        },
      );
    } else {
      // Android-spezifischer Dialog
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(AppLocalizations.of(context)!.takePhoto),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(AppLocalizations.of(context)!.chooseFromGallery),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // Hilfsfunktion zur Simulator-Erkennung
  bool get _isRunningOnSimulator {
    if (Platform.isIOS) {
      // Zuverlässige iOS-Simulator-Erkennung
      return Platform.environment['SIMULATOR_DEVICE_NAME'] != null ||
          Platform.environment['SIMULATOR_MODEL_IDENTIFIER'] != null ||
          Platform.environment['SIMULATOR_ROOT'] != null;
    }
    return false;
  }

  // Funktion zum Auswählen und Hochladen eines Bildes
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Simulator-spezifische Behandlung
      if (_isRunningOnSimulator) {
        if (source == ImageSource.camera) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '🚫 Kamera ist im iOS-Simulator nicht verfügbar. Bitte verwenden Sie die Galerie oder ein echtes Gerät.',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        // Auch Galerie kann im Simulator problematisch sein
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ Sie nutzen den iOS-Simulator. Bei Problemen verwenden Sie bitte ein echtes Gerät.',
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final fileBytes = await imageFile.readAsBytes();

        // Dateiendung ermitteln
        final String fileExt = pickedFile.path.split('.').last.toLowerCase();

        // Loading-Anzeige für den Upload
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('📤 Bild wird hochgeladen...'),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 10),
            ),
          );
        }

        // Bild hochladen
        await widget.viewModel.uploadProfileImage(fileBytes, fileExt);

        if (mounted) {
          // Vorherige SnackBar entfernen
          ScaffoldMessenger.of(context).removeCurrentSnackBar();

          // Erfolgsmeldung anzeigen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('✅ Profilbild erfolgreich aktualisiert!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Vorherige Loading-SnackBar entfernen
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      }

      // Detaillierte Fehlerbehandlung mit verbessertem UI-Feedback
      if (mounted) {
        String errorMessage;
        Color backgroundColor;
        IconData errorIcon;

        // Spezifische Fehlermeldungen für bekannte Probleme
        if (e.toString().contains('Simulator') ||
            e.toString().contains('PlatformException')) {
          errorMessage =
              '📱 iOS-Simulator Limitierung: Bitte verwenden Sie ein echtes Gerät für optimale Ergebnisse.';
          backgroundColor = Colors.orange;
          errorIcon = Icons.devices;
        } else if (e.toString().contains('permission') ||
            e.toString().contains('denied')) {
          errorMessage =
              '🔐 Berechtigung verweigert: Bitte erlauben Sie den Zugriff auf Kamera/Galerie in den Einstellungen.';
          backgroundColor = Colors.red[700]!;
          errorIcon = Icons.security;
        } else if (e.toString().contains('network') ||
            e.toString().contains('timeout') ||
            e.toString().contains('connection')) {
          errorMessage =
              '🌐 Netzwerkfehler: Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.';
          backgroundColor = Colors.red[600]!;
          errorIcon = Icons.wifi_off;
        } else if (e.toString().contains(
              AppLocalizations.of(context)!.imageTooLarge,
            ) ||
            e.toString().contains('size')) {
          errorMessage = '📏 ${e.toString()}';
          backgroundColor = Colors.orange[700]!;
          errorIcon = Icons.photo_size_select_large;
        } else if (e.toString().contains('storage') ||
            e.toString().contains('bucket')) {
          errorMessage =
              '💾 Upload-Service Problem: Bitte versuchen Sie es später erneut.';
          backgroundColor = Colors.red[800]!;
          errorIcon = Icons.cloud_off;
        } else {
          // Allgemeine Fehlermeldung mit mehr Details
          final String errorDetail = e.toString().length > 100
              ? '${e.toString().substring(0, 100)}...'
              : e.toString();
          errorMessage = '❌ Upload fehlgeschlagen: $errorDetail';
          backgroundColor = Colors.red;
          errorIcon = Icons.error;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(errorIcon, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(errorMessage, style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'VERSTANDEN',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        actions: [
          IconButton(
            onPressed: () {
              widget.viewModel.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            // Textfelder um Namen und Adresse des Users zu ändern
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profilbild
                    GestureDetector(
                      onTap: () => _showImagePickerDialog(context),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                                backgroundImage:
                                    widget.viewModel.profile.imageUrl.isNotEmpty
                                    ? NetworkImage(
                                        widget.viewModel.profile.imageUrl,
                                      )
                                    : null,
                                child: widget.viewModel.profile.imageUrl.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              // Debug-Info für Entwicklung (kann später entfernt werden)
                              if (widget.viewModel.profile.imageUrl.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 8.0),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green[600],
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '✅ Bild geladen',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  margin: const EdgeInsets.only(top: 8.0),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        color: Colors.grey[600],
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '📷 Kein Profilbild',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: TextEditingController(
                        text: widget.viewModel.profile.firstName,
                      ),
                      onChanged: (value) {
                        widget.viewModel.profile.firstName = value;
                      },
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.firstName,
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(
                        text: widget.viewModel.profile.lastName,
                      ),
                      onChanged: (value) {
                        widget.viewModel.profile.lastName = value;
                      },
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.lastName,
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // E-Mail-Feld
                    TextField(
                      controller: TextEditingController(
                        text: widget.viewModel.profile.email,
                      ),
                      onChanged: (value) {
                        widget.viewModel.profile.email = value;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.email,
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Geburtsdatum-Feld
                    InkWell(
                      onTap: () => _showDatePicker(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.dateOfBirth,
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          widget.viewModel.profile.dateOfBirth != null
                              ? _dateFormat.format(
                                  widget.viewModel.profile.dateOfBirth!,
                                )
                              : AppLocalizations.of(context)!.selectDate,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Erweiterte Validierung mit benutzerfreundlichen SnackBars

                        // 1. Prüfen ob Geburtsdatum überhaupt gesetzt ist
                        if (widget.viewModel.profile.dateOfBirth == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '📅 Bitte tragen Sie Ihr Geburtsdatum ein, um Ihr Profil zu speichern.',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.orange[600],
                              duration: Duration(seconds: 5),
                              action: SnackBarAction(
                                label: 'VERSTANDEN',
                                textColor: Colors.white,
                                onPressed: () {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                },
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        // 2. Prüfen ob Benutzer mindestens 18 Jahre alt ist
                        if (!_isAtLeast18YearsOld(
                          widget.viewModel.profile.dateOfBirth!,
                        )) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.block, color: Colors.white),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '🔞 Sie müssen mindestens 18 Jahre alt sein, um diese App zu nutzen.',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red[700],
                              duration: Duration(seconds: 6),
                              action: SnackBarAction(
                                label: 'VERSTANDEN',
                                textColor: Colors.white,
                                onPressed: () {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                },
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        // 3. Alles OK - Profil speichern
                        widget.viewModel.updateProfile(
                          widget.viewModel.profile,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.save),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
