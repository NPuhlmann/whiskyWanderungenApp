import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/profile.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';

class TestHelpers {
  static List<Hike> createSampleHikes() {
    return [
      const Hike(
        id: 1,
        name: 'Alpine Adventure',
        length: 8.5,
        steep: 0.6,
        elevation: 800,
        description: 'A challenging mountain hike with spectacular views',
        price: 29.99,
        difficulty: Difficulty.hard,
        thumbnailImageUrl: 'https://example.com/alpine.jpg',
        isFavorite: false,
      ),
      const Hike(
        id: 2,
        name: 'Forest Walk',
        length: 3.2,
        steep: 0.1,
        elevation: 100,
        description: 'A gentle walk through beautiful forest paths',
        price: 12.99,
        difficulty: Difficulty.easy,
        thumbnailImageUrl: 'https://example.com/forest.jpg',
        isFavorite: true,
      ),
      const Hike(
        id: 3,
        name: 'Valley Trail',
        length: 5.8,
        steep: 0.3,
        elevation: 300,
        description: 'Moderate hike through scenic valley landscapes',
        price: 19.99,
        difficulty: Difficulty.mid,
        thumbnailImageUrl: null,
        isFavorite: false,
      ),
      const Hike(
        id: 4,
        name: 'Peak Challenger',
        length: 12.4,
        steep: 0.8,
        elevation: 1200,
        description: 'Extreme hike for experienced adventurers only',
        price: 49.99,
        difficulty: Difficulty.veryHard,
        thumbnailImageUrl: 'https://example.com/peak.jpg',
        isFavorite: true,
      ),
    ];
  }

  static List<Waypoint> createSampleWaypoints(int hikeId) {
    return [
      Waypoint(
        id: 1,
        hikeId: hikeId,
        name: 'Trailhead',
        description: 'Starting point of the hike with parking area',
        latitude: 47.3769,
        longitude: 8.5417,
        images: ['trailhead1.jpg', 'trailhead2.jpg'],
        isVisited: false,
      ),
      Waypoint(
        id: 2,
        hikeId: hikeId,
        name: 'Scenic Overlook',
        description: 'Beautiful viewpoint overlooking the valley',
        latitude: 47.3800,
        longitude: 8.5450,
        images: ['overlook1.jpg', 'overlook2.jpg', 'overlook3.jpg'],
        isVisited: false,
      ),
      Waypoint(
        id: 3,
        hikeId: hikeId,
        name: 'Rest Area',
        description: 'Perfect spot for a break with benches and shelter',
        latitude: 47.3830,
        longitude: 8.5480,
        images: [],
        isVisited: true,
      ),
      Waypoint(
        id: 4,
        hikeId: hikeId,
        name: 'Summit',
        description: 'The highest point of the hike with panoramic views',
        latitude: 47.3860,
        longitude: 8.5510,
        images: ['summit1.jpg', 'summit2.jpg'],
        isVisited: false,
      ),
    ];
  }

  static List<Profile> createSampleProfiles() {
    return [
      Profile(
        id: 'user1',
        firstName: 'John',
        lastName: 'Doe',
        dateOfBirth: DateTime(1990, 5, 15),
        email: 'john.doe@example.com',
        imageUrl: 'https://example.com/john.jpg',
      ),
      Profile(
        id: 'user2',
        firstName: 'Jane',
        lastName: 'Smith',
        dateOfBirth: DateTime(1985, 12, 20),
        email: 'jane.smith@example.com',
        imageUrl: 'https://example.com/jane.jpg',
      ),
      Profile(
        id: 'user3',
        firstName: 'Bob',
        lastName: 'Wilson',
        dateOfBirth: DateTime(1992, 8, 10),
        email: 'bob.wilson@example.com',
        imageUrl: '',
      ),
      Profile(
        id: 'user4',
        firstName: '',
        lastName: '',
        dateOfBirth: null,
        email: 'empty@example.com',
        imageUrl: '',
      ),
    ];
  }

