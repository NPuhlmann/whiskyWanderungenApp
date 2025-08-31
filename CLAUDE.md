# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is "Whisky Hikes" - a Flutter mobile application for discovering and tracking hiking trails. The user shall be able to buy whisky samples and hike the routes that he bought. At special locations on the map, the user gets some infos about a whisky and shall drink one of the samples. That is the case for 4-7 Whiskys along the route. The app uses Supabase as the backend service for authentication, data storage, and image hosting.

## Common Development Commands

### Build and Run
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build APK for Android
- `flutter build ios` - Build for iOS

### Code Generation
- `flutter pub run build_runner build --delete-conflicting-outputs` - Generate Freezed models and JSON serialization
- `flutter pub run flutter_launcher_icons:main` - Generate app icons
- `flutter gen-l10n` - Generate localizations

### Testing and Analysis
- `flutter test` - Run unit tests
- `flutter analyze` - Run static analysis using analysis_options.yaml

### Dependencies
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

## Architecture

### Overall Structure
The app follows a clean architecture pattern with clear separation between UI, business logic, and data layers:

- **UI Layer** (`lib/UI/`) - Flutter widgets and view models using Provider for state management
- **Data Layer** (`lib/data/`) - Repositories and services for external data sources
- **Domain Layer** (`lib/domain/`) - Business models using Freezed for immutable data classes
- **Config Layer** (`lib/config/`) - App configuration, dependencies, routing, and localization

### Key Architectural Patterns

#### State Management
- Uses **Provider** pattern for dependency injection and state management
- ViewModels extend ChangeNotifier for reactive UI updates
- Dependencies are configured in `lib/config/dependencies.dart`

#### Navigation
- **GoRouter** for declarative routing with nested routes
- Routes defined in `lib/config/routing/routes.dart`
- Authentication-based route protection with automatic redirects

#### Data Models
- **Freezed** for immutable data classes with built-in serialization
- Models located in `lib/domain/models/` with generated `.freezed.dart` and `.g.dart` files
- Core models: Hike, Profile, Waypoint

#### Backend Integration
- **Supabase** client for authentication, database, and storage
- `BackendApiService` centralizes all API calls
- Repositories pattern abstracts data access from UI layer

### Directory Structure

```
lib/
├── UI/                     # User interface layer
│   ├── auth/              # Login and signup pages
│   ├── core/              # Shared UI components
│   ├── hike_details/      # Hike detail view
│   ├── hike_map/          # Map view for hikes
│   ├── home/              # Main home page
│   ├── my_hikes/          # User's purchased hikes
│   └── profile/           # User profile management
├── config/                # App configuration
│   ├── dependencies.dart  # Provider dependency injection setup
│   ├── routing/           # GoRouter configuration
│   └── l10n/              # Localization files (EN/DE)
├── data/                  # Data access layer
│   ├── repositories/      # Data repositories
│   └── services/          # External service integrations
└── domain/                # Business logic layer
    └── models/            # Freezed data models
```

### Key Services and Repositories

#### BackendApiService (`lib/data/services/database/backend_api.dart`)
Central service for all Supabase operations:
- User profile management with image upload
- Hike data retrieval and user purchase tracking
- Waypoint CRUD operations with hike associations
- Image management for hikes and profiles

#### Repositories
- **HikeRepository** - Manages hike data and user purchases
- **WaypointRepository** - Handles waypoint operations with offline caching
- **ProfileRepository** - User profile management with local caching and image upload
- **UserRepository** - Authentication state management
- **HikeImagesRepository** - Hike image management

#### LocalCacheService (`lib/data/services/cache/local_cache_service.dart`)
Provides transparent caching for profile data and images:
- TTL-based cache invalidation (24h for data, 7 days for images)
- Automatic background sync with conflict resolution
- Size-limited cache (50MB) with LRU eviction
- Offline-first loading strategy

### Localization
- Supports English (en_US) and German (de_DE)
- ARB files in `lib/config/l10n/`
- Uses `flutter_localizations` with `intl` package

### Environment Configuration
- Uses `.env` file for sensitive configuration (Supabase credentials)
- Environment variables loaded with `flutter_dotenv`
- Required: `SUPABASE_URL` and `SUPABASE_ANON_KEY`

### Map Integration
- **flutter_map** with **latlong2** for map display
- **geolocator** for location services
- Custom waypoint management with map interactions

## Important Notes

