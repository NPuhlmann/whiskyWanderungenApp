# Code Style Guide - Whisky Hikes

## Language Consistency

### Primary Language: English
- **Code comments**: English only
- **Variable names**: English only  
- **Method names**: English only
- **Class names**: English only

### Exception: User-facing content
- UI strings should be localized (German/English via app_localizations)
- Log messages can remain in German for local debugging

### Examples

```dart
// ✅ GOOD
/// Repository for managing hike data
class HikeRepository {
  Future<List<Hike>> getAllAvailableHikes() async {
    // Fetch all hikes from backend
    return await _backendService.fetchHikes();
  }
}

// ❌ BAD  
/// Repository für Hike-Daten-Verwaltung
class HikeRepository {
  Future<List<Hike>> alleVerfügbareHikes() async {
    // Hole alle Wanderungen vom Backend
    return await _backendService.fetchHikes();
  }
}
```

## Documentation Standards

### Class Documentation
```dart
/// Service responsible for managing user profiles
/// 
/// Handles profile CRUD operations, image uploads,
/// and caching strategies for optimal performance
class ProfileService {
  // ...
}
```

### Method Documentation
```dart
/// Uploads profile image for the specified user
/// 
/// [userId] - The unique identifier for the user
/// [imageBytes] - The image data as bytes
/// [fileExt] - File extension (e.g., 'jpg', 'png')
/// 
/// Returns the public URL of the uploaded image
/// Throws [Exception] if upload fails
Future<String> uploadProfileImage(
  String userId, 
  Uint8List imageBytes, 
  String fileExt
) async {
  // Implementation
}
```

## Naming Conventions

### Variables and Methods
- Use camelCase: `getUserById`, `isLoading`
- Be descriptive: `fetchUserHikes` not `getHikes`
- Use verbs for methods: `loadHikes()`, `updateProfile()`
- Use nouns for variables: `hikeList`, `userName`

### Classes
- Use PascalCase: `HikeRepository`, `ProfileService`
- Be specific: `HikeDetailsViewModel` not `HikeViewModel`

### Constants
- Use SCREAMING_SNAKE_CASE: `MAX_CACHE_SIZE`, `DEFAULT_TIMEOUT`

## Error Handling

### User-friendly messages (German for UI)
```dart
throw Exception('Netzwerkfehler. Bitte überprüfen Sie Ihre Internetverbindung.');
```

### Technical logs (English)
```dart
dev.log('Failed to fetch user profile: network timeout');
```

## Performance Guidelines

### Memory Management
```dart
@override
void dispose() {
  // Clear large data structures
  _imageCache.clear();
  _hikesList.clear();
  super.dispose();
}
```

### Async Operations
```dart
// ✅ GOOD - Concurrent operations
final results = await Future.wait([
  _loadHikes(),
  _loadUserProfile(),
]);

// ❌ BAD - Sequential operations
final hikes = await _loadHikes();
final profile = await _loadUserProfile();
```

## Code Organization

### Import Order
1. Dart core libraries
2. Flutter libraries
3. Third-party packages
4. Local imports (relative paths)

```dart
import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/hike.dart';
import '../error/error_handler.dart';
```

### File Structure
- One class per file
- File name matches class name (snake_case)
- Place related files in same directory

## Testing Standards

### Test Naming
```dart
// ✅ GOOD
test('should return user hikes when user exists', () async {
  // Test implementation
});

// ❌ BAD
test('user hikes test', () async {
  // Test implementation
});
```

### Test Organization
```dart
group('HikeRepository', () {
  group('getAllAvailableHikes', () {
    test('should return hikes when data exists', () {
      // Test implementation
    });
    
    test('should throw exception when network fails', () {
      // Test implementation
    });
  });
});
```

## Migration Checklist

When refactoring existing code:

- [ ] Update German comments to English
- [ ] Rename German method/variable names to English
- [ ] Keep user-facing strings localized
- [ ] Update documentation
- [ ] Run tests to ensure nothing breaks
- [ ] Update related test names if needed

## Tools

### Linting
- Use `flutter analyze` to check code quality
- Follow `analysis_options.yaml` rules
- Address all warnings before committing

### Formatting
- Use `dart format` before committing
- 80 character line limit
- 2-space indentation