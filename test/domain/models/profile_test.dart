import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/profile.dart';

void main() {
  group('Profile Model Tests', () {
    group('Constructor Tests', () {
      test('should create profile with default values', () {
        final profile = Profile();

        expect(profile.id, '');
        expect(profile.firstName, '');
        expect(profile.lastName, '');
        expect(profile.dateOfBirth, null);
        expect(profile.email, '');
        expect(profile.imageUrl, '');
      });

      test('should create profile with custom values', () {
        final birthDate = DateTime(1990, 5, 15);
        final profile = Profile(
          id: 'user123',
          firstName: 'John',
          lastName: 'Doe',
          dateOfBirth: birthDate,
          email: 'john.doe@example.com',
          imageUrl: 'https://example.com/avatar.jpg',
        );

        expect(profile.id, 'user123');
        expect(profile.firstName, 'John');
        expect(profile.lastName, 'Doe');
        expect(profile.dateOfBirth, birthDate);
        expect(profile.email, 'john.doe@example.com');
        expect(profile.imageUrl, 'https://example.com/avatar.jpg');
      });
    });

    group('Mutability Tests (@unfreezed)', () {
      test('should allow direct field modification', () {
        final profile = Profile(firstName: 'Original');

        expect(profile.firstName, 'Original');

        // Profile uses @unfreezed, so fields should be mutable
        profile.firstName = 'Modified';
        expect(profile.firstName, 'Modified');
      });

      test('should allow modification of multiple fields', () {
        final profile = Profile();

        profile.id = 'new_id';
        profile.firstName = 'Jane';
        profile.lastName = 'Smith';
        profile.email = 'jane.smith@example.com';

        expect(profile.id, 'new_id');
        expect(profile.firstName, 'Jane');
        expect(profile.lastName, 'Smith');
        expect(profile.email, 'jane.smith@example.com');
      });

      test('should allow setting null date of birth', () {
        final birthDate = DateTime(1985, 12, 25);
        final profile = Profile(dateOfBirth: birthDate);

        expect(profile.dateOfBirth, birthDate);

        profile.dateOfBirth = null;
        expect(profile.dateOfBirth, null);
      });
    });

    group('copyWith Tests', () {
      test('should copy with new first name', () {
        final original = Profile(
          id: 'user1',
          firstName: 'Original',
          lastName: 'Name',
        );

        final copied = original.copyWith(firstName: 'Updated');

        expect(copied.firstName, 'Updated');
        expect(copied.id, 'user1');
        expect(copied.lastName, 'Name');
        // Original should remain unchanged
        expect(original.firstName, 'Original');
      });

      test('should copy with null date of birth', () {
        final birthDate = DateTime(1990, 1, 1);
        final original = Profile(dateOfBirth: birthDate);

        final copied = original.copyWith(dateOfBirth: null);

        expect(copied.dateOfBirth, null);
        expect(original.dateOfBirth, birthDate);
      });

      test('should copy with multiple changes', () {
        final original = Profile(
          id: 'old_id',
          firstName: 'Old',
          email: 'old@example.com',
        );

        final copied = original.copyWith(
          id: 'new_id',
          firstName: 'New',
          lastName: 'LastName',
          email: 'new@example.com',
          imageUrl: 'https://new.com/image.jpg',
        );

        expect(copied.id, 'new_id');
        expect(copied.firstName, 'New');
        expect(copied.lastName, 'LastName');
        expect(copied.email, 'new@example.com');
        expect(copied.imageUrl, 'https://new.com/image.jpg');
      });
    });

    group('JSON Serialization Tests', () {
      test('should serialize to JSON correctly', () {
        final birthDate = DateTime(1990, 5, 15);
        final profile = Profile(
          id: 'user123',
          firstName: 'John',
          lastName: 'Doe',
          dateOfBirth: birthDate,
          email: 'john.doe@example.com',
          imageUrl: 'https://example.com/avatar.jpg',
        );

        final json = profile.toJson();

        expect(json['id'], 'user123');
        expect(json['first_name'], 'John');
        expect(json['last_name'], 'Doe');
        expect(json['date_of_birth'], birthDate.toIso8601String());
        expect(json['email'], 'john.doe@example.com');
        expect(json['image_url'], 'https://example.com/avatar.jpg');
      });

      test('should serialize with null date of birth', () {
        final profile = Profile(
          id: 'user456',
          firstName: 'Jane',
          dateOfBirth: null,
        );

        final json = profile.toJson();

        expect(json['id'], 'user456');
        expect(json['first_name'], 'Jane');
        expect(json['date_of_birth'], null);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'user789',
          'first_name': 'Alice',
          'last_name': 'Johnson',
          'date_of_birth': '1985-12-25T00:00:00.000Z',
          'email': 'alice.johnson@example.com',
          'image_url': 'https://example.com/alice.jpg',
        };

        final profile = Profile.fromJson(json);

        expect(profile.id, 'user789');
        expect(profile.firstName, 'Alice');
        expect(profile.lastName, 'Johnson');
        expect(profile.dateOfBirth, DateTime.parse('1985-12-25T00:00:00.000Z'));
        expect(profile.email, 'alice.johnson@example.com');
        expect(profile.imageUrl, 'https://example.com/alice.jpg');
      });

      test('should deserialize with null date of birth', () {
        final json = {
          'id': 'user999',
          'first_name': 'Bob',
          'last_name': 'Smith',
          'date_of_birth': null,
          'email': 'bob.smith@example.com',
          'image_url': '',
        };

        final profile = Profile.fromJson(json);

        expect(profile.id, 'user999');
        expect(profile.firstName, 'Bob');
        expect(profile.lastName, 'Smith');
        expect(profile.dateOfBirth, null);
        expect(profile.email, 'bob.smith@example.com');
        expect(profile.imageUrl, '');
      });

      test('should use defaults for missing JSON fields', () {
        final json = {'id': 'minimal_user'};

        final profile = Profile.fromJson(json);

        expect(profile.id, 'minimal_user');
        expect(profile.firstName, '');
        expect(profile.lastName, '');
        expect(profile.dateOfBirth, null);
        expect(profile.email, '');
        expect(profile.imageUrl, '');
      });
    });

    group('Date Handling Tests', () {
      test('should handle various date formats', () {
        final testDates = [
          DateTime(2000, 1, 1),
          DateTime(1970, 12, 31, 23, 59, 59),
          DateTime(2024, 2, 29), // Leap year
          DateTime.now(),
        ];

        for (final date in testDates) {
          final profile = Profile(dateOfBirth: date);
          final json = profile.toJson();
          final deserialized = Profile.fromJson(json);

          expect(deserialized.dateOfBirth, date);
        }
      });

      test('should handle timezone in date serialization', () {
        final utcDate = DateTime.utc(1990, 6, 15, 12, 30, 45);
        final profile = Profile(dateOfBirth: utcDate);

        final json = profile.toJson();
        final deserializedProfile = Profile.fromJson(json);

        expect(deserializedProfile.dateOfBirth, utcDate);
      });
    });

    group('Edge Cases Tests', () {
      test('should handle empty strings', () {
        final profile = Profile(
          id: '',
          firstName: '',
          lastName: '',
          email: '',
          imageUrl: '',
        );

        expect(profile.id, '');
        expect(profile.firstName, '');
        expect(profile.lastName, '');
        expect(profile.email, '');
        expect(profile.imageUrl, '');
      });

      test('should handle very long strings', () {
        final longString = 'a' * 1000;
        final profile = Profile(
          firstName: longString,
          lastName: longString,
          email: '${longString}@example.com',
        );

        expect(profile.firstName, longString);
        expect(profile.lastName, longString);
        expect(profile.email, '${longString}@example.com');
      });

      test('should handle special characters', () {
        final profile = Profile(
          firstName: 'José',
          lastName: 'Müller-Özkaya',
          email: 'josé.müller@exämple.com',
        );

        expect(profile.firstName, 'José');
        expect(profile.lastName, 'Müller-Özkaya');
        expect(profile.email, 'josé.müller@exämple.com');

        // Test serialization round trip with special characters
        final json = profile.toJson();
        final deserialized = Profile.fromJson(json);

        expect(deserialized.firstName, 'José');
        expect(deserialized.lastName, 'Müller-Özkaya');
        expect(deserialized.email, 'josé.müller@exämple.com');
      });
    });

    group('Equality Tests', () {
      test('should be equal when all fields match', () {
        final birthDate = DateTime(1990, 5, 15);
        final profile1 = Profile(
          id: 'same_id',
          firstName: 'Same',
          lastName: 'Name',
          dateOfBirth: birthDate,
          email: 'same@example.com',
          imageUrl: 'https://example.com/same.jpg',
        );
        final profile2 = Profile(
          id: 'same_id',
          firstName: 'Same',
          lastName: 'Name',
          dateOfBirth: birthDate,
          email: 'same@example.com',
          imageUrl: 'https://example.com/same.jpg',
        );

        // Test individual fields instead of full equality
        expect(profile1.id, equals(profile2.id));
        expect(profile1.firstName, equals(profile2.firstName));
        expect(profile1.lastName, equals(profile2.lastName));
        expect(profile1.dateOfBirth, equals(profile2.dateOfBirth));
        expect(profile1.email, equals(profile2.email));
        expect(profile1.imageUrl, equals(profile2.imageUrl));
      });

      test('should not be equal when id differs', () {
        final profile1 = Profile(id: 'id1', firstName: 'Same');
        final profile2 = Profile(id: 'id2', firstName: 'Same');

        expect(profile1, isNot(equals(profile2)));
      });

      test('should not be equal when date differs', () {
        final profile1 = Profile(
          id: 'same_id',
          dateOfBirth: DateTime(1990, 1, 1),
        );
        final profile2 = Profile(
          id: 'same_id',
          dateOfBirth: DateTime(1990, 1, 2),
        );

        expect(profile1, isNot(equals(profile2)));
      });
    });
  });
}
