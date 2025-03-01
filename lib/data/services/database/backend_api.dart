import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/hike.dart';
import '../../../domain/models/profile.dart';

class BackendApiService {
  final SupabaseClient client = Supabase.instance.client;
  

  // get User Profile by id
  Future<Profile> getUserProfileById(String id) async {
    final response = await client.from('profiles').select().eq('id', id);
    return (response as List<dynamic>).map<Profile>((element) => Profile.fromJson(element)).first;
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
    await client.from('profiles').upsert([profile.toJson()]);
  }

}