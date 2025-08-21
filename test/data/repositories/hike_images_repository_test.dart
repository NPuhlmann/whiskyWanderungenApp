import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/repositories/hike_images_repository.dart';
import 'package:whisky_hikes/domain/models/hike.dart';

import '../../mocks/mock_backend_api_service.dart';

void main() {
  group('HikeImagesRepository Tests', () {
    late MockBackendApiService mockBackendApiService;
    late HikeImagesRepository hikeImagesRepository;

    setUp(() {
      mockBackendApiService = MockBackendApiService();
      hikeImagesRepository = HikeImagesRepository(mockBackendApiService);
    });

    group('uploadHikeImages', () {
      test('should call backendApiService uploadHikeImages with correct parameters', () async {
        // Arrange
        const hike = Hike(
          id: 1,
          name: 'Test Hike',
          length: 5.0,
          price: 19.99,
          difficulty: Difficulty.mid,
        );
        const imagePaths = [
          '/path/to/image1.jpg',
          '/path/to/image2.png',
          '/path/to/image3.webp',
        ];

        when(mockBackendApiService.uploadHikeImages(hike.id, imagePaths))
            .thenAnswer((_) async {});

        // Act
        await hikeImagesRepository.uploadHikeImages(hike, imagePaths);

        // Assert
        verify(mockBackendApiService.uploadHikeImages(hike.id, imagePaths)).called(1);
      });

      test('should handle empty image paths list', () async {
        // Arrange
        const hike = Hike(
          id: 1,
          name: 'Test Hike',
          length: 5.0,
          price: 19.99,
          difficulty: Difficulty.mid,
        );
        const imagePaths = <String>[];

        when(mockBackendApiService.uploadHikeImages(hike.id, imagePaths))
            .thenAnswer((_) async {});

        // Act
        await hikeImagesRepository.uploadHikeImages(hike, imagePaths);

        // Assert
        verify(mockBackendApiService.uploadHikeImages(hike.id, imagePaths)).called(1);
      });

      test('should propagate exceptions from backendApiService', () async {
        // Arrange
        const hike = Hike(
          id: 1,
          name: 'Test Hike',
          length: 5.0,
          price: 19.99,
          difficulty: Difficulty.mid,
        );
        const imagePaths = ['/path/to/image.jpg'];
        final exception = Exception('Upload failed');

        when(mockBackendApiService.uploadHikeImages(hike.id, imagePaths))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await hikeImagesRepository.uploadHikeImages(hike, imagePaths),
          throwsA(equals(exception)),
        );
        verify(mockBackendApiService.uploadHikeImages(hike.id, imagePaths)).called(1);
      });

      test('should handle single image upload', () async {
        // Arrange
        const hike = Hike(
          id: 2,
          name: 'Single Image Hike',
          length: 3.0,
          price: 15.99,
          difficulty: Difficulty.easy,
        );
        const imagePaths = ['/path/to/single_image.jpg'];

        when(mockBackendApiService.uploadHikeImages(hike.id, imagePaths))
            .thenAnswer((_) async {});

        // Act
        await hikeImagesRepository.uploadHikeImages(hike, imagePaths);

        // Assert
        verify(mockBackendApiService.uploadHikeImages(hike.id, imagePaths)).called(1);
      });

      test('should handle multiple image uploads with different formats', () async {
        // Arrange
        const hike = Hike(
          id: 3,
          name: 'Multi Format Hike',
          length: 7.5,
          price: 29.99,
          difficulty: Difficulty.hard,
        );
        const imagePaths = [
          '/path/to/image.jpg',
          '/path/to/image.jpeg',
          '/path/to/image.png',
          '/path/to/image.webp',
        ];

        when(mockBackendApiService.uploadHikeImages(hike.id, imagePaths))
            .thenAnswer((_) async {});

        // Act
        await hikeImagesRepository.uploadHikeImages(hike, imagePaths);

        // Assert
        verify(mockBackendApiService.uploadHikeImages(hike.id, imagePaths)).called(1);
      });
    });

    group('getHikeImages', () {
      test('should call backendApiService getHikeImages and return image URLs', () async {
        // Arrange
        const hikeId = 1;
        const expectedImageUrls = [
          'https://example.com/image1.jpg',
          'https://example.com/image2.png',
          'https://example.com/image3.webp',
        ];

        when(mockBackendApiService.getHikeImages(hikeId))
            .thenAnswer((_) async => expectedImageUrls);

        // Act
        final result = await hikeImagesRepository.getHikeImages(hikeId);

        // Assert
        expect(result, equals(expectedImageUrls));
        verify(mockBackendApiService.getHikeImages(hikeId)).called(1);
      });

      test('should return empty list when no images found', () async {
        // Arrange
        const hikeId = 2;
        const expectedImageUrls = <String>[];

        when(mockBackendApiService.getHikeImages(hikeId))
            .thenAnswer((_) async => expectedImageUrls);

        // Act
        final result = await hikeImagesRepository.getHikeImages(hikeId);

        // Assert
        expect(result, isEmpty);
        verify(mockBackendApiService.getHikeImages(hikeId)).called(1);
      });

      test('should propagate exceptions from backendApiService', () async {
        // Arrange
        const hikeId = 3;
        final exception = Exception('Failed to fetch images');

        when(mockBackendApiService.getHikeImages(hikeId))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () async => await hikeImagesRepository.getHikeImages(hikeId),
          throwsA(equals(exception)),
        );
        verify(mockBackendApiService.getHikeImages(hikeId)).called(1);
      });

      test('should handle single image response', () async {
        // Arrange
        const hikeId = 4;
        const expectedImageUrls = ['https://example.com/single_image.jpg'];

        when(mockBackendApiService.getHikeImages(hikeId))
            .thenAnswer((_) async => expectedImageUrls);

        // Act
        final result = await hikeImagesRepository.getHikeImages(hikeId);

        // Assert
        expect(result.length, 1);
        expect(result.first, 'https://example.com/single_image.jpg');
        verify(mockBackendApiService.getHikeImages(hikeId)).called(1);
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        const hikeId = 5;
        final networkException = Exception('Network timeout');

        when(mockBackendApiService.getHikeImages(hikeId))
            .thenThrow(networkException);

        // Act & Assert
        expect(
          () async => await hikeImagesRepository.getHikeImages(hikeId),
          throwsA(equals(networkException)),
        );
        verify(mockBackendApiService.getHikeImages(hikeId)).called(1);
      });
    });

    group('Integration Tests', () {
      test('should handle upload and then fetch images workflow', () async {
        // Arrange
        const hike = Hike(
          id: 10,
          name: 'Workflow Test Hike',
          length: 4.5,
          price: 22.99,
          difficulty: Difficulty.mid,
        );
        const imagePaths = [
          '/local/path/image1.jpg',
          '/local/path/image2.png',
        ];
        const expectedUrls = [
          'https://storage.com/hike_10_image1.jpg',
          'https://storage.com/hike_10_image2.png',
        ];

        // Setup upload mock
        when(mockBackendApiService.uploadHikeImages(hike.id, imagePaths))
            .thenAnswer((_) async {});

        // Setup fetch mock
        when(mockBackendApiService.getHikeImages(hike.id))
            .thenAnswer((_) async => expectedUrls);

        // Act
        await hikeImagesRepository.uploadHikeImages(hike, imagePaths);
        final fetchedUrls = await hikeImagesRepository.getHikeImages(hike.id);

        // Assert
        verify(mockBackendApiService.uploadHikeImages(hike.id, imagePaths)).called(1);
        verify(mockBackendApiService.getHikeImages(hike.id)).called(1);
        expect(fetchedUrls, equals(expectedUrls));
      });

      test('should handle multiple consecutive operations', () async {
        // Arrange
        const hikeId1 = 1;
        const hikeId2 = 2;
        const images1 = ['https://example.com/hike1_img1.jpg'];
        const images2 = ['https://example.com/hike2_img1.jpg', 'https://example.com/hike2_img2.png'];

        when(mockBackendApiService.getHikeImages(hikeId1))
            .thenAnswer((_) async => images1);
        when(mockBackendApiService.getHikeImages(hikeId2))
            .thenAnswer((_) async => images2);

        // Act
        final result1 = await hikeImagesRepository.getHikeImages(hikeId1);
        final result2 = await hikeImagesRepository.getHikeImages(hikeId2);

        // Assert
        expect(result1, equals(images1));
        expect(result2, equals(images2));
        verify(mockBackendApiService.getHikeImages(hikeId1)).called(1);
        verify(mockBackendApiService.getHikeImages(hikeId2)).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle different types of exceptions consistently', () async {
        // Arrange
        const hikeId = 1;
        final exceptions = [
          Exception('Network error'),
          StateError('Invalid state'),
          ArgumentError('Invalid argument'),
        ];

        for (final exception in exceptions) {
          when(mockBackendApiService.getHikeImages(hikeId))
              .thenThrow(exception);

          // Act & Assert
          expect(
            () async => await hikeImagesRepository.getHikeImages(hikeId),
            throwsA(equals(exception)),
          );
        }
      });
    });
  });
}