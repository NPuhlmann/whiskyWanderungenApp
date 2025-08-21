// Test Runner Script
// This file provides a comprehensive overview of all test files
// Run with: flutter test test/run_all_tests.dart

import 'package:flutter_test/flutter_test.dart';

// Import all test suites
import 'domain/models/hike_test.dart' as hike_tests;
import 'domain/models/waypoint_test.dart' as waypoint_tests;  
import 'domain/models/profile_test.dart' as profile_tests;
import 'data/repositories/hike_repository_test.dart' as hike_repo_tests;
import 'data/repositories/waypoint_repository_test.dart' as waypoint_repo_tests;
import 'data/repositories/profile_repository_test.dart' as profile_repo_tests;
import 'data/services/backend_api_test.dart' as backend_api_tests;
import 'UI/home/home_view_model_test.dart' as home_viewmodel_tests;

void main() {
  group('All Whisky Hikes Tests', () {
    group('Domain Models', () {
      hike_tests.main();
      waypoint_tests.main();
      profile_tests.main();
    });

    group('Data Repositories', () {
      hike_repo_tests.main();
      waypoint_repo_tests.main();
      profile_repo_tests.main();
    });

    group('Services', () {
      backend_api_tests.main();
    });

    group('ViewModels', () {
      home_viewmodel_tests.main();
    });
  });
}