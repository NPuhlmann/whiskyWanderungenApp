import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:developer' as dev;

import '../../../domain/models/hike.dart';
import '../../../domain/models/profile.dart';

class BackendApiService {
  final SupabaseClient client = Supabase.instance.client;
  

  // get User Profile by id
  Future<Profile> getUserProfileById(String id) async {
    final response = await client.from('profiles').select().eq('id', id);
    if ((response as List<dynamic>).isEmpty) {
      // Wenn kein Profil gefunden wurde, erstelle ein neues mit der ID
      return Profile();
    }
    
    // Konvertiere die Antwort in ein Profil-Objekt
    final Map<String, dynamic> profileData = response.first;
    
    // Erstelle ein neues Profil mit den Daten aus der Datenbank
    return Profile.fromJson(profileData);
  }
  
  // get a list of hikes from the 'hikes' table
  Future<List<Hike>> fetchHikes() async {
    final response = await client.from('hikes').select();
    final List<dynamic> hikeData = response as List<dynamic>;

    return hikeData.map((element) => Hike.fromJson(element as Map<String, dynamic>)).toList();
  }

  // get a list of hikes purchased by a user
  Future<List<Hike>> fetchUserHikes(String userId) async {
    try {
      // Verwende die korrekte Tabelle 'purchased_hikes'
      final response = await client
          .from('purchased_hikes')
          .select('hike_id')
          .eq('user_id', userId);
      
      final List<dynamic> userHikeData = response as List<dynamic>;
      if (userHikeData.isEmpty) {
        return [];
      }

      // Extrahiere die Hike-IDs und behandle mögliche Typprobleme
      final List<int> hikeIds = [];
      for (final element in userHikeData) {
        if (element['hike_id'] != null) {
          // Konvertiere zu int, unabhängig davon, ob es als String oder int gespeichert ist
          hikeIds.add(int.parse(element['hike_id'].toString()));
        }
      }
      
      if (hikeIds.isEmpty) {
        return [];
      }

      // Holen Sie sich die vollständigen Hike-Objekte für die IDs
      List<Hike> userHikes = [];
      for (final hikeId in hikeIds) {
        try {
          final hikeResponse = await client
              .from('hikes')
              .select()
              .eq('id', hikeId);
          
          final List<dynamic> hikeDataList = hikeResponse as List<dynamic>;
          if (hikeDataList.isNotEmpty) {
            final hikeData = hikeDataList.first as Map<String, dynamic>;
            userHikes.add(Hike.fromJson(hikeData));
          }
        } catch (e) {
          print('Fehler beim Laden der Hike mit ID $hikeId: $e');
          // Fahre mit der nächsten Hike fort
          continue;
        }
      }
      
      return userHikes;
    } catch (e) {
      print('Fehler beim Laden der Benutzer-Hikes: $e');
      return [];
    }
  }

  // Section for Hike Images
  // Table Structure: hike_images
  // id: int
  // hike_id: int
  // image_url: text
  // created_at: timestamp


  // get images for a hike by hike.id
  Future<List<String>> getHikeImages(int hikeId) async {
    final response = await client.from('hike_images').select().eq('hike_id', hikeId);
    final List<dynamic> hikeImageData = response as List<dynamic>;

    return hikeImageData.map((element) => element['image_url'] as String).toList();
  }

  // upload images for a hike with hike id and image urls
  Future<void> uploadHikeImages(int hikeId, List<String> imageUrls) async {
    final List<Map<String, dynamic>> imageRecords = imageUrls.map((imageUrl) => {
      'hike_id': hikeId,
      'image_url': imageUrl,
    }).toList();

    await client.from('hike_images').upsert(imageRecords);
  }

  // update user profile
  Future<void> updateUserProfile(Profile profile) async {
    // Konvertiere das Profil in JSON und entferne Felder, die in der Datenbank nicht existieren
    final Map<String, dynamic> profileJson = profile.toJson();
    profileJson.remove('email'); // Email-Feld entfernen, da es in der auth.users Tabelle gespeichert wird
    profileJson.remove('imageUrl'); // imageUrl-Feld entfernen, da es in der Datenbank nicht existiert
    
    // Stelle sicher, dass die ID gesetzt ist
    if (profileJson['id'] == null || profileJson['id'].isEmpty) {
      final String? userId = client.auth.currentUser?.id;
      if (userId != null) {
        profileJson['id'] = userId;
      } else {
        throw Exception('Benutzer-ID konnte nicht ermittelt werden');
      }
    }
    
    // Verwende update statt upsert, um die RLS-Policy zu respektieren
    final String userId = profileJson['id'];
    await client.from('profiles')
        .update(profileJson)
        .eq('id', userId);
  }

  // Methode zum Hochladen eines Profilbilds
  Future<String> uploadProfileImage(String userId, Uint8List fileBytes, String fileExt) async {
    final String path = 'profile_images/$userId.$fileExt';
    
    dev.log("Beginne Upload nach $path mit ${fileBytes.length} Bytes");
    
    try {
      // Prüfen, ob der Bucket existiert, bevor wir hochladen
      try {
        final List<Bucket> buckets = await client.storage.listBuckets();
        final bool bucketExists = buckets.any((bucket) => bucket.name == 'avatars');
        if (!bucketExists) {
          dev.log("Der Bucket 'avatars' existiert nicht!");
          throw Exception("Der Storage-Bucket 'avatars' existiert nicht. Bitte erstellen Sie ihn in Supabase.");
        }
        dev.log("Bucket 'avatars' gefunden, fahre mit Upload fort");
      } catch (bucketError) {
        dev.log("Fehler beim Prüfen der Buckets: $bucketError", error: bucketError);
        // Wir versuchen trotzdem hochzuladen, falls es nur ein Berechtigungsproblem war
      }
      
      // Bild in den Storage hochladen
      await client.storage.from('avatars').uploadBinary(
        path,
        fileBytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );
      
      dev.log("Upload erfolgreich abgeschlossen");
      
      // Öffentliche URL des Bildes zurückgeben
      final String imageUrl = client.storage.from('avatars').getPublicUrl(path);
      dev.log("Generierte öffentliche URL: $imageUrl");
      return imageUrl;
    } catch (e) {
      dev.log("Fehler beim Hochladen des Profilbilds: $e", error: e);
      
      // Detaillierte Fehleranalyse
      if (e.toString().contains('permission denied')) {
        throw Exception("Keine Berechtigung zum Hochladen in den 'avatars' Bucket. Bitte überprüfen Sie die Supabase-Berechtigungen.");
      } else if (e.toString().contains('network')) {
        throw Exception("Netzwerkfehler beim Hochladen. Bitte überprüfen Sie Ihre Internetverbindung.");
      } else if (e.toString().contains('PlatformException')) {
        throw Exception("Plattformspezifischer Fehler: $e. Dies kann im Simulator auftreten.");
      }
      
      rethrow;
    }
  }

  // Methode zum Abrufen der Profilbild-URL
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      // Suche nach Dateien im Storage, die mit der Benutzer-ID beginnen
      final List<FileObject> files = await client.storage.from('avatars')
          .list(path: 'profile_images');
      
      // Filtere die Dateien nach der Benutzer-ID
      final List<FileObject> userFiles = files.where(
        (file) => file.name.startsWith(userId)
      ).toList();
      
      if (userFiles.isNotEmpty) {
        // Öffentliche URL des ersten gefundenen Bildes zurückgeben
        return client.storage.from('avatars').getPublicUrl('profile_images/${userFiles.first.name}');
      }
      return null;
    } catch (e) {
      print('Fehler beim Abrufen des Profilbilds: $e');
      return null;
    }
  }
}