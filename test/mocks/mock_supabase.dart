import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([
  SupabaseClient,
  SupabaseQueryBuilder,
  PostgrestFilterBuilder,
  PostgrestBuilder,
  SupabaseStorageClient,
  StorageFileApi,
  GoTrueClient,
  User,
  Bucket,
  FileObject,
])
import 'mock_supabase.mocks.dart';

export 'mock_supabase.mocks.dart';