  static Profile createTestProfile({
    String id = 'test_user',
    String firstName = 'Test',
    String lastName = 'User',
    DateTime? dateOfBirth,
    String email = 'test@example.com',
    String imageUrl = '',
  }) {
    return Profile(
      id: id,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      email: email,
      imageUrl: imageUrl,
    );
  }

  static Hike createTestHike({
    int id = 1,
    String name = 'Test Hike',
    double length = 5.0,
    double steep = 0.3,
    int elevation = 200,
    String description = 'A test hike',
    double price = 19.99,
    Difficulty difficulty = Difficulty.mid,
    String? thumbnailImageUrl,
    bool isFavorite = false,
  }) {
    return Hike(
      id: id,
      name: name,
      length: length,
      steep: steep,
      elevation: elevation,
      description: description,
      price: price,
      difficulty: difficulty,
      thumbnailImageUrl: thumbnailImageUrl,
      isFavorite: isFavorite,
    );
  }

  static Waypoint createTestWaypoint({
    int id = 1,
    int hikeId = 1,
    String name = 'Test Waypoint',
    String description = 'A test waypoint',
    double latitude = 47.3769,
    double longitude = 8.5417,
    List<String> images = const [],
    bool isVisited = false,
  }) {
    return Waypoint(
      id: id,
      hikeId: hikeId,
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      images: images,
      isVisited: isVisited,
    );
  }

  /// Creates hikes with specific difficulty distributions for testing
  static List<Hike> createHikesByDifficulty() {
    return [
      createTestHike(id: 1, name: 'Easy Hike 1', difficulty: Difficulty.easy),
      createTestHike(id: 2, name: 'Easy Hike 2', difficulty: Difficulty.easy),
      createTestHike(id: 3, name: 'Mid Hike 1', difficulty: Difficulty.mid),
      createTestHike(id: 4, name: 'Mid Hike 2', difficulty: Difficulty.mid),
      createTestHike(id: 5, name: 'Hard Hike 1', difficulty: Difficulty.hard),
      createTestHike(id: 6, name: 'Very Hard Hike 1', difficulty: Difficulty.veryHard),
    ];
  }

  /// Creates waypoints at various geographical locations
  static List<Waypoint> createWaypointsAtDifferentLocations(int hikeId) {
    return [
      createTestWaypoint(
        id: 1,
        hikeId: hikeId,
        name: 'Zurich Point',
        latitude: 47.3769,
        longitude: 8.5417,
      ),
      createTestWaypoint(
        id: 2,
        hikeId: hikeId,
        name: 'Bern Point',
        latitude: 46.9481,
        longitude: 7.4474,
      ),
      createTestWaypoint(
        id: 3,
        hikeId: hikeId,
        name: 'Geneva Point',
        latitude: 46.2044,
        longitude: 6.1432,
      ),
      createTestWaypoint(
        id: 4,
        hikeId: hikeId,
        name: 'Basel Point',
        latitude: 47.5596,
        longitude: 7.5886,
      ),
    ];
  }

  /// Creates profiles representing different user types
  static List<Profile> createDiverseProfiles() {
    final birthDates = [
      DateTime(1980, 1, 1), // Older user
      DateTime(1995, 6, 15), // Mid-age user
      DateTime(2000, 12, 31), // Younger user
      null, // User without birthdate
    ];

    return [
      createTestProfile(
        id: 'complete_user',
        firstName: 'Complete',
        lastName: 'User',
        dateOfBirth: birthDates[0],
        email: 'complete@example.com',
        imageUrl: 'https://example.com/complete.jpg',
      ),
      createTestProfile(
        id: 'partial_user',
        firstName: 'Partial',
        lastName: '',
        dateOfBirth: birthDates[1],
        email: 'partial@example.com',
        imageUrl: '',
      ),
      createTestProfile(
        id: 'minimal_user',
        firstName: '',
        lastName: '',
        dateOfBirth: null,
        email: 'minimal@example.com',
        imageUrl: '',
      ),
      createTestProfile(
        id: 'special_char_user',
        firstName: 'José',
        lastName: 'Müller-Özkaya',
        dateOfBirth: birthDates[2],
        email: 'josé.müller@exämple.com',
        imageUrl: 'https://example.com/josé.jpg',
      ),
    ];
  }

