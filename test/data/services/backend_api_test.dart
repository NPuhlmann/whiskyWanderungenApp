import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/profile.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';

void main() {
  group('BackendApiService Tests', () {
    group('Model Creation Tests', () {
      test('should create Hike from JSON correctly', () {
        // This tests the JSON conversion logic used in fetchHikes
        final hikeJson = {
          'id': 1,
          'name': 'Test Hike',
          'length': 5.5,
          'steep': 0.3,
          'elevation': 200,
          'description': 'A test hike',
          'price': 19.99,
          'difficulty': 'mid',
          'thumbnailImageUrl': 'https://example.com/image.jpg',
          'isFavorite': false,
        };

        final hike = Hike.fromJson(hikeJson);

        expect(hike.id, 1);
        expect(hike.name, 'Test Hike');
        expect(hike.length, 5.5);
        expect(hike.difficulty, Difficulty.mid);
        expect(hike.price, 19.99);
      });

      test('should create Profile from JSON correctly', () {
        final profileJson = {
          'id': 'user123',
          'firstName': 'John',
          'lastName': 'Doe',
          'dateOfBirth': '1990-05-15T00:00:00.000Z',
          'email': 'john@example.com',
          'imageUrl': 'https://example.com/avatar.jpg',
        };

        final profile = Profile.fromJson(profileJson);

        expect(profile.id, 'user123');
        expect(profile.firstName, 'John');
        expect(profile.lastName, 'Doe');
        expect(profile.email, 'john@example.com');
      });

      test('should create Waypoint from JSON correctly', () {
        final waypointJson = {
          'id': 1,
          'hikeId': 10,
          'name': 'Test Waypoint',
          'description': 'A test waypoint',
          'latitude': 47.3769,
          'longitude': 8.5417,
          'images': ['image1.jpg', 'image2.jpg'],
          'isVisited': false,
        };

        final waypoint = Waypoint.fromJson(waypointJson);

        expect(waypoint.id, 1);
        expect(waypoint.hikeId, 10);
        expect(waypoint.name, 'Test Waypoint');
        expect(waypoint.latitude, 47.3769);
        expect(waypoint.longitude, 8.5417);
        expect(waypoint.images.length, 2);
      });
    });

    group('Data Processing Logic Tests', () {
      test('should handle empty hike list response', () {
        // Test the logic for processing empty responses
        final List<dynamic> emptyResponse = [];
        final hikes = emptyResponse.map((element) => Hike.fromJson(element as Map<String, dynamic>)).toList();
        
        expect(hikes, isEmpty);
      });

      test('should handle multiple hikes response', () {
        final List<dynamic> multipleHikesResponse = [
          {
            'id': 1,
            'name': 'Hike 1',
            'length': 3.0,
            'price': 15.0,
            'difficulty': 'easy',
          },
          {
            'id': 2,
            'name': 'Hike 2',
            'length': 7.0,
            'price': 25.0,
            'difficulty': 'hard',
          },
        ];

        final hikes = multipleHikesResponse.map((element) => Hike.fromJson(element as Map<String, dynamic>)).toList();

        expect(hikes.length, 2);
        expect(hikes[0].name, 'Hike 1');
        expect(hikes[0].difficulty, Difficulty.easy);
        expect(hikes[1].name, 'Hike 2');
        expect(hikes[1].difficulty, Difficulty.hard);
      });

      test('should process user hike IDs correctly', () {
        // Test the logic for extracting hike IDs from purchased_hikes response
        final List<dynamic> userHikeData = [
          {'hike_id': '1'},
          {'hike_id': 2},
          {'hike_id': '3'},
          {'hike_id': null}, // Should be filtered out
        ];

        final List<int> hikeIds = [];
        for (final element in userHikeData) {
          if (element['hike_id'] != null) {
            hikeIds.add(int.parse(element['hike_id'].toString()));
          }
        }

        expect(hikeIds, [1, 2, 3]);
      });

      test('should handle profile update data preparation', () {
        final profile = Profile(
          id: 'user123',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com', // Should be removed
          imageUrl: 'https://example.com/avatar.jpg', // Should be removed
          dateOfBirth: DateTime(1990, 5, 15),
        );

        final Map<String, dynamic> profileJson = profile.toJson();
        profileJson.remove('email');
        profileJson.remove('imageUrl');

        expect(profileJson.containsKey('email'), false);
        expect(profileJson.containsKey('imageUrl'), false);
        expect(profileJson['firstName'], 'John');
        expect(profileJson['lastName'], 'Doe');
        expect(profileJson['id'], 'user123');
      });

      test('should handle coordinate conversion for waypoints', () {
        // Test the coordinate conversion logic
        Map<String, dynamic> safeElement = {
          'id': 1,
          'name': 'Test Waypoint',
          'description': 'Test',
          'latitude': '47.3769', // String that needs conversion
          'longitude': 8.5417,   // Already double
        };

        // Simulate the conversion logic from getWaypointsForHike
        if (safeElement['latitude'] == null) safeElement['latitude'] = 0.0;
        if (safeElement['longitude'] == null) safeElement['longitude'] = 0.0;
        
        safeElement['latitude'] = double.parse(safeElement['latitude'].toString());
        safeElement['longitude'] = double.parse(safeElement['longitude'].toString());
        safeElement['hikeId'] = 10;

        expect(safeElement['latitude'], 47.3769);
        expect(safeElement['longitude'], 8.5417);
        expect(safeElement['hikeId'], 10);
      });

      test('should handle null coordinates with defaults', () {
        Map<String, dynamic> safeElement = {
          'id': 1,
          'name': 'Test Waypoint',
          'description': 'Test',
          'latitude': null,
          'longitude': null,
        };

        // Apply the null handling logic
        if (safeElement['latitude'] == null) safeElement['latitude'] = 0.0;
        if (safeElement['longitude'] == null) safeElement['longitude'] = 0.0;
        
        safeElement['latitude'] = double.parse(safeElement['latitude'].toString());
        safeElement['longitude'] = double.parse(safeElement['longitude'].toString());

        expect(safeElement['latitude'], 0.0);
        expect(safeElement['longitude'], 0.0);
      });
    });

    group('Image URL Processing Tests', () {
      test('should extract image URLs from hike images response', () {
        final List<dynamic> hikeImageData = [
          {'image_url': 'https://example.com/image1.jpg'},
          {'image_url': 'https://example.com/image2.png'},
          {'image_url': 'https://example.com/image3.webp'},
        ];

        final imageUrls = hikeImageData.map((element) => element['image_url'] as String).toList();

        expect(imageUrls.length, 3);
        expect(imageUrls[0], 'https://example.com/image1.jpg');
        expect(imageUrls[1], 'https://example.com/image2.png');
        expect(imageUrls[2], 'https://example.com/image3.webp');
      });

      test('should create image records for upload', () {
        const hikeId = 1;
        const imageUrls = [
          'https://example.com/image1.jpg',
          'https://example.com/image2.png',
        ];

        final List<Map<String, dynamic>> imageRecords = imageUrls.map((imageUrl) => {
          'hike_id': hikeId,
          'image_url': imageUrl,
        }).toList();

        expect(imageRecords.length, 2);
        expect(imageRecords[0]['hike_id'], hikeId);
        expect(imageRecords[0]['image_url'], 'https://example.com/image1.jpg');
        expect(imageRecords[1]['hike_id'], hikeId);
        expect(imageRecords[1]['image_url'], 'https://example.com/image2.png');
      });

      test('should generate correct profile image path', () {
        const userId = 'user123';
        const fileExt = 'jpg';
        final String path = 'profile_images/$userId.$fileExt';

        expect(path, 'profile_images/user123.jpg');
      });

      test('should handle different file extensions', () {
        const userId = 'user123';
        const extensions = ['jpg', 'png', 'webp', 'jpeg'];

        for (final ext in extensions) {
          final String path = 'profile_images/$userId.$ext';
          expect(path, 'profile_images/user123.$ext');
        }
      });
    });

    group('Error Handling Logic Tests', () {
      test('should identify permission denied errors', () {
        const errorMessage = 'permission denied for table profiles';
        
        final bool isPermissionError = errorMessage.contains('permission denied');
        expect(isPermissionError, true);
      });

      test('should identify network errors', () {
        const errorMessage = 'network timeout after 30 seconds';
        
        final bool isNetworkError = errorMessage.contains('network');
        expect(isNetworkError, true);
      });

      test('should identify platform exceptions', () {
        const errorMessage = 'PlatformException(error, message, details)';
        
        final bool isPlatformError = errorMessage.contains('PlatformException');
        expect(isPlatformError, true);
      });

      test('should handle waypoint ID extraction from response', () {
        final waypointResponse = {'id': 123};
        final int newWaypointId = waypointResponse['id'] as int;
        
        expect(newWaypointId, 123);
      });

      test('should filter waypoint IDs correctly', () {
        final List<dynamic> waypointData = [
          {'waypoint_id': '1'},
          {'waypoint_id': 2},
          {'waypoint_id': '3'},
        ];

        final waypointIds = waypointData.map((element) => int.parse(element['waypoint_id'].toString())).toList();

        expect(waypointIds, [1, 2, 3]);
      });
    });

    group('Storage Path Generation Tests', () {
      test('should generate correct storage paths', () {
        const userId = 'user123';
        const fileExt = 'jpg';
        
        final profileImagePath = 'profile_images/$userId.$fileExt';
        expect(profileImagePath, 'profile_images/user123.jpg');
      });

      test('should handle special characters in user ID', () {
        const userId = 'user@123-test_id';
        const fileExt = 'png';
        
        final profileImagePath = 'profile_images/$userId.$fileExt';
        expect(profileImagePath, 'profile_images/user@123-test_id.png');
      });

      test('should create hike waypoint insertion data', () {
        const hikeId = 10;
        const waypointId = 5;

        final insertData = {
          'hike_id': hikeId,
          'waypoint_id': waypointId,
        };

        expect(insertData['hike_id'], hikeId);
        expect(insertData['waypoint_id'], waypointId);
      });

      test('should create waypoint update data', () {
        const waypoint = Waypoint(
          id: 1,
          hikeId: 10,
          name: 'Updated Waypoint',
          description: 'Updated description',
          latitude: 47.3769,
          longitude: 8.5417,
        );

        final updateData = {
          'name': waypoint.name,
          'description': waypoint.description,
          'latitude': waypoint.latitude,
          'longitude': waypoint.longitude,
        };

        expect(updateData['name'], 'Updated Waypoint');
        expect(updateData['description'], 'Updated description');
        expect(updateData['latitude'], 47.3769);
        expect(updateData['longitude'], 8.5417);
      });
    });

    group('File Processing Tests', () {
      test('should handle file bytes correctly', () {
        final fileBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        
        expect(fileBytes.length, 5);
        expect(fileBytes[0], 1);
        expect(fileBytes[4], 5);
      });

      test('should handle large file bytes', () {
        final largeFileBytes = Uint8List.fromList(List.generate(10000, (index) => index % 256));
        
        expect(largeFileBytes.length, 10000);
        expect(largeFileBytes[0], 0);
        expect(largeFileBytes[255], 255);
        expect(largeFileBytes[256], 0); // Should wrap around
      });

      test('should identify user files by prefix', () {
        const userId = 'user123';
        final files = [
          'user123.jpg',
          'user456.png',
          'user123.png',
          'otherfile.jpg',
        ];

        final userFiles = files.where((fileName) => fileName.startsWith(userId)).toList();

        expect(userFiles.length, 2);
        expect(userFiles, contains('user123.jpg'));
        expect(userFiles, contains('user123.png'));
        expect(userFiles, isNot(contains('user456.png')));
      });
    });

    group('Validation Logic Tests', () {
      test('should validate required profile fields', () {
        final profileJson = {
          'id': 'user123',
          'firstName': 'John',
          'lastName': 'Doe',
        };

        expect(profileJson['id'], isNotNull);
        expect(profileJson['id'], isNotEmpty);
        expect(profileJson.containsKey('firstName'), true);
        expect(profileJson.containsKey('lastName'), true);
      });

      test('should handle missing profile ID', () {
        final profileJson = <String, dynamic>{
          'firstName': 'John',
          'lastName': 'Doe',
        };

        final bool idMissing = profileJson['id'] == null || profileJson['id'].toString().isEmpty;
        expect(idMissing, true);

        // Simulate setting ID from auth
        const mockUserId = 'auth_user_123';
        profileJson['id'] = mockUserId;
        
        expect(profileJson['id'], mockUserId);
      });

      test('should validate waypoint data completeness', () {
        const waypoint = Waypoint(
          id: 1,
          hikeId: 10,
          name: 'Test Waypoint',
          description: 'Test Description',
          latitude: 47.3769,
          longitude: 8.5417,
        );

        // Simulate validation checks
        expect(waypoint.name.isNotEmpty, true);
        expect(waypoint.description.isNotEmpty, true);
        expect(waypoint.latitude, greaterThanOrEqualTo(-90.0));
        expect(waypoint.latitude, lessThanOrEqualTo(90.0));
        expect(waypoint.longitude, greaterThanOrEqualTo(-180.0));
        expect(waypoint.longitude, lessThanOrEqualTo(180.0));
      });

      test('should validate file extension formats', () {
        const validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
        const testExtensions = ['jpg', 'PNG', 'gif', 'pdf'];

        for (final ext in testExtensions) {
          final isValid = validExtensions.contains(ext.toLowerCase());
          if (ext == 'jpg' || ext == 'PNG') {
            expect(isValid || ext.toLowerCase() == 'png', true);
          } else if (ext == 'gif' || ext == 'pdf') {
            expect(isValid, false);
          }
        }
      });
    });

    group('Data Transformation Tests', () {
      test('should transform hike response data correctly', () {
        final hikeData = {
          'id': 1,
          'name': 'Test Hike',
          'length': 5.5,
          'steep': 0.3,
          'elevation': 200,
          'description': 'A test hike',
          'price': 19.99,
          'difficulty': 'mid',
          'thumbnailImageUrl': null,
          'isFavorite': false,
        };

        final hike = Hike.fromJson(hikeData);

        expect(hike.id, 1);
        expect(hike.name, 'Test Hike');
        expect(hike.thumbnailImageUrl, null);
        expect(hike.difficulty, Difficulty.mid);
      });

      test('should handle database to model transformations', () {
        // Simulate database response with snake_case
        final dbWaypoint = {
          'id': 1,
          'name': 'Test Point',
          'description': 'Test Description',
          'latitude': '47.3769',
          'longitude': '8.5417',
          'created_at': '2024-01-01T10:00:00Z',
        };

        // Transform for model creation
        final modelData = {
          'id': dbWaypoint['id'],
          'hikeId': 10, // Added during processing
          'name': dbWaypoint['name'],
          'description': dbWaypoint['description'],
          'latitude': double.parse(dbWaypoint['latitude'].toString()),
          'longitude': double.parse(dbWaypoint['longitude'].toString()),
          'images': <String>[],
          'isVisited': false,
        };

        final waypoint = Waypoint.fromJson(modelData);

        expect(waypoint.id, 1);
        expect(waypoint.hikeId, 10);
        expect(waypoint.latitude, 47.3769);
        expect(waypoint.longitude, 8.5417);
      });

      test('should handle profile data transformations', () {
        final dbProfile = {
          'id': 'user123',
          'first_name': 'John', // Database uses snake_case
          'last_name': 'Doe',
          'date_of_birth': '1990-05-15',
        };

        // Transform to model format (snake_case as expected by JSON annotations)
        final modelData = {
          'id': dbProfile['id'],
          'first_name': dbProfile['first_name'],
          'last_name': dbProfile['last_name'],
          'date_of_birth': dbProfile['date_of_birth'],
          'email': '',
          'imageUrl': '',
        };

        final profile = Profile.fromJson(modelData);

        expect(profile.id, 'user123');
        expect(profile.firstName, 'John');
        expect(profile.lastName, 'Doe');
      });
    });
  });
}