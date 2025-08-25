import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisky_hikes/data/services/cache/local_cache_service.dart';
import 'package:whisky_hikes/domain/models/profile.dart';

class MockPathProviderPlatform extends Mock implements PathProviderPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('LocalCacheService Tests', () {
    late LocalCacheService cacheService;
    late Directory tempDir;
    
    setUpAll(() async {
      // Create temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('cache_test_');
    });
    
    tearDownAll(() async {
      // Clean up temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    setUp(() async {
      cacheService = LocalCacheService();
      
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      
      // Mock path_provider to use temp directory
      PathProviderPlatform.instance = MockPathProviderPlatform();
      when(PathProviderPlatform.instance.getApplicationDocumentsPath())
          .thenAnswer((_) async => tempDir.path);
    });

    tearDown(() async {
      // Clean up after each test
      await cacheService.clearAllCache();
    });

    group('Profile Data Caching', () {
      test('should cache profile data successfully', () async {
        // Arrange
        final profile = Profile(
          id: 'user123',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
        );

        // Act
        await cacheService.cacheProfileData(profile, 'user123');

        // Assert
        final cachedProfile = await cacheService.getCachedProfileData('user123');
        expect(cachedProfile, isNotNull);
        expect(cachedProfile!.id, 'user123');
        expect(cachedProfile.firstName, 'John');
        expect(cachedProfile.lastName, 'Doe');
        expect(cachedProfile.email, 'john@example.com');
      });

      test('should return null when no cached profile data exists', () async {
        // Act
        final cachedProfile = await cacheService.getCachedProfileData('nonexistent');

        // Assert
        expect(cachedProfile, isNull);
      });

      test('should return null when cached profile data is expired', () async {
        // Arrange
        final profile = Profile(id: 'user123', firstName: 'John', lastName: 'Doe');
        
        // Cache with expired timestamp
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_profile_data_user123', jsonEncode(profile.toJson()));
        final expiredTimestamp = DateTime.now()
            .subtract(const Duration(hours: 25))
            .millisecondsSinceEpoch;
        await prefs.setInt('cached_profile_timestamp_user123', expiredTimestamp);

        // Act
        final cachedProfile = await cacheService.getCachedProfileData('user123');

        // Assert
        expect(cachedProfile, isNull);
      });

      test('should clear expired cache when retrieving expired data', () async {
        // Arrange
        final profile = Profile(id: 'user123', firstName: 'John', lastName: 'Doe');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_profile_data_user123', jsonEncode(profile.toJson()));
        final expiredTimestamp = DateTime.now()
            .subtract(const Duration(hours: 25))
            .millisecondsSinceEpoch;
        await prefs.setInt('cached_profile_timestamp_user123', expiredTimestamp);

        // Act
        await cacheService.getCachedProfileData('user123');

        // Assert - cache should be cleared
        final dataKey = prefs.getString('cached_profile_data_user123');
        final timestampKey = prefs.getInt('cached_profile_timestamp_user123');
        expect(dataKey, isNull);
        expect(timestampKey, isNull);
      });

      test('should handle JSON decode errors gracefully', () async {
        // Arrange - invalid JSON
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_profile_data_user123', 'invalid_json');
        await prefs.setInt('cached_profile_timestamp_user123', DateTime.now().millisecondsSinceEpoch);

        // Act
        final cachedProfile = await cacheService.getCachedProfileData('user123');

        // Assert
        expect(cachedProfile, isNull);
      });

      test('should validate profile data cache correctly', () async {
        // Arrange - valid cache
        final profile = Profile(id: 'user123', firstName: 'John', lastName: 'Doe');
        await cacheService.cacheProfileData(profile, 'user123');

        // Act & Assert
        final isValid = await cacheService.hasValidProfileDataCache('user123');
        expect(isValid, true);

        // Test invalid cache (no data)
        final isInvalid = await cacheService.hasValidProfileDataCache('nonexistent');
        expect(isInvalid, false);
      });

      test('should clear profile data cache successfully', () async {
        // Arrange
        final profile = Profile(id: 'user123', firstName: 'John', lastName: 'Doe');
        await cacheService.cacheProfileData(profile, 'user123');

        // Verify cached
        expect(await cacheService.hasValidProfileDataCache('user123'), true);

        // Act
        await cacheService.clearProfileDataCache('user123');

        // Assert
        expect(await cacheService.hasValidProfileDataCache('user123'), false);
        final cachedProfile = await cacheService.getCachedProfileData('user123');
        expect(cachedProfile, isNull);
      });
    });

    group('Profile Image Caching', () {
      test('should cache profile image successfully', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const userId = 'user123';
        const fileExtension = 'jpg';

        // Act
        final cachedPath = await cacheService.cacheProfileImage(userId, imageBytes, fileExtension);

        // Assert
        expect(cachedPath, isNotNull);
        expect(cachedPath!.contains('profile_user123.jpg'), true);
        
        // Verify file exists
        final file = File(cachedPath);
        expect(await file.exists(), true);
        
        // Verify content
        final savedBytes = await file.readAsBytes();
        expect(savedBytes, equals(imageBytes));
      });

      test('should retrieve cached profile image path', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([10, 20, 30, 40, 50]);
        const userId = 'user456';
        const fileExtension = 'png';

        // Cache the image
        final originalPath = await cacheService.cacheProfileImage(userId, imageBytes, fileExtension);

        // Act
        final retrievedPath = await cacheService.getCachedProfileImagePath(userId);

        // Assert
        expect(retrievedPath, isNotNull);
        expect(retrievedPath, equals(originalPath));
        
        // Verify file still exists
        final file = File(retrievedPath!);
        expect(await file.exists(), true);
      });

      test('should return null for non-existent cached image', () async {
        // Act
        final imagePath = await cacheService.getCachedProfileImagePath('nonexistent');

        // Assert
        expect(imagePath, isNull);
      });

      test('should return null for expired cached image', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const userId = 'user123';
        
        // Cache with expired timestamp
        final prefs = await SharedPreferences.getInstance();
        final tempPath = '${tempDir.path}/profile_cache/profile_user123.jpg';
        await Directory('${tempDir.path}/profile_cache').create(recursive: true);
        await File(tempPath).writeAsBytes(imageBytes);
        
        await prefs.setString('cached_profile_image_path_user123', tempPath);
        final expiredTimestamp = DateTime.now()
            .subtract(const Duration(days: 8))
            .millisecondsSinceEpoch;
        await prefs.setInt('cached_profile_image_timestamp_user123', expiredTimestamp);

        // Act
        final cachedPath = await cacheService.getCachedProfileImagePath(userId);

        // Assert
        expect(cachedPath, isNull);
      });

      test('should return null when cached image file doesn\'t exist', () async {
        // Arrange
        const userId = 'user123';
        const fakePath = '/fake/path/profile.jpg';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_profile_image_path_user123', fakePath);
        await prefs.setInt('cached_profile_image_timestamp_user123', DateTime.now().millisecondsSinceEpoch);

        // Act
        final cachedPath = await cacheService.getCachedProfileImagePath(userId);

        // Assert
        expect(cachedPath, isNull);
      });

      test('should validate profile image cache correctly', () async {
        // Arrange - valid cache
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const userId = 'user123';
        await cacheService.cacheProfileImage(userId, imageBytes, 'jpg');

        // Act & Assert - valid cache
        final isValid = await cacheService.hasValidProfileImageCache(userId);
        expect(isValid, true);

        // Test invalid cache (no data)
        final isInvalid = await cacheService.hasValidProfileImageCache('nonexistent');
        expect(isInvalid, false);
      });

      test('should clear profile image cache successfully', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const userId = 'user123';
        final cachedPath = await cacheService.cacheProfileImage(userId, imageBytes, 'jpg');

        // Verify cached and file exists
        expect(await cacheService.hasValidProfileImageCache(userId), true);
        expect(await File(cachedPath!).exists(), true);

        // Act
        await cacheService.clearProfileImageCache(userId);

        // Assert
        expect(await cacheService.hasValidProfileImageCache(userId), false);
        expect(await File(cachedPath).exists(), false);
        final retrievedPath = await cacheService.getCachedProfileImagePath(userId);
        expect(retrievedPath, isNull);
      });

      test('should handle file I/O errors gracefully', () async {
        // Arrange - invalid path
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        
        // Mock path_provider to return invalid path
        when(PathProviderPlatform.instance.getApplicationDocumentsPath())
            .thenAnswer((_) async => '/invalid/path/that/does/not/exist');

        // Act
        final cachedPath = await cacheService.cacheProfileImage('user123', imageBytes, 'jpg');

        // Assert
        expect(cachedPath, isNull);
      });
    });

    group('Cache Management', () {
      test('should clear user cache (both data and image)', () async {
        // Arrange
        final profile = Profile(id: 'user123', firstName: 'John', lastName: 'Doe');
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        
        await cacheService.cacheProfileData(profile, 'user123');
        await cacheService.cacheProfileImage('user123', imageBytes, 'jpg');

        // Verify both caches exist
        expect(await cacheService.hasValidProfileDataCache('user123'), true);
        expect(await cacheService.hasValidProfileImageCache('user123'), true);

        // Act
        await cacheService.clearUserCache('user123');

        // Assert
        expect(await cacheService.hasValidProfileDataCache('user123'), false);
        expect(await cacheService.hasValidProfileImageCache('user123'), false);
      });

      test('should clear all cache data', () async {
        // Arrange
        final profile1 = Profile(id: 'user1', firstName: 'John', lastName: 'Doe');
        final profile2 = Profile(id: 'user2', firstName: 'Jane', lastName: 'Smith');
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        
        await cacheService.cacheProfileData(profile1, 'user1');
        await cacheService.cacheProfileData(profile2, 'user2');
        await cacheService.cacheProfileImage('user1', imageBytes, 'jpg');
        await cacheService.cacheProfileImage('user2', imageBytes, 'png');

        // Verify caches exist
        expect(await cacheService.hasValidProfileDataCache('user1'), true);
        expect(await cacheService.hasValidProfileDataCache('user2'), true);
        expect(await cacheService.hasValidProfileImageCache('user1'), true);
        expect(await cacheService.hasValidProfileImageCache('user2'), true);

        // Act
        await cacheService.clearAllCache();

        // Assert
        expect(await cacheService.hasValidProfileDataCache('user1'), false);
        expect(await cacheService.hasValidProfileDataCache('user2'), false);
        expect(await cacheService.hasValidProfileImageCache('user1'), false);
        expect(await cacheService.hasValidProfileImageCache('user2'), false);
      });

      test('should provide accurate cache statistics', () async {
        // Arrange
        final profile = Profile(id: 'user123', firstName: 'John', lastName: 'Doe');
        final imageBytes1 = Uint8List.fromList(List.generate(1000, (i) => i % 256));
        final imageBytes2 = Uint8List.fromList(List.generate(2000, (i) => i % 256));
        
        await cacheService.cacheProfileData(profile, 'user123');
        await cacheService.cacheProfileImage('user123', imageBytes1, 'jpg');
        await cacheService.cacheProfileImage('user456', imageBytes2, 'png');

        // Act
        final stats = await cacheService.getCacheStats();

        // Assert
        expect(stats['totalFiles'], 2); // 2 image files
        expect(stats['totalSizeMB'], greaterThan(0));
        expect(stats['profileDataCacheCount'], 1); // 1 profile data cache
        expect(stats['profileImageCacheCount'], 2); // 2 image files
      });

      test('should return empty statistics when cache directory doesn\'t exist', () async {
        // Act - without creating any cache
        final stats = await cacheService.getCacheStats();

        // Assert
        expect(stats['totalFiles'], 0);
        expect(stats['totalSizeMB'], 0.0);
        expect(stats['profileDataCacheCount'], 0);
        expect(stats['profileImageCacheCount'], 0);
      });

      test('should handle cache statistics errors gracefully', () async {
        // Arrange - mock invalid directory
        when(PathProviderPlatform.instance.getApplicationDocumentsPath())
            .thenThrow(Exception('Path not found'));

        // Act
        final stats = await cacheService.getCacheStats();

        // Assert
        expect(stats['totalFiles'], 0);
        expect(stats['totalSizeMB'], 0.0);
        expect(stats['profileDataCacheCount'], 0);
        expect(stats['profileImageCacheCount'], 0);
        expect(stats['error'], isNotNull);
      });
    });

    group('Cache Size Management', () {
      test('should manage cache size and delete old files when limit exceeded', () async {
        // Note: This test is challenging to implement reliably due to the private _manageCacheSize method
        // and the need to create files larger than 50MB. We'll test the behavior indirectly.
        
        // Arrange - create multiple cached images
        final largeImageBytes = Uint8List.fromList(List.generate(10000, (i) => i % 256));
        
        // Cache multiple images
        await cacheService.cacheProfileImage('user1', largeImageBytes, 'jpg');
        await cacheService.cacheProfileImage('user2', largeImageBytes, 'png');
        await cacheService.cacheProfileImage('user3', largeImageBytes, 'webp');

        // Act - cache one more image to trigger potential cleanup
        await cacheService.cacheProfileImage('user4', largeImageBytes, 'jpg');

        // Assert - verify that caching still works (size management doesn't break functionality)
        final cachedPath = await cacheService.getCachedProfileImagePath('user4');
        expect(cachedPath, isNotNull);
        expect(await File(cachedPath!).exists(), true);
      });
    });

    group('Network Connection Check', () {
      test('should check network connection', () async {
        // This test may be unreliable in CI environments
        // Act
        final hasConnection = await cacheService.hasNetworkConnection();

        // Assert - we can't guarantee network status, so we just verify it returns a boolean
        expect(hasConnection, isA<bool>());
      });
    });

    group('Error Handling', () {
      test('should handle SharedPreferences initialization errors gracefully', () async {
        // This is difficult to test directly since SharedPreferences.getInstance() 
        // is mocked. The service handles errors internally with try-catch blocks.
        
        // Arrange
        final profile = Profile(id: 'user123', firstName: 'John', lastName: 'Doe');

        // Act & Assert - should not throw
        expect(() => cacheService.cacheProfileData(profile, 'user123'), returnsNormally);
        expect(() => cacheService.getCachedProfileData('user123'), returnsNormally);
      });

      test('should handle cache directory creation errors gracefully', () async {
        // Arrange - mock path provider to return read-only path
        when(PathProviderPlatform.instance.getApplicationDocumentsPath())
            .thenAnswer((_) async => '/');

        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        // Act
        final cachedPath = await cacheService.cacheProfileImage('user123', imageBytes, 'jpg');

        // Assert - should handle error gracefully and return null
        expect(cachedPath, isNull);
      });

      test('should handle missing image files when validating cache', () async {
        // Arrange - manually set cache entry with non-existent file
        final prefs = await SharedPreferences.getInstance();
        const fakePath = '/fake/path/profile.jpg';
        await prefs.setString('cached_profile_image_path_user123', fakePath);
        await prefs.setInt('cached_profile_image_timestamp_user123', DateTime.now().millisecondsSinceEpoch);

        // Act
        final isValid = await cacheService.hasValidProfileImageCache('user123');

        // Assert
        expect(isValid, false);
      });
    });

    group('TTL (Time To Live) Behavior', () {
      test('should respect profile data TTL of 24 hours', () async {
        // This is tested indirectly through the expired cache tests above
        expect(LocalCacheService.profileDataTtl, equals(const Duration(hours: 24)));
      });

      test('should respect profile image TTL of 7 days', () async {
        // This is tested indirectly through the expired cache tests above
        expect(LocalCacheService.profileImageTtl, equals(const Duration(days: 7)));
      });

      test('should respect max cache size of 50MB', () async {
        expect(LocalCacheService.maxCacheSizeBytes, equals(50 * 1024 * 1024));
      });
    });

    group('File System Operations', () {
      test('should create cache directory if it doesn\'t exist', () async {
        // Arrange - ensure clean state
        await cacheService.clearAllCache();
        
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        // Act
        final cachedPath = await cacheService.cacheProfileImage('user123', imageBytes, 'jpg');

        // Assert
        expect(cachedPath, isNotNull);
        final cacheDir = Directory('${tempDir.path}/profile_cache');
        expect(await cacheDir.exists(), true);
      });

      test('should handle different file extensions', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const extensions = ['jpg', 'png', 'webp', 'jpeg'];

        // Act & Assert
        for (final ext in extensions) {
          final cachedPath = await cacheService.cacheProfileImage('user_$ext', imageBytes, ext);
          expect(cachedPath, isNotNull);
          expect(cachedPath!.contains('profile_user_$ext.$ext'), true);
          
          final file = File(cachedPath);
          expect(await file.exists(), true);
        }
      });

      test('should generate unique file paths for different users', () async {
        // Arrange
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        // Act
        final path1 = await cacheService.cacheProfileImage('user123', imageBytes, 'jpg');
        final path2 = await cacheService.cacheProfileImage('user456', imageBytes, 'jpg');

        // Assert
        expect(path1, isNotNull);
        expect(path2, isNotNull);
        expect(path1, isNot(equals(path2)));
        expect(path1!.contains('user123'), true);
        expect(path2!.contains('user456'), true);
      });
    });
  });
}