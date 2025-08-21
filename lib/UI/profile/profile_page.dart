import 'package:flutter/material.dart';
import 'package:whisky_hikes/UI/profile/profile_view_model.dart';
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
    final DateTime initialDate = widget.viewModel.profile.date_of_birth ?? 
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
                    maximumDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
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
        widget.viewModel.profile.date_of_birth = pickedDate;
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
  
  // Funktion zum Auswählen und Hochladen eines Bildes
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Prüfen, ob wir im Simulator sind
      bool isSimulator = false;
      if (Platform.isIOS) {
        try {
          // Versuche, auf die Galerie zuzugreifen - dies schlägt im Simulator oft fehl
          await _imagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1,
            maxHeight: 1,
            imageQuality: 1,
          );
        } catch (e) {
          // Wenn ein Fehler auftritt, sind wahrscheinlich im Simulator
          isSimulator = true;
          print('Simulator erkannt: $e');
        }
      }
      
      if (isSimulator) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Im iOS-Simulator ist der Zugriff auf Bilder eingeschränkt. Bitte verwenden Sie ein echtes Gerät für diese Funktion.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
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
        
        // Bild hochladen
        await widget.viewModel.uploadProfileImage(fileBytes, fileExt);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profilbild erfolgreich aktualisiert'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Detaillierte Fehlerbehandlung
      print('Fehler beim Hochladen des Bildes: $e');
      if (mounted) {
        String errorMessage = AppLocalizations.of(context)!.errorUploadingImage;
        
        // Spezifische Fehlermeldungen für bekannte Probleme
        if (e.toString().contains('Simulator')) {
          errorMessage = 'Diese Funktion ist im iOS-Simulator eingeschränkt. Bitte verwenden Sie ein echtes Gerät.';
        } else if (e.toString().contains('permission')) {
          errorMessage = 'Keine Berechtigung zum Zugriff auf Kamera oder Galerie. Bitte überprüfen Sie die App-Einstellungen.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Netzwerkfehler beim Hochladen. Bitte überprüfen Sie Ihre Internetverbindung.';
        } else if (e.toString().contains('PlatformException')) {
          errorMessage = 'Fehler beim Zugriff auf die Kamera oder Galerie. Dies kann im Simulator auftreten.';
        } else {
          // Allgemeine Fehlermeldung mit Details
          errorMessage = '$errorMessage: ${e.toString().split(':').last}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
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
          }
          
          if (widget.viewModel.profile.first_name == "" && !widget.viewModel.isLoading) {
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
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: widget.viewModel.profile.imageUrl.isNotEmpty
                                ? NetworkImage(widget.viewModel.profile.imageUrl)
                                : null,
                            child: widget.viewModel.profile.imageUrl.isEmpty
                                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                : null,
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
                      controller: TextEditingController(text: widget.viewModel.profile.first_name),
                      onChanged: (value) {
                        widget.viewModel.profile.first_name = value;
                      },
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.firstName,
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: widget.viewModel.profile.last_name),
                      onChanged: (value) {
                        widget.viewModel.profile.last_name = value;
                      },
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.lastName,
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // E-Mail-Feld
                    TextField(
                      controller: TextEditingController(text: widget.viewModel.profile.email),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          widget.viewModel.profile.date_of_birth != null
                              ? _dateFormat.format(widget.viewModel.profile.date_of_birth!)
                              : AppLocalizations.of(context)!.selectDate,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Überprüfen, ob der Benutzer mindestens 18 Jahre alt ist
                        if (widget.viewModel.profile.date_of_birth != null &&
                            !_isAtLeast18YearsOld(widget.viewModel.profile.date_of_birth!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.mustBeAtLeast18),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        widget.viewModel.updateProfile(widget.viewModel.profile);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
