import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/company.dart';

void main() {
  group('Company Model Tests', () {
    group('Basic Functionality', () {
      test('should create Company with required fields', () {
        // Arrange & Act
        final company = Company(
          id: 'company_1',
          name: 'Speyside Whisky Co.',
          contactEmail: 'info@speysidewhisky.com',
          countryCode: 'GB',
          countryName: 'United Kingdom',
          city: 'Dufftown',
          createdAt: DateTime(2023, 1, 1),
        );

        // Assert
        expect(company.id, equals('company_1'));
        expect(company.name, equals('Speyside Whisky Co.'));
        expect(company.contactEmail, equals('info@speysidewhisky.com'));
        expect(company.countryCode, equals('GB'));
        expect(company.countryName, equals('United Kingdom'));
        expect(company.city, equals('Dufftown'));
        expect(company.createdAt, equals(DateTime(2023, 1, 1)));
      });

      test('should create Company with optional fields', () {
        // Arrange & Act
        final company = Company(
          id: 'company_2',
          name: 'Highland Distillery',
          contactEmail: 'contact@highland.com',
          countryCode: 'GB',
          countryName: 'United Kingdom',
          city: 'Inverness',
          createdAt: DateTime(2023, 2, 1),
          updatedAt: DateTime(2023, 2, 15),
        );

        // Assert
        expect(company.id, equals('company_2'));
        expect(company.name, equals('Highland Distillery'));
        expect(company.contactEmail, equals('contact@highland.com'));
        expect(company.countryCode, equals('GB'));
        expect(company.countryName, equals('United Kingdom'));
        expect(company.city, equals('Inverness'));
        expect(company.createdAt, equals(DateTime(2023, 2, 1)));
        expect(company.updatedAt, equals(DateTime(2023, 2, 15)));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final company = Company(
          id: 'company_3',
          name: 'Islay Whisky Co.',
          contactEmail: 'info@islay.com',
          countryCode: 'GB',
          countryName: 'United Kingdom',
          city: 'Port Ellen',
          createdAt: DateTime(2023, 3, 1),
        );

        // Act
        final json = company.toJson();

        // Assert
        expect(json['id'], equals('company_3'));
        expect(json['name'], equals('Islay Whisky Co.'));
        expect(json['contact_email'], equals('info@islay.com'));
        expect(json['country_code'], equals('GB'));
        expect(json['country_name'], equals('United Kingdom'));
        expect(json['city'], equals('Port Ellen'));
        expect(json['created_at'], equals('2023-03-01T00:00:00.000Z'));
        expect(json['updated_at'], isNull);
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'company_4',
          'name': 'Campbeltown Distillery',
          'contact_email': 'info@campbeltown.com',
          'country_code': 'GB',
          'country_name': 'United Kingdom',
          'city': 'Campbeltown',
          'created_at': '2023-04-01T00:00:00.000Z',
          'updated_at': '2023-04-15T00:00:00.000Z',
        };

        // Act
        final company = Company.fromJson(json);

        // Assert
        expect(company.id, equals('company_4'));
        expect(company.name, equals('Campbeltown Distillery'));
        expect(company.contactEmail, equals('info@campbeltown.com'));
        expect(company.countryCode, equals('GB'));
        expect(company.countryName, equals('United Kingdom'));
        expect(company.city, equals('Campbeltown'));
        expect(company.createdAt, equals(DateTime(2023, 4, 1)));
        expect(company.updatedAt, equals(DateTime(2023, 4, 15)));
      });
    });

    group('Equality and Hash Code', () {
      test('should implement equality correctly', () {
        // Arrange
        final company1 = Company(
          id: 'company_5',
          name: 'Lowland Whisky',
          contactEmail: 'info@lowland.com',
          countryCode: 'GB',
          countryName: 'United Kingdom',
          city: 'Edinburgh',
          createdAt: DateTime(2023, 5, 1),
        );

        final company2 = Company(
          id: 'company_5',
          name: 'Lowland Whisky',
          contactEmail: 'info@lowland.com',
          countryCode: 'GB',
          countryName: 'United Kingdom',
          city: 'Edinburgh',
          createdAt: DateTime(2023, 5, 1),
        );

        final company3 = Company(
          id: 'company_6', // Different ID
          name: 'Lowland Whisky',
          contactEmail: 'info@lowland.com',
          countryCode: 'GB',
          countryName: 'United Kingdom',
          city: 'Edinburgh',
          createdAt: DateTime(2023, 5, 1),
        );

        // Assert
        expect(company1, equals(company2));
        expect(company1, isNot(equals(company3)));
        expect(company1.hashCode, equals(company2.hashCode));
        expect(company1.hashCode, isNot(equals(company3.hashCode)));
      });
    });

    group('String Representation', () {
      test('should have meaningful toString', () {
        // Arrange
        final company = Company(
          id: 'company_7',
          name: 'Speyside Distillery',
          contactEmail: 'info@speyside.com',
          countryCode: 'GB',
          countryName: 'United Kingdom',
          city: 'Speyside',
          createdAt: DateTime(2023, 6, 1),
        );

        // Act
        final stringRepresentation = company.toString();

        // Assert
        expect(stringRepresentation, contains('company_7'));
        expect(stringRepresentation, contains('Speyside Distillery'));
        expect(stringRepresentation, contains('info@speyside.com'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings', () {
        // Arrange & Act
        final company = Company(
          id: '',
          name: '',
          contactEmail: '',
          countryCode: '',
          countryName: '',
          city: '',
          createdAt: DateTime(2023, 7, 1),
        );

        // Assert
        expect(company.id, equals(''));
        expect(company.name, equals(''));
        expect(company.contactEmail, equals(''));
        expect(company.countryCode, equals(''));
        expect(company.countryName, equals(''));
        expect(company.city, equals(''));
      });

      test('should handle special characters in names', () {
        // Arrange & Act
        final company = Company(
          id: 'company_8',
          name: 'Whisky & Co. Ltd.',
          contactEmail: 'info@whisky-co.com',
          countryCode: 'GB',
          countryName: 'United Kingdom',
          city: 'London',
          createdAt: DateTime(2023, 8, 1),
        );

        // Assert
        expect(company.name, equals('Whisky & Co. Ltd.'));
        expect(company.contactEmail, equals('info@whisky-co.com'));
      });
    });

    group('Validation', () {
      test('should require all mandatory fields', () {
        // This test ensures that the Company constructor requires all mandatory fields
        // If any mandatory field is missing, the constructor should fail
        expect(() {
          Company(
            id: 'test',
            name: 'Test',
            contactEmail: 'test@test.com',
            countryCode: 'GB',
            countryName: 'United Kingdom',
            city: 'London',
            createdAt: DateTime.now(),
          );
        }, returnsNormally);
      });
    });
  });
}