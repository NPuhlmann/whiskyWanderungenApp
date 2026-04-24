import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/services/database/backend_api.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/profile.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';

@GenerateMocks([BackendApiService])
import 'mock_backend_api_service.mocks.dart';

export 'mock_backend_api_service.mocks.dart';
