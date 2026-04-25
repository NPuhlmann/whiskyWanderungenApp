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
import 'data/repositories/user_repository_test.dart' as user_repo_tests;
import 'data/repositories/hike_images_repository_test.dart'
    as hike_images_repo_tests;
import 'data/services/backend_api_simple_test.dart' as backend_api_tests;
import 'data/services/auth_service_simple_test.dart' as auth_service_tests;
// import 'data/services/auth_service_test.dart' as auth_service_full_tests; // Deleted on WHI-11 slice 4 (broken at runtime).
// import 'data/services/local_cache_service_test.dart' as cache_service_tests; // File doesn't exist
// import 'UI/home/home_view_model_test.dart' as home_viewmodel_tests; // File doesn't exist
import 'UI/hike_details/hike_details_view_model_test.dart'
    as hike_details_tests;
// import 'UI/hike_map/hike_map_view_model_test.dart' as hike_map_tests; // File doesn't exist
import 'UI/my_hikes/my_hikes_view_model_test.dart' as my_hikes_tests;
import 'UI/profile/profile_view_model_test.dart' as profile_viewmodel_tests;
import 'UI/auth/login_page_view_model_test.dart' as login_viewmodel_tests;
import 'UI/auth/signup_page_view_model_test.dart' as signup_viewmodel_tests;
// import 'UI/tasting_sets/tasting_set_selection_view_model_test.dart'
//     as tasting_set_viewmodel_tests; // Deleted on WHI-11 slice 4 (broken).
// import 'data/repositories/tasting_set_repository_test.dart' as tasting_set_repo_tests; // File doesn't exist
import 'domain/models/company_test.dart' as company_model_tests;
// import 'data/services/shipping/shipping_calculation_service_test.dart' as shipping_service_tests; // File doesn't exist

void main() {
  group('All Whisky Hikes Tests', () {
    group('Domain Models', () {
      hike_tests.main();
      waypoint_tests.main();
      profile_tests.main();
      company_model_tests.main();
    });

    group('Data Repositories', () {
      hike_repo_tests.main();
      waypoint_repo_tests.main();
      profile_repo_tests.main();
      user_repo_tests.main();
      hike_images_repo_tests.main();
      // tasting_set_repo_tests.main(); // File doesn't exist
    });

    group('Services', () {
      backend_api_tests.main();
      auth_service_tests.main();
      // auth_service_full_tests.main(); // Deleted on WHI-11 slice 4.
      // cache_service_tests.main(); // File doesn't exist
      // shipping_service_tests.main(); // File doesn't exist
    });

    group('ViewModels', () {
      // home_viewmodel_tests.main(); // File doesn't exist
      hike_details_tests.main();
      // hike_map_tests.main(); // File doesn't exist
      my_hikes_tests.main();
      profile_viewmodel_tests.main();
      login_viewmodel_tests.main();
      signup_viewmodel_tests.main();
      // tasting_set_viewmodel_tests.main(); // Deleted on WHI-11 slice 4.
    });
  });
}