### When Working with Models
Always run code generation after modifying Freezed models:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Database Schema
The app uses these main Supabase tables:
- `hikes` - Hiking trail information
- `profiles` - User profile data with automatic creation via triggers
- `waypoints` - GPS waypoints for trails with ordering system
- `hikes_waypoints` - Junction table linking hikes to waypoints
- `purchased_hikes` - User purchase tracking
- `hike_images` - Trail images

**Important**: When making database schema changes, always check if corresponding updates are needed in the Terraform configuration (`terraform-supabase/` directory).

### Storage
- Supabase Storage buckets with RLS policies for user-specific image access
- Profile images with comprehensive upload validation and retry logic
- iOS privacy permissions configured (Camera, Photo Library, Microphone)

### Offline Functionality
- **WaypointRepository** implements caching for offline access to previously loaded waypoints
- **LocalCacheService** provides transparent profile data and image caching with TTL support
- Profile data cached for 24h, images for 7 days with 50MB size limit
- Cache-first loading strategy with automatic background sync

### Latest Updates (December 2024)

**Flutter Version:** 3.35.1 (Latest Stable)  
**Dart SDK:** 3.9.0

#### Recent Major Dependency Updates (August 2024):
- **flutter_map**: 6.1.0 → 8.2.1 (Breaking Changes - API updates required)
- **go_router**: 14.6.2 → 16.2.0 (Breaking Changes - Route definitions updated)  
- **geolocator**: 11.0.0 → 14.0.2 (Breaking Changes - Permission handling updated)
- **freezed**: 2.5.7 → 3.2.0 (Breaking Changes - @unfreezed syntax updated)
- **flutter_lints**: 5.0.0 → 6.0.0 (New lint rules active)

#### Supabase Dependencies (December 2024):
- **supabase_flutter**: 2.9.1
- **gotrue**: 2.13.0 (Breaking Changes - API type changes)
- **storage_client**: 2.4.0 (Breaking Changes - constructor parameters)

#### Known Issues After Updates:
✅ **Localization Issue**: Fixed - imports updated to use local l10n files  
✅ **flutter_map Breaking Changes**: Fixed - removed deprecated `enableScrollWheel` parameter  
✅ **Freezed Models**: Fixed - Freezed 3.x migration completed, all models regenerated
✅ **Profile Loading Issue**: Fixed - infinite loading spinner resolved
✅ **Supabase API Breaking Changes**: Fixed - test suite updated for new API types
✅ **Test Suite Compatibility**: Fixed - mocking patterns updated for new dependencies

#### Migration Notes:
- Profile model uses `@unfreezed` for mutability
- Hike and Waypoint models use `@freezed` for immutability  
- Use `copyWith()` for immutable model updates

#### Supabase API Migration (December 2024):
- **emailConfirmedAt**: Now expects `String` instead of `DateTime` (use `.toIso8601String()`)
- **Session.user**: No longer nullable - use try/catch for error handling
- **UserResponse**: Constructor changed - use `AuthResponse` where appropriate
- **Bucket**: Requires `id`, `name`, `owner`, `public`, `createdAt`, `updatedAt` parameters
- **FileObject**: Requires `bucketId`, `name`, `id`, `owner` parameters in constructor

### Testing
Widget tests are located in the `test/` directory. 

**Development Approach**: Use Test Driven Development (TDD) - write tests first, then implement functionality.

**Current Status**: Comprehensive unit test suite implemented with mocking support.  
**Resolution**: All Freezed 3.x issues resolved, code generation working correctly.
**Latest**: Test suite compatibility restored after Supabase dependency updates (December 2024).

#### Testing Guidelines:
1. Write tests before implementing new features
2. Use mocking for external dependencies (Supabase, local storage)
3. Test both success and error scenarios
4. Include integration tests for critical user flows

#### Test Mocking Best Practices (Updated December 2024):
- **Sequential Mock Calls**: Use call counters instead of chaining `.thenAnswer().thenAnswer()`
- **Async ViewModels**: Use `Future.delayed()` to wait for async operations in tests
- **Supabase Mocks**: Always include all required constructor parameters for API objects
- **Null Safety**: Handle non-nullable session types with proper error simulation

#### Development Dependencies Added:
- **path_provider**: Local file storage for caching
- **mockito**: Mock generation support for repositories in testing
- Mock classes generated for Supabase client components

- Add to Memory, how the payment process works
- Dein Ziel ist immer am Ende einer neuen Implementierung, dass die App ausführbar ist

