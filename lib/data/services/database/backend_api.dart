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

}