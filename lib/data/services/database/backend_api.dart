import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/profile.dart';

class BackendApiService {
  final SupabaseClient client = Supabase.instance.client;

  // get User Profile by id
  Future<Profile> getUserProfileById(String id) async {
    final response = await client.from('profiles').select().eq('id', id);
    print(response);
    return (response as List<dynamic>).map<Profile>((element) => Profile.fromJson(element)).first;
  }

}