  /// Utility methods for test assertions
  static bool areHikesEqual(Hike hike1, Hike hike2) {
    return hike1.id == hike2.id &&
        hike1.name == hike2.name &&
        hike1.length == hike2.length &&
        hike1.steep == hike2.steep &&
        hike1.elevation == hike2.elevation &&
        hike1.description == hike2.description &&
        hike1.price == hike2.price &&
        hike1.difficulty == hike2.difficulty &&
        hike1.thumbnailImageUrl == hike2.thumbnailImageUrl &&
        hike1.isFavorite == hike2.isFavorite;
  }

  static bool areWaypointsEqual(Waypoint waypoint1, Waypoint waypoint2) {
    return waypoint1.id == waypoint2.id &&
        waypoint1.hikeId == waypoint2.hikeId &&
        waypoint1.name == waypoint2.name &&
        waypoint1.description == waypoint2.description &&
        waypoint1.latitude == waypoint2.latitude &&
        waypoint1.longitude == waypoint2.longitude &&
        waypoint1.isVisited == waypoint2.isVisited &&
        _areListsEqual(waypoint1.images, waypoint2.images);
  }

  static bool _areListsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  /// Constants for testing
  static const String validEmail = 'test@example.com';
  static const String invalidEmail = 'invalid-email';
  static const String validPassword = 'TestPassword123!';
  static const String weakPassword = '123';
  
  static const double validLatitude = 47.3769;
  static const double validLongitude = 8.5417;
  static const double invalidLatitude = 91.0; // Out of range
  static const double invalidLongitude = 181.0; // Out of range
  
  static const List<String> validImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> invalidImageExtensions = ['gif', 'bmp', 'pdf', 'txt'];
  
  static const List<String> sampleImageUrls = [
    'https://example.com/image1.jpg',
    'https://example.com/image2.png',
    'https://example.com/image3.webp',
  ];

  /// Helper to create error scenarios
  static Exception createNetworkError([String message = 'Network error']) {
    return Exception('network: $message');
  }

  static Exception createPermissionError([String message = 'Permission denied']) {
    return Exception('permission denied: $message');
  }

  static Exception createTimeoutError([String message = 'Request timeout']) {
    return Exception('timeout: $message');
  }

  static Exception createDatabaseError([String message = 'Database error']) {
    return Exception('database: $message');
  }

