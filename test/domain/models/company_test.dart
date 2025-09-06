import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/company.dart';

void main() {
  group('Company Model Tests', () {
    group('Constructor and Default Values', () {
      test('should create company with required fields', () {
        final company = Company(
          id: 'company_123',
          name: 'Highland Distilleries Ltd.',
          contactEmail: 'info@highland.com',
          countryCode: 'GB',
          countryName: 'United Kingdom',
          city: 'Edinburgh',
          createdAt: DateTime.now(),
        );

        expect(company.id, equals('company_123'));
        expect(company.name, equals('Highland Distilleries Ltd.'));
        expect(company.contactEmail, equals('info@highland.com'));
        expect(company.countryCode, equals('GB'));
        expect(company.countryName, equals('United Kingdom'));
        expect(company.city, equals('Edinburgh'));
        expect(company.description, isNull);
        expect(company.logoUrl, isNull);
        expect(company.websiteUrl, isNull);
        expect(company.phone, isNull);
        expect(company.isActive, isTrue);
        expect(company.isVerified, isFalse);
      });

      test('should create company with all fields', () {
        final company = Company(
          id: 'company_456',
          name: 'Speyside Whisky Co.',
          description: 'Premium whisky experiences in the Scottish Highlands',
          logoUrl: 'https://example.com/logo.png',
          website: 'https://speysidewhisky.com',
          contactEmail: 'info@speysidewhisky.com',
          contactPhone: '+44 1234 567890',
          address: {
            'street': '123 Whisky Lane',
            'city': 'Dufftown',
            'country': 'Scotland',
            'postalCode': 'AB55 4BR'
          },
          foundedYear: 1887,
          isActive: true,
        );

        expect(company.id, equals('company_456'));
        expect(company.name, equals('Speyside Whisky Co.'));
        expect(company.description, equals('Premium whisky experiences in the Scottish Highlands'));
        expect(company.logoUrl, equals('https://example.com/logo.png'));
        expect(company.website, equals('https://speysidewhisky.com'));
        expect(company.contactEmail, equals('info@speysidewhisky.com'));
        expect(company.contactPhone, equals('+44 1234 567890'));
        expect(company.address!['city'], equals('Dufftown'));
        expect(company.foundedYear, equals(1887));
        expect(company.isActive, isTrue);
      });

      test('should create inactive company', () {
        const company = Company(
          id: 'inactive_company',
          name: 'Closed Distillery',
          isActive: false,
        );

        expect(company.isActive, isFalse);
      });
    });

    group('copyWith Tests', () {
      const baseCompany = Company(
        id: 'base_company',
        name: 'Base Company',
        description: 'Original description',
        isActive: true,
      );

      test('should copy with new name', () {
        final updatedCompany = baseCompany.copyWith(name: 'Updated Company Name');

        expect(updatedCompany.id, equals(baseCompany.id));
        expect(updatedCompany.name, equals('Updated Company Name'));
        expect(updatedCompany.description, equals(baseCompany.description));
        expect(updatedCompany.isActive, equals(baseCompany.isActive));
      });

      test('should copy with new description', () {
        final updatedCompany = baseCompany.copyWith(
          description: 'New comprehensive description',
        );

        expect(updatedCompany.description, equals('New comprehensive description'));
        expect(updatedCompany.name, equals(baseCompany.name));
      });

      test('should copy with new contact details', () {
        final updatedCompany = baseCompany.copyWith(
          contactEmail: 'new@company.com',
          contactPhone: '+44 9876 543210',
          website: 'https://newcompany.com',
        );

        expect(updatedCompany.contactEmail, equals('new@company.com'));
        expect(updatedCompany.contactPhone, equals('+44 9876 543210'));
        expect(updatedCompany.website, equals('https://newcompany.com'));
        expect(updatedCompany.id, equals(baseCompany.id));
        expect(updatedCompany.name, equals(baseCompany.name));
      });

      test('should copy with new address', () {
        final newAddress = {
          'street': '456 New Street',
          'city': 'Glasgow',
          'country': 'Scotland',
        };

        final updatedCompany = baseCompany.copyWith(address: newAddress);

        expect(updatedCompany.address, equals(newAddress));
        expect(updatedCompany.address!['city'], equals('Glasgow'));
      });

      test('should copy with active status change', () {
        final inactiveCompany = baseCompany.copyWith(isActive: false);

        expect(inactiveCompany.isActive, isFalse);
        expect(inactiveCompany.id, equals(baseCompany.id));
        expect(inactiveCompany.name, equals(baseCompany.name));
      });

      test('should copy with multiple changes', () {
        final multiUpdatedCompany = baseCompany.copyWith(
          name: 'Multi Update Co.',
          description: 'Updated with multiple changes',
          foundedYear: 1950,
          logoUrl: 'https://example.com/new-logo.png',
          isActive: false,
        );

        expect(multiUpdatedCompany.name, equals('Multi Update Co.'));
        expect(multiUpdatedCompany.description, equals('Updated with multiple changes'));
        expect(multiUpdatedCompany.foundedYear, equals(1950));
        expect(multiUpdatedCompany.logoUrl, equals('https://example.com/new-logo.png'));
        expect(multiUpdatedCompany.isActive, isFalse);
        expect(multiUpdatedCompany.id, equals(baseCompany.id));
      });
    });

    group('JSON Serialization Tests', () {
      test('should serialize to JSON correctly', () {
        final company = Company(
          id: 'json_company',
          name: 'JSON Test Company',
          description: 'A company for JSON testing',
          logoUrl: 'https://example.com/json-logo.png',
          website: 'https://jsontest.com',
          contactEmail: 'test@json.com',
          contactPhone: '+1 555-0123',
          address: {
            'street': '123 JSON St',
            'city': 'Test City',
            'state': 'TS',
            'country': 'Testland',
            'postalCode': '12345'
          },
          foundedYear: 2000,
          isActive: true,
        );

        final json = company.toJson();

        expect(json['id'], equals('json_company'));
        expect(json['name'], equals('JSON Test Company'));
        expect(json['description'], equals('A company for JSON testing'));
        expect(json['logo_url'], equals('https://example.com/json-logo.png'));
        expect(json['website'], equals('https://jsontest.com'));
        expect(json['contact_email'], equals('test@json.com'));
        expect(json['contact_phone'], equals('+1 555-0123'));
        expect(json['address']['city'], equals('Test City'));
        expect(json['founded_year'], equals(2000));
        expect(json['is_active'], isTrue);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'from_json_company',
          'name': 'From JSON Company',
          'description': 'Deserialized from JSON',
          'logo_url': 'https://example.com/from-json.png',
          'website': 'https://fromjson.com',
          'contact_email': 'contact@fromjson.com',
          'contact_phone': '+44 1234 567890',
          'address': {
            'street': '456 From JSON Ave',
            'city': 'JSON City',
            'country': 'JSONland'
          },
          'founded_year': 1995,
          'is_active': false,
        };

        final company = Company.fromJson(json);

        expect(company.id, equals('from_json_company'));
        expect(company.name, equals('From JSON Company'));
        expect(company.description, equals('Deserialized from JSON'));
        expect(company.logoUrl, equals('https://example.com/from-json.png'));
        expect(company.website, equals('https://fromjson.com'));
        expect(company.contactEmail, equals('contact@fromjson.com'));
        expect(company.contactPhone, equals('+44 1234 567890'));
        expect(company.address!['city'], equals('JSON City'));
        expect(company.foundedYear, equals(1995));
        expect(company.isActive, isFalse);
      });

      test('should handle null fields in JSON', () {
        final json = {
          'id': 'minimal_company',
          'name': 'Minimal Company',
          'description': null,
          'logo_url': null,
          'website': null,
          'contact_email': null,
          'contact_phone': null,
          'address': null,
          'founded_year': null,
          'is_active': true,
        };

        final company = Company.fromJson(json);

        expect(company.id, equals('minimal_company'));
        expect(company.name, equals('Minimal Company'));
        expect(company.description, isNull);
        expect(company.logoUrl, isNull);
        expect(company.website, isNull);
        expect(company.contactEmail, isNull);
        expect(company.contactPhone, isNull);
        expect(company.address, isNull);
        expect(company.foundedYear, isNull);
        expect(company.isActive, isTrue);
      });

      test('should use defaults for missing JSON fields', () {
        final json = {
          'id': 'defaults_company',
          'name': 'Defaults Company',
        };

        final company = Company.fromJson(json);

        expect(company.id, equals('defaults_company'));
        expect(company.name, equals('Defaults Company'));
        expect(company.isActive, isTrue); // Default value
      });

      test('should roundtrip JSON serialization', () {
        const originalCompany = Company(
          id: 'roundtrip_test',
          name: 'Roundtrip Test Co.',
          description: 'Testing JSON roundtrip',
          foundedYear: 1888,
          isActive: true,
        );

        final json = originalCompany.toJson();
        final deserializedCompany = Company.fromJson(json);

        expect(deserializedCompany, equals(originalCompany));
      });
    });

    group('Address Handling Tests', () {
      test('should handle complex address structure', () {
        final complexAddress = {
          'street': '789 Complex Street',
          'unit': 'Suite 100',
          'city': 'Complex City',
          'state': 'CC',
          'country': 'Complexland',
          'postalCode': '54321',
          'coordinates': {
            'latitude': 55.8642,
            'longitude': -4.2518,
          },
        };

        final company = Company(
          id: 'complex_address_company',
          name: 'Complex Address Co.',
          address: complexAddress,
        );

        expect(company.address!['street'], equals('789 Complex Street'));
        expect(company.address!['unit'], equals('Suite 100'));
        expect(company.address!['coordinates']['latitude'], equals(55.8642));
      });

      test('should handle empty address', () {
        final company = Company(
          id: 'empty_address_company',
          name: 'Empty Address Co.',
          address: const {},
        );

        expect(company.address, isNotNull);
        expect(company.address, isEmpty);
      });
    });

    group('Business Logic Extensions', () {
      test('should identify active companies', () {
        const activeCompany = Company(
          id: 'active_co',
          name: 'Active Company',
          isActive: true,
        );

        const inactiveCompany = Company(
          id: 'inactive_co',
          name: 'Inactive Company',
          isActive: false,
        );

        expect(activeCompany.isActive, isTrue);
        expect(inactiveCompany.isActive, isFalse);
      });

      test('should handle contact information availability', () {
        const companyWithContact = Company(
          id: 'contact_co',
          name: 'Contact Company',
          contactEmail: 'info@contact.com',
          contactPhone: '+1 555-0199',
        );

        const companyWithoutContact = Company(
          id: 'no_contact_co',
          name: 'No Contact Company',
        );

        expect(companyWithContact.contactEmail, isNotNull);
        expect(companyWithContact.contactPhone, isNotNull);
        expect(companyWithoutContact.contactEmail, isNull);
        expect(companyWithoutContact.contactPhone, isNull);
      });

      test('should handle company age calculation', () {
        final currentYear = DateTime.now().year;
        final foundedYear = currentYear - 50;

        final company = Company(
          id: 'aged_company',
          name: 'Aged Company',
          foundedYear: foundedYear,
        );

        expect(company.foundedYear, equals(foundedYear));
        // Age would be approximately 50 years (calculated by extensions if needed)
      });
    });

    group('Equality Tests', () {
      test('should be equal when all fields match', () {
        const company1 = Company(
          id: 'same_company',
          name: 'Same Company',
          description: 'Same description',
          isActive: true,
        );

        const company2 = Company(
          id: 'same_company',
          name: 'Same Company',
          description: 'Same description',
          isActive: true,
        );

        expect(company1, equals(company2));
        expect(company1.hashCode, equals(company2.hashCode));
      });

      test('should not be equal when id differs', () {
        const company1 = Company(
          id: 'company_1',
          name: 'Same Company',
        );

        const company2 = Company(
          id: 'company_2',
          name: 'Same Company',
        );

        expect(company1, isNot(equals(company2)));
      });

      test('should not be equal when fields differ', () {
        const company1 = Company(
          id: 'same_id',
          name: 'Company One',
          isActive: true,
        );

        const company2 = Company(
          id: 'same_id',
          name: 'Company Two',
          isActive: false,
        );

        expect(company1, isNot(equals(company2)));
      });
    });

    group('Edge Cases', () {
      test('should handle very long company names', () {
        final longName = 'A' * 200;
        final company = Company(
          id: 'long_name_company',
          name: longName,
        );

        expect(company.name.length, equals(200));
        expect(company.name, equals(longName));
      });

      test('should handle special characters in company data', () {
        const company = Company(
          id: 'special_chars_company',
          name: 'Spëcîål Çhäracters & Símböls Ltd. ñ',
          description: 'Company with spëcîål çhäracters & symbols: @#\$%^&*()',
          contactEmail: 'info@spëcîål-company.com',
        );

        expect(company.name, contains('Spëcîål'));
        expect(company.description, contains('@#\$%^&*()'));
        expect(company.contactEmail, contains('spëcîål'));
      });

      test('should handle future founded years', () {
        final futureYear = DateTime.now().year + 10;
        final company = Company(
          id: 'future_company',
          name: 'Future Company',
          foundedYear: futureYear,
        );

        expect(company.foundedYear, equals(futureYear));
      });

      test('should handle very old founded years', () {
        const oldYear = 1600;
        const company = Company(
          id: 'old_company',
          name: 'Very Old Company',
          foundedYear: oldYear,
        );

        expect(company.foundedYear, equals(oldYear));
      });
    });
  });
}