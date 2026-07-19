import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/UI/mobile/auth/magic_link/magic_link_view_model.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  group('MagicLinkViewModel', () {
    late MockUserRepository mockUserRepository;
    late MagicLinkViewModel viewModel;

    setUp(() {
      mockUserRepository = MockUserRepository();
      viewModel = MagicLinkViewModel(userRepository: mockUserRepository);
    });

    group('sendMagicLink', () {
      test('sends the link and moves to the code-entry step', () async {
        // Arrange
        const email = ' Test@Example.com ';
        when(
          mockUserRepository.sendMagicLink('test@example.com'),
        ).thenAnswer((_) async {});

        // Act
        await viewModel.sendMagicLink(email);

        // Assert — email is trimmed and lowercased before it reaches the
        // repository, because verifyOtp must be given the identical address.
        verify(mockUserRepository.sendMagicLink('test@example.com')).called(1);
        expect(viewModel.linkSent, isTrue);
        expect(viewModel.email, 'test@example.com');
        expect(viewModel.isBusy, isFalse);
      });

      test('rejects an empty email without calling the repository', () async {
        // Act & Assert
        await expectLater(viewModel.sendMagicLink('   '), throwsA(anything));
        verifyNever(mockUserRepository.sendMagicLink(any));
        expect(viewModel.linkSent, isFalse);
      });

      test(
        'rejects an address with no @ without calling the repository',
        () async {
          // Act & Assert
          await expectLater(
            viewModel.sendMagicLink('not-an-email'),
            throwsA(anything),
          );
          verifyNever(mockUserRepository.sendMagicLink(any));
          expect(viewModel.linkSent, isFalse);
        },
      );

      test(
        'clears the busy flag and stays on step one when sending fails',
        () async {
          // Arrange
          when(
            mockUserRepository.sendMagicLink(any),
          ).thenThrow(Exception('rate limited'));

          // Act & Assert
          await expectLater(
            viewModel.sendMagicLink('test@example.com'),
            throwsA(isA<Exception>()),
          );
          expect(viewModel.isBusy, isFalse);
          expect(viewModel.linkSent, isFalse);
        },
      );
    });

    group('verifyCode', () {
      setUp(() async {
        when(
          mockUserRepository.sendMagicLink('test@example.com'),
        ).thenAnswer((_) async {});
        await viewModel.sendMagicLink('test@example.com');
      });

      test('verifies the code against the email it was sent to', () async {
        // Arrange
        final response = AuthResponse(user: null, session: null);
        when(
          mockUserRepository.verifyMagicLinkCode('test@example.com', '123456'),
        ).thenAnswer((_) async => response);

        // Act
        await viewModel.verifyCode(' 123456 ');

        // Assert
        verify(
          mockUserRepository.verifyMagicLinkCode('test@example.com', '123456'),
        ).called(1);
        expect(viewModel.isBusy, isFalse);
      });

      test('rejects an empty code without calling the repository', () async {
        // Act & Assert
        await expectLater(viewModel.verifyCode('  '), throwsA(anything));
        verifyNever(mockUserRepository.verifyMagicLinkCode(any, any));
      });

      test('clears the busy flag when verification fails', () async {
        // Arrange
        when(
          mockUserRepository.verifyMagicLinkCode(any, any),
        ).thenThrow(Exception('invalid code'));

        // Act & Assert
        await expectLater(
          viewModel.verifyCode('000000'),
          throwsA(isA<Exception>()),
        );
        expect(viewModel.isBusy, isFalse);
      });
    });

    test('restart returns to the email step', () async {
      // Arrange
      when(mockUserRepository.sendMagicLink(any)).thenAnswer((_) async {});
      await viewModel.sendMagicLink('test@example.com');
      expect(viewModel.linkSent, isTrue);

      // Act
      viewModel.restart();

      // Assert
      expect(viewModel.linkSent, isFalse);
    });
  });
}
