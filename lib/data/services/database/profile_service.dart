import 'dart:typed_data';
import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/profile.dart';
import '../error/error_handler.dart';

/// Dedicated service for profile-related operations
class ProfileService {
  final SupabaseClient client;

  ProfileService({SupabaseClient? client}) 
      : client = client ?? Supabase.instance.client;

  /// Get user profile by ID
  Future<Profile> getUserProfileById(String id) async {
    try {
      final response = await client.from('profiles').select().eq('id', id);
      if ((response as List<dynamic>).isEmpty) {
        dev.log('Profile not found for user ID: $id. Creating empty profile.');
        return Profile(id: id);
      }
      
      final Map<String, dynamic> profileData = response.first;
      return Profile.fromJson(profileData);
    } catch (e) {
      throw ErrorHandler.createSafeException('Get user profile', e);
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(Profile profile) async {
    try {
      final Map<String, dynamic> profileJson = profile.toJson();
      profileJson.remove('email'); // Email is stored in auth.users table
      profileJson.remove('imageUrl'); // imageUrl field doesn't exist in database
      
      if (profileJson['id'] == null || profileJson['id'].isEmpty) {
        final String? userId = client.auth.currentUser?.id;
        if (userId != null) {
          profileJson['id'] = userId;
        } else {
          throw Exception('Could not determine user ID');
        }
      }
      
      final String userId = profileJson['id'];
      await client.from('profiles')
          .update(profileJson)
          .eq('id', userId);
    } catch (e) {
      throw ErrorHandler.createSafeException('Update user profile', e);
    }
  }

  /// Upload profile image
  Future<String> uploadProfileImage(String userId, Uint8List fileBytes, String fileExt) async {
    final String path = '$userId/profile.$fileExt';
    
    dev.log("Starting upload to $path with ${fileBytes.length} bytes");
    
    try {
      await _ensureBucketExists();
      
      await client.storage.from('avatars').uploadBinary(
        path,
        fileBytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );
      
      dev.log("Upload completed successfully");
      
      final String imageUrl = client.storage.from('avatars').getPublicUrl(path);
      dev.log("Generated public URL: $imageUrl");
      return imageUrl;
    } catch (e) {
      throw ErrorHandler.createSafeException('Profile image upload', e);
    }
  }

  /// Get profile image URL
  Future<String?> getProfileImageUrl(String userId) async {
    try {
      dev.log("🔍 Looking for profile image for user: $userId");
      
      final List<FileObject> files = await client.storage.from('avatars')
          .list(path: userId);
      
      dev.log("📁 Found ${files.length} files in $userId/");
      
      if (files.isNotEmpty) {
        for (var file in files) {
          dev.log("📄 File: ${file.name}, Size: ${file.metadata?['size']}, Type: ${file.metadata?['mimetype']}");
        }
      }
      
      final List<FileObject> userFiles = files.where(
        (file) => file.name.startsWith('profile.')
      ).toList();
      
      if (userFiles.isNotEmpty) {
        final String filePath = '$userId/${userFiles.first.name}';
        final String publicUrl = client.storage.from('avatars').getPublicUrl(filePath);
        
        dev.log("✅ Profile image URL found: $publicUrl");
        return publicUrl;
      } else {
        dev.log("❌ No profile image found for user $userId");
        return null;
      }
    } catch (e) {
      ErrorHandler.logError('Get profile image URL', e);
      return null;
    }
  }

  /// Ensure avatars bucket exists
  Future<void> _ensureBucketExists() async {
    try {
      final List<Bucket> buckets = await client.storage.listBuckets();
      final bool bucketExists = buckets.any((bucket) => bucket.name == 'avatars');
      if (!bucketExists) {
        dev.log("The 'avatars' bucket does not exist!");
        throw Exception("The storage bucket 'avatars' does not exist. Please create it in Supabase.");
      }
      dev.log("Bucket 'avatars' found, continuing with upload");
    } catch (bucketError) {
      dev.log("Error checking buckets: $bucketError", error: bucketError);
      // Continue trying to upload in case it's just a permission issue
    }
  }
}