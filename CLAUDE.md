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

### Latest Updates (August 2024)

**Flutter Version:** 3.35.1 (Latest Stable)  
**Dart SDK:** 3.9.0

#### Recent Major Dependency Updates:
- **flutter_map**: 6.1.0 → 8.2.1 (Breaking Changes - API updates required)
- **go_router**: 14.6.2 → 16.2.0 (Breaking Changes - Route definitions updated)  
- **geolocator**: 11.0.0 → 14.0.2 (Breaking Changes - Permission handling updated)
- **freezed**: 2.5.7 → 3.2.0 (Breaking Changes - @unfreezed syntax updated)
- **flutter_lints**: 5.0.0 → 6.0.0 (New lint rules active)

#### Known Issues After Updates:
✅ **Localization Issue**: Fixed - imports updated to use local l10n files  
✅ **flutter_map Breaking Changes**: Fixed - removed deprecated `enableScrollWheel` parameter  
✅ **Freezed Models**: Fixed - Freezed 3.x migration completed, all models regenerated
✅ **Profile Loading Issue**: Fixed - infinite loading spinner resolved

#### Migration Notes:
- Profile model uses `@unfreezed` for mutability
- Hike and Waypoint models use `@freezed` for immutability  
- Use `copyWith()` for immutable model updates

### Testing
Widget tests are located in the `test/` directory. 

**Development Approach**: Use Test Driven Development (TDD) - write tests first, then implement functionality.

**Current Status**: Comprehensive unit test suite implemented with mocking support.  
**Resolution**: All Freezed 3.x issues resolved, code generation working correctly.

#### Testing Guidelines:
1. Write tests before implementing new features
2. Use mocking for external dependencies (Supabase, local storage)
3. Test both success and error scenarios
4. Include integration tests for critical user flows

#### Development Dependencies Added:
- **path_provider**: Local file storage for caching
- Mock generation support for repositories in testing
