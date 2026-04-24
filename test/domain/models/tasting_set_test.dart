import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';

void main() {
  group('WhiskySample', () {
    test('should create WhiskySample with required fields', () {
      final sample = WhiskySample(
        id: 1,
        name: 'Highland Park 12',
        distillery: 'Highland Park',
        age: 12,
        region: 'Highland',
        tastingNotes: 'Honig, Vanille, leichte Rauchnoten',
        imageUrl: 'https://example.com/highland-park-12.jpg',
        abv: 43.0,
        category: 'Single Malt',
        sampleSizeMl: 5.0,
      );

      expect(sample.id, equals(1));
      expect(sample.name, equals('Highland Park 12'));
      expect(sample.distillery, equals('Highland Park'));
      expect(sample.age, equals(12));
      expect(sample.region, equals('Highland'));
      expect(sample.tastingNotes, equals('Honig, Vanille, leichte Rauchnoten'));
      expect(
        sample.imageUrl,
        equals('https://example.com/highland-park-12.jpg'),
      );
      expect(sample.abv, equals(43.0));
      expect(sample.category, equals('Single Malt'));
      expect(sample.sampleSizeMl, equals(5.0));
    });

    test('should create WhiskySample with default values', () {
      final sample = WhiskySample(
        id: 1,
        name: 'Test Whisky',
        distillery: 'Test Distillery',
        age: 10,
        region: 'Test Region',
        tastingNotes: 'Test notes',
        imageUrl: 'https://example.com/test.jpg',
        abv: 40.0,
      );

      expect(sample.sampleSizeMl, equals(5.0)); // Default value
      expect(sample.category, isNull); // Optional field
    });

    test('should convert WhiskySample to and from JSON', () {
      final sample = WhiskySample(
        id: 1,
        name: 'Highland Park 12',
        distillery: 'Highland Park',
        age: 12,
        region: 'Highland',
        tastingNotes: 'Honig, Vanille, leichte Rauchnoten',
        imageUrl: 'https://example.com/highland-park-12.jpg',
        abv: 43.0,
        category: 'Single Malt',
        sampleSizeMl: 5.0,
      );

      final json = sample.toJson();
      final fromJson = WhiskySample.fromJson(json);

      expect(fromJson, equals(sample));
    });

    test('should handle null optional fields in JSON', () {
      final sample = WhiskySample(
        id: 1,
        name: 'Test Whisky',
        distillery: 'Test Distillery',
        age: 10,
        region: 'Test Region',
        tastingNotes: 'Test notes',
        imageUrl: 'https://example.com/test.jpg',
        abv: 40.0,
        // category and sampleSizeMl are null/use defaults
      );

      final json = sample.toJson();
      expect(json['category'], isNull);
      expect(json['sample_size_ml'], equals(5.0)); // Default value
    });

    test('should test business logic extensions', () {
      final sample = WhiskySample(
        id: 1,
        name: 'Highland Park 12',
        distillery: 'Highland Park',
        age: 12,
        region: 'Highland',
        tastingNotes: 'Test notes',
        imageUrl: 'https://example.com/test.jpg',
        abv: 43.0,
        category: 'Single Malt',
        sampleSizeMl: 5.0,
      );

      expect(sample.formattedAge, equals('12 Jahre'));
      expect(sample.formattedAbv, equals('43.0%'));
      expect(sample.formattedSampleSize, equals('5ml'));
      expect(sample.hasCategory, isTrue);
      expect(sample.displayName, equals('Highland Park 12 (Highland Park)'));
      expect(sample.shortName, equals('Highland Park 12'));
    });
  });

  group('TastingSet', () {
    final sampleWhisky = WhiskySample(
      id: 1,
      name: 'Test Whisky',
      distillery: 'Test Distillery',
      age: 10,
      region: 'Test Region',
      tastingNotes: 'Test notes',
      imageUrl: 'https://example.com/test.jpg',
      abv: 40.0,
    );

    test('should create TastingSet with required fields', () {
      final tastingSet = TastingSet(
        id: 1,
        hikeId: 100,
        name: 'Highland Collection',
        description: 'Eine Auswahl der besten Highland Whiskys',
        samples: [sampleWhisky],
        price: 0.0, // Always 0 since it's included
        imageUrl: 'https://example.com/highland-collection.jpg',
      );

      expect(tastingSet.id, equals(1));
      expect(tastingSet.hikeId, equals(100));
      expect(tastingSet.name, equals('Highland Collection'));
      expect(
        tastingSet.description,
        equals('Eine Auswahl der besten Highland Whiskys'),
      );
      expect(tastingSet.samples, equals([sampleWhisky]));
      expect(tastingSet.price, equals(0.0)); // Always 0
      expect(
        tastingSet.imageUrl,
        equals('https://example.com/highland-collection.jpg'),
      );
    });

    test('should create TastingSet with default values', () {
      final tastingSet = TastingSet(
        id: 1,
        hikeId: 100,
        name: 'Test Set',
        description: 'Test description',
        samples: [sampleWhisky],
        // price defaults to 0.0
        imageUrl: 'https://example.com/test.jpg',
      );

      expect(tastingSet.price, equals(0.0)); // Default value
      expect(tastingSet.isIncluded, isTrue); // Default value
      expect(tastingSet.isAvailable, isTrue); // Default value
      expect(tastingSet.availableFrom, isNull); // Optional field
      expect(tastingSet.availableUntil, isNull); // Optional field
    });

    test('should handle empty samples list', () {
      final tastingSet = TastingSet(
        id: 1,
        hikeId: 100,
        name: 'Empty Set',
        description: 'No samples included',
        samples: [],
        price: 0.0,
        imageUrl: 'https://example.com/empty.jpg',
      );

      expect(tastingSet.samples, isEmpty);
      expect(tastingSet.price, equals(0.0));
    });

    test('should handle multiple samples', () {
      final sample1 = WhiskySample(
        id: 1,
        name: 'Whisky 1',
        distillery: 'Distillery 1',
        age: 10,
        region: 'Region 1',
        tastingNotes: 'Notes 1',
        imageUrl: 'https://example.com/1.jpg',
        abv: 40.0,
      );

      final sample2 = WhiskySample(
        id: 2,
        name: 'Whisky 2',
        distillery: 'Distillery 2',
        age: 12,
        region: 'Region 2',
        tastingNotes: 'Notes 2',
        imageUrl: 'https://example.com/2.jpg',
        abv: 43.0,
      );

      final tastingSet = TastingSet(
        id: 1,
        hikeId: 100,
        name: 'Multi Sample Set',
        description: 'Multiple samples',
        samples: [sample1, sample2],
        price: 0.0,
        imageUrl: 'https://example.com/multi.jpg',
      );

      expect(tastingSet.samples, hasLength(2));
      expect(tastingSet.samples.first, equals(sample1));
      expect(tastingSet.samples.last, equals(sample2));
    });

    test('should test business logic extensions', () {
      final tastingSet = TastingSet(
        id: 1,
        hikeId: 100,
        name: 'Test Set',
        description: 'Test description',
        samples: [sampleWhisky],
        price: 0.0,
        imageUrl: 'https://example.com/test.jpg',
      );

      expect(tastingSet.isCurrentlyAvailable, isTrue);
      expect(tastingSet.sampleCount, equals(1));
      expect(tastingSet.hasSamples, isTrue);
      expect(tastingSet.totalVolumeMl, equals(5.0));
      expect(
        tastingSet.formattedPrice,
        equals('Inklusive'),
      ); // Always "Inklusive"
      expect(tastingSet.shortDescription, equals('Test description'));
      expect(tastingSet.mainRegion, equals('Test Region'));
      expect(tastingSet.averageAge, equals(10.0));
      expect(tastingSet.averageAbv, equals(40.0));
    });

    test('should handle multiple samples with different regions', () {
      final sample1 = WhiskySample(
        id: 1,
        name: 'Whisky 1',
        distillery: 'Distillery 1',
        age: 10,
        region: 'Highland',
        tastingNotes: 'Notes 1',
        imageUrl: 'https://example.com/1.jpg',
        abv: 40.0,
      );

      final sample2 = WhiskySample(
        id: 2,
        name: 'Whisky 2',
        distillery: 'Distillery 2',
        age: 12,
        region: 'Highland', // Same region
        tastingNotes: 'Notes 2',
        imageUrl: 'https://example.com/2.jpg',
        abv: 43.0,
      );

      final sample3 = WhiskySample(
        id: 3,
        name: 'Whisky 3',
        distillery: 'Distillery 3',
        age: 15,
        region: 'Islay', // Different region
        tastingNotes: 'Notes 3',
        imageUrl: 'https://example.com/3.jpg',
        abv: 46.0,
      );

      final tastingSet = TastingSet(
        id: 1,
        hikeId: 100,
        name: 'Mixed Region Set',
        description: 'Mixed regions',
        samples: [sample1, sample2, sample3],
        price: 0.0,
        imageUrl: 'https://example.com/mixed.jpg',
      );

      expect(tastingSet.mainRegion, equals('Highland')); // Most common region
      expect(tastingSet.averageAge, closeTo(12.33, 0.01)); // (10 + 12 + 15) / 3
      expect(tastingSet.averageAbv, equals(43.0)); // (40 + 43 + 46) / 3
    });
  });
}