## Code Quality & Development Standards

### Code Formatting
- **Dart Format**: Always run `dart format` before commits
- **Line Length**: Maximum 80 characters per line
- **Indentation**: 2 spaces (Flutter Standard)
- **Comments**: Use `///` for public APIs, `//` for complex business logic

### Code Structure Principles
- **Single Responsibility**: Each class has one clear responsibility
- **Dependency Injection**: Use constructor injection
- **Composition over Inheritance**: Prefer composition patterns
- **Avoid God Objects**: Keep classes focused and small

### Anti-Patterns to Avoid
- **Deep Nesting**: Maximum 3-4 levels of nesting
- **Magic Numbers**: Define constants instead of hardcoding
- **String Concatenation**: Use StringBuffer for multiple strings

## Test-Driven Development (TDD)

### TDD Cycle: Red → Green → Refactor

#### Red Phase (Write Failing Test)
```dart
test('should create TastingSet with required fields', () {
  final tastingSet = TastingSet(
    id: 1,
    hikeId: 100,
    name: 'Test Set',
    description: 'Test description',
    samples: [],
    price: 0.0, // Always 0 - included in hike
  );
  
  expect(tastingSet.name, equals('Test Set'));
  expect(tastingSet.price, equals(0.0));
});
```

#### Green Phase (Make Test Pass)
```dart
@freezed
abstract class TastingSet with _$TastingSet {
  const factory TastingSet({
    required int id,
    @JsonKey(name: 'hike_id') required int hikeId,
    required String name,
    required String description,
    required List<WhiskySample> samples,
    @Default(0.0) double price, // Default to 0
  }) = _TastingSet;
  
  factory TastingSet.fromJson(Map<String, dynamic> json) => _$TastingSetFromJson(json);
}
```

### Code Generation Workflow
```bash
# After Freezed model changes
flutter pub run build_runner build --delete-conflicting-outputs

# Continuous generation during development
flutter pub run build_runner watch

# Clean build when needed
flutter clean && flutter pub get && flutter pub run build_runner build
```

## Freezed 3.x Configuration (Critical Update)

### Correct Freezed Syntax
**IMPORTANT**: All Freezed models MUST be defined as `abstract class`:

```dart
// ✅ CORRECT - Freezed 3.x
@freezed
abstract class Company with _$Company {
  const factory Company({
    required String id,
    required String name,
    String? description,
  }) = _Company;

  factory Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);
}

// ❌ WRONG - Won't work with Freezed 3.x
@freezed
class Company with _$Company { ... }  // Missing 'abstract'
```

### Required Annotations
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'company.freezed.dart';  // Freezed generation
part 'company.g.dart';        // JSON serialization
```

## Tasting Set System Implementation

### Business Rules
- **1:1 Relationship**: Each hike has exactly one tasting set
- **Always Included**: Tasting sets are included in hike price (price = 0.00)
- **Company Management**: Companies manage tasting sets for their hikes
- **No Selection Logic**: Users don't select tasting sets - they're automatic

### Database Schema
```sql
CREATE TABLE public.tasting_sets (
    id SERIAL PRIMARY KEY,
    hike_id INTEGER UNIQUE REFERENCES public.hikes(id) ON DELETE CASCADE,
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00, -- Always 0
    is_included BOOLEAN DEFAULT TRUE, -- Always true
    name VARCHAR NOT NULL,
    description TEXT
);
```

### Model Extensions
```dart
extension TastingSetExtensions on TastingSet {
  String get formattedPrice => 'Inklusive'; // Always "Included"
  int get sampleCount => samples.length;
  double get totalVolumeMl => samples.fold(0.0, (sum, sample) => sum + sample.sampleSizeMl);
  String get mainRegion { /* most common region logic */ }
  double get averageAge { /* average calculation */ }
}
```

## Implementation Priorities

### Phase 1: Critical Business Features (Week 1-4)
1. **Payment & Checkout System** - Stripe integration, checkout UI, order database
2. **Tasting-Set-Management** - Models, samples, pricing (always 0.0)

### Phase 2: User Experience Features (Week 5-8)
1. **Order Tracking & Management** - Order status tracking, shipping updates  
2. **Offline Functionality** - Local caching, offline-first repository

### Phase 3: Admin & Business Features (Week 9-16)
1. **Admin Dashboard (Web App)** - Admin UI, route planning, order management
2. **Analytics & Reporting** - Sales statistics, customer analytics

## Security Guidelines

### Critical Security Rules
**NEVER COMMIT**:
- API Keys (especially Supabase tokens starting with `sbp_`)
- Database passwords
- Project IDs
- Organization IDs
- Access tokens

### Environment Configuration
- Use `.env` file from `.env.example` template
- Add `.env*` to `.gitignore`
- Use environment variables for all sensitive data
- Mark sensitive Terraform variables with `sensitive = true`

### HTTPS Enforcement
- Always use HTTPS for production URLs
- Implement `_ensureHttps()` helper function in main.dart
- Set `DEV_MODE=false` in production .env files

## Repository Pattern Best Practices

### ViewModels MUST Depend on Repositories
```dart
// ✅ Correct - Use Repository
final hikes = await _hikeRepository.getAllAvailableHikes();

