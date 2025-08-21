import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:developer' as dev;

import '../../../domain/models/hike.dart';
import '../../../domain/models/profile.dart';
import '../../../domain/models/waypoint.dart';

class BackendApiService {
  final SupabaseClient client = Supabase.instance.client;
  

  // get User Profile by id
  Future<Profile> getUserProfileById(String id) async {
    final response = await client.from('profiles').select().eq('id', id);
    if ((response as List<dynamic>).isEmpty) {
      // Profil nicht gefunden - erstelle ein leeres Profil für die UI
      dev.log('Profil nicht gefunden für Benutzer-ID: $id. Erstelle leeres Profil.');
      return Profile(id: id);
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
          // logging: 'Fehler beim Laden der Hike mit ID $hikeId: $e');
          // Fahre mit der nächsten Hike fort
          continue;
        }
      }
      
      return userHikes;
    } catch (e) {
      // logging: 'Fehler beim Laden der Benutzer-Hikes: $e');
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
      // logging: 'Fehler beim Abrufen des Profilbilds: $e');
      return null;
    }
  }

  // get waypoints for a hike by hike.id from the 'hikes_waypoints' table
  Future<List<Map<String, dynamic>>> _getWaypointDataForHike(int hikeId) async {
    try {
      final response = await client
          .from('hikes_waypoints')
          .select('waypoint_id, order_index')
          .eq('hike_id', hikeId)
          .order('order_index', ascending: true);
      
      return List<Map<String, dynamic>>.from(response as List<dynamic>);
    } catch (e) {
      dev.log('Fehler beim Abrufen der Wegpunkt-Daten: $e', error: e);
      throw Exception('Fehler beim Abrufen der Wegpunkt-Daten für Wanderung $hikeId: $e');
    }
  }

  // get waypoints for for a hike by hike.id from the waypoints table
  Future<List<Waypoint>> getWaypointsForHike(int hikeId) async {
    try {
      // Zuerst die Wegpunkt-Daten mit order_index für die Wanderung abrufen
      final List<Map<String, dynamic>> waypointDataList = await _getWaypointDataForHike(hikeId);
      
      if (waypointDataList.isEmpty) {
        return [];
      }
      
      // Map für orderIndex pro waypoint_id erstellen
      final Map<int, int> waypointOrderMap = {};
      final List<int> waypointIds = [];
      
      for (var data in waypointDataList) {
        final waypointId = int.parse(data['waypoint_id'].toString());
        final orderIndex = int.parse(data['order_index'].toString());
        waypointIds.add(waypointId);
        waypointOrderMap[waypointId] = orderIndex;
      }
      
      // Dann die Wegpunkte für diese IDs abrufen
      final response = await client
          .from('waypoints')
          .select()
          .inFilter('id', waypointIds);
      
      final List<dynamic> waypointData = response as List<dynamic>;
      
      List<Waypoint> waypoints = waypointData.map((element) {
        // Sicherstellen, dass alle erforderlichen Felder vorhanden und vom richtigen Typ sind
        Map<String, dynamic> safeElement = Map<String, dynamic>.from(element);
        
        // Überprüfen und konvertieren der numerischen Werte
        if (safeElement['latitude'] == null) safeElement['latitude'] = 0.0;
        if (safeElement['longitude'] == null) safeElement['longitude'] = 0.0;
        
        // Sicherstellen, dass die Werte den richtigen Typ haben
        safeElement['latitude'] = double.parse(safeElement['latitude'].toString());
        safeElement['longitude'] = double.parse(safeElement['longitude'].toString());
        
        // Füge hikeId und orderIndex hinzu
        safeElement['hikeId'] = hikeId;
        final waypointId = int.parse(safeElement['id'].toString());
        safeElement['orderIndex'] = waypointOrderMap[waypointId] ?? 0;
        
        return Waypoint.fromJson(safeElement);
      }).toList();
      
      // Sortierung nach orderIndex (zusätzliche Sicherheit)
      waypoints.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      
      return waypoints;
    } catch (e) {
      dev.log('Fehler beim Abrufen der Wegpunkte: $e', error: e);
      throw Exception('Fehler beim Abrufen der Wegpunkte für Wanderung $hikeId: $e');
    }
  }

  // Methode zum Hinzufügen eines neuen Wegpunkts
  Future<void> addWaypoint(Waypoint waypoint, int hikeId, {int? orderIndex}) async {
    try {
      // Zuerst den Wegpunkt in die 'waypoints' Tabelle einfügen
      final waypointResponse = await client.from('waypoints').insert({
        'name': waypoint.name,
        'description': waypoint.description,
        'latitude': waypoint.latitude,
        'longitude': waypoint.longitude,
      }).select('id').single();
      
      // Die ID des neu erstellten Wegpunkts abrufen
      final int newWaypointId = waypointResponse['id'];
      
      // Wenn kein orderIndex angegeben, den nächsten verfügbaren verwenden
      int finalOrderIndex = orderIndex ?? waypoint.orderIndex;
      if (finalOrderIndex == 0) {
        // Bestimme den höchsten order_index für diese Wanderung + 1
        final maxOrderResponse = await client
            .from('hikes_waypoints')
            .select('order_index')
            .eq('hike_id', hikeId)
            .order('order_index', ascending: false)
            .limit(1);
        
        if (maxOrderResponse.isNotEmpty) {
          final maxOrder = int.parse(maxOrderResponse.first['order_index'].toString());
          finalOrderIndex = maxOrder + 1;
        } else {
          finalOrderIndex = 1;
        }
      }
      
      // Verknüpfung zwischen Wanderung und Wegpunkt in der 'hikes_waypoints' Tabelle erstellen
      await client.from('hikes_waypoints').insert({
        'hike_id': hikeId,
        'waypoint_id': newWaypointId,
        'order_index': finalOrderIndex,
      });
      
    } catch (e) {
      dev.log('Fehler beim Hinzufügen des Wegpunkts: $e', error: e);
      throw Exception('Fehler beim Hinzufügen des Wegpunkts: $e');
    }
  }
  
  // Methode zum Aktualisieren eines bestehenden Wegpunkts
  Future<void> updateWaypoint(Waypoint waypoint) async {
    try {
      await client.from('waypoints').update({
        'name': waypoint.name,
        'description': waypoint.description,
        'latitude': waypoint.latitude,
        'longitude': waypoint.longitude,
      }).eq('id', waypoint.id);
      
    } catch (e) {
      dev.log('Fehler beim Aktualisieren des Wegpunkts: $e', error: e);
      throw Exception('Fehler beim Aktualisieren des Wegpunkts: $e');
    }
  }
  
  // Methode zum Löschen eines Wegpunkts
  Future<void> deleteWaypoint(int waypointId, int hikeId) async {
    try {
      // Zuerst die Verknüpfung in der 'hikes_waypoints' Tabelle löschen
      await client.from('hikes_waypoints')
          .delete()
          .eq('waypoint_id', waypointId)
          .eq('hike_id', hikeId);
      
      // Dann den Wegpunkt selbst aus der 'waypoints' Tabelle löschen
      await client.from('waypoints')
          .delete()
          .eq('id', waypointId);
      
    } catch (e) {
      dev.log('Fehler beim Löschen des Wegpunkts: $e', error: e);
      throw Exception('Fehler beim Löschen des Wegpunkts: $e');
    }
  }
  
  // Methode zum Aktualisieren der Wegpunkt-Reihenfolge
  Future<void> updateWaypointOrder(int hikeId, int waypointId, int newOrderIndex) async {
    try {
      await client
          .from('hikes_waypoints')
          .update({'order_index': newOrderIndex})
          .eq('hike_id', hikeId)
          .eq('waypoint_id', waypointId);
    } catch (e) {
      dev.log('Fehler beim Aktualisieren der Wegpunkt-Reihenfolge: $e', error: e);
      throw Exception('Fehler beim Aktualisieren der Wegpunkt-Reihenfolge: $e');
    }
  }
}