  /// TastingSet and WhiskySample helpers
  static TastingSet createTestTastingSet({
    int id = 1,
    int hikeId = 1,
    String name = 'Test Tasting Set',
    String description = 'A test tasting set with premium whiskies',
    List<WhiskySample> samples = const [],
    double price = 0.0,
    String? imageUrl,
    bool isIncluded = true,
    bool isAvailable = true,
    DateTime? availableFrom,
    DateTime? availableUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TastingSet(
      id: id,
      hikeId: hikeId,
      name: name,
      description: description,
      samples: samples.isEmpty ? createSampleWhiskySamples() : samples,
      price: price,
      imageUrl: imageUrl,
      isIncluded: isIncluded,
      isAvailable: isAvailable,
      availableFrom: availableFrom,
      availableUntil: availableUntil,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  static WhiskySample createTestWhiskySample({
    int id = 1,
    String name = 'Test Whisky',
    String distillery = 'Test Distillery',
    int age = 12,
    String region = 'Speyside',
    String tastingNotes = 'Smooth and complex with notes of honey and vanilla',
    String imageUrl = 'https://example.com/whisky.jpg',
    double abv = 43.0,
    String? category = 'Single Malt',
    double sampleSizeMl = 5.0,
    int orderIndex = 0,
  }) {
    return WhiskySample(
      id: id,
      name: name,
      distillery: distillery,
      age: age,
      region: region,
      tastingNotes: tastingNotes,
      imageUrl: imageUrl,
      abv: abv,
      category: category,
      sampleSizeMl: sampleSizeMl,
      orderIndex: orderIndex,
    );
  }

  static List<WhiskySample> createSampleWhiskySamples() {
    return [
      createTestWhiskySample(
        id: 1,
        name: 'Glenfiddich 12',
        distillery: 'Glenfiddich',
        age: 12,
        region: 'Speyside',
        abv: 40.0,
        orderIndex: 0,
      ),
      createTestWhiskySample(
        id: 2,
        name: 'Macallan 15',
        distillery: 'Macallan',
        age: 15,
        region: 'Speyside',
        abv: 43.0,
        orderIndex: 1,
      ),
      createTestWhiskySample(
        id: 3,
        name: 'Ardbeg 10',
        distillery: 'Ardbeg',
        age: 10,
        region: 'Islay',
        abv: 46.0,
        orderIndex: 2,
      ),
    ];
  }

  static List<TastingSet> createSampleTastingSets() {
    return [
      createTestTastingSet(
        id: 1,
        hikeId: 1,
        name: 'Highland Collection',
        description: 'A selection of premium Highland whiskies',
        samples: [
          createTestWhiskySample(id: 1, name: 'Glenlivet 12', region: 'Speyside'),
          createTestWhiskySample(id: 2, name: 'Macallan 15', region: 'Speyside'),
          createTestWhiskySample(id: 3, name: 'Balvenie 14', region: 'Speyside'),
        ],
      ),
      createTestTastingSet(
        id: 2,
        hikeId: 2,
        name: 'Islay Experience',
        description: 'Smoky and peated whiskies from Islay',
        samples: [
          createTestWhiskySample(id: 4, name: 'Ardbeg 10', region: 'Islay'),
          createTestWhiskySample(id: 5, name: 'Laphroaig 10', region: 'Islay'),
          createTestWhiskySample(id: 6, name: 'Lagavulin 16', region: 'Islay'),
        ],
      ),
      createTestTastingSet(
        id: 3,
        hikeId: 3,
        name: 'Mixed Regions',
        description: 'A diverse selection from various Scottish regions',
        samples: [
          createTestWhiskySample(id: 7, name: 'Oban 14', region: 'Highlands'),
          createTestWhiskySample(id: 8, name: 'Springbank 12', region: 'Campbeltown'),
          createTestWhiskySample(id: 9, name: 'Auchentoshan 12', region: 'Lowlands'),
        ],
      ),
    ];
  }

  /// Utility methods for TastingSet assertions
  static bool areTastingSetsEqual(TastingSet set1, TastingSet set2) {
    return set1.id == set2.id &&
        set1.hikeId == set2.hikeId &&
        set1.name == set2.name &&
        set1.description == set2.description &&
        set1.price == set2.price &&
        set1.imageUrl == set2.imageUrl &&
        set1.isIncluded == set2.isIncluded &&
        set1.isAvailable == set2.isAvailable &&
        _areWhiskySampleListsEqual(set1.samples, set2.samples);
  }

  static bool areWhiskySamplesEqual(WhiskySample sample1, WhiskySample sample2) {
    return sample1.id == sample2.id &&
        sample1.name == sample2.name &&
        sample1.distillery == sample2.distillery &&
        sample1.age == sample2.age &&
        sample1.region == sample2.region &&
        sample1.tastingNotes == sample2.tastingNotes &&
        sample1.imageUrl == sample2.imageUrl &&
        sample1.abv == sample2.abv &&
        sample1.category == sample2.category &&
        sample1.sampleSizeMl == sample2.sampleSizeMl &&
        sample1.orderIndex == sample2.orderIndex;
  }

  static bool _areWhiskySampleListsEqual(List<WhiskySample> list1, List<WhiskySample> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (!areWhiskySamplesEqual(list1[i], list2[i])) return false;
    }
    return true;
  }

  /// Constants for whisky testing
  static const List<String> whiskyRegions = [
    'Speyside',
    'Highlands',
    'Islay',
    'Lowlands',
    'Campbeltown'
  ];

  static const List<String> whiskyCategories = [
    'Single Malt',
    'Blended Malt',
    'Single Grain',
    'Blended Grain',
    'Blended Scotch'
  ];

  static const List<double> validAbvValues = [40.0, 43.0, 46.0, 48.0, 50.0, 57.1];
  static const List<int> validAgeValues = [3, 8, 10, 12, 15, 18, 21, 25, 30];
}