// ❌ Avoid - Direct service call
final hikes = await _backendApiService.getHikes();
```

### Error Handling in Repositories
```dart
Future<Profile> getUserProfileById(String userId) async {
  try {
    return profile;
  } catch (e) {
    log("Error getting profile for user $userId: $e");
    rethrow; // Let ViewModel handle the error
  }
}
```

## ViewModel Patterns

### Loading State Management
Always use try-finally pattern:
```dart
Future<void> operation() async {
  _isLoading = true;
  notifyListeners();
  
  try {
    await repository.operation();
  } catch (e) {
    log("Error: $e");
    // Handle gracefully, don't rethrow
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

### File Upload with Retry Logic
```dart
Future<void> uploadProfileImage(Uint8List imageBytes, String fileExt) async {
  const int maxRetries = 3;
  
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      imageUrl = await _profileRepository.uploadProfileImage(userId, imageBytes, fileExt);
      break; // Success
    } catch (e) {
      if (attempt < maxRetries && _isRetryableError(e)) {
        await Future.delayed(Duration(seconds: attempt * 2));
      } else {
        break;
      }
    }
  }
}
```

## Testing Patterns & Mock Setup

### Mock Generation
```dart
@GenerateMocks([
  SupabaseClient,
  SupabaseQueryBuilder, 
  PostgrestFilterBuilder,
  HikeRepository,
  ProfileRepository,
  BackendApiService,
])
```

### Test Helpers
Create centralized test data creation in `test/test_helpers.dart`:
```dart
class TestHelpers {
  static List<Hike> createSampleHikes() { /* ... */ }
  static Hike createTestHike({...}) { /* ... */ }
  static TastingSet createTestTastingSet({...}) { /* ... */ }
}
```

### ViewModel Testing
```dart
test('should handle errors gracefully', () async {
  when(mockRepository.operation()).thenThrow(Exception('Error'));
  
  await viewModel.someAsyncOperation(); // Should not throw
  
  expect(viewModel.isLoading, false);
  verify(mockRepository.operation()).called(1);
});
```

## Terraform Infrastructure

### Project Structure
- `terraform-supabase/main.tf` - Main Terraform configuration
- `terraform-supabase/variables.tf` - Variable definitions (no sensitive defaults)
- `terraform-supabase/terraform.tfvars.example` - Configuration template
- `terraform-supabase/sql/` - SQL migration files

### Common Commands
```bash
make init     # Initialize Terraform
make plan     # Review changes  
make apply    # Deploy infrastructure
make schema   # Create database schema
make policies # Apply security policies
```

### Environment Variables
All scripts load from `.env`:
- `SUPABASE_ACCESS_TOKEN`
- `PROJECT_ID` 
- `ORGANIZATION_ID`
- `DATABASE_PASSWORD`

## Supabase Integration Patterns

### FileObject Constructor (Breaking Change)
```dart
// ✅ Correct - FileObject requires updatedAt
FileObject(
  bucketId: 'avatars',
  name: 'profile.jpg', 
  id: 'profile-id',
  owner: 'owner-id',
  metadata: {'size': 1024},
  updatedAt: DateTime.now().toIso8601String(), // Required!
)
```

### Profile Image Operations
```dart
Future<String> uploadProfileImage(String userId, Uint8List fileBytes, String fileExt) async {
  final String path = '$userId/profile.$fileExt';
  
  await client.storage.from('avatars').uploadBinary(
    path,
    fileBytes,
    fileOptions: FileOptions(
      cacheControl: '3600',
      upsert: true,
    ),
  );
  
  return client.storage.from('avatars').getPublicUrl(path);
